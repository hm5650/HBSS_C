local CPUTab = {}

-- Local aliases (resolved at init)
local Players, RunService, UserInputService, Workspace, HttpService
local LocalPlayer, Camera

local cfg -- = config.cpu (bound at init)

-- ---------------------------------------------------------------------------
-- Ray / probe helpers
-- ---------------------------------------------------------------------------

local cachedRayParams = {}
local cachedFloorParams = {}

local function makeRayParams(char)
    local c = cachedRayParams[char]
    if c then return c end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = { char }
    p.IgnoreWater = true
    p.RespectCanCollide = true
    cachedRayParams[char] = p
    return p
end

local function makeFloorRayParams(char)
    local c = cachedFloorParams[char]
    if c then return c end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = { char }
    p.IgnoreWater = true
    p.RespectCanCollide = true
    cachedFloorParams[char] = p
    return p
end

local function raycastFiltered(origin, dir, params)
    local hit = Workspace:Raycast(origin, dir, params)
    return hit
end

local function getRootAndHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health > 0 then
        return root, hum, char
    end
end

-- ---------------------------------------------------------------------------
-- Cell memory + trail
-- ---------------------------------------------------------------------------

local function cellKey(x, z)
    return math.floor(x / cfg.CELL_SIZE) * 100000 + math.floor(z / cfg.CELL_SIZE)
end

local function markVisited(pos)
    local k = cellKey(pos.X, pos.Z)
    if cfg.memory[k] == nil then cfg.memoryCount += 1 end
    cfg.memory[k] = 1
end

local function decayMemory(rate)
    local toRemove
    for k, v in pairs(cfg.memory) do
        local nv = v * rate
        if nv < 0.02 then
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = k
        else
            cfg.memory[k] = nv
        end
    end
    if toRemove then
        for _, k in ipairs(toRemove) do
            cfg.memory[k] = nil
            cfg.memoryCount -= 1
        end
    end
end

local function pushTrail(pos)
    cfg.trail[cfg.trailIndex] = { pos = pos, t = os.clock() }
    cfg.trailIndex += 1
    if cfg.trailIndex > cfg.TRAIL_LEN then cfg.trailIndex = 1 end
end

local function trailPenaltyAt(pos)
    local now = os.clock()
    local penalty = 0
    local px, pz = pos.X, pos.Z
    for i = 1, cfg.TRAIL_LEN do
        local e = cfg.trail[i]
        if e then
            local dt = now - e.t
            if dt < 6 then
                local ep = e.pos
                local dx = px - ep.X
                local dz = pz - ep.Z
                local d2 = dx*dx + dz*dz
                local r2 = cfg.TRAIL_RADIUS * cfg.TRAIL_RADIUS
                if d2 < r2 then
                    local d = math.sqrt(d2)
                    penalty += (1 - d / cfg.TRAIL_RADIUS) * cfg.TRAIL_PENALTY
                end
            end
        end
    end
    return math.min(penalty, 1.5)
end

-- ---------------------------------------------------------------------------
-- Voxel nav (simple)
-- ---------------------------------------------------------------------------

local function voxelKey(px, py, pz)
    local s = cfg.LIDAR_VOXEL_SIZE
    return math.floor(px/s)*73856093 + math.floor(py/s)*19349663 + math.floor(pz/s)*83492791
end

local function markVoxelSolid(pos)
    local k = voxelKey(pos.X, pos.Y, pos.Z)
    local v = cfg.voxels[k]
    if not v then
        v = { occ = 0, last = 0, seen = 0 }
        cfg.voxels[k] = v
        cfg.voxelCount += 1
    end
    v.occ = math.min(1, v.occ + 0.4)
    v.last = os.clock()
    v.seen += 1
end

local function markVoxelFree(pos)
    local k = voxelKey(pos.X, pos.Y, pos.Z)
    local v = cfg.voxels[k]
    if not v then
        v = { occ = 0, last = 0, seen = 0 }
        cfg.voxels[k] = v
        cfg.voxelCount += 1
    end
    v.occ = math.max(0, v.occ - 0.15)
    v.last = os.clock()
    v.seen += 1
end

local function queryVoxel(pos)
    local v = cfg.voxels[voxelKey(pos.X, pos.Y, pos.Z)]
    if not v then return -1 end
    return v.occ
end

local function decayVoxels()
    local now = os.clock()
    local toRemove
    for k, v in pairs(cfg.voxels) do
        if now - v.last > 30 then
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = k
        else
            v.occ = v.occ * cfg.LIDAR_VOXEL_DECAY
            if v.occ < 0.02 and v.seen < 2 then
                toRemove = toRemove or {}
                toRemove[#toRemove + 1] = k
            end
        end
    end
    if toRemove then
        for _, k in ipairs(toRemove) do
            cfg.voxels[k] = nil
            cfg.voxelCount -= 1
        end
    end
end

-- ---------------------------------------------------------------------------
-- Blacklist / goal scanning
-- ---------------------------------------------------------------------------

local function nameMatchesPatterns(name, patterns)
    if not name or not patterns or #patterns == 0 then return false end
    local lname = name:lower()
    for _, p in ipairs(patterns) do
        if lname:find(p, 1, true) then return true end
    end
    return false
end

local function collectBaseParts(inst, out, seen)
    if not inst then return end
    if inst:IsA("BasePart") then
        if not seen[inst] then
            seen[inst] = true
            out[#out + 1] = inst
        end
    end
    for _, child in ipairs(inst:GetChildren()) do
        if child and child.Parent then
            collectBaseParts(child, out, seen)
        end
    end
end

local function scanBlacklist(now)
    if not cfg.BLACKLIST_ENABLED then return end
    if now - cfg.BLACKLIST_LAST_SCAN < cfg.BLACKLIST_SCAN_INTERVAL then return end
    cfg.BLACKLIST_LAST_SCAN = now
    if #cfg.BLACKLIST_PARTS == 0 then
        cfg.BLACKLIST_INSTANCES = {}
        return
    end
    local newCache = {}
    local seen = {}
    local function visit(inst)
        if not inst or not inst.Parent then return end
        local name = inst.Name
        local cls = inst.ClassName
        if nameMatchesPatterns(name, cfg.BLACKLIST_PARTS)
           or nameMatchesPatterns(cls, cfg.BLACKLIST_PARTS) then
            local parts = {}
            collectBaseParts(inst, parts, seen)
            for _, p in ipairs(parts) do
                newCache[p] = true
            end
            return
        end
        for _, child in ipairs(inst:GetChildren()) do
            if child and child.Parent then visit(child) end
        end
    end
    for _, top in ipairs(Workspace:GetChildren()) do
        if top and top.Parent then visit(top) end
    end
    cfg.BLACKLIST_INSTANCES = newCache
end

local function scanGoals(now, rootPos)
    if not cfg.GOAL_SEEK_ENABLED then return end
    if now - cfg.GOAL_LAST_SCAN < cfg.GOAL_SCAN_INTERVAL then return end
    cfg.GOAL_LAST_SCAN = now
    if #cfg.GOAL_PARTS == 0 then
        cfg.GOAL_TARGET = nil
        cfg.GOAL_TARGET_POS = nil
        return
    end
    local seen = {}
    local bestPart, bestPos, bestDist = nil, nil, math.huge
    local function visit(inst)
        if not inst or not inst.Parent then return end
        local name = inst.Name
        local cls = inst.ClassName
        if nameMatchesPatterns(name, cfg.GOAL_PARTS)
           or nameMatchesPatterns(cls, cfg.GOAL_PARTS) then
            local parts = {}
            collectBaseParts(inst, parts, seen)
            for _, p in ipairs(parts) do
                if p.Parent then
                    local d = rootPos and (p.Position - rootPos).Magnitude or 0
                    if d < bestDist then
                        bestDist = d; bestPart = p; bestPos = p.Position
                    end
                end
            end
            return
        end
        for _, child in ipairs(inst:GetChildren()) do
            if child and child.Parent then visit(child) end
        end
    end
    for _, top in ipairs(Workspace:GetChildren()) do
        if top and top.Parent then visit(top) end
    end
    if bestPart then
        cfg.GOAL_TARGET = bestPart
        cfg.GOAL_TARGET_POS = bestPos
        cfg.GOAL_STATS.nearestDist = bestDist
    else
        cfg.GOAL_TARGET = nil
        cfg.GOAL_TARGET_POS = nil
    end
end

local function isBlacklisted(part)
    if not cfg.BLACKLIST_ENABLED or not part then return false end
    return cfg.BLACKLIST_INSTANCES[part] == true
end

-- ---------------------------------------------------------------------------
-- Target acquisition (Players/NPCs) - uses Gravel's masterTeamTarget
-- ---------------------------------------------------------------------------

local function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
       and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head"))
end

local function matchesTeamFilter(target)
    -- Reads Gravel's global targeting config (not a duplicate)
    if cfg.linkMasterTarget then
        local g = getgenv().Graaaaaaaaaaaaaaaaaaaaaaavel_
        -- Fall back to local read of the shared config table
    end
    -- This module relies on the caller (Gravel.cc) to filter targets,
    -- so we just accept whatever the caller passes in cfg._pendingTargets
    return true
end

local function findClosestHumanoidTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    -- Ask Gravel.cc's targeting layer via callback
    if cfg.acquireTargetCallback then
        local ok, t = pcall(cfg.acquireTargetCallback)
        if ok and t then return t end
    end

    -- Fallback: naive nearest player
    local best, bestD = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local r = pl.Character:FindFirstChild("HumanoidRootPart")
            local h = pl.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - myRoot.Position).Magnitude
                if d < bestD then bestD = d; best = pl end
            end
        end
    end
    return best
end

local function getTargetRootAndHumanoid(target)
    if not target then return nil, nil end
    if typeof(target) == "Instance" and target:IsA("Player") then
        local c = target.Character
        if not c then return nil, nil end
        return c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid"), c
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        return target:FindFirstChild("HumanoidRootPart"), target:FindFirstChildOfClass("Humanoid"), target
    end
    return nil, nil
end

-- ---------------------------------------------------------------------------
-- Orbit direction randomizer
-- ---------------------------------------------------------------------------

local function pickOrbitDir()
    if cfg.orbitDirMode == "Random" then
        return math.random() < 0.5 and 1 or -1
    elseif cfg.orbitDirMode == "Clockwise" then
        return 1
    else
        return -1
    end
end

-- ---------------------------------------------------------------------------
-- Combat follower (Melee / Gun)
-- ---------------------------------------------------------------------------

local function orbitVector(rootPos, targetPos, dir, radius)
    local toTarget = Vector3.new(targetPos.X - rootPos.X, 0, targetPos.Z - rootPos.Z)
    local d = toTarget.Magnitude
    if d < 0.01 then return nil end
    local u = toTarget / d
    local perp = Vector3.new(-u.Z, 0, u.X) * dir
    -- Blend inward to keep the radius stable
    local radial = u * (d - radius)
    return (perp * radius + radial).Unit
end

local function meleeDodgeTick(root, hum, targetRoot)
    -- Predict the target's melee swing by watching the tool's Handle.CFrame.LookVector
    local char = LocalPlayer.Character
    if not char then return nil end
    local targetChar = targetRoot and targetRoot.Parent
    if not targetChar then return nil end
    local tool = targetChar:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return nil end
    local look = handle.CFrame.LookVector
    local toMe = Vector3.new(root.Position.X - handle.Position.X, 0,
                             root.Position.Z - handle.Position.Z)
    if toMe.Magnitude < 0.01 then return nil end
    toMe = toMe.Unit
    local align = look:Dot(toMe)
    -- If they're aiming at us, sidestep perpendicular
    if align > cfg.MELEE_DODGE_TRIGGER_DOT then
        local perp = Vector3.new(-look.Z, 0, look.X) * cfg._meleeDodgeDir
        return perp.Unit
    end
    return nil
end

local function combatTick(root, hum, target, dir, dt)
    local targetRoot = select(1, getTargetRootAndHumanoid(target))
    if not targetRoot then return nil end

    local toTarget = targetRoot.Position - root.Position
    local flatDist = Vector3.new(toTarget.X, 0, toTarget.Z).Magnitude

    if cfg.botMode == "Melee" then
        -- Jitter the dodge direction periodically for unpredictability
        cfg._meleeDodgeTimer = (cfg._meleeDodgeTimer or 0) + dt
        if cfg._meleeDodgeTimer >= cfg.MELEE_DODGE_DIR_SWITCH then
            cfg._meleeDodgeTimer = 0
            cfg._meleeDodgeDir = -cfg._meleeDodgeDir
        end

        local dodge = meleeDodgeTick(root, hum, targetRoot)
        if dodge then
            return dodge
        end

        -- Otherwise orbit around them at orbit distance
        local dirVec = orbitVector(root.Position, targetRoot.Position,
                                   cfg._orbitDir, cfg.GUN_ORBIT_RADIUS)
        if dirVec then return dirVec end
    elseif cfg.botMode == "Gun" then
        -- Orbit the target and bhop; Gravel's TriggerBot/SilentAim will handle
        -- shooting when its own toggles are on.
        local dirVec = orbitVector(root.Position, targetRoot.Position,
                                   cfg._orbitDir, cfg.GUN_ORBIT_RADIUS)
        if dirVec then
            -- Bhop: jump whenever we're on the ground
            if cfg.GUN_BHOP and hum.FloorMaterial ~= Enum.Material.Air then
                local now = os.clock()
                if now - cfg._lastBhop >= cfg.GUN_BHOP_INTERVAL then
                    cfg._lastBhop = now
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hum.Jump = true
                end
            end
            -- Periodically re-pick the orbit direction so we don't get read
            cfg._orbitTimer = (cfg._orbitTimer or 0) + dt
            if cfg._orbitTimer >= cfg.GUN_ORBIT_SWITCH then
                cfg._orbitTimer = 0
                cfg._orbitDir = pickOrbitDir()
            end
            return dirVec
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Navigation core (goal seeking + maze solving)
-- ---------------------------------------------------------------------------

local function hasSolidBelow(pos, maxDown, params)
    maxDown = maxDown or cfg.FALL_PROBE_DOWN
    local origin = pos + Vector3.new(0, 3, 0)
    local hit = raycastFiltered(origin, Vector3.new(0, -(maxDown + 3), 0), params)
    return hit ~= nil, hit
end

local function analyzeGapAhead(root, char, hum, dir)
    local result = {
        active = false, startD = 0, endD = 0, width = 0,
        farSolid = false, canJump = false, dir = nil,
        landingPoint = nil,
    }
    if not dir then return result end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return result end
    flat = flat.Unit
    result.dir = flat

    local params = makeFloorRayParams(char)
    local origin = root.Position
    local scanMax = 34
    local step = 1.0
    local gapStart, gapEnd
    local d = step
    while d <= scanMax do
        local probe = origin + flat * d
        local ok = hasSolidBelow(probe, cfg.FALL_PROBE_DOWN, params)
        if not ok and not gapStart then
            gapStart = d
        elseif ok and gapStart and not gapEnd then
            gapEnd = d
            break
        end
        d += step
    end
    if not gapStart then return result end

    result.active = true
    result.startD = gapStart
    result.endD = gapEnd or scanMax
    result.width = (gapEnd and (gapEnd - gapStart)) or (scanMax - gapStart)
    result.farSolid = gapEnd ~= nil

    if result.farSolid and result.width >= cfg.JUMP_GAP_MIN and result.width <= 20 then
        local landingProbe = origin + flat * (result.endD + 1.5)
        local landHit = raycastFiltered(landingProbe + Vector3.new(0, 6, 0),
                                        Vector3.new(0, -cfg.JUMP_LANDING_PROBE_DOWN, 0),
                                        params)
        if landHit and landHit.Normal.Y > 0.5 then
            result.landingPoint = landHit.Position
            result.canJump = true
        end
    end
    return result
end

local function scoreDirectionFromVoxels(origin, dir)
    if not cfg.LIDAR_NAV_ENABLED then return 0 end
    if cfg.voxelCount < 8 then return 0 end
    local d = dir.Unit
    local samples = cfg.LIDAR_NAV_SAMPLES
    local look = cfg.LIDAR_NAV_LOOKAHEAD
    local step = look / samples
    local free, solid, unknown = 0, 0, 0
    for i = 1, samples do
        local p = origin + d * (step * i)
        local occ = queryVoxel(p)
        if occ < 0 then unknown += 1
        elseif occ >= 0.55 then solid += 1
        else free += 1 end
    end
    local total = samples
    local score = (free/total) * cfg.LIDAR_VOXEL_FREE_BIAS
                + (unknown/total) * 0.20
                - (solid/total) * cfg.LIDAR_VOXEL_SOLID_PENALTY
    return math.clamp(score, -1, 1)
end

local function scoreGoalDirection(origin, dir)
    if not cfg.GOAL_SEEK_ENABLED or not cfg.GOAL_TARGET_POS then return 0 end
    local toGoal = cfg.GOAL_TARGET_POS - origin
    local flatGoal = Vector3.new(toGoal.X, 0, toGoal.Z)
    if flatGoal.Magnitude < 0.5 then
        return cfg.GOAL_SEEK_WEIGHT * 3
    end
    flatGoal = flatGoal.Unit
    local flatDir = Vector3.new(dir.X, 0, dir.Z)
    if flatDir.Magnitude < 0.001 then return 0 end
    flatDir = flatDir.Unit
    local align = flatDir:Dot(flatGoal)
    if align <= 0 then return 0 end
    local goalDist = toGoal.Magnitude
    local proximity = math.clamp(1 - goalDist / cfg.GOAL_DIST_NORM,
                                 cfg.GOAL_MIN_PROXIMITY, 1.0)
    return align * proximity * cfg.GOAL_SEEK_WEIGHT
end

local function scoreTouchPenalty(origin, dir)
    if not cfg.TOUCH_STORE_ENABLED or cfg.TOUCH_COUNT == 0 then return 0 end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return 0 end
    flat = flat.Unit
    local penalty = 0
    for inst in pairs(cfg.TOUCHED_PARTS) do
        if inst and inst.Parent then
            local toPart = inst.Position - origin
            local dist = toPart.Magnitude
            if dist > 0.01 then
                local toPartFlat = Vector3.new(toPart.X, 0, toPart.Z)
                local mag = toPartFlat.Magnitude
                if mag > 0.01 then
                    local align = (toPartFlat / mag):Dot(flat)
                    if align > 0 then
                        local proxW = 1 + cfg.TOUCH_PROXIMITY_BONUS
                                     * math.max(0, 1 - dist / 50)
                        penalty += align * proxW * cfg.TOUCH_PENALTY
                    end
                end
            end
        end
    end
    return penalty
end

local function scoreProbe(res, noveltyScore, dir, prevDir, trailPenalty, goalScore, touchPenalty)
    local distScore = math.clamp(res.distance / cfg.MAX_RAY_DIST, 0, 1)
    local bouncePenalty = res.bounces / cfg.MAX_BOUNCES
    local escapeBonus = res.escaped and 0.30 or 0
    local momentum = 0
    if prevDir then
        momentum = dir:Dot(prevDir) * cfg.MOMENTUM
                   * (1 - cfg.forceExploration * 0.5)
    end
    local novelty = noveltyScore * cfg.NOVELTY_WEIGHT
                    * (1 + cfg.forceExploration * 1.5)
    local base = distScore * 0.50 + escapeBonus
                 - bouncePenalty * 0.25 + momentum + novelty
                 - trailPenalty + goalScore - touchPenalty
    return base
end

local sweepDirs = {}
for i = 1, 256 do sweepDirs[i] = Vector3.zero end

local function bounceRay(origin, dir, params)
    local pos, d = origin, dir.Unit
    local travelled, bounces, novelty = 0, 0, 0
    for _ = 1, cfg.MAX_BOUNCES do
        local remaining = cfg.MAX_RAY_DIST - travelled
        if remaining <= 0 then break end
        local hit = raycastFiltered(pos, d * remaining, params)
        local segEnd, escaped
        if not hit then
            segEnd = pos + d * remaining
            escaped = true
        else
            segEnd = hit.Position
            escaped = false
        end
        local seg = segEnd - pos
        local len = seg.Magnitude
        if len > 0.01 then
            local n = math.max(1, math.floor(len / (cfg.SAMPLE_STEP * 1.5)))
            for i = 1, n do
                local p = pos + seg * (i / n)
                local k = cellKey(p.X, p.Z)
                novelty += (1 - (cfg.memory[k] or 0))
            end
        end
        if escaped then
            return {
                escaped = true,
                distance = travelled + remaining,
                bounces = bounces,
                finalPos = segEnd,
                endDir = d,
                novelty = novelty,
            }
        end
        travelled += len
        bounces += 1
        local n = hit.Normal
        d = d - 2 * d:Dot(n) * n
        if d.Magnitude < 0.001 then d = -n end
        d = d.Unit
        pos = hit.Position + d * 0.15
    end
    return {
        escaped = false, distance = travelled, bounces = bounces,
        finalPos = pos, endDir = d, novelty = novelty,
    }
end

local function sweepProbes(root, char, hum, forcedDir)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, cfg.WALL_PROBE_Y, 0)
    local look = root.CFrame.LookVector
    local baseYaw = math.atan2(look.X, look.Z)
    local spinOffset = cfg.SPIN_SCAN_ENABLED and cfg.SPIN_ANGLE or 0
    local emitYaw = baseYaw + spinOffset

    local probeCount = cfg.PROBE_COUNT
    if cfg.state == "OPEN" then
        probeCount = math.max(8, cfg.PROBE_COUNT - 4)
    elseif cfg.state == "SURROUNDED" then
        probeCount = cfg.PROBE_COUNT + 6
    end

    local prevDir = cfg.bestDir
    local best = { score = -math.huge, dir = nil, dist = 0,
                   bounces = 0, novelty = 0, escaped = false }
    local totalBounces, totalDist, totalNovelty, lowCount = 0, 0, 0, 0
    local jitter = 0.04 + (cfg.neuronCount / cfg.NEURON_COUNT) * 0.10
                   + cfg.forceExploration * 0.22

    local sweepDirCount = 0
    local pitchMax = math.rad(cfg.SPHERE_PITCH)
    local rings = math.max(1, cfg.SPHERE_RINGS)

    for i = 1, probeCount do
        local angle = emitYaw + ((i - 1) / probeCount) * math.pi * 2
        sweepDirCount += 1
        if sweepDirCount > #sweepDirs then sweepDirs[sweepDirCount] = Vector3.zero end
        sweepDirs[sweepDirCount] = Vector3.new(math.sin(angle), 0, math.cos(angle))
    end
    for r = 1, rings do
        local pitch = (r / rings) * pitchMax
        local ringCount = math.max(6, math.floor(probeCount * math.cos(pitch)))
        for sign = -1, 1, 2 do
            local p = pitch * sign
            local cy, ch = math.sin(p), math.cos(p)
            for i = 1, ringCount do
                local angle = emitYaw + ((i - 1) / ringCount) * math.pi * 2
                sweepDirCount += 1
                if sweepDirCount > #sweepDirs then sweepDirs[sweepDirCount] = Vector3.zero end
                sweepDirs[sweepDirCount] = Vector3.new(
                    math.sin(angle) * ch, cy, math.cos(angle) * ch)
            end
        end
    end
    sweepDirCount += 1
    if sweepDirCount > #sweepDirs then sweepDirs[sweepDirCount] = Vector3.zero end
    sweepDirs[sweepDirCount] = Vector3.new(0, 1, 0)
    sweepDirCount += 1
    if sweepDirCount > #sweepDirs then sweepDirs[sweepDirCount] = Vector3.zero end
    sweepDirs[sweepDirCount] = Vector3.new(0, -1, 0)

    for i = 1, sweepDirCount do
        local dir = sweepDirs[i]
        local flatDir = Vector3.new(dir.X, 0, dir.Z)
        if flatDir.Magnitude > 0.001 then flatDir = flatDir.Unit end

        local res = bounceRay(origin, dir, params)
        local noveltyScore = math.clamp(res.novelty / cfg.NOVELTY_NORM, 0, 1)
        local tp = 0
        if flatDir.Magnitude > 0.001 then
            tp = trailPenaltyAt(origin + flatDir * math.min(res.distance, 12))
        end
        local goalScore = scoreGoalDirection(origin, dir)
        local touchPenalty = scoreTouchPenalty(origin, dir)
        local navScore = 0
        if flatDir.Magnitude > 0.001 then
            navScore = scoreDirectionFromVoxels(origin, dir)
        end

        local score = scoreProbe(res, noveltyScore, dir, prevDir, tp,
                                 goalScore, touchPenalty) + navScore
        score += (math.random() - 0.5) * jitter

        if forcedDir then
            local align = dir:Dot(forcedDir)
            score += align * cfg.TARGET_BIAS
        end

        totalBounces += res.bounces
        totalDist += res.distance
        totalNovelty += noveltyScore
        if res.distance < 15 then lowCount += 1 end

        if score > best.score then
            best.score = score
            best.dir = dir
            best.dist = res.distance
            best.bounces = res.bounces
            best.novelty = noveltyScore
            best.escaped = res.escaped
        end
    end

    cfg.avgBounces = totalBounces / sweepDirCount
    cfg.avgNovelty = totalNovelty / sweepDirCount
    cfg.bestDist = best.dist
    cfg.bestBounces = best.bounces
    cfg.bestNovelty = best.novelty

    if lowCount >= sweepDirCount - 2 and cfg.avgBounces > 5 then
        cfg.state = "SURROUNDED"
    elseif best.escaped and best.bounces <= 3 and best.dist > 60 then
        cfg.state = "OPEN"
    elseif best.bounces >= 6 then
        cfg.state = "MAZE"
    else
        cfg.state = "CORRIDOR"
    end

    local newDir = best.dir
    if newDir then
        if not cfg.committedDir then
            cfg.committedDir = newDir
            cfg.commitTimer = cfg.COMMIT_TIME
        else
            local dot = cfg.committedDir:Dot(newDir)
            if dot >= cfg.COMMIT_DOT_MIN then
                local blended = cfg.committedDir * (1 - cfg.TURN_BLEND)
                              + newDir * cfg.TURN_BLEND
                if blended.Magnitude > 0.05 then
                    cfg.committedDir = blended.Unit
                end
                cfg.commitTimer = cfg.COMMIT_TIME
                cfg.pendingDir = nil
                cfg.pendingTimer = 0
            elseif dot <= cfg.FLIP_DOT_MAX then
                if cfg.pendingDir and cfg.pendingDir:Dot(newDir) > 0.7 then
                    cfg.pendingTimer += cfg.SWEEP_INTERVAL
                else
                    cfg.pendingDir = newDir
                    cfg.pendingTimer = 0
                end
                if cfg.pendingTimer >= cfg.FLIP_HOLD_TIME then
                    cfg.committedDir = newDir
                    cfg.commitTimer = cfg.COMMIT_TIME
                    cfg.pendingDir = nil
                    cfg.pendingTimer = 0
                end
            else
                cfg.commitTimer -= cfg.SWEEP_INTERVAL
                if cfg.commitTimer <= 0 then
                    local blended = cfg.committedDir * (1 - cfg.TURN_BLEND)
                                  + newDir * cfg.TURN_BLEND
                    if blended.Magnitude > 0.05 then
                        cfg.committedDir = blended.Unit
                    else
                        cfg.committedDir = newDir
                    end
                    cfg.commitTimer = cfg.COMMIT_TIME
                end
                cfg.pendingDir = nil
                cfg.pendingTimer = 0
            end
        end
        cfg.bestDir = cfg.committedDir
    end
end

-- ---------------------------------------------------------------------------
-- Stuck recovery
-- ---------------------------------------------------------------------------

local function startStuckRecovery(root, hum, char, dir)
    if not cfg.STUCK_RECOVERY_ENABLED then return end
    if not dir or dir.Magnitude < 0.001 then
        dir = cfg.bestDir or cfg.committedDir or root.CFrame.LookVector
    end
    dir = dir.Unit
    cfg.recoveryActive = true
    cfg.recoveryTimer = cfg.STUCK_RECOVERY_WINDOW
    cfg.recoveryCount += 1
    local now = os.clock()
    if now - cfg.recoveryLastJumpTime >= cfg.STUCK_RECOVERY_JUMP_COOLDOWN then
        cfg.recoveryLastJumpTime = now
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        hum.Jump = true
    end
    if cfg.recoveryBackupsUsed < cfg.STUCK_RECOVERY_MAX_BACKUPS then
        cfg.recoveryBackupTimer = cfg.STUCK_RECOVERY_BACKUP_TIME
        cfg.recoveryBackupDir = -dir
        cfg.recoveryBackupsUsed += 1
    end
    cfg.forceExploration = math.min(1, cfg.forceExploration + 0.55)
end

local function updateStuckRecovery(root, hum, char, dt)
    if not cfg.STUCK_RECOVERY_ENABLED then return end
    if cfg.recoveryActive then
        cfg.recoveryTimer -= dt
        if cfg.recoveryBackupTimer > 0 then
            cfg.recoveryBackupTimer -= dt
            local rp = hum.RootPart
            if rp and cfg.recoveryBackupDir then
                local spd = cfg.STUCK_RECOVERY_BACKUP_SPEED
                local v = rp.AssemblyLinearVelocity
                rp.AssemblyLinearVelocity = Vector3.new(
                    cfg.recoveryBackupDir.X * spd, v.Y, cfg.recoveryBackupDir.Z * spd)
            end
        end
        if cfg.recoveryTimer <= 0 then
            cfg.recoveryActive = false
            cfg.recoveryBackupTimer = 0
            cfg.recoveryBackupDir = nil
            cfg.recoveryLastPos = root.Position
            cfg.recoveryWindowTimer = 0
        end
        return
    end
    cfg.recoveryWindowTimer += dt
    if cfg.recoveryWindowTimer >= cfg.STUCK_RECOVERY_WINDOW then
        if cfg.recoveryLastPos then
            local moved = (root.Position - cfg.recoveryLastPos).Magnitude
            if moved < cfg.STUCK_RECOVERY_MIN_MOVE then
                cfg.recoveryCount += 1
                if cfg.recoveryCount >= cfg.STUCK_RECOVERY_TRIGGER_COUNT then
                    startStuckRecovery(root, hum, char,
                        cfg.bestDir or cfg.committedDir)
                    cfg.recoveryCount = 0
                end
            else
                cfg.recoveryCount = math.max(0, cfg.recoveryCount - 1)
            end
        end
        cfg.recoveryLastPos = root.Position
        cfg.recoveryWindowTimer = 0
    end
end

-- ---------------------------------------------------------------------------
-- Main tick
-- ---------------------------------------------------------------------------

local function botTick(dt)
    if not cfg.active then return end

    local root, hum, char = getRootAndHumanoid()
    if not root then return end

    local now = os.clock()
    scanBlacklist(now)
    scanGoals(now, root.Position)

    -- Neurons
    local stimulus = cfg.bestNovelty
    local activeCount = 0
    local rate = 0.05 + stimulus * 0.14
    for i = 1, cfg.NEURON_COUNT do
        if math.random() < rate then
            cfg.neurons[i] = math.min(1, cfg.neurons[i] + 0.30 + math.random() * 0.3)
        end
        cfg.neurons[i] = math.max(0, cfg.neurons[i] - dt * 0.55)
        if cfg.neurons[i] > 0.6 then activeCount += 1 end
    end
    cfg.neuronCount = activeCount

    if cfg.SPIN_SCAN_ENABLED then
        cfg.SPIN_ANGLE = (cfg.SPIN_ANGLE + cfg.SPIN_RATE * dt * math.pi * 2)
                        % (math.pi * 2)
    end

    cfg.forceExploration = math.max(0, cfg.forceExploration - dt * 1.2)
    markVisited(root.Position)
    pushTrail(root.Position)

    if cfg.entranceTimer > 0 then cfg.entranceTimer -= dt end
    if cfg.fallBrake > 0 then cfg.fallBrake -= dt end

    if cfg.pathMemoryDecayAccum >= 0.5 then
        cfg.pathMemoryDecayAccum = 0
    end

    updateStuckRecovery(root, hum, char, dt)

    -- Combat / target following
    local combatDir
    if cfg.followTarget and cfg.botMode ~= "Navigate" then
        local target = cfg.currentTargetInstance
        if not target or not getTargetRootAndHumanoid(target) then
            target = findClosestHumanoidTarget()
            cfg.currentTargetInstance = target
        end
        if target then
            local tr = select(1, getTargetRootAndHumanoid(target))
            if tr then
                local flatDist = (Vector3.new(tr.Position.X, 0, tr.Position.Z)
                                - Vector3.new(root.Position.X, 0, root.Position.Z)).Magnitude
                if flatDist <= cfg.TARGET_ENGAGE_RANGE then
                    cfg.engaged = true
                    combatDir = combatTick(root, hum, target, nil, dt)
                else
                    cfg.engaged = false
                    -- Move toward the target as a goal
                    local toT = tr.Position - root.Position
                    local flat = Vector3.new(toT.X, 0, toT.Z)
                    if flat.Magnitude > 0.1 then
                        combatDir = flat.Unit
                    end
                end
            end
        end
    end

    -- Navigation probe (always runs so mazes work)
    cfg.sweepTimer -= dt
    if cfg.sweepTimer <= 0 then
        cfg.sweepTimer = cfg.SWEEP_INTERVAL
        sweepProbes(root, char, hum, combatDir)
        cfg.decayAccum += 1
        if cfg.decayAccum >= 5 then
            cfg.decayAccum = 0
            decayMemory(cfg.MEMORY_DECAY)
        end
        if cfg.LIDAR_NAV_ENABLED then
            cfg.lidarDecayAccum += 1
            if cfg.lidarDecayAccum >= 10 then
                cfg.lidarDecayAccum = 0
                decayVoxels()
            end
        end
    end

    -- Choose move direction
    local moveDir
    if combatDir then
        moveDir = combatDir
    elseif cfg.bestDir then
        moveDir = cfg.bestDir
    else
        moveDir = root.CFrame.LookVector
    end

    if moveDir.Magnitude < 0.001 then
        moveDir = root.CFrame.LookVector
    else
        moveDir = moveDir.Unit
    end

    -- Fall protection in navigate mode
    if cfg.AVOID_FALLS and not cfg.engaged then
        local params = makeFloorRayParams(char)
        local target = root.Position + moveDir * cfg.AHEAD_DISTANCE
        local ok = hasSolidBelow(target, cfg.FALL_PROBE_DOWN, params)
        if not ok then
            local pulled = target
            for _ = 1, 4 do
                pulled = (pulled + root.Position) * 0.5
                if hasSolidBelow(pulled, cfg.FALL_PROBE_DOWN, params) then break end
            end
            target = pulled
            cfg.fallBrake = math.max(cfg.fallBrake, 0.4)
        end
    end

    -- Jump logic for obbies
    if cfg.JUMP_ENABLED and not cfg.engaged then
        local gap = analyzeGapAhead(root, char, hum, moveDir)
        cfg.lastGap = gap
        if gap.active and gap.canJump
           and gap.startD <= cfg.JUMP_NUDGE_DIST + 1.0 then
            local now2 = os.clock()
            if now2 - cfg.lastJumpTime >= cfg.JUMP_COOLDOWN then
                cfg.lastJumpTime = now2
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hum.Jump = true
            end
        end
    end

    -- Move
    if cfg.fallBrake <= 0 and not cfg.recoveryActive then
        local sway = math.sin(os.clock() * cfg.SINE_FREQUENCY) * cfg.SINE_AMPLITUDE
        local perp = Vector3.new(-moveDir.Z, 0, moveDir.X)
        local step = math.clamp(cfg.AHEAD_DISTANCE, 1, 30)
        local forward = Vector3.new(moveDir.X * step, 0, moveDir.Z * step)
        local target = root.Position + forward + perp * sway
        hum:MoveTo(target)
    end

    -- Goal reached?
    if cfg.GOAL_SEEK_ENABLED and cfg.GOAL_TARGET_POS then
        local dist = (cfg.GOAL_TARGET_POS - root.Position).Magnitude
        if dist <= cfg.GOAL_REACH_DIST then
            if not cfg.GOAL_FOUND then
                cfg.GOAL_FOUND = true
                cfg.GOAL_STATS.reached += 1
                if cfg.onGoalReached then pcall(cfg.onGoalReached) end
                if cfg.GOAL_STOP_ON_REACH and cfg.botMode == "Navigate" then
                    cfg.active = false
                end
            end
        else
            cfg.GOAL_FOUND = false
        end
    end
end

-- ---------------------------------------------------------------------------
-- UI Construction
-- ---------------------------------------------------------------------------

function CPUTab.init(WindUI, GravelConfig)
    Players       = game:GetService("Players")
    RunService    = game:GetService("RunService")
    UserInputService = game:GetService("UserInputService")
    Workspace     = game:GetService("Workspace")
    HttpService   = game:GetService("HttpService")
    LocalPlayer   = Players.LocalPlayer
    Camera        = Workspace.CurrentCamera

    cfg = GravelConfig.cpu
    if not cfg then
        warn("[CPUTab] config.cpu not initialized by Gravel.cc - aborting.")
        return nil
    end

    local Tab = WindUI:Tab({
        Title = "CPU",
        Desc = "Robot brain. Follows goals & targets. Uses Gravel features for combat.",
        Icon = "cpu",
        IconColor = Color3.fromRGB(200, 200, 200),
    })

    -- ================== MASTER ==================
    Tab:Paragraph({
        Title = "CPU Master",
        Desc = "The bot only NAVIGATES and ORBITS. Actual shooting/aiming is Gravel's job.\nEnable SilentAim / Hitbox / TriggerBot / Reach from their tabs.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Toggle({
        Title = "Enable CPU",
        Desc = "Activate the bot (uses config.cpu.active)",
        Value = cfg.active,
        Callback = function(v)
            cfg.active = v
            if not v then
                local root, hum = getRootAndHumanoid()
                if hum and hum.RootPart then
                    hum:MoveTo(hum.RootPart.Position)
                end
            end
        end,
    })

    Tab:Dropdown({
        Title = "Bot Mode",
        Desc = "Melee = dodge + orbit close | Gun = orbit wide + bhop | Navigate = maze/obby solver",
        Values = {"Melee", "Gun", "Navigate"},
        Value = cfg.botMode,
        Multi = false,
        Callback = function(opt)
            cfg.botMode = opt
            cfg.engaged = false
            cfg.currentTargetInstance = nil
        end,
    })

    Tab:Toggle({
        Title = "Follow Current Target",
        Desc = "Use Gravel's target (masterTeamTarget / TargetType / GetTarget) as the bot's target",
        Value = cfg.followTarget,
        Callback = function(v) cfg.followTarget = v end,
    })

    Tab:Slider({
        Title = "Engage Range",
        Desc = "Distance to start orbiting/dodging instead of walking straight to the target",
        IsTextbox = true, Step = 1,
        Value = { Min = 2, Max = 100, Default = cfg.TARGET_ENGAGE_RANGE },
        Callback = function(v) cfg.TARGET_ENGAGE_RANGE = v end,
    })

    Tab:Slider({
        Title = "Target Bias",
        Desc = "How much the bot prefers moving toward its combat target during probes",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0, Max = 5, Default = cfg.TARGET_BIAS },
        Callback = function(v) cfg.TARGET_BIAS = v end,
    })

    -- ================== MELEE MODE ==================
    Tab:Paragraph({
        Title = "Melee Mode",
        Desc = "Bot dodges enemy swings and orbits in close. Gravel's Reach autoSwing can hit for you.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Slider({
        Title = "Melee Dodge Trigger",
        Desc = "How aligned the enemy tool must be with us before we dodge (higher = only when they aim at us)",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0, Max = 1, Default = cfg.MELEE_DODGE_TRIGGER_DOT },
        Callback = function(v) cfg.MELEE_DODGE_TRIGGER_DOT = v end,
    })

    Tab:Slider({
        Title = "Melee Dodge Switch Interval",
        Desc = "How often to flip the perpendicular dodge direction (seconds)",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0.1, Max = 3, Default = cfg.MELEE_DODGE_DIR_SWITCH },
        Callback = function(v) cfg.MELEE_DODGE_DIR_SWITCH = v end,
    })

    -- ================== GUN MODE ==================
    Tab:Paragraph({
        Title = "Gun Mode",
        Desc = "Bot orbits the target + bhops. Gravel's SilentAim / TriggerBot do the shooting.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Dropdown({
        Title = "Orbit Direction",
        Desc = "Fixed CW / CCW, or Random flips periodically",
        Values = {"Random", "Clockwise", "Counterclockwise"},
        Value = cfg.orbitDirMode,
        Multi = false,
        Callback = function(opt) cfg.orbitDirMode = opt end,
    })

    Tab:Slider({
        Title = "Orbit Radius",
        Desc = "Distance the bot keeps from the target while orbiting",
        IsTextbox = true, Step = 0.5,
        Value = { Min = 2, Max = 60, Default = cfg.GUN_ORBIT_RADIUS },
        Callback = function(v) cfg.GUN_ORBIT_RADIUS = v end,
    })

    Tab:Slider({
        Title = "Orbit Direction Switch",
        Desc = "Seconds between random CW/CCW flips",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0.2, Max = 10, Default = cfg.GUN_ORBIT_SWITCH },
        Callback = function(v) cfg.GUN_ORBIT_SWITCH = v end,
    })

    Tab:Toggle({
        Title = "Bhop While Orbiting",
        Desc = "Bunny hop while circling the target",
        Value = cfg.GUN_BHOP,
        Callback = function(v) cfg.GUN_BHOP = v end,
    })

    Tab:Slider({
        Title = "Bhop Interval",
        Desc = "Minimum seconds between hops",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0.02, Max = 1, Default = cfg.GUN_BHOP_INTERVAL },
        Callback = function(v) cfg.GUN_BHOP_INTERVAL = v end,
    })

    -- ================== NAVIGATION ==================
    Tab:Paragraph({
        Title = "Navigation (Mazes / Obby)",
        Desc = "Raycast + LiDAR probing. Only drives Humanoid:MoveTo.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Slider({
        Title = "Probe Count",
        Desc = "Horizontal raycast probes per sweep",
        IsTextbox = true, Step = 1,
        Value = { Min = 6, Max = 100, Default = cfg.PROBE_COUNT },
        Callback = function(v) cfg.PROBE_COUNT = v end,
    })

    Tab:Slider({
        Title = "Sweep Interval",
        Desc = "Seconds between probe sweeps",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0.05, Max = 0.5, Default = cfg.SWEEP_INTERVAL },
        Callback = function(v) cfg.SWEEP_INTERVAL = v end,
    })

    Tab:Slider({
        Title = "Momentum",
        Desc = "Preference to continue in the current direction",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0, Max = 1, Default = cfg.MOMENTUM },
        Callback = function(v) cfg.MOMENTUM = v end,
    })

    Tab:Slider({
        Title = "Novelty Weight",
        Desc = "Preference for unvisited cells",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0, Max = 1, Default = cfg.NOVELTY_WEIGHT },
        Callback = function(v) cfg.NOVELTY_WEIGHT = v end,
    })

    Tab:Slider({
        Title = "Weave Amplitude",
        Desc = "Sideways sway while moving (human-like)",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0, Max = 8, Default = cfg.SINE_AMPLITUDE },
        Callback = function(v) cfg.SINE_AMPLITUDE = v end,
    })

    Tab:Slider({
        Title = "Weave Frequency",
        Desc = "How fast the sideways sway oscillates",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0, Max = 12, Default = cfg.SINE_FREQUENCY },
        Callback = function(v) cfg.SINE_FREQUENCY = v end,
    })

    Tab:Slider({
        Title = "Lookahead Distance",
        Desc = "How far ahead the bot aims its MoveTo",
        IsTextbox = true, Step = 0.5,
        Value = { Min = 2, Max = 30, Default = cfg.AHEAD_DISTANCE },
        Callback = function(v) cfg.AHEAD_DISTANCE = v end,
    })

    -- ================== GOALS ==================
    Tab:Paragraph({
        Title = "Goal Seeking",
        Desc = "Name patterns (comma-separated). Bot walks to the nearest matching part.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Input({
        Title = "Goal Parts",
        Desc = "e.g. finish, goal, end, checkpoint",
        Placeholder = "finish, goal, end",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(text)
            cfg.GOAL_PARTS = {}
            for tok in text:gmatch("[^,]+") do
                local t = tok:match("^%s*(.-)%s*$"):lower()
                if t ~= "" then table.insert(cfg.GOAL_PARTS, t) end
            end
            cfg.GOAL_TARGET = nil
            cfg.GOAL_TARGET_POS = nil
            cfg.GOAL_LAST_SCAN = 0
        end,
    })

    Tab:Toggle({
        Title = "Goal Seeking Enabled",
        Desc = "Walk to the nearest matching goal part",
        Value = cfg.GOAL_SEEK_ENABLED,
        Callback = function(v) cfg.GOAL_SEEK_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Goal Reach Distance",
        Desc = "Consider the goal reached within this distance",
        IsTextbox = true, Step = 0.5,
        Value = { Min = 2, Max = 30, Default = cfg.GOAL_REACH_DIST },
        Callback = function(v) cfg.GOAL_REACH_DIST = v end,
    })

    Tab:Slider({
        Title = "Goal Seek Weight",
        Desc = "How strongly the bot prefers directions toward the goal",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0, Max = 4, Default = cfg.GOAL_SEEK_WEIGHT },
        Callback = function(v) cfg.GOAL_SEEK_WEIGHT = v end,
    })

    Tab:Toggle({
        Title = "Stop On Goal Reached",
        Desc = "Disable the bot once a goal is reached (Navigate mode)",
        Value = cfg.GOAL_STOP_ON_REACH,
        Callback = function(v) cfg.GOAL_STOP_ON_REACH = v end,
    })

    -- ================== OBBIES / JUMPS ==================
    Tab:Paragraph({
        Title = "Obby / Jump",
        Desc = "Gap detection and jumping",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Toggle({
        Title = "Allow Jumping",
        Desc = "Bot jumps over detected gaps",
        Value = cfg.JUMP_ENABLED,
        Callback = function(v) cfg.JUMP_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Jump Cooldown",
        Desc = "Seconds between jumps",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0.05, Max = 2, Default = cfg.JUMP_COOLDOWN },
        Callback = function(v) cfg.JUMP_COOLDOWN = v end,
    })

    Tab:Slider({
        Title = "Gap Min Width",
        Desc = "Don't jump for gaps narrower than this",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0.5, Max = 6, Default = cfg.JUMP_GAP_MIN },
        Callback = function(v) cfg.JUMP_GAP_MIN = v end,
    })

    Tab:Slider({
        Title = "Nudge Distance",
        Desc = "Distance from gap edge where the bot jumps",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0.5, Max = 4, Default = cfg.JUMP_NUDGE_DIST },
        Callback = function(v) cfg.JUMP_NUDGE_DIST = v end,
    })

    Tab:Slider({
        Title = "Jump Landing Probe Down",
        Desc = "How far below to look for landing surfaces",
        IsTextbox = true, Step = 1,
        Value = { Min = 10, Max = 100, Default = cfg.JUMP_LANDING_PROBE_DOWN },
        Callback = function(v) cfg.JUMP_LANDING_PROBE_DOWN = v end,
    })

    Tab:Toggle({
        Title = "Avoid Falls",
        Desc = "Bot steers away from ledges it can't see a floor under",
        Value = cfg.AVOID_FALLS,
        Callback = function(v) cfg.AVOID_FALLS = v end,
    })

    Tab:Slider({
        Title = "Fall Probe Distance",
        Desc = "How far ahead to check for floor",
        IsTextbox = true, Step = 0.5,
        Value = { Min = 4, Max = 30, Default = cfg.FALL_PROBE_DIST },
        Callback = function(v) cfg.FALL_PROBE_DIST = v end,
    })

    Tab:Slider({
        Title = "Fall Penalty",
        Desc = "Penalty applied to directions with little floor coverage",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0, Max = 6, Default = cfg.FALL_PENALTY },
        Callback = function(v) cfg.FALL_PENALTY = v end,
    })

    -- ================== STUCK RECOVERY ==================
    Tab:Paragraph({
        Title = "Stuck Recovery",
        Desc = "When the bot can't make progress, back up and jump",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Toggle({
        Title = "Stuck Recovery Enabled",
        Value = cfg.STUCK_RECOVERY_ENABLED,
        Callback = function(v) cfg.STUCK_RECOVERY_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Recovery Window",
        Desc = "Seconds between movement checks",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0.3, Max = 3, Default = cfg.STUCK_RECOVERY_WINDOW },
        Callback = function(v) cfg.STUCK_RECOVERY_WINDOW = v end,
    })

    Tab:Slider({
        Title = "Recovery Min Move",
        Desc = "Movement under this counts as stuck",
        IsTextbox = true, Step = 0.1,
        Value = { Min = 0.2, Max = 5, Default = cfg.STUCK_RECOVERY_MIN_MOVE },
        Callback = function(v) cfg.STUCK_RECOVERY_MIN_MOVE = v end,
    })

    Tab:Slider({
        Title = "Recovery Trigger Count",
        Desc = "Consecutive stuck checks before recovery",
        IsTextbox = true, Step = 1,
        Value = { Min = 1, Max = 6, Default = cfg.STUCK_RECOVERY_TRIGGER_COUNT },
        Callback = function(v) cfg.STUCK_RECOVERY_TRIGGER_COUNT = v end,
    })

    Tab:Slider({
        Title = "Recovery Backup Time",
        Desc = "Seconds the bot moves backward to unstick",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0.1, Max = 2, Default = cfg.STUCK_RECOVERY_BACKUP_TIME },
        Callback = function(v) cfg.STUCK_RECOVERY_BACKUP_TIME = v end,
    })

    Tab:Slider({
        Title = "Recovery Backup Speed",
        Desc = "Studs/sec while backing up",
        IsTextbox = true, Step = 1,
        Value = { Min = 8, Max = 50, Default = cfg.STUCK_RECOVERY_BACKUP_SPEED },
        Callback = function(v) cfg.STUCK_RECOVERY_BACKUP_SPEED = v end,
    })

    Tab:Slider({
        Title = "Recovery Jump Cooldown",
        Desc = "Seconds between recovery jumps",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0.1, Max = 3, Default = cfg.STUCK_RECOVERY_JUMP_COOLDOWN },
        Callback = function(v) cfg.STUCK_RECOVERY_JUMP_COOLDOWN = v end,
    })

    -- ================== LIDAR / VOXEL NAV ==================
    Tab:Paragraph({
        Title = "LiDAR Voxel Nav",
        Desc = "3D voxel memory from sweeps. Helps maze/obby solving.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Toggle({
        Title = "Voxel Nav Enabled",
        Value = cfg.LIDAR_NAV_ENABLED,
        Callback = function(v) cfg.LIDAR_NAV_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Voxel Size",
        Desc = "Grid size (smaller = finer)",
        IsTextbox = true, Step = 0.5,
        Value = { Min = 1.5, Max = 10, Default = cfg.LIDAR_VOXEL_SIZE },
        Callback = function(v)
            cfg.LIDAR_VOXEL_SIZE = v
            cfg.voxels = {}
            cfg.voxelCount = 0
        end,
    })

    Tab:Slider({
        Title = "Voxel Free Bias",
        Desc = "Reward for moving into known-free space",
        IsTextbox = true, Step = 0.01,
        Value = { Min = 0, Max = 1, Default = cfg.LIDAR_VOXEL_FREE_BIAS },
        Callback = function(v) cfg.LIDAR_VOXEL_FREE_BIAS = v end,
    })

    Tab:Slider({
        Title = "Voxel Solid Penalty",
        Desc = "Penalty for known-solid space",
        IsTextbox = true, Step = 0.05,
        Value = { Min = 0, Max = 3, Default = cfg.LIDAR_VOXEL_SOLID_PENALTY },
        Callback = function(v) cfg.LIDAR_VOXEL_SOLID_PENALTY = v end,
    })

    Tab:Slider({
        Title = "Nav Lookahead",
        Desc = "How far ahead voxel samples go",
        IsTextbox = true, Step = 1,
        Value = { Min = 6, Max = 60, Default = cfg.LIDAR_NAV_LOOKAHEAD },
        Callback = function(v) cfg.LIDAR_NAV_LOOKAHEAD = v end,
    })

    Tab:Slider({
        Title = "Nav Samples",
        Desc = "Voxel samples per direction",
        IsTextbox = true, Step = 1,
        Value = { Min = 2, Max = 16, Default = cfg.LIDAR_NAV_SAMPLES },
        Callback = function(v) cfg.LIDAR_NAV_SAMPLES = v end,
    })

    Tab:Slider({
        Title = "Voxel Decay",
        Desc = "Per-frame decay of voxel occupancy",
        IsTextbox = true, Step = 0.001,
        Value = { Min = 0.90, Max = 1.0, Default = cfg.LIDAR_VOXEL_DECAY },
        Callback = function(v) cfg.LIDAR_VOXEL_DECAY = v end,
    })

    Tab:Button({
        Title = "Clear Voxel Map",
        Desc = "Wipe the voxel nav memory",
        Callback = function()
            cfg.voxels = {}
            cfg.voxelCount = 0
        end,
    })

    -- ================== BLACKLIST ==================
    Tab:Paragraph({
        Title = "Blacklist (Avoid Parts)",
        Desc = "Name patterns of parts to avoid (e.g. killbricks)",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Input({
        Title = "Blacklist Patterns",
        Desc = "Comma-separated; matches name or class",
        Placeholder = "killbrick, damage, hazard",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(text)
            cfg.BLACKLIST_PARTS = {}
            for tok in text:gmatch("[^,]+") do
                local t = tok:match("^%s*(.-)%s*$"):lower()
                if t ~= "" then table.insert(cfg.BLACKLIST_PARTS, t) end
            end
            cfg.BLACKLIST_INSTANCES = {}
            cfg.BLACKLIST_LAST_SCAN = 0
        end,
    })

    Tab:Toggle({
        Title = "Blacklist Enabled",
        Value = cfg.BLACKLIST_ENABLED,
        Callback = function(v) cfg.BLACKLIST_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Blacklist Avoid Radius",
        Value = { Min = 1, Max = 30, Default = cfg.BLACKLIST_AVOID_RADIUS },
        IsTextbox = true, Step = 0.5,
        Callback = function(v) cfg.BLACKLIST_AVOID_RADIUS = v end,
    })

    Tab:Button({
        Title = "Clear Blacklist Cache",
        Callback = function()
            cfg.BLACKLIST_INSTANCES = {}
            cfg.BLACKLIST_LAST_SCAN = 0
        end,
    })

    -- ================== TOUCH MEMORY ==================
    Tab:Paragraph({
        Title = "Touch Memory",
        Desc = "Avoid parts you've touched recently (killbricks, hazards).",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Toggle({
        Title = "Touch Store Enabled",
        Value = cfg.TOUCH_STORE_ENABLED,
        Callback = function(v) cfg.TOUCH_STORE_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Touch Penalty",
        Value = { Min = 0, Max = 8, Default = cfg.TOUCH_PENALTY },
        IsTextbox = true, Step = 0.1,
        Callback = function(v) cfg.TOUCH_PENALTY = v end,
    })

    Tab:Slider({
        Title = "Touch Proximity Weight",
        Value = { Min = 0, Max = 8, Default = cfg.TOUCH_PROXIMITY_BONUS },
        IsTextbox = true, Step = 0.1,
        Callback = function(v) cfg.TOUCH_PROXIMITY_BONUS = v end,
    })

    Tab:Button({
        Title = "Clear Touched Parts",
        Callback = function()
            cfg.TOUCHED_PARTS = {}
            cfg.TOUCH_PENDING = {}
            cfg.TOUCH_COUNT = 0
        end,
    })

    -- ================== PROBE / STATE ==================
    Tab:Paragraph({
        Title = "Probe / State Tuning",
        Desc = "Fine-tuning for the raycast probes.",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Slider({
        Title = "Max Ray Distance",
        Value = { Min = 40, Max = 300, Default = cfg.MAX_RAY_DIST },
        IsTextbox = true, Step = 5,
        Callback = function(v) cfg.MAX_RAY_DIST = v end,
    })

    Tab:Slider({
        Title = "Max Bounces",
        Value = { Min = 4, Max = 48, Default = cfg.MAX_BOUNCES },
        IsTextbox = true, Step = 1,
        Callback = function(v) cfg.MAX_BOUNCES = v end,
    })

    Tab:Slider({
        Title = "Sphere Rings",
        Value = { Min = 1, Max = 6, Default = cfg.SPHERE_RINGS },
        IsTextbox = true, Step = 1,
        Callback = function(v) cfg.SPHERE_RINGS = v end,
    })

    Tab:Slider({
        Title = "Sphere Max Pitch",
        Value = { Min = 10, Max = 85, Default = cfg.SPHERE_PITCH },
        IsTextbox = true, Step = 1,
        Callback = function(v) cfg.SPHERE_PITCH = v end,
    })

    Tab:Toggle({
        Title = "Spin Scan Enabled",
        Desc = "Rotate the probe pattern over time (defeats getting stuck facing one way)",
        Value = cfg.SPIN_SCAN_ENABLED,
        Callback = function(v) cfg.SPIN_SCAN_ENABLED = v end,
    })

    Tab:Slider({
        Title = "Spin Rate",
        Desc = "Revolutions/sec of the probe pattern",
        Value = { Min = 0, Max = 10, Default = cfg.SPIN_RATE },
        IsTextbox = true, Step = 0.1,
        Callback = function(v) cfg.SPIN_RATE = v end,
    })

    Tab:Slider({
        Title = "Neuron Count",
        Value = { Min = 4, Max = 64, Default = cfg.NEURON_COUNT },
        IsTextbox = true, Step = 1,
        Callback = function(v)
            cfg.NEURON_COUNT = v
            cfg.neurons = {}
            for i = 1, v do cfg.neurons[i] = math.random() * 0.4 end
        end,
    })

    Tab:Toggle({
        Title = "Vertical Probe Weighting",
        Desc = "Allow probes to prefer vertical openings (3D movement)",
        Value = cfg.VERTICAL_PROBE_ENABLED,
        Callback = function(v) cfg.VERTICAL_PROBE_ENABLED = v end,
    })

    -- ================== ACTIONS ==================
    Tab:Paragraph({
        Title = "Actions",
        Desc = "Manual triggers and cache wipes",
        Color = Color3.fromRGB(150, 255, 150),
    })

    Tab:Button({
        Title = "Clear Memory",
        Callback = function()
            cfg.memory = {}
            cfg.memoryCount = 0
        end,
    })

    Tab:Button({
        Title = "Clear Trail",
        Callback = function()
            for i = 1, cfg.TRAIL_LEN do cfg.trail[i] = nil end
            cfg.trailIndex = 1
        end,
    })

    Tab:Button({
        Title = "Force Stuck Recovery",
        Callback = function()
            local root, hum, char = getRootAndHumanoid()
            if root and hum then
                startStuckRecovery(root, hum, char,
                    cfg.bestDir or cfg.committedDir)
            end
        end,
    })

    Tab:Button({
        Title = "Reset Goal Stats",
        Callback = function()
            cfg.GOAL_STATS = { reached = 0, attempts = 0, nearestDist = math.huge }
            cfg.GOAL_FOUND = false
        end,
    })

    -- ================== STATUS ==================
    local statusDisplay
    statusDisplay = Tab:Paragraph({
        Title = "Status",
        Desc = "Starting up...",
        Color = Color3.fromRGB(200, 200, 200),
    })

    RunService.Heartbeat:Connect(function(dt)
        botTick(dt)

        if statusDisplay and cfg.active and statusDisplay.SetDesc then
            local root = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetName = "-"
            if cfg.currentTargetInstance then
                if typeof(cfg.currentTargetInstance) == "Instance" then
                    targetName = cfg.currentTargetInstance.Name or "?"
                end
            end
            local wallText = cfg.wallDist and string.format("%.1f studs", cfg.wallDist) or "clear"
            statusDisplay:SetDesc(string.format(
                "Mode: %s\n"
             .. "State: %s\n"
             .. "Neurons: %d/%d\n"
             .. "Best dist: %.1f\n"
             .. "Bounces: best %d avg %.1f\n"
             .. "Novelty: %.2f\n"
             .. "Memory cells: %d\n"
             .. "Voxels: %d\n"
             .. "Target: %s\n"
             .. "Engaged: %s\n"
             .. "Wall: %s\n"
             .. "Explore: %.2f  Stuck: %d\n"
             .. "Goal: %s",
                cfg.botMode,
                cfg.state,
                cfg.neuronCount, cfg.NEURON_COUNT,
                cfg.bestDist,
                cfg.bestBounces, cfg.avgBounces,
                cfg.bestNovelty,
                cfg.memoryCount,
                cfg.voxelCount,
                targetName,
                cfg.engaged and "YES" or "no",
                wallText,
                cfg.forceExploration, cfg.stuckLevel,
                cfg.GOAL_TARGET and (cfg.GOAL_TARGET.Name
                    .. " @ " .. string.format("%.1f",
                        (cfg.GOAL_TARGET_POS - root.Position).Magnitude))
                    or "none"
            ))
        end
    end)

    return Tab
end

return CPUTab
