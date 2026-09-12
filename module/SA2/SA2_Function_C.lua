local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local Camera = workspace.CurrentCamera
local WorldToScreen = Camera.WorldToScreenPoint
local GetPlayers = plrs.GetPlayers
local GetMouseLocation = UserInputService and UserInputService.GetMouseLocation
local random = Random.new()
local functions = {}

functions.GetScreenPosition = function(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

functions.IsTool = function(Tool)
    return Tool:IsA("Tool")
end

functions.IsAlive = function(Plr)
    local char = Plr.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

functions.TeamCheck = function(Plr)
    local lTeam = lplr.Team
    local pTeam = Plr.Team
    if not lTeam or not pTeam then return true end
    return lTeam ~= pTeam
end

local lastMousePos = Vector2.new(0, 0)
functions.GetMousePosition = function()
    if UserInputService then
        local success, pos = pcall(GetMouseLocation, UserInputService)
        if success and pos then
            lastMousePos = pos
            return pos
        end
    end
    return lastMousePos
end

functions.GetGun = function(Plr)
    local Character = lplr.Character
    if not Character then return end
    return Character:FindFirstChildOfClass("Tool")
end

functions.HitChance = function(Percentage)
    if Percentage >= 100 then return true end
    if Percentage <= 0 then return false end
    return random:NextNumber() <= Percentage / 100
end

functions.Direction = function(Origin, Pos)
    return (Pos - Origin).Unit * 1000
end

local _cache = {
    camera = Camera,
    players = plrs,
    localPlayer = lplr,
    lastUpdate = 0,
}

functions.BatchCheck = function(targets, checkType, ...)
    local results = {}
    for i, target in ipairs(targets) do
        if checkType == "Alive" then
            results[i] = functions.IsAlive(target)
        elseif checkType == "Team" then
            results[i] = functions.TeamCheck(target)
        elseif checkType == "Visible" then
            results[i] = functions.IsVisible(target, ...)
        end
    end
    return results
end

local visCache = {}
local visCacheTimeout = 0.05

functions.IsVisible = function(target, maxDistance)
    local now = tick()
    local cacheKey = tostring(target)
    local cached = visCache[cacheKey]
    if cached and (now - cached.time) < visCacheTimeout then
        return cached.visible
    end
    local targetChar = target.Character
    local localChar = lplr.Character
    if not targetChar or not localChar then
        visCache[cacheKey] = {visible = false, time = now}
        return false
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
    local localRoot = localChar:FindFirstChild("Head") or localChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not localRoot then
        visCache[cacheKey] = {visible = false, time = now}
        return false
    end
    
    local origin = localRoot.Position
    local targetPos = targetRoot.Position
    local direction = targetPos - origin
    local distance = direction.Magnitude
    
    if maxDistance and distance > maxDistance then
        visCache[cacheKey] = {visible = false, time = now}
        return false
    end
    
    if distance < 0.1 then
        visCache[cacheKey] = {visible = true, time = now}
        return true
    end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {localChar, targetChar}
    params.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction.Unit * distance, params)
    local visible = not result or result.Instance:IsDescendantOf(targetChar)
    
    visCache[cacheKey] = {visible = visible, time = now}
    if #visCache > 100 then
        local toRemove = {}
        for key, data in pairs(visCache) do
            if now - data.time > 5 then
                table.insert(toRemove, key)
            end
        end
        for _, key in ipairs(toRemove) do
            visCache[key] = nil
        end
    end
    
    return visible
end

functions.GetClosestPlayer = function(targets, useFOV, fovRadius, maxRange)
    local localPos = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if not localPos then return nil end
    localPos = localPos.Position
    
    local best = nil
    local bestDist = math.huge
    
    local cam = Camera
    local viewport = cam.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    for _, target in ipairs(targets) do
        if target ~= lplr and functions.IsAlive(target) and functions.TeamCheck(target) then
            local targetChar = target.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Head")
            if targetRoot then
                local dx = targetRoot.Position.X - localPos.X
                local dy = targetRoot.Position.Y - localPos.Y
                local dz = targetRoot.Position.Z - localPos.Z
                local distSq = dx*dx + dy*dy + dz*dz
                
                if maxRange and distSq > maxRange * maxRange then
                    continue
                end
                
                local dist = math.sqrt(distSq)
                
                if useFOV then
                    local screenPos, onScreen = cam:WorldToViewportPoint(targetRoot.Position)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius and screenDist < bestDist then
                            bestDist = screenDist
                            best = target
                        end
                    end
                else
                    if dist < bestDist then
                        bestDist = dist
                        best = target
                    end
                end
            end
        end
    end
    
    return best
end

local targetUpdateCounter = 0
functions.UpdateTarget = function(targets, config)
    targetUpdateCounter = targetUpdateCounter + 1
    if targetUpdateCounter % 3 ~= 0 then
        return functions.currentTarget
    end
    
    local newTarget = functions.GetClosestPlayer(
        targets,
        not config.SA2_ThreeSixtyMode,
        config.SA2_FovRadius,
        config.SA2_TargetRange
    )
    
    if newTarget then
        functions.currentTarget = newTarget
    end
    
    return functions.currentTarget
end

return functions
