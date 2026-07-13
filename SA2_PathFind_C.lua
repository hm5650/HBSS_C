local PathfindingService = game:GetService("PathfindingService")
local lplr = game:GetService("Players").LocalPlayer

-- Cache system
local PathCache = {
    cache = {},
    maxSize = 10,
    ttl = 5, -- seconds before cache expires
    enabled = true
}

local function getCacheKey(startPos, endPos)
    -- Round positions to reduce cache size
    local function round(v)
        return math.round(v / 5) * 5
    end
    return string.format("%d,%d,%d|%d,%d,%d",
        round(startPos.X), round(startPos.Y), round(startPos.Z),
        round(endPos.X), round(endPos.Y), round(endPos.Z)
    )
end

local function cleanCache()
    local now = tick()
    local toRemove = {}
    for key, data in pairs(PathCache.cache) do
        if now - data.timestamp > PathCache.ttl then
            table.insert(toRemove, key)
        end
    end
    for _, key in ipairs(toRemove) do
        PathCache.cache[key] = nil
    end
end

-- Run cache cleanup periodically (not every frame)
task.spawn(function()
    while PathCache.enabled do
        task.wait(PathCache.ttl)
        cleanCache()
    end
end)

-- Clean up when player leaves/disconnects
game.Players.PlayerRemoving:Connect(function()
    PathCache.cache = {}
end)

local FindPath = function(endPosition)
    if not endPosition or typeof(endPosition) ~= "CFrame" then
        return false, {}, nil
    end
    
    if not lplr.Character or not lplr.Character.HumanoidRootPart then
        return false, {}, nil
    end
    
    local startPos = lplr.Character.HumanoidRootPart.Position
    local endPos = endPosition.Position
    
    -- Check cache first
    local cacheKey = getCacheKey(startPos, endPos)
    local cached = PathCache.cache[cacheKey]
    if cached then
        return cached.success, cached.waypoints, cached.path
    end
    
    -- Compute new path
    local path = PathfindingService:CreatePath()
    local success, message = pcall(function()
        path:ComputeAsync(startPos, endPos)
    end)
    
    if not success then
        return false, {}, nil
    end
    
    local waypoints = {}
    local pathStatus = path.Status
    
    if pathStatus == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()
    end
    
    local result = {
        success = pathStatus == Enum.PathStatus.Success,
        waypoints = waypoints,
        path = path
    }
    
    -- Cache the result if cache is under size limit
    if PathCache.enabled and #PathCache.cache < PathCache.maxSize then
        PathCache.cache[cacheKey] = {
            success = result.success,
            waypoints = result.waypoints,
            path = result.path,
            timestamp = tick()
        }
    end
    
    return result.success, result.waypoints, result.path
end

local ShowPath = function(endPosition)
    local success, waypoints, path = FindPath(endPosition)
    
    -- Clean up old path models
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == "Path" then
            child:Destroy()
        end
    end
    
    if success and #waypoints > 0 then
        local parent = Instance.new("Model")
        parent.Name = "Path"
        parent.Parent = workspace
        
        -- Reduce waypoint parts for performance
        local step = math.max(1, math.floor(#waypoints / 20)) -- Max 20 parts
        for i = 1, #waypoints, step do
            local waypoint = waypoints[i]
            local part = Instance.new("Part")
            part.Name = "PathPart"
            part.Size = Vector3.new(1, 1, 1)
            part.Position = waypoint.Position
            part.Anchored = true
            part.CanCollide = false
            part.Parent = parent
        end
    end
end

local RemovePath = function()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == "Path" then
            child:Destroy()
        end
    end
end

local MoveCharacter = function(endPosition)
    local success, waypoints, path = FindPath(endPosition)
    
    if not success or #waypoints == 0 then
        return false
    end
    
    local humanoid = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local nextWaypointIndex = 1
    local reachedConnection
    
    reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
        if reached and nextWaypointIndex < #waypoints then
            nextWaypointIndex = nextWaypointIndex + 1
            humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
        else
            reachedConnection:Disconnect()
        end
    end)
    
    humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
    return true
end

-- Manual cache control
local ClearCache = function()
    PathCache.cache = {}
end

local SetCacheSize = function(size)
    PathCache.maxSize = math.max(1, size or 10)
end

local SetCacheTTL = function(seconds)
    PathCache.ttl = math.max(1, seconds or 5)
end

return {
    FindPath = FindPath,
    ShowPath = ShowPath,
    RemovePath = RemovePath,
    MoveCharacter = MoveCharacter,
    ClearCache = ClearCache,
    SetCacheSize = SetCacheSize,
    SetCacheTTL = SetCacheTTL
}
