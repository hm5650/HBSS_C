local M = {}

local _config, _api
local Players, RunService, Workspace, UserInputService

-- ==== Module-local state (non-config, ephemeral) ====
local S = {
    -- navigator
    sweepDirs = {},
    sweepTimer = 0,
    committedDir = nil,
    pendingDir = nil,
    pendingTimer = 0,
    commitTimer = 0,
    bestDir = nil,
    sweepPreferredDir = nil,
    neurons = {},
    memory = {},
    memoryCount = 0,
    trail = {},
    trailIndex = 1,
    currentTarget = nil,
    sinePhase = 0,
    forceExploration = 0,
    stuckAnchor = nil,
    stuckTimer = 0,
    stuckLevel = 0,
    wallLockDir = nil,
    wallLockTimer = 0,
    entranceDir = nil,
    entranceTimer = 0,
    entranceSide = 0,
    spinAngle = 0,
    sweepCount = 0,
    decayAccum = 0,
    -- fall/gap
    fallDetected = false,
    fallBrake = 0,
    fallWarnCount = 0,
    lastGap = {active=false, startD=0, endD=0, width=0, canJump=false, dir=nil},
    pendingGapJump = false,
    pendingGapTimer = 0,
    gapLockDir = nil,
    gapLockTimer = 0,
    gapJumpFired = false,
    -- jump
    jumpCooldownTimer = 0,
    wallJumpable = false,
    statsCache = {time=0},
    observedJumpHeight = nil,
    observedJumpRange = nil,
    observedJumpSamples = 0,
    effectiveHeight = 7.5,
    effectiveRange = 18,
    airborne = false,
    airborneStartY = 0,
    airborneStartXZ = nil,
    airbornePeakY = 0,
    airborneLastPos = nil,
    airLandingTarget = nil,
    airAdjustTimer = 0,
    airTargetLocked = false,
    airLastMoveTo = 0,
    -- truss
    wallIsTruss = false,
    trussClimbing = false,
    trussClimbTimer = 0,
    trussJumpTimer = 0,
    trussDir = nil,
    trussTopY = nil,
    trussAttempts = 0,
    trussSuccesses = 0,
    -- recovery
    recoveryActive = false,
    recoveryTimer = 0,
    recoveryBackupTimer = 0,
    recoveryBackupDir = nil,
    recoveryCount = 0,
    recoveryBackupsUsed = 0,
    recoveryLastPos = nil,
    recoveryWindowTimer = 0,
    recoveryLastJumpTime = 0,
    -- combat
    orbitAngle = 0,
    orbitDir = 1,
    lastJump = 0,
    lastSwing = 0,
    lastStrafe = 0,
    strafeDir = 1,
    lastTargetSwitch = 0,
    lastTargetPos = nil,
    targetVelocity = Vector3.new(0, 0, 0),
    myHumanoid = nil,
    myRoot = nil,
    -- goals/blacklist resolved instances
    goalInstances = {},
    goalTarget = nil,
    goalTargetPos = nil,
    lastGoalScan = 0,
    blacklistInstances = {},
    lastBlacklistScan = 0,
    -- lidar
    lidarFolder = nil,
    lidarBounceFolder = nil,
    lidarPoints = {},
    lidarHead = 1,
    lidarCount = 0,
    lidarVoxels = {},
    lidarVoxelCount = 0,
    lidarPathVoxels = {},
    lidarPathVoxelCount = 0,
    bouncePool = {},
    bouncePoolSize = 0,
    bounceActive = {},
    bounceSpawnTimer = 0,
    bounceMaxPool = 400,
    surfaceColors = {},
    -- rayviz
    rayFolder = nil,
    rayPool = {},
    rayPoolSize = 0,
    rayActive = {},
    rayMaxPool = 64,
    -- raycast param cache
    rayParamsCache = {},
    floorParamsCache = {},
    -- doorway
    doorwayDir = nil,
    doorwayTimer = 0,
    doorwayWidth = 0,
    doorwayCount = 0,
    doorwayHistory = {},
    -- frame
    connection = nil,
    running = false,
    initTime = 0,
    lastKickTime = 0,
    lastMoveToCadence = 0,
    decayAccum = 0,
    lidarDecayAccum = 0,
    pathMemoryDecayAccum = 0,
}

-- ==== Forward decls ====
local getRootAndHumanoid, makeRayParams, makeFloorRayParams, raycastFiltered
local isTruss, findTrussAhead, tryClimbTruss
local hasSolidBelow, floorCoverageAlong
local analyzeGapAhead, checkFallAndGapAhead, findLandingSpot
local airControlTick, sampleAirborne
local predictEntrance, checkWallAhead, computeWallFollowDir
local findFallSafeDirection, doJump
local startStuckRecovery, updateStuckRecovery
local findWallTop, analyzeWallForJump, getTriggerWindow, tryJump
local getJumpCapabilities, refreshStats, readRawStats
local tickNeurons, trailPenaltyAt
local bounceRay, scoreProbe, sweepProbes
local scoreGoalDirection, scoreBlacklistPenalty
local scoreDirectionFromVoxels, queryVoxel, markVoxelSolid, markVoxelFree
local markPathVoxel, markPathAround, queryPathHeat, pathMemoryPenalty, decayPathMemory
local decayVoxels, markVisited, decayMemory, pushTrail
local lidarInit, lidarUpdate, lidarSweep, lidarClear, lidarMarkFreeAround
local lidarAddPoint, lidarSpawnBounce, classifySurface
local detectDoorwayFromLidar
local vizRay, pruneRayViz, clearRayViz
local isBlacklisted, scanBlacklist, scanGoals, collectBaseParts, nameMatchesPatterns
local parsePatternList, cellKey
local getTargetCharacter_local

-- =========================================================
-- Helpers
-- =========================================================
local function getPlayer()
    return _api.player or _api.localPlayer or Players.LocalPlayer
end

function getRootAndHumanoid()
    local char = getPlayer().Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health > 0 then
        return root, hum, char
    end
    return nil, nil, nil
end

function makeRayParams(char)
    local cached = S.rayParamsCache[char]
    if cached then return cached end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = {char}
    p.IgnoreWater = true
    p.RespectCanCollide = true
    S.rayParamsCache[char] = p
    return p
end

function makeFloorRayParams(char)
    local cached = S.floorParamsCache[char]
    if cached then return cached end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = {char}
    p.IgnoreWater = true
    p.RespectCanCollide = true
    S.floorParamsCache[char] = p
    return p
end

function raycastFiltered(origin, direction, params)
    -- Skips blacklisted parts (multi-pass)
    local maxPass = 4
    local pass = 0
    local currOrigin = origin
    local totalDist = 0
    local maxDist = direction.Magnitude
    local dirUnit = direction.Unit
    while pass < maxPass do
        pass += 1
        local remaining = maxDist - totalDist
        if remaining <= 0.05 then return nil end
        local hit = Workspace:Raycast(currOrigin, dirUnit * remaining, params)
        if not hit then return nil end
        if isBlacklisted(hit.Instance) then
            local skip = 2.0
            currOrigin = hit.Position + dirUnit * skip
            totalDist = totalDist + hit.Distance + skip
            if totalDist >= maxDist then return nil end
        else
            return hit
        end
    end
    return nil
end

local function parsePatternList(str)
    local out = {}
    if not str or str == "" then return out end
    if type(str) == "table" then
        for _, v in ipairs(str) do
            if type(v) == "string" and v ~= "" then
                table.insert(out, v:lower())
            end
        end
        return out
    end
    for token in tostring(str):gmatch("[^,]+") do
        local t = token:match("^%s*(.-)%s*$"):lower()
        if t ~= "" then out[#out + 1] = t end
    end
    return out
end

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
    local ok, children = pcall(function() return inst:GetChildren() end)
    if not ok or not children then return end
    for _, child in ipairs(children) do
        if child and child.Parent then
            collectBaseParts(child, out, seen)
        end
    end
end

function isBlacklisted(part)
    if not part then return false end
    return S.blacklistInstances[part] == true
end

function scanBlacklist(now)
    if now - S.lastBlacklistScan < 0.5 then return end
    S.lastBlacklistScan = now
    local patterns = _config.cpu.blacklist
    if not patterns or #patterns == 0 then
        S.blacklistInstances = {}
        return
    end
    local newCache = {}
    local seen = {}
    local function visit(inst)
        if not inst or not inst.Parent then return end
        local ok, name = pcall(function() return inst.Name end)
        local ok2, cls = pcall(function() return inst.ClassName end)
        if ok and ok2 and (nameMatchesPatterns(name, patterns)
                        or nameMatchesPatterns(cls, patterns)) then
            local parts = {}
            collectBaseParts(inst, parts, seen)
            for _, p in ipairs(parts) do
                newCache[p] = true
            end
            return
        end
        local okC, children = pcall(function() return inst:GetChildren() end)
        if not okC or not children then return end
        for _, child in ipairs(children) do
            if child and child.Parent then visit(child) end
        end
    end
    local okW, tops = pcall(function() return Workspace:GetChildren() end)
    if not okW or not tops then return end
    for _, top in ipairs(tops) do
        if top and top.Parent then visit(top) end
    end
    S.blacklistInstances = newCache
end

function scanGoals(now, rootPos)
    if now - S.lastGoalScan < 0.5 then return end
    S.lastGoalScan = now
    local patterns = _config.cpu.goals
    if not patterns or #patterns == 0 then
        S.goalTarget = nil
        S.goalTargetPos = nil
        _config.cpu._runtime.goalName = nil
        _config.cpu._runtime.goalDist = nil
        return
    end
    local seen = {}
    local bestPart, bestPos, bestDist = nil, nil, math.huge
    local function visit(inst)
        if not inst or not inst.Parent then return end
        local ok, name = pcall(function() return inst.Name end)
        local ok2, cls = pcall(function() return inst.ClassName end)
        if ok and ok2 and (nameMatchesPatterns(name, patterns)
                        or nameMatchesPatterns(cls, patterns)) then
            local parts = {}
            collectBaseParts(inst, parts, seen)
            for _, p in ipairs(parts) do
                if p.Parent then
                    local dist = rootPos and (p.Position - rootPos).Magnitude or 0
                    if dist < bestDist then
                        bestDist = dist
                        bestPart = p
                        bestPos = p.Position
                    end
                end
            end
            return
        end
        local okC, children = pcall(function() return inst:GetChildren() end)
        if not okC or not children then return end
        for _, child in ipairs(children) do
            if child and child.Parent then visit(child) end
        end
    end
    local okW, tops = pcall(function() return Workspace:GetChildren() end)
    if not okW or not tops then return end
    for _, top in ipairs(tops) do
        if top and top.Parent then visit(top) end
    end
    if bestPart then
        S.goalTarget = bestPart
        S.goalTargetPos = bestPos
        _config.cpu._runtime.goalName = bestPart.Name
        _config.cpu._runtime.goalDist = bestDist
    else
        S.goalTarget = nil
        S.goalTargetPos = nil
        _config.cpu._runtime.goalName = nil
        _config.cpu._runtime.goalDist = nil
    end
end

-- =========================================================
-- Surface classification (for LiDAR colors)
-- =========================================================
function classifySurface(part, normal)
    if not part then return "other" end
    if isBlacklisted(part) then return "blacklist" end
    if part:IsA("TrussPart") then return "truss" end
    if part:IsA("WedgePart") or part:IsA("CornerWedgePart") then return "wedge" end
    if isTruss(part) then return "truss" end
    local ny = normal and normal.Y or 0
    if ny >= 0.7 then return "floor" end
    if ny <= -0.7 then return "ceil" end
    if math.abs(ny) >= 0.15 and math.abs(ny) <= 0.7 then return "wedge" end
    return "wall"
end

-- =========================================================
-- Truss
-- =========================================================
local TRUSS_HINTS = {"truss", "ladder", "climb", "scaffold"}
function isTruss(part)
    if not part then return false end
    if part:IsA("TrussPart") then return true end
    local name = part.Name:lower()
    for _, hint in ipairs(TRUSS_HINTS) do
        if name:find(hint, 1, true) then
            local size = part.Size
            if size and size.Y > 2 then return true end
        end
    end
    return false
end

function findTrussAhead(root, char, dir, dist)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return nil end
    flat = flat.Unit
    local hit = raycastFiltered(origin, flat * (dist or 14), params)
    if not hit or not isTruss(hit.Instance) then return nil end
    return {
        instance = hit.Instance,
        position = hit.Position,
        distance = hit.Distance,
        normal = hit.Normal,
        dir = flat,
        topY = hit.Position.Y + 3,
    }
end

function tryClimbTruss(root, hum, char, dir)
    if not _config.cpu.trussEnabled then return false end
    if not hum or hum.Health <= 0 then return false end
    local info = findTrussAhead(root, char, dir, 14)
    if not info then
        S.trussClimbing = false
        return false
    end
    S.wallIsTruss = true
    S.trussDir = info.dir
    S.trussTopY = info.topY
    S.trussClimbing = true
    S.trussClimbTimer = 0.8
    local rootPart = hum.RootPart
    if rootPart then
        local push = info.dir * math.max(hum.WalkSpeed, 16) * 0.35
        local vel = rootPart.AssemblyLinearVelocity
        rootPart.AssemblyLinearVelocity = Vector3.new(push.X, vel.Y, push.Z)
    end
    if S.trussJumpTimer <= 0 and hum.FloorMaterial ~= Enum.Material.Air then
        S.trussAttempts += 1
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        hum.Jump = true
        S.trussSuccesses += 1
        S.trussJumpTimer = 0.35
    end
    return true
end

-- =========================================================
-- Floor / Fall checks
-- =========================================================
function hasSolidBelow(pos, maxDown, params)
    maxDown = maxDown or 25
    local origin = pos + Vector3.new(0, 3, 0)
    local hit = raycastFiltered(origin, Vector3.new(0, -(maxDown + 3), 0), params)
    return hit ~= nil, hit
end

function floorCoverageAlong(origin, dir, params)
    local safe, total = 0, 0
    local step = 2.5
    local d = Vector3.new(dir.X, 0, dir.Z)
    if d.Magnitude < 0.001 then return 1 end
    d = d.Unit
    local dist = step
    while dist <= 14 do
        total += 1
        local probe = origin + d * dist
        local ok = hasSolidBelow(probe, 25, params)
        if ok then safe += 1 end
        dist += step
    end
    if total == 0 then return 1 end
    return safe / total
end

function analyzeGapAhead(root, char, hum, dir)
    local result = {active=false, startD=0, endD=0, width=0, farSolid=false, canJump=false, dir=nil, landingPoint=nil}
    if not dir then return result end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return result end
    flat = flat.Unit
    result.dir = flat
    local maxH, maxR = getJumpCapabilities(hum)
    local params = makeFloorRayParams(char)
    local origin = root.Position
    local scanMax = math.min(maxR * 0.9 + 8, 34)
    local step = 1.0
    local gapStart, gapEnd = nil, nil
    local d = step
    while d <= scanMax do
        local probe = origin + flat * d
        local ok = hasSolidBelow(probe, 25, params)
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
    if result.farSolid and result.width >= 1.5 and result.width <= maxR * 0.9 + 2 then
        local landingProbe = origin + flat * (result.endD + 1.5)
        local landHit = raycastFiltered(landingProbe + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), params)
        if landHit and landHit.Normal.Y > 0.5 then
            local rise = landHit.Position.Y - origin.Y
            if rise <= maxH * 0.95 then
                result.landingPoint = landHit.Position
                result.canJump = true
            end
        end
    end
    return result
end

function checkFallAndGapAhead(root, char, hum, dir)
    local coverage = 1
    if _config.cpu.avoidFalls then
        coverage = floorCoverageAlong(root.Position, dir, makeFloorRayParams(char))
    end
    local gapInfo = analyzeGapAhead(root, char, hum, dir)
    return coverage, gapInfo
end

function findLandingSpot(root, char, hum, dir)
    local params = makeFloorRayParams(char)
    local origin = root.Position
    local base = Vector3.new(dir.X, 0, dir.Z)
    if base.Magnitude < 0.001 then return nil end
    base = base.Unit
    local perp = Vector3.new(-base.Z, 0, base.X)
    local best, bestScore = nil, -math.huge
    for _, angDeg in ipairs({0, 10, -10, 20, -20, 35, -35, 50, -50}) do
        local a = math.rad(angDeg)
        local d = base * math.cos(a) + perp * math.sin(a)
        if d.Magnitude > 0.001 then
            d = d.Unit
            local hit = raycastFiltered(origin + d * 1.0 + Vector3.new(0, 1.5, 0), Vector3.new(0, -60, 0), params)
            if hit and hit.Normal.Y >= 0.5 then
                local rise = hit.Position.Y - origin.Y
                if rise > -6 then
                    local flatDist = (Vector3.new(hit.Position.X, 0, hit.Position.Z) - Vector3.new(origin.X, 0, origin.Z)).Magnitude
                    local fwdness = d:Dot(base)
                    local score = fwdness * 0.4 * 4 + math.max(0, 22 - flatDist) * 0.15 - math.abs(rise) * 0.05
                    if score > bestScore then
                        bestScore = score
                        best = hit.Position
                    end
                end
            end
        end
    end
    return best
end

-- =========================================================
-- Jump capabilities
-- =========================================================
function readRawStats(hum)
    local gravity = Workspace.Gravity
    if gravity <= 0 then gravity = 196.2 end
    local useJumpPower = hum.UseJumpPower
    local jumpPower = hum.JumpPower or 50
    local jumpHeight = hum.JumpHeight or 0
    local height
    if useJumpPower and jumpPower > 0 then
        height = (jumpPower * jumpPower) / (2 * gravity)
    elseif jumpHeight > 0 then
        height = jumpHeight
    else
        height = (50 * 50) / (2 * gravity)
    end
    local riseTime = math.sqrt(math.max(0.0001, 2 * height / gravity))
    local airTime = riseTime * 2
    local walkSpeed = hum.WalkSpeed
    if walkSpeed <= 0 then walkSpeed = 16 end
    local range = walkSpeed * airTime
    return {jumpPower=jumpPower, jumpHeight=jumpHeight, useJumpPower=useJumpPower,
            walkSpeed=walkSpeed, gravity=gravity, height=height, range=range, airTime=airTime}
end

function refreshStats(hum, now)
    if now - (S.statsCache.time or 0) >= 0.25 then
        S.statsCache.time = now
        local s = readRawStats(hum)
        for k, v in pairs(s) do S.statsCache[k] = v end
    end
    local theoH = S.statsCache.height
    local theoR = S.statsCache.range
    local effH = theoH
    local effR = theoR
    if S.observedJumpHeight then effH = math.min(theoH, S.observedJumpHeight * 0.95) end
    if S.observedJumpRange then effR = math.min(theoR, S.observedJumpRange * 0.95) end
    effH = math.max(effH, 2.0)
    effR = math.max(effR, 4.0)
    if S.observedJumpHeight then
        S.observedJumpHeight = S.observedJumpHeight * 0.95 + theoH * 0.05
    end
    if S.observedJumpRange then
        S.observedJumpRange = S.observedJumpRange * 0.95 + theoR * 0.05
    end
    S.effectiveHeight = effH
    S.effectiveRange = effR
    return effH, effR
end

function getJumpCapabilities(hum)
    if not hum then return 7.5, 18, 1.0, 196.2 end
    local now = os.clock()
    local effH, effR = refreshStats(hum, now)
    return effH, effR, S.statsCache.airTime or 1.0, S.statsCache.gravity or 196.2
end

function sampleAirborne(root, hum)
    local onGround = hum.FloorMaterial ~= Enum.Material.Air
    if S.airborne then
        if onGround then
            local peak = S.airbornePeakY - S.airborneStartY
            if peak > 0.5 then
                if not S.observedJumpHeight then
                    S.observedJumpHeight = peak
                else
                    S.observedJumpHeight = S.observedJumpHeight * 0.7 + peak * 0.3
                end
            end
            if S.airborneStartXZ and S.airborneLastPos then
                local dxz = (Vector3.new(S.airborneLastPos.X, 0, S.airborneLastPos.Z)
                          - Vector3.new(S.airborneStartXZ.X, 0, S.airborneStartXZ.Z)).Magnitude
                if dxz > 1 then
                    S.observedJumpRange = (S.observedJumpRange or dxz) * 0.7 + dxz * 0.3
                end
            end
            S.observedJumpSamples += 1
            S.airborne = false
            S.airborneStartXZ = nil
            S.airborneLastPos = nil
            S.airbornePeakY = 0
            S.airLandingTarget = nil
            S.airAdjustTimer = 0
            S.airTargetLocked = false
        else
            if root.Position.Y > S.airbornePeakY then
                S.airbornePeakY = root.Position.Y
            end
            S.airborneLastPos = root.Position
        end
    else
        if not onGround then
            S.airborne = true
            S.airborneStartY = root.Position.Y
            S.airborneStartXZ = root.Position
            S.airbornePeakY = root.Position.Y
            S.airborneLastPos = root.Position
            S.airAdjustTimer = 0
            S.airTargetLocked = false
            S.airLandingTarget = nil
        end
    end
end

function airControlTick(root, hum, char, dt)
    if not S.airborne then return end
    if not hum or hum.Health <= 0 then return end
    if S.airAdjustTimer > 2.5 then return end
    S.airAdjustTimer += dt
    local target = S.airLandingTarget
    if not target and S.lastGap and S.lastGap.landingPoint then
        target = S.lastGap.landingPoint
        S.airLandingTarget = target
        S.airTargetLocked = true
    end
    if not target then
        local lookDir = S.gapLockDir or S.bestDir or root.CFrame.LookVector
        target = findLandingSpot(root, char, hum, lookDir)
        if target then
            S.airLandingTarget = target
            S.airTargetLocked = true
        end
    end
    if target then
        local toTarget = Vector3.new(target.X - root.Position.X, 0, target.Z - root.Position.Z)
        local dist = toTarget.Magnitude
        if dist > 0.25 then
            local dir = toTarget.Unit
            local rootPart = hum.RootPart
            if rootPart then
                local vel = rootPart.AssemblyLinearVelocity
                local desired = dir * math.max(hum.WalkSpeed, 16)
                local sx = vel.X + (desired.X - vel.X) * 0.6 * dt * 12
                local sz = vel.Z + (desired.Z - vel.Z) * 0.6 * dt * 12
                rootPart.AssemblyLinearVelocity = Vector3.new(sx, vel.Y, sz)
            end
            local now = os.clock()
            if now - S.airLastMoveTo > 0.05 then
                S.airLastMoveTo = now
                hum:MoveTo(root.Position + dir * math.min(dist * 0.9, 20))
            end
        else
            hum:MoveTo(root.Position)
        end
    end
end

function doJump(hum)
    if not hum or hum.Health <= 0 then return false end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    hum.Jump = true
    return true
end

function findWallTop(hitPos, params, maxHeight)
    local acc = 0
    local step = 0.8
    local probeOrigin = hitPos + Vector3.new(0, 0.2, 0)
    while acc <= maxHeight + step do
        local probe = raycastFiltered(probeOrigin + Vector3.new(0, acc, 0), Vector3.new(0, step, 0), params)
        if probe == nil then return probeOrigin.Y + acc end
        acc += step
    end
    return nil
end

function analyzeWallForJump(root, char, hum, dir)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local rayDir = Vector3.new(dir.X, 0, dir.Z)
    if rayDir.Magnitude < 0.001 then return false end
    rayDir = rayDir.Unit
    local maxH, maxR = getJumpCapabilities(hum)
    local maxLook = math.min(16, maxR * 0.9)
    local hit = raycastFiltered(origin, rayDir * maxLook, params)
    if not hit then return false end
    if isTruss(hit.Instance) then return false end
    local hitDist = hit.Distance
    local topY = findWallTop(hit.Position, params, maxH + 4)
    if not topY then return false end
    local wallHeight = topY - root.Position.Y
    if wallHeight < 0.8 then return false end
    local needed = wallHeight + 0.5
    if needed > maxH * 0.95 then return false end
    if hitDist > maxR * 0.9 then return false end
    local landingOrigin = origin + Vector3.new(0, needed, 0) + rayDir * (hitDist + 2)
    local landingHit = raycastFiltered(landingOrigin, Vector3.new(0, -40, 0), params)
    if not landingHit or landingHit.Normal.Y < 0.5 then return false end
    local rise = landingHit.Position.Y - root.Position.Y
    if rise > maxH * 0.95 then return false end
    return true
end

function getTriggerWindow()
    local scale = math.clamp(S.effectiveRange / 20, 0.6, 2.5)
    return 0.5 * scale, 6 * scale
end

function tryJump(root, hum, char, dir)
    if not _config.cpu.jumpEnabled then return false end
    if S.jumpCooldownTimer > 0 then return false end
    if not hum or hum.Health <= 0 then return false end
    if hum.FloorMaterial == Enum.Material.Air and not S.pendingGapJump then return false end
    if not dir then return false end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return false end
    flat = flat.Unit
    if analyzeWallForJump(root, char, hum, flat) then
        return doJump(hum)
    end
    local scanDir = S.gapLockDir or flat
    local gapInfo
    if S.lastGap and S.lastGap.dir and S.lastGap.dir:Dot(scanDir) > 0.85 then
        gapInfo = S.lastGap
    else
        gapInfo = analyzeGapAhead(root, char, hum, scanDir)
    end
    if (S.pendingGapJump or gapInfo.canJump) and gapInfo.canJump then
        local mn, mx = getTriggerWindow()
        if gapInfo.startD >= mn and gapInfo.startD <= mx then
            if doJump(hum) then
                S.pendingGapJump = false
                S.gapJumpFired = true
                S.pendingGapTimer = 0
                return true
            end
        end
    end
    return false
end

-- =========================================================
-- Stuck recovery
-- =========================================================
function startStuckRecovery(root, hum, char, dir)
    if not _config.cpu.stuckRecovery then return end
    if not dir then dir = S.bestDir or S.committedDir or root.CFrame.LookVector end
    if not dir or dir.Magnitude < 0.001 then return end
    dir = dir.Unit
    S.recoveryActive = true
    S.recoveryTimer = 0.9
    S.recoveryCount += 1
    local now = os.clock()
    if now - S.recoveryLastJumpTime >= 0.6 then
        S.recoveryLastJumpTime = now
        doJump(hum)
    end
    if S.recoveryBackupsUsed < 3 then
        local rootPart = hum.RootPart
        if rootPart then
            local back = -dir.Unit
            local speed = 22
            local vel = rootPart.AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(back.X * speed, vel.Y, back.Z * speed)
            S.recoveryBackupDir = back
            S.recoveryBackupTimer = 0.55
            S.recoveryBackupsUsed += 1
        end
    end
    S.forceExploration = math.min(1, S.forceExploration + 0.55)
    S.sweepTimer = 0
    S.commitTimer = 0
    S.pendingDir = nil
    S.bestDir = nil
    S.committedDir = nil
end

function updateStuckRecovery(root, hum, char, dt)
    if not _config.cpu.stuckRecovery then return end
    if S.recoveryActive then
        S.recoveryTimer -= dt
        if S.recoveryBackupTimer > 0 then
            S.recoveryBackupTimer -= dt
            local rootPart = hum.RootPart
            if rootPart and S.recoveryBackupDir then
                local vel = rootPart.AssemblyLinearVelocity
                rootPart.AssemblyLinearVelocity = Vector3.new(S.recoveryBackupDir.X * 22, vel.Y, S.recoveryBackupDir.Z * 22)
            end
        end
        if S.recoveryTimer <= 0 then
            S.recoveryActive = false
            S.recoveryBackupTimer = 0
            S.recoveryBackupDir = nil
            S.recoveryLastPos = root.Position
            S.recoveryWindowTimer = 0
        end
        return
    end
    S.recoveryWindowTimer += dt
    if S.recoveryWindowTimer >= 0.9 then
        if S.recoveryLastPos then
            local moved = (root.Position - S.recoveryLastPos).Magnitude
            if moved < 1.2 then
                S.recoveryCount += 1
                if S.recoveryCount >= 2 then
                    startStuckRecovery(root, hum, char, S.bestDir or S.committedDir or root.CFrame.LookVector)
                    S.recoveryCount = 0
                end
            else
                S.recoveryCount = math.max(0, S.recoveryCount - 1)
            end
        end
        S.recoveryLastPos = root.Position
        S.recoveryWindowTimer = 0
    end
end

-- =========================================================
-- Walls / entrances
-- =========================================================
function predictEntrance(root, char, forwardDir)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local baseYaw = math.atan2(forwardDir.X, forwardDir.Z)
    local half = math.rad(75)
    local n = 11
    local samples = {}
    for i = 1, n do
        local a = -half + (i - 1) / (n - 1) * (half * 2)
        local ang = baseYaw + a
        local dir = Vector3.new(math.sin(ang), 0, math.cos(ang))
        local hit = raycastFiltered(origin, dir * 16, params)
        local dist = hit and hit.Distance or 16
        if _config.cpu.showRays then
            local endpoint = hit and hit.Position or (origin + dir * 16)
            vizRay(origin, endpoint, Color3.fromRGB(180, 100, 255))
        end
        samples[i] = {dir=dir, dist=dist, angle=a}
    end
    local best, runStart = nil, nil
    for i = 1, n + 1 do
        local far = samples[i] and samples[i].dist >= 7
        if far and not runStart then
            runStart = i
        elseif (not far or i > n) and runStart then
            local runEnd = i - 1
            if runEnd - runStart + 1 >= 2 then
                local midIdx = math.floor((runStart + runEnd) / 2)
                local avgDist = 0
                for k = runStart, runEnd do avgDist += samples[k].dist end
                avgDist = avgDist / (runEnd - runStart + 1)
                local cand = {angle=samples[midIdx].angle, dist=avgDist, dir=samples[midIdx].dir}
                if not best or cand.dist > best.dist then best = cand end
            end
            runStart = nil
        end
    end
    if not best then return nil, 0, 0 end
    local side = 0
    if best.angle > 0.15 then side = 1
    elseif best.angle < -0.15 then side = -1 end
    return best.dir, side, best.dist
end

function checkWallAhead(root, char, dir, dist)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local hit = raycastFiltered(origin, dir.Unit * dist, params)
    if _config.cpu.showRays then
        local endpoint = hit and hit.Position or (origin + dir.Unit * dist)
        vizRay(origin, endpoint, hit and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(120, 120, 120))
    end
    if not hit then return nil end
    local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
    if n.Magnitude < 0.001 then n = nil else n = n.Unit end
    return hit.Distance, n, hit.Position, hit.Instance, isTruss(hit.Instance)
end

function computeWallFollowDir(wallNormal, preferSide)
    local t1 = Vector3.new(-wallNormal.Z, 0, wallNormal.X)
    local t2 = Vector3.new( wallNormal.Z, 0, -wallNormal.X)
    if preferSide >= 0 then return t2 else return t1 end
end

function findFallSafeDirection(root, char, hum, dir)
    if not _config.cpu.avoidFalls then return dir end
    local params = makeFloorRayParams(char)
    local base = Vector3.new(dir.X, 0, dir.Z)
    if base.Magnitude < 0.001 then return dir end
    base = base.Unit
    local candidates = {0, math.rad(25), -math.rad(25), math.rad(50), -math.rad(50), math.rad(75), -math.rad(75), math.rad(100), -math.rad(100), math.pi}
    local bestDir, bestCov = nil, -1
    for _, a in ipairs(candidates) do
        local cd = base * math.cos(a) + Vector3.new(-base.Z, 0, base.X) * math.sin(a)
        if cd.Magnitude > 0.001 then
            cd = cd.Unit
            local cov = floorCoverageAlong(root.Position, cd, params)
            if cov > bestCov then bestCov = cov; bestDir = cd end
            if cov >= 0.85 then return cd end
        end
    end
    if bestCov >= 0.5 then return bestDir end
    return nil
end

-- =========================================================
-- Voxels & path memory
-- =========================================================
function cellKey(x, z)
    return math.floor(x / 6) * 100000 + math.floor(z / 6)
end

local function voxelKey(px, py, pz)
    local s = 4.0
    local vx = math.floor(px / s)
    local vy = math.floor(py / s)
    local vz = math.floor(pz / s)
    return vx * 73856093 + vy * 19349663 + vz * 83492791
end

function markVoxelSolid(pos)
    local key = voxelKey(pos.X, pos.Y, pos.Z)
    local v = S.lidarVoxels[key]
    if not v then
        v = {occ=0, last=0, seen=0}
        S.lidarVoxels[key] = v
        S.lidarVoxelCount += 1
    end
    v.occ = math.min(1, v.occ + 0.4)
    v.last = os.clock()
    v.seen = v.seen + 1
end

function markVoxelFree(pos)
    local key = voxelKey(pos.X, pos.Y, pos.Z)
    local v = S.lidarVoxels[key]
    if not v then
        v = {occ=0, last=0, seen=0}
        S.lidarVoxels[key] = v
        S.lidarVoxelCount += 1
    end
    v.occ = math.max(0, v.occ - 0.15)
    v.last = os.clock()
    v.seen = v.seen + 1
end

function queryVoxel(pos)
    local v = S.lidarVoxels[voxelKey(pos.X, pos.Y, pos.Z)]
    if not v then return -1 end
    return v.occ
end

function markPathVoxel(pos, hotness)
    if not _config.cpu.pathMemory then return end
    local key = voxelKey(pos.X, pos.Y, pos.Z)
    local v = S.lidarPathVoxels[key]
    if not v then
        v = {heat=0, last=0}
        S.lidarPathVoxels[key] = v
        S.lidarPathVoxelCount += 1
    end
    v.heat = math.min(3.0, v.heat + (hotness or 1.0))
    v.last = os.clock()
end

function markPathAround(pos, radius)
    if not _config.cpu.pathMemory then return end
    local s = 4.0
    local steps = math.max(1, math.floor((radius or 2.0) / s))
    for dx = -steps, steps do
        for dy = -1, 1 do
            for dz = -steps, steps do
                markPathVoxel(Vector3.new(pos.X + dx * s, pos.Y + dy * s * 0.5, pos.Z + dz * s), 0.4)
            end
        end
    end
end

function queryPathHeat(pos)
    if not _config.cpu.pathMemory then return 0 end
    local v = S.lidarPathVoxels[voxelKey(pos.X, pos.Y, pos.Z)]
    if not v then return 0 end
    local age = os.clock() - v.last
    if age > 4.5 then return 0 end
    return math.clamp(v.heat * math.exp(-age / 2.25), 0, 1)
end

function pathMemoryPenalty(origin, dir, maxDist)
    if not _config.cpu.pathMemory then return 0 end
    if S.lidarPathVoxelCount == 0 then return 0 end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return 0 end
    flat = flat.Unit
    local samples = 8
    local look = math.min(maxDist or 26, 26)
    local step = look / samples
    local total = 0
    for i = 1, samples do
        local p = origin + flat * (step * i)
        total = total + queryPathHeat(p)
    end
    local avg = total / samples
    if S.goalTargetPos then
        local toGoal = Vector3.new(S.goalTargetPos.X - origin.X, 0, S.goalTargetPos.Z - origin.Z)
        if toGoal.Magnitude > 0.5 then
            toGoal = toGoal.Unit
            local align = flat:Dot(toGoal)
            if align > 0 then avg = avg * (1 - 0.6 * align) end
        end
    end
    return math.min(avg * 2.2, 3.5)
end

function decayPathMemory()
    if not _config.cpu.pathMemory then return end
    local now = os.clock()
    local toRemove = nil
    for k, v in pairs(S.lidarPathVoxels) do
        local age = now - v.last
        if age > 13.5 then
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = k
        else
            v.heat = v.heat * 0.94
            if v.heat < 0.01 then
                toRemove = toRemove or {}
                toRemove[#toRemove + 1] = k
            end
        end
    end
    if toRemove then
        for _, k in ipairs(toRemove) do
            S.lidarPathVoxels[k] = nil
            S.lidarPathVoxelCount -= 1
        end
    end
end

function decayVoxels()
    local now = os.clock()
    local toRemove = nil
    for k, v in pairs(S.lidarVoxels) do
        if now - v.last > 30 then
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = k
        else
            v.occ = v.occ * 0.99
            if v.occ < 0.02 and v.seen < 2 then
                toRemove = toRemove or {}
                toRemove[#toRemove + 1] = k
            end
        end
    end
    if toRemove then
        for _, k in ipairs(toRemove) do
            S.lidarVoxels[k] = nil
            S.lidarVoxelCount -= 1
        end
    end
end

function scoreDirectionFromVoxels(origin, dir)
    if not _config.cpu.lidarNav then return 0 end
    if S.lidarVoxelCount < 8 then return 0 end
    local d = dir
    if d.Magnitude < 0.001 then return 0 end
    d = d.Unit
    local samples = 6
    local look = 22
    local step = look / samples
    local free, solid, unknown, frontier = 0, 0, 0, 0
    local lastKnown = nil
    for i = 1, samples do
        local p = origin + d * (step * i)
        local occ = queryVoxel(p)
        if occ < 0 then
            unknown += 1
            if lastKnown == "free" then frontier += 1 end
            lastKnown = "unknown"
        elseif occ >= 0.55 then
            solid += 1
            lastKnown = "solid"
        else
            free += 1
            lastKnown = "free"
        end
    end
    local total = samples
    local score = (free / total) * 0.25 + (frontier / total) * 0.65 - (solid / total) * 1.20
    score += (unknown / total) * 0.20
    if score > 1 then score = 1 elseif score < -1 then score = -1 end
    return score
end

function markVisited(pos)
    local key = cellKey(pos.X, pos.Z)
    if _config.cpu._runtime and not S.memory[key] then S.memoryCount += 1 end
    S.memory[key] = 1
end

function decayMemory(rate)
    local toRemove = nil
    for k, v in pairs(S.memory) do
        local nv = v * rate
        if nv < 0.02 then
            toRemove = toRemove or {}
            toRemove[#toRemove + 1] = k
        else
            S.memory[k] = nv
        end
    end
    if toRemove then
        for _, k in ipairs(toRemove) do
            S.memory[k] = nil
            S.memoryCount -= 1
        end
    end
end

function pushTrail(pos)
    S.trail[S.trailIndex] = {pos=pos, t=os.clock()}
    S.trailIndex += 1
    if S.trailIndex > 24 then S.trailIndex = 1 end
end

function trailPenaltyAt(pos)
    local now = os.clock()
    local penalty = 0
    for i = 1, 24 do
        local e = S.trail[i]
        if e and (now - e.t) < 6 then
            local dx = pos.X - e.pos.X
            local dz = pos.Z - e.pos.Z
            local d2 = dx*dx + dz*dz
            if d2 < 36 then
                penalty += (1 - math.sqrt(d2) / 6) * 0.45
            end
        end
    end
    return math.min(penalty, 1.5)
end

function tickNeurons(dt, stimulus)
    local active = 0
    local rate = 0.05 + stimulus * 0.14
    if not S.neurons[1] then
        for i = 1, 32 do S.neurons[i] = math.random() * 0.4 end
    end
    for i = 1, 32 do
        if math.random() < rate then
            S.neurons[i] = math.min(1, S.neurons[i] + 0.30 + math.random() * 0.3)
        end
        S.neurons[i] = math.max(0, S.neurons[i] - dt * 0.55)
        if S.neurons[i] > 0.6 then active += 1 end
    end
    return active
end

-- =========================================================
-- LiDAR
-- =========================================================
function lidarClear()
    for i = 1, #S.lidarPoints do
        local p = S.lidarPoints[i]
        if p.active then p.active = false; p.part.Transparency = 1 end
    end
    S.lidarHead = 1
    S.lidarCount = 0
    S.lidarVoxels = {}
    S.lidarVoxelCount = 0
    S.lidarPathVoxels = {}
    S.lidarPathVoxelCount = 0
    for i = 1, #S.bounceActive do
        local b = S.bounceActive[i]
        if b.part then b.part.Transparency = 1 end
    end
    S.bounceActive = {}
end

function lidarInit()
    if not S.lidarFolder then
        local existing = Workspace:FindFirstChild("__GravelCPULidarMap")
        if existing then existing:Destroy() end
        S.lidarFolder = Instance.new("Folder")
        S.lidarFolder.Name = "__GravelCPULidarMap"
        S.lidarFolder.Parent = Workspace
    end
    if not S.lidarBounceFolder then
        local existing = Workspace:FindFirstChild("__GravelCPUBounces")
        if existing then existing:Destroy() end
        S.lidarBounceFolder = Instance.new("Folder")
        S.lidarBounceFolder.Name = "__GravelCPUBounces"
        S.lidarBounceFolder.Parent = Workspace
    end
    if #S.lidarPoints > 0 then return end
    for i = 1, 4000 do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.35, 0.35, 0.35)
        part.Transparency = 1
        part.Color = Color3.fromRGB(0, 200, 255)
        part.Parent = S.lidarFolder
        S.lidarPoints[i] = {part=part, born=0, active=false}
    end
end

function lidarAddPoint(pos, normal, dist, surfaceType)
    if not _config.cpu.lidarEnabled then
        if _config.cpu.lidarNav then markVoxelSolid(pos) end
        return
    end
    lidarInit()
    local col = S.surfaceColors[surfaceType or "wall"] or Color3.fromRGB(0, 200, 255)
    local t = math.clamp(dist / 140, 0, 1)
    col = col:Lerp(Color3.fromRGB(0, 120, 255), t * 0.35)
    local idx = S.lidarHead
    local slot = S.lidarPoints[idx]
    if not slot then return end
    slot.born = os.clock()
    slot.active = true
    local part = slot.part
    part.CFrame = CFrame.new(pos)
    part.Color = col
    part.Transparency = 0.15
    S.lidarHead = (idx % 4000) + 1
    if S.lidarCount < 4000 then S.lidarCount += 1 end
    if _config.cpu.lidarNav then markVoxelSolid(pos) end
end

function lidarSpawnBounce(pos, normal, surfaceType)
    if not _config.cpu.lidarEnabled or not _config.cpu.showBounces then return end
    if S.bounceSpawnTimer > 0 then return end
    S.bounceSpawnTimer = 0.08
    local part
    if S.bouncePoolSize > 0 then
        part = S.bouncePool[S.bouncePoolSize]
        S.bouncePool[S.bouncePoolSize] = nil
        S.bouncePoolSize -= 1
    else
        part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(0.55, 0.55, 0.55)
        part.Parent = S.lidarBounceFolder
    end
    part.CFrame = CFrame.new(pos + (normal and normal * 0.2 or Vector3.zero))
    part.Color = S.surfaceColors[surfaceType or "other"] or Color3.fromRGB(255, 255, 255)
    part.Transparency = 0.05
    table.insert(S.bounceActive, {part=part, born=os.clock()})
end

local function pruneBounces()
    if #S.bounceActive == 0 then return end
    local now = os.clock()
    local i = 1
    while i <= #S.bounceActive do
        local b = S.bounceActive[i]
        if now - b.born >= 6.0 then
            b.part.Transparency = 1
            if S.bouncePoolSize < S.bounceMaxPool then
                S.bouncePoolSize += 1
                S.bouncePool[S.bouncePoolSize] = b.part
            else
                b.part:Destroy()
            end
            table.remove(S.bounceActive, i)
        else
            b.part.Transparency = 0.05 + ((now - b.born) / 6.0) * 0.90
            i += 1
        end
    end
end

function lidarUpdate()
    if not _config.cpu.lidarEnabled then
        pruneBounces()
        return
    end
    local now = os.clock()
    for i = 1, #S.lidarPoints do
        local p = S.lidarPoints[i]
        if p.active then
            local age = now - p.born
            if age >= 12.0 then
                p.active = false
                p.part.Transparency = 1
            else
                p.part.Transparency = 0.15 + (age / 12.0) * 0.85
            end
        end
    end
    pruneBounces()
end

function lidarSweep(root, char)
    if not (_config.cpu.lidarEnabled or _config.cpu.lidarNav) then return end
    if _config.cpu.lidarEnabled then lidarInit() end
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local spinOffset = S.spinAngle
    if _config.cpu.scan3D then
        local rings = 8
        local raysPerRing = 24
        local maxPitch = math.rad(75)
        for r = 0, rings do
            local pitch = -maxPitch + (r / rings) * (maxPitch * 2)
            local cy = math.sin(pitch)
            local ch = math.cos(pitch)
            local ringRays = math.max(6, math.floor(raysPerRing * ch + 4))
            for i = 1, ringRays do
                local angle = spinOffset + ((i - 1) / ringRays) * math.pi * 2
                local dir = Vector3.new(math.sin(angle) * ch, cy, math.cos(angle) * ch)
                local hit = raycastFiltered(origin, dir * 140, params)
                if _config.cpu.lidarNav then
                    local travel = hit and hit.Distance or 140
                    local freeSteps = math.max(1, math.floor(travel / 4))
                    for s = 1, freeSteps do
                        markVoxelFree(origin + dir * (s * 4))
                    end
                end
                if hit then
                    local stype = classifySurface(hit.Instance, hit.Normal)
                    lidarAddPoint(hit.Position, hit.Normal, hit.Distance, stype)
                    if hit.Distance >= 4 then
                        lidarSpawnBounce(hit.Position, hit.Normal, stype)
                    end
                end
            end
        end
    else
        for i = 1, 48 do
            local angle = spinOffset + ((i - 1) / 48) * math.pi * 2
            local dir = Vector3.new(math.sin(angle), 0, math.cos(angle))
            local hit = raycastFiltered(origin, dir * 140, params)
            if _config.cpu.lidarNav then
                local travel = hit and hit.Distance or 140
                local freeSteps = math.max(1, math.floor(travel / 4))
                for s = 1, freeSteps do
                    markVoxelFree(origin + dir * (s * 4))
                end
            end
            if hit then
                local stype = classifySurface(hit.Instance, hit.Normal)
                lidarAddPoint(hit.Position, hit.Normal, hit.Distance, stype)
                if hit.Distance >= 4 then
                    lidarSpawnBounce(hit.Position, hit.Normal, stype)
                end
            end
        end
    end
end

function lidarMarkFreeAround(pos)
    if not _config.cpu.lidarNav then return end
    local r = 3.0
    local s = 4.0
    local steps = math.max(1, math.floor(r / s))
    for dx = -steps, steps do
        for dz = -steps, steps do
            markVoxelFree(Vector3.new(pos.X + dx * s, pos.Y, pos.Z + dz * s))
        end
    end
end

function detectDoorwayFromLidar(origin, forwardDir)
    if not _config.cpu.lidarNav then return nil end
    if S.lidarVoxelCount < 12 then return nil end
    local flat = Vector3.new(forwardDir.X, 0, forwardDir.Z)
    if flat.Magnitude < 0.001 then return nil end
    flat = flat.Unit
    local halfAngle = math.rad(80)
    local scanDist = 20
    local heightSlices = {-2, 0, 2, 4, 6}
    local candidates = {}
    for i = 1, 24 do
        local a = -halfAngle + ((i - 1) / 23) * (halfAngle * 2)
        local baseYaw = math.atan2(flat.X, flat.Z)
        local ang = baseYaw + a
        local dir = Vector3.new(math.sin(ang), 0, math.cos(ang))
        local wallHits, openHits = 0, 0
        for _, yOff in ipairs(heightSlices) do
            for d = 1, scanDist do
                local p = origin + dir * d + Vector3.new(0, yOff, 0)
                local occ = queryVoxel(p)
                if occ >= 0.55 then wallHits += 1
                elseif occ >= 0 then openHits += 1 end
            end
        end
        if openHits > 0 and wallHits > 0 then
            local score = openHits / math.max(1, wallHits)
            if score > 0.3 then
                candidates[#candidates + 1] = {dir=dir, score=score}
            end
        end
    end
    if #candidates == 0 then return nil end
    local best = candidates[1]
    for _, c in ipairs(candidates) do
        if c.score > best.score then best = c end
    end
    local align = best.dir:Dot(flat)
    if align < 0.2 then return nil end
    return {dir=best.dir, score=best.score, width=3, depth=10, method="voxel"}
end

-- =========================================================
-- Ray visualization
-- =========================================================
function vizRay(origin, hitPos, color)
    if not _config.cpu.showRays then return end
    local seg = hitPos - origin
    local len = seg.Magnitude
    if len < 0.01 then return end
    local part
    if S.rayPoolSize > 0 then
        part = S.rayPool[S.rayPoolSize]
        S.rayPool[S.rayPoolSize] = nil
        S.rayPoolSize -= 1
    else
        if not S.rayFolder then
            local existing = Workspace:FindFirstChild("__GravelCPURays")
            if existing then existing:Destroy() end
            S.rayFolder = Instance.new("Folder")
            S.rayFolder.Name = "__GravelCPURays"
            S.rayFolder.Parent = Workspace
        end
        part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Parent = S.rayFolder
    end
    part.Color = color or Color3.fromRGB(0, 200, 255)
    part.Size = Vector3.new(0.05, 0.05, len)
    part.CFrame = CFrame.new(origin + seg * 0.5, hitPos)
    part.Transparency = 0.35
    table.insert(S.rayActive, {part=part, born=os.clock()})
end

function pruneRayViz()
    if #S.rayActive == 0 then return end
    local now = os.clock()
    local i = 1
    while i <= #S.rayActive do
        local e = S.rayActive[i]
        if now - e.born >= 0.25 then
            e.part.Transparency = 1
            if S.rayPoolSize < S.rayMaxPool then
                S.rayPoolSize += 1
                S.rayPool[S.rayPoolSize] = e.part
            else
                e.part:Destroy()
            end
            table.remove(S.rayActive, i)
        else
            e.part.Transparency = 0.35 + ((now - e.born) / 0.25) * 0.65
            i += 1
        end
    end
end

function clearRayViz()
    for _, e in ipairs(S.rayActive) do
        if e.part then e.part:Destroy() end
    end
    S.rayActive = {}
    for _, p in ipairs(S.rayPool) do p:Destroy() end
    S.rayPool = {}
    S.rayPoolSize = 0
end

-- =========================================================
-- Probe / sweeps
-- =========================================================
function bounceRay(origin, dir, params)
    local pos = origin
    local d = dir.Unit
    local travelled = 0
    local bounces = 0
    local novelty = 0
    for _ = 1, 24 do
        local remaining = 140 - travelled
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
            local n = math.max(1, math.floor(len / 5.25))
            for i = 1, n do
                local p = pos + seg * (i / n)
                local key = cellKey(p.X, p.Z)
                novelty += (1 - (S.memory[key] or 0))
            end
        end
        if _config.cpu.showRays then
            vizRay(pos, segEnd, escaped and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(0, 200, 255))
        end
        if escaped then
            return {escaped=true, distance=travelled+remaining, bounces=bounces, finalPos=segEnd, endDir=d, novelty=novelty}
        end
        travelled += len
        bounces += 1
        local n = hit.Normal
        d = d - 2 * d:Dot(n) * n
        if d.Magnitude < 0.001 then d = -n end
        d = d.Unit
        pos = hit.Position + d * 0.15
    end
    return {escaped=false, distance=travelled, bounces=bounces, finalPos=pos, endDir=d, novelty=novelty}
end

function scoreGoalDirection(origin, dir, probeRes)
    if not S.goalTargetPos then return 0 end
    local toGoal = S.goalTargetPos - origin
    local goalDist = toGoal.Magnitude
    local flatGoal = Vector3.new(toGoal.X, 0, toGoal.Z)
    if flatGoal.Magnitude < 0.5 then return 4 * 3 * 4 end
    flatGoal = flatGoal.Unit
    local flatDir = Vector3.new(dir.X, 0, dir.Z)
    if flatDir.Magnitude < 0.001 then return 0 end
    flatDir = flatDir.Unit
    local align = flatDir:Dot(flatGoal)
    if align <= 0 then return 0 end
    local proximity = math.clamp(1 - goalDist / 120, 0.35, 1.0)
    local pathQuality = 1
    if probeRes and probeRes.distance then
        local pd = math.clamp(probeRes.distance / 140, 0, 1)
        pathQuality = 0.3 + 0.7 * pd
    end
    local raw = align * proximity * pathQuality * 1.2 * 0.9 * 4
    if align > 0.85 and pathQuality > 0.6 then
        raw = raw + 1.2 * 4 * 0.5
    end
    if align > 0.35 and raw < 0.6 then raw = 0.6 end
    return raw
end

function scoreBlacklistPenalty(origin, dir, distance)
    if next(S.blacklistInstances) == nil then return 0 end
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.001 then return 0 end
    flat = flat.Unit
    local maxCheck = math.min(distance or 20, 30)
    local penalty = 0
    local d = 3
    while d <= maxCheck do
        local p = origin + flat * d
        for inst in pairs(S.blacklistInstances) do
            if inst and inst.Parent then
                local ok, dist = pcall(function() return (inst.Position - p).Magnitude end)
                if ok and dist and dist < 8 then
                    penalty = penalty + (1 - dist / 8) * 3 * 0.25
                end
            end
        end
        d = d + 3
    end
    return math.min(penalty, 3)
end

function scoreProbe(res, noveltyScore, dir, prevDir, trailPenalty, fallCoverage, lidarScore, doorwayScore, goalScore, blacklistPenalty, pathPenalty)
    local distScore = math.clamp(res.distance / 140, 0, 1)
    local bouncePenalty = res.bounces / 24
    local escapeBonus = res.escaped and 0.30 or 0
    local momentum = 0
    if prevDir then
        momentum = dir:Dot(prevDir) * 0.45 * (1 - S.forceExploration * 0.5)
    end
    local novelty = noveltyScore * _config.cpu.noveltyWeight * (1 + S.forceExploration * 1.5)
    local base = distScore * 0.50 + escapeBonus - bouncePenalty * 0.25 + momentum + novelty - trailPenalty
    if _config.cpu.avoidFalls and fallCoverage then
        base = base - (1 - fallCoverage) * 2.5
    end
    if lidarScore then base = base + lidarScore end
    if doorwayScore and doorwayScore > 0 then base = base + doorwayScore * 0.70 end
    if pathPenalty and pathPenalty > 0 then base = base - pathPenalty end
    if goalScore and goalScore > 0 then base = base + goalScore end
    if blacklistPenalty and blacklistPenalty > 0 then base = base - blacklistPenalty end
    return base
end

function sweepProbes(root, char, hum)
    local params = makeRayParams(char)
    local origin = root.Position + Vector3.new(0, 1.5, 0)
    local look = root.CFrame.LookVector
    local baseYaw = math.atan2(look.X, look.Z)
    local emitYaw = baseYaw + S.spinAngle
    local probeCount = _config.cpu.probeCount
    local prevDir = S.bestDir
    local best = {score=-math.huge, dir=nil, dist=0, bounces=0, novelty=0, escaped=false}
    local totalBounces, totalNovelty = 0, 0
    local jitter = 0.04 + (S.neuronCount / 32) * 0.10 + S.forceExploration * 0.22
    -- Reset sweep directions
    local dirs = {}
    for i = 1, probeCount do
        local angle = emitYaw + ((i - 1) / probeCount) * math.pi * 2
        dirs[#dirs + 1] = Vector3.new(math.sin(angle), 0, math.cos(angle))
    end
    local maxPitch = math.rad(45)
    for r = 1, 3 do
        local pitch = (r / 3) * maxPitch
        local ringCount = math.max(6, math.floor(probeCount * math.cos(pitch)))
        for sign = -1, 1, 2 do
            local p = pitch * sign
            local cy = math.sin(p)
            local ch = math.cos(p)
            for i = 1, ringCount do
                local angle = emitYaw + ((i - 1) / ringCount) * math.pi * 2
                dirs[#dirs + 1] = Vector3.new(math.sin(angle) * ch, cy, math.cos(angle) * ch)
            end
        end
    end
    dirs[#dirs + 1] = Vector3.new(0, 1, 0)
    dirs[#dirs + 1] = Vector3.new(0, -1, 0)

    local doorwayInfo = nil
    if S.sweepCount % 2 == 0 then
        local fwd = Vector3.new(math.sin(baseYaw), 0, math.cos(baseYaw))
        doorwayInfo = detectDoorwayFromLidar(origin, fwd)
        if doorwayInfo then
            S.doorwayDir = doorwayInfo.dir
            S.doorwayTimer = 0.85
            S.doorwayWidth = doorwayInfo.width or 0
            S.doorwayCount += 1
        end
    end

    local fallParams = _config.cpu.avoidFalls and makeFloorRayParams(char) or nil
    local totalProbes = #dirs
    for i = 1, totalProbes do
        local dir = dirs[i]
        local flatDir = Vector3.new(dir.X, 0, dir.Z)
        if flatDir.Magnitude > 0.001 then flatDir = flatDir.Unit end
        local res = bounceRay(origin, dir, params)
        local noveltyScore = math.clamp(res.novelty / 18, 0, 1)
        local tp = flatDir.Magnitude > 0.001 and trailPenaltyAt(origin + flatDir * math.min(res.distance, 12)) or 0
        local fallCoverage = 1
        if _config.cpu.avoidFalls and flatDir.Magnitude > 0.001 then
            fallCoverage = floorCoverageAlong(root.Position, flatDir, fallParams)
        end
        local lidarScore = 0
        if _config.cpu.lidarNav and flatDir.Magnitude > 0.001 then
            lidarScore = scoreDirectionFromVoxels(origin, dir)
        end
        local doorwayScore = 0
        if doorwayInfo and flatDir.Magnitude > 0.001 then
            local align = flatDir:Dot(doorwayInfo.dir)
            if align > 0 then doorwayScore = align * doorwayInfo.score end
        end
        local goalScore = scoreGoalDirection(origin, dir, res)
        local blacklistPenalty = scoreBlacklistPenalty(origin, dir, res.distance)
        local pathPenalty = 0
        if _config.cpu.pathMemory and flatDir.Magnitude > 0.001 then
            pathPenalty = pathMemoryPenalty(origin, dir, res.distance)
        end
        local score = scoreProbe(res, noveltyScore, dir, prevDir, tp, fallCoverage, lidarScore, doorwayScore, goalScore, blacklistPenalty, pathPenalty)
        score = score + (math.random() - 0.5) * jitter
        totalBounces += res.bounces
        totalNovelty += noveltyScore
        if score > best.score then
            best.score = score; best.dir = dir; best.dist = res.distance
            best.bounces = res.bounces; best.novelty = noveltyScore
            best.escaped = res.escaped
        end
    end
    S.avgBounces = totalBounces / totalProbes
    S.avgNovelty = totalNovelty / totalProbes
    _config.cpu._runtime.bestDist = best.dist
    _config.cpu._runtime.bestBounces = best.bounces

    local wantEntrance = best.dist < 16 or S.forceExploration > 0.4
    if wantEntrance and best.dir then
        local flat = Vector3.new(best.dir.X, 0, best.dir.Z)
        if flat.Magnitude > 0.05 then
            flat = flat.Unit
            local eDir, eSide, eWidth = predictEntrance(root, char, flat)
            if eDir and eWidth >= 7 then
                local combined = flat * 0.15 + eDir * 0.85
                if combined.Magnitude > 0.05 then
                    combined = combined.Unit
                    best.dir = Vector3.new(combined.X, best.dir.Y, combined.Z)
                    S.entranceDir = eDir
                    S.entranceSide = eSide
                    S.entranceTimer = 0.6
                end
            end
        end
    end

    -- Commitment
    local newDir = best.dir
    if newDir then
        if not S.committedDir then
            S.committedDir = newDir
            S.commitTimer = _config.cpu.commitTime
        else
            local dot = S.committedDir:Dot(newDir)
            if dot >= 0.55 then
                local blended = S.committedDir * 0.45 + newDir * 0.55
                if blended.Magnitude > 0.05 then S.committedDir = blended.Unit end
                S.commitTimer = _config.cpu.commitTime
                S.pendingDir = nil
                S.pendingTimer = 0
            elseif dot <= -0.35 then
                if S.pendingDir and S.pendingDir:Dot(newDir) > 0.7 then
                    S.pendingTimer += _config.cpu.sweepInterval
                else
                    S.pendingDir = newDir
                    S.pendingTimer = 0
                end
                if S.pendingTimer >= 0.18 then
                    S.committedDir = newDir
                    S.commitTimer = _config.cpu.commitTime
                    S.pendingDir = nil
                    S.pendingTimer = 0
                end
            else
                S.commitTimer -= _config.cpu.sweepInterval
                if S.commitTimer <= 0 then
                    local blended = S.committedDir * 0.45 + newDir * 0.55
                    if blended.Magnitude > 0.05 then
                        S.committedDir = blended.Unit
                    else
                        S.committedDir = newDir
                    end
                    S.commitTimer = _config.cpu.commitTime
                end
                S.pendingDir = nil
                S.pendingTimer = 0
            end
        end
        S.bestDir = S.committedDir
    end
end

-- =========================================================
-- TARGETING (delegates to Gravel's systems)
-- =========================================================
-- Use Gravel's getAllTargets via _api, apply config.cpu filters
local function cpuFindTarget()
    local myRoot = getPlayer().Character and getPlayer().Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local all
    if _api.getAllTargets then
        local ok, res = pcall(_api.getAllTargets)
        if ok and type(res) == "table" then
            all = res
        end
    end
    if not all then return nil end
    local rt = _config.cpu._runtime
    local now = tick()
    if now - S.lastTargetSwitch < 0.1 then
        -- Hold target for a bit to avoid flip-flopping
        local held = rt.currentTarget
        if held then
            local char = _api.getTargetCharacter and _api.getTargetCharacter(held)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist <= _config.cpu.targetRange then
                    return {target=held, char=char, hum=hum, root=root, dist=dist}
                end
            end
        end
    end
    -- Apply filters
    local candidates = {}
    for _, t in ipairs(all) do
        if t ~= getPlayer() then
            local char = _api.getTargetCharacter and _api.getTargetCharacter(t)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local isPlyr = typeof(t) == "Instance" and t:IsA("Player")
                    local isModel = typeof(t) == "Instance" and t:IsA("Model")
                    local shouldConsider = false
                    -- Target type (from config.cpu via masterTarget)
                    local masterTarget = _config.masterTarget or "Players"
                    if masterTarget == "Both" then shouldConsider = true
                    elseif masterTarget == "Players" and isPlyr then shouldConsider = true
                    elseif masterTarget == "NPCs" and isModel then shouldConsider = true end
                    -- Team filter
                    if shouldConsider then
                        if _config.specificTeamTarget and #(_config.targetedTeams or {}) > 0 then
                            if _api.isInSpecificTeam and not _api.isInSpecificTeam(t) then
                                shouldConsider = false
                            end
                        else
                            local teamTarget = _config.masterTeamTarget or "Enemies"
                            if teamTarget == "Enemies" and _api.isTeammate and isPlyr and _api.isTeammate(t) then
                                shouldConsider = false
                            elseif teamTarget == "Teams" and _api.isTeammate and isPlyr and not _api.isTeammate(t) then
                                shouldConsider = false
                            end
                        end
                    end
                    -- Forcefield
                    if shouldConsider and _config.ignoreForcefield and _api.hasForcefield then
                        if _api.hasForcefield(char) then shouldConsider = false end
                    end
                    -- Range
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if shouldConsider and dist <= _config.cpu.targetRange then
                        -- Wall check
                        if _config.cpu.wallCheck and _api.wallCheck then
                            local targetPos = root.Position
                            local sourcePos = myRoot.Position
                            local ok, visible = pcall(_api.wallCheck, targetPos, sourcePos)
                            if ok and not visible then shouldConsider = false end
                        end
                    else
                        shouldConsider = false
                    end
                    if shouldConsider then
                        local targetPartName = _config.cpu.targetPart or "Head"
                        local targetPart
                        if targetPartName == "Random" then
                            targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                        else
                            targetPart = char:FindFirstChild(targetPartName) or char:FindFirstChild("Head")
                        end
                        if targetPart then
                            table.insert(candidates, {
                                target = t, char = char, hum = hum, root = root,
                                part = targetPart, dist = dist,
                            })
                        end
                    end
                end
            end
        end
    end
    if #candidates == 0 then
        rt.currentTarget = nil
        return nil
    end
    -- Sort by masterGetTarget
    local mode = _config.masterGetTarget or "Closest"
    if mode == "Lowest Health" then
        table.sort(candidates, function(a, b) return a.hum.Health < b.hum.Health end)
    else
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
    end
    local chosen = candidates[1]
    rt.currentTarget = chosen.target
    S.lastTargetSwitch = now
    return chosen
end

-- =========================================================
-- COMBAT
-- =========================================================
local function cpuGetTool(mode)
    local char = getPlayer().Character
    if not char then return nil end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    local backpack = getPlayer():FindFirstChild("Backpack")
    if not backpack then return nil end
    local fallback = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if mode == "Melee" then
                if name:find("sword") or name:find("knife") or name:find("bat")
                   or name:find("melee") or name:find("blade") or name:find("axe")
                   or name:find("pickaxe") or name:find("crowbar") or name:find("scythe")
                   or name:find("hammer") or name:find("spear") then
                    return tool
                end
            else
                if name:find("gun") or name:find("pistol") or name:find("rifle")
                   or name:find("shotgun") or name:find("smg") or name:find("sniper")
                   or name:find("bow") or name:find("blaster") or name:find("launcher") then
                    return tool
                end
            end
            fallback = fallback or tool
        end
    end
    return fallback
end

local function cpuPredictPosition(root, velocity, prediction)
    if not root then return Vector3.zero end
    local predTime = math.clamp(prediction or 0, 0, 0.5)
    return root.Position + (velocity or Vector3.zero) * predTime
end

local function cpuAimAt(targetPos)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local currentCF = cam.CFrame
    local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
    local smoothing = math.clamp(_config.cpu.aimSmoothing or 0.3, 0.05, 1)
    local lerped = currentCF:Lerp(targetCF, 1 - smoothing)
    local jitter = _config.cpu.jitterAmount or 0
    if jitter > 0 then
        local jx = (math.random() - 0.5) * jitter * 0.01
        local jy = (math.random() - 0.5) * jitter * 0.01
        lerped = lerped * CFrame.Angles(jy, jx, 0)
    end
    cam.CFrame = lerped
end

local function runCombatGun(targetData, dt)
    local lp = getPlayer()
    if not lp.Character then return end
    local myRoot = lp.Character:FindFirstChild("HumanoidRootPart")
    local myHum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then return end
    S.myRoot = myRoot
    S.myHumanoid = myHum

    -- Orbit direction
    local dirOpt = _config.cpu.orbitDirection or "Random"
    if dirOpt == "Clockwise" then S.orbitDir = 1
    elseif dirOpt == "CounterClockwise" then S.orbitDir = -1
    else
        if not S.orbitDir or S.orbitDir == 0 then
            S.orbitDir = (math.random() < 0.5) and 1 or -1
        end
        if math.random() < 0.005 then S.orbitDir = S.orbitDir * -1 end
    end

    S.orbitAngle += (_config.cpu.orbitSpeed or 1.0) * dt * 1.5 * S.orbitDir
    if S.orbitAngle > math.pi * 2 then S.orbitAngle -= math.pi * 2 end

    local targetRoot = targetData.root
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity

    local aimPos = cpuPredictPosition(targetRoot, targetVel, _config.cpu.prediction)
    cpuAimAt(aimPos)

    local radius = _config.cpu.orbitRadius or 15
    local orbitOffset = Vector3.new(math.cos(S.orbitAngle) * radius, 0, math.sin(S.orbitAngle) * radius)
    local desiredPos = targetPos + orbitOffset

    -- Face target while moving
    local lookDir = targetPos - myRoot.Position
    local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
    if flatLook.Magnitude > 0.01 then
        myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + flatLook)
    end

    myHum:MoveTo(desiredPos)

    -- BHop
    if _config.cpu.bhopEnabled then
        local now = tick()
        if now - S.lastJump >= (_config.cpu.bhopDelay or 0.05) then
            if myHum.FloorMaterial ~= Enum.Material.Air then
                myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                S.lastJump = now
            end
        end
    end

    -- Ensure gun is equipped (TriggerBot handles firing)
    local tool = cpuGetTool("Gun")
    if tool and tool.Parent ~= lp.Character and myHum then
        pcall(function() myHum:EquipTool(tool) end)
    end
end

local function runCombatMelee(targetData, dt)
    local lp = getPlayer()
    if not lp.Character then return end
    local myRoot = lp.Character:FindFirstChild("HumanoidRootPart")
    local myHum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum then return end
    S.myRoot = myRoot
    S.myHumanoid = myHum

    local targetRoot = targetData.root
    local targetChar = targetData.char
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity
    local dist = (myRoot.Position - targetPos).Magnitude

    local aimPos = cpuPredictPosition(targetRoot, targetVel, _config.cpu.prediction)
    cpuAimAt(aimPos)

    -- Dodge
    local dodgeDir = Vector3.zero
    local targetTool = targetChar:FindFirstChildOfClass("Tool")
    S.enemyToolActive = targetTool ~= nil
    if _config.cpu.dodgeEnabled then
        -- Detect whether target is swinging (animation) — approximate via tool present
        if targetTool then
            local targetLook = targetRoot.CFrame.LookVector
            local flatLook = Vector3.new(targetLook.X, 0, targetLook.Z)
            if flatLook.Magnitude > 0.01 then
                flatLook = flatLook.Unit
                local perp = Vector3.new(-flatLook.Z, 0, flatLook.X)
                -- Strafe flip
                local now = tick()
                if now - S.lastStrafe >= (_config.cpu.strafeDelay or 0.4) then
                    if _config.cpu.strafeEnabled then
                        S.strafeDir = (math.random() < 0.5) and 1 or -1
                    else
                        S.strafeDir = 1
                    end
                    S.lastStrafe = now
                end
                dodgeDir = perp * S.strafeDir * (_config.cpu.dodgeStrength or 0.7)
            end
        end
    end

    -- Movement
    local moveVec = Vector3.zero
    if dist > _config.cpu.meleeRange then
        local toTarget = (targetPos - myRoot.Position)
        local flatToTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
        if flatToTarget.Magnitude > 0.01 then
            flatToTarget = flatToTarget.Unit
            moveVec = flatToTarget * 0.7 + dodgeDir * 0.3
        end
    elseif dodgeDir.Magnitude > 0.01 then
        moveVec = dodgeDir
    end
    if moveVec.Magnitude > 0.01 then
        local moveTarget = myRoot.Position + moveVec.Unit * 10
        myHum:MoveTo(moveTarget)
    else
        myHum:MoveTo(myRoot.Position)
    end

    -- Face target
    local lookDir = targetPos - myRoot.Position
    local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
    if flatLook.Magnitude > 0.01 then
        myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + flatLook)
    end

    -- Equip melee
    local tool = cpuGetTool("Melee")
    if tool and tool.Parent ~= lp.Character and myHum then
        pcall(function() myHum:EquipTool(tool) end)
    end

    -- Auto swing
    if _config.cpu.autoSwing and tool and tool:IsA("Tool") and tool.Parent == lp.Character then
        local now = tick()
        if now - S.lastSwing >= (_config.cpu.autoSwingDelay or 0.15) then
            if dist <= _config.cpu.meleeRange then
                pcall(function() tool:Activate() end)
                S.lastSwing = now
            end
        end
    end

    -- BHop while dodging
    if _config.cpu.bhopEnabled and _config.cpu.dodgeEnabled then
        local now = tick()
        if now - S.lastJump >= (_config.cpu.bhopDelay or 0.05) then
            if myHum.FloorMaterial ~= Enum.Material.Air then
                myHum:ChangeState(Enum.HumanoidStateType.Jumping)
                S.lastJump = now
            end
        end
    end
end

-- =========================================================
-- NAVIGATION (fallback when no target)
-- =========================================================
local function runNavigator(root, hum, char, dt)
    _config.cpu._runtime.navState = "RUNNING"
    local now = os.clock()
    scanBlacklist(now)
    scanGoals(now, root.Position)
    markVisited(root.Position)
    pushTrail(root.Position)
    if _config.cpu.pathMemory then
        markPathVoxel(root.Position, 1.0)
        markPathAround(root.Position, 2.0)
    end

    S.sweepCount += 1
    S.spinAngle = (S.spinAngle + (3.0 * dt * math.pi * 2)) % (math.pi * 2)

    S.forceExploration = math.max(0, S.forceExploration - dt * 1.2)
    S.neuronCount = tickNeurons(dt, S.avgNovelty or 0)
    _config.cpu._runtime.neuronCount = S.neuronCount
    _config.cpu._runtime.voxelCount = S.lidarVoxelCount
    _config.cpu._runtime.doorwayCount = S.doorwayCount

    if S.entranceTimer > 0 then S.entranceTimer -= dt end
    if S.wallLockTimer > 0 then S.wallLockTimer -= dt; if S.wallLockTimer <= 0 then S.wallLockDir = nil end end
    if S.fallBrake > 0 then S.fallBrake -= dt end
    if S.jumpCooldownTimer > 0 then S.jumpCooldownTimer -= dt end
    if S.trussClimbTimer > 0 then S.trussClimbTimer -= dt; if S.trussClimbTimer <= 0 then S.trussClimbing = false end end
    if S.trussJumpTimer > 0 then S.trussJumpTimer -= dt end
    if S.pendingGapTimer > 0 then S.pendingGapTimer -= dt; if S.pendingGapTimer <= 0 then S.pendingGapJump = false end end
    if S.doorwayTimer > 0 then S.doorwayTimer -= dt; if S.doorwayTimer <= 0 then S.doorwayDir = nil end end

    updateStuckRecovery(root, hum, char, dt)

    local dirForCheck = S.bestDir or S.committedDir or root.CFrame.LookVector
    local coverage, gapInfo = checkFallAndGapAhead(root, hum and char or nil, hum, dirForCheck)
    S.lastGap = gapInfo

    if S.gapLockTimer > 0 then
        S.gapLockTimer -= dt
        if S.gapLockTimer <= 0 then
            S.gapLockDir = nil
            S.pendingGapJump = false
            S.gapJumpFired = false
        end
    end

    local gapJumpable = _config.cpu.jumpEnabled and gapInfo.active and gapInfo.canJump and gapInfo.dir ~= nil
    if gapJumpable then
        if not S.gapLockDir then
            S.gapLockDir = gapInfo.dir
            S.gapJumpFired = false
        end
        S.gapLockTimer = 0.70
        S.pendingGapJump = not S.gapJumpFired
        S.pendingGapTimer = 0.70
        S.committedDir = S.gapLockDir
        S.bestDir = S.gapLockDir
        S.wallLockDir = nil
        S.wallLockTimer = 0
        S.fallDetected = false
        S.fallBrake = 0
    elseif _config.cpu.avoidFalls then
        if not (S.gapLockDir and S.gapLockTimer > 0) then
            if coverage < 0.4 then
                S.fallDetected = true
                S.fallWarnCount += 1
                _config.cpu._runtime.fallWarnCount = S.fallWarnCount
                S.forceExploration = math.min(1, S.forceExploration + 0.4)
                S.commitTimer = 0
                S.sweepTimer = 0
                local safe = findFallSafeDirection(root, char, hum, dirForCheck)
                if safe then
                    S.committedDir = safe
                    S.bestDir = safe
                else
                    S.fallBrake = 3.0
                    S.bestDir = nil
                    S.committedDir = nil
                end
            else
                S.fallDetected = false
            end
        end
    end

    -- Stuck detection
    if not (S.gapLockDir and S.gapLockTimer > 0) then
        S.stuckTimer += dt
        if S.stuckTimer >= 0.5 then
            if S.stuckAnchor then
                local moved = (root.Position - S.stuckAnchor).Magnitude
                if moved < 2.0 then
                    S.stuckLevel = math.min(S.stuckLevel + 1, 8)
                    S.forceExploration = math.min(1, S.forceExploration + 0.35)
                    S.sweepTimer = 0
                    if S.stuckLevel >= 2 then
                        local _, wallN, _, _, wallTruss = checkWallAhead(root, char, S.bestDir or root.CFrame.LookVector, 12)
                        if wallN and not wallTruss then
                            S.wallLockDir = computeWallFollowDir(wallN, S.entranceSide)
                            S.wallLockTimer = 2.5
                        elseif wallTruss then
                            S.stuckLevel = math.max(0, S.stuckLevel - 1)
                            S.forceExploration = math.min(1, S.forceExploration + 0.15)
                        end
                    end
                else
                    S.stuckLevel = math.max(0, S.stuckLevel - 1)
                    if S.stuckLevel == 0 then S.wallLockDir = nil end
                end
            end
            S.stuckAnchor = root.Position
            S.stuckTimer = 0
        end
    end

    S.sweepTimer -= dt
    if S.sweepTimer <= 0 then
        S.sweepTimer = _config.cpu.sweepInterval
        local wasLocked = S.gapLockDir ~= nil and S.gapLockTimer > 0
        sweepProbes(root, char, hum)
        if _config.cpu.lidarEnabled or _config.cpu.lidarNav then
            if S.sweepCount % 2 == 0 then
                lidarSweep(root, char)
                lidarMarkFreeAround(root.Position)
                S.lidarDecayAccum += 1
                if S.lidarDecayAccum >= 10 then
                    S.lidarDecayAccum = 0
                    decayVoxels()
                end
            end
        end
        S.decayAccum += 1
        if S.decayAccum >= 5 then
            S.decayAccum = 0
            decayMemory(0.985)
        end
        if wasLocked then
            S.sweepPreferredDir = S.bestDir
            S.bestDir = S.gapLockDir
            S.committedDir = S.gapLockDir
        end
    end

    if _config.cpu.jumpEnabled and S.fallBrake <= 0 then
        local jumpDir = S.gapLockDir or S.bestDir or S.committedDir or root.CFrame.LookVector
        if tryJump(root, hum, char, jumpDir) then
            S.jumpCooldownTimer = 0.30
            S.pendingDir = nil
            S.pendingTimer = 0
        end
    end

    if S.airborne then
        airControlTick(root, hum, char, dt)
    end

    if S.bestDir and S.fallBrake <= 0 then
        S.sinePhase += dt * 4.5 * (1 + S.forceExploration * 0.8)
        if S.wallLockDir and not (S.gapLockDir and S.gapLockTimer > 0) then
            S.bestDir = S.wallLockDir
            S.committedDir = S.wallLockDir
        end
        local hitDist, wallNormal, _, _, wallIsTruss = nil, nil, nil, nil, false
        hitDist, wallNormal, _, _, wallIsTruss = checkWallAhead(root, char, S.bestDir, 12)
        S.wallIsTruss = wallIsTruss
        local wallIsJumpable = false
        if _config.cpu.jumpEnabled and hitDist and wallNormal and not wallIsTruss then
            wallIsJumpable = analyzeWallForJump(root, hum and char or nil, hum, S.bestDir)
        end
        S.wallJumpable = wallIsJumpable
        local trussActive = false
        if wallIsTruss and _config.cpu.trussEnabled then
            trussActive = tryClimbTruss(root, hum, char, S.bestDir)
        end
        if trussActive or wallIsTruss then
            S.wallLockDir = nil
            S.wallLockTimer = 0
        elseif hitDist and wallNormal and not wallIsJumpable then
            local into = S.bestDir:Dot(wallNormal)
            if into < 0 then
                local slide = S.bestDir - wallNormal * into
                if slide.Magnitude > 0.05 then
                    S.bestDir = slide.Unit
                else
                    S.bestDir = computeWallFollowDir(wallNormal, S.entranceSide)
                end
                S.committedDir = S.bestDir
            end
            if hitDist < 5 then S.sweepTimer = math.min(S.sweepTimer, 0.02) end
        elseif wallIsJumpable then
            if hitDist and hitDist < 5 then S.sweepTimer = math.min(S.sweepTimer, 0.02) end
        end

        local ampScale = 1
        if S.forceExploration > 0.5 then ampScale = 0.5 end
        if trussActive or wallIsTruss then ampScale = ampScale * 0.15 end
        if S.pendingGapJump then ampScale = ampScale * 0.15 end
        if wallIsJumpable then ampScale = ampScale * 0.20 end

        local moveDir = S.bestDir
        if moveDir.Magnitude < 0.001 then moveDir = root.CFrame.LookVector end
        moveDir = moveDir.Unit
        local perp = Vector3.new(-moveDir.Z, 0, moveDir.X)
        if perp.Magnitude > 0.001 then perp = perp.Unit end
        local sway = math.sin(S.sinePhase) * 2.6 * ampScale
        local forward = Vector3.new(moveDir.X * 10, math.clamp(moveDir.Y * 10, -6, 6), moveDir.Z * 10)
        local target = root.Position + forward + perp * sway

        if _config.cpu.avoidFalls and not wallIsJumpable and not S.pendingGapJump then
            local fParams = makeFloorRayParams(char)
            if not hasSolidBelow(target, 25, fParams) then
                local pulled = target
                for _ = 1, 4 do
                    pulled = (pulled + root.Position) * 0.5
                    if hasSolidBelow(pulled, 25, fParams) then break end
                end
                target = pulled
                S.fallBrake = math.max(S.fallBrake, 0.4)
            end
        end
        S.currentTarget = target
        S.lastMoveToCadence += dt
        if S.lastMoveToCadence >= 0.08 then
            S.lastMoveToCadence = 0
            hum:MoveTo(target)
        end
        -- Kick if too slow
        if not S.airborne and not S.recoveryActive and not S.pendingGapJump and not trussActive and not wallIsTruss and hum.FloorMaterial ~= Enum.Material.Air then
            local rootPart = hum.RootPart
            if rootPart then
                local vel = rootPart.AssemblyLinearVelocity
                local horiz = math.sqrt(vel.X * vel.X + vel.Z * vel.Z)
                local wantSpeed = math.max(hum.WalkSpeed * 0.5, 6)
                if horiz < wantSpeed then
                    if (now - S.lastKickTime) > 0.15 then
                        S.lastKickTime = now
                        local push = Vector3.new(moveDir.X, 0, moveDir.Z)
                        if push.Magnitude > 0.001 then
                            push = push.Unit * math.max(hum.WalkSpeed, 16)
                            rootPart.AssemblyLinearVelocity = Vector3.new(push.X, vel.Y, push.Z)
                        end
                    end
                end
            end
        end
    elseif S.fallBrake > 0 then
        hum:MoveTo(root.Position)
    end
    _config.cpu._runtime.state = "NAVIGATING"
end

-- =========================================================
-- HEARTBEAT
-- =========================================================
local function heartbeat(dt)
    if not S.running then return end
    if not _config.cpu.enabled then
        _config.cpu._runtime.state = "IDLE"
        return
    end
    local root, hum, char = getRootAndHumanoid()
    if not root or not hum then
        _config.cpu._runtime.state = "NO_CHARACTER"
        return
    end
    _config.cpu._runtime.uptime = os.clock() - S.initTime
    _config.cpu._runtime.ticks = (_config.cpu._runtime.ticks or 0) + 1
    getJumpCapabilities(hum)
    sampleAirborne(root, hum)
    lidarUpdate()
    if S.bounceSpawnTimer > 0 then S.bounceSpawnTimer -= dt end

    local targetData = cpuFindTarget()
    if targetData then
        _config.cpu._runtime.state = "COMBAT_" .. (_config.cpu.mode or "Gun")
        _config.cpu._runtime.lastTargetPos = targetData.root.Position
        _config.cpu._runtime.targetVelocity = targetData.root.Velocity
        if _config.cpu.mode == "Melee" then
            runCombatMelee(targetData, dt)
        else
            runCombatGun(targetData, dt)
        end
    else
        _config.cpu._runtime.currentTarget = nil
        runNavigator(root, hum, char, dt)
    end

    -- Decay path memory periodically
    S.pathMemoryDecayAccum += dt
    if S.pathMemoryDecayAccum >= 0.5 then
        S.pathMemoryDecayAccum = 0
        decayPathMemory()
    end
    pruneRayViz()
end

-- =========================================================
-- PUBLIC API
-- =========================================================
function M.init(config, api)
    _config = config
    _api = api
    Players = api.excusemesir.Players
    RunService = api.excusemesir.RunService
    Workspace = api.excusemesir.Workspace
    UserInputService = api.excusemesir.UserInputService
    _config.cpu._runtime.navModule = M
    S.surfaceColors = {
        floor = Color3.fromRGB(255, 200, 0),
        ceil = Color3.fromRGB(255, 80, 200),
        wall = Color3.fromRGB(0, 200, 255),
        wedge = Color3.fromRGB(255, 120, 0),
        truss = Color3.fromRGB(180, 255, 80),
        blacklist = Color3.fromRGB(255, 30, 30),
        other = Color3.fromRGB(0, 200, 255),
    }
    -- Initial patterns
    local goals = parsePatternList(_config.cpu.goals)
    _config.cpu.goals = goals
    local bl = parsePatternList(_config.cpu.blacklist)
    _config.cpu.blacklist = bl
end

function M.start()
    if S.running then return end
    S.running = true
    S.initTime = os.clock()
    S.connection = RunService.Heartbeat:Connect(heartbeat)
end

function M.stop()
    S.running = false
    if S.connection then
        S.connection:Disconnect()
        S.connection = nil
    end
    -- Stop movement
    local hum = getPlayer().Character and getPlayer().Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local rt = hum.RootPart
        pcall(function() hum:MoveTo(rt and rt.Position or Vector3.zero) end)
    end
end

function M.clearMemory()
    S.memory = {}
    S.memoryCount = 0
    for i = 1, 24 do S.trail[i] = nil end
    S.trailIndex = 1
    S.lidarVoxels = {}
    S.lidarVoxelCount = 0
    S.lidarPathVoxels = {}
    S.lidarPathVoxelCount = 0
    clearRayViz()
    lidarClear()
end

function M.setGoals(list)
    _config.cpu.goals = list or {}
    S.lastGoalScan = 0
end

function M.setBlacklist(list)
    _config.cpu.blacklist = list or {}
    S.lastBlacklistScan = 0
    S.blacklistInstances = {}
end

-- Cleanup on module reload
local function cleanup()
    if S.connection then
        pcall(function() S.connection:Disconnect() end)
        S.connection = nil
    end
    if S.lidarFolder then pcall(function() S.lidarFolder:Destroy() end) end
    if S.lidarBounceFolder then pcall(function() S.lidarBounceFolder:Destroy() end) end
    if S.rayFolder then pcall(function() S.rayFolder:Destroy() end) end
end
M.cleanup = cleanup

return M
