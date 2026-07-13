local PathfindingService = game:GetService("PathfindingService")
local lplr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local pathCache = {}
local ClearCache = function()
    pathCache = {}
end

local connection
connection = RunService.Heartbeat:Connect(function()
    ClearCache()
end)

lplr.CharacterAdded:Connect(function(character)
    ClearCache()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        ClearCache()
    end)
end)

if lplr.Character then
    local humanoid = lplr.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            ClearCache()
        end)
    end
end

local FindPath = function(endPosition)
    if not endPosition or not typeof(endPosition) == "CFrame" then
        error("Invalid endPosition")
        return false, {}, nil
    end
    
    if not lplr.Character or not lplr.Character.HumanoidRootPart then
        error("LocalPlayer character or HumanoidRootPart not found")
        return false, {}, nil
    end
    local cacheKey = tostring(lplr.Character.HumanoidRootPart.Position) .. tostring(endPosition.Position)
    if pathCache[cacheKey] then
        return pathCache[cacheKey].success, pathCache[cacheKey].waypoints, pathCache[cacheKey].path
    end
    
    local path = PathfindingService:CreatePath()
    
    local success, message = pcall(function()
        path:ComputeAsync(lplr.Character.HumanoidRootPart.Position, endPosition.Position)
    end)
    
    if not success then
        error("Error computing path: " .. tostring(message))
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
    pathCache[cacheKey] = result
    
    return result.success, result.waypoints, result.path
end

local ShowPath = function(endPosition)
    local success, waypoints, path = FindPath(endPosition)
    
    if success then
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and child.Name == "Path" then
                child:Destroy()
            end
        end
        
        if #waypoints > 0 then
            local parent = Instance.new("Model")
            parent.Name = "Path"
            parent.Parent = workspace
            
            for i, waypoint in ipairs(waypoints) do
                local part = Instance.new("Part")
                part.Name = "PathPart"
                part.Size = Vector3.new(1, 1, 1)
                part.Position = waypoint.Position
                part.Anchored = true
                part.CanCollide = false
                
                part.Parent = parent
            end
        else
            print("No waypoints found in the path")
        end
    else
        print("Failed to find a valid path")
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
    
    if success then
        local nextWaypointIndex = 1
        
        if path.Status == Enum.PathStatus.Success then
            local reachedConnection
            reachedConnection = lplr.Character.Humanoid.MoveToFinished:Connect(function(reached)
                if reached and nextWaypointIndex < #waypoints then
                    nextWaypointIndex = nextWaypointIndex + 1
                    lplr.Character.Humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
                else
                    reachedConnection:Disconnect()
                end
            end)
            
            lplr.Character.Humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
        end
    else
        print("Failed to find a valid path")
    end
end

local StopClearingCache = function()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

return {
    FindPath = FindPath,
    ShowPath = ShowPath,
    RemovePath = RemovePath,
    MoveCharacter = MoveCharacter,
    ClearCache = ClearCache,
    StopClearingCache = StopClearingCache
}
