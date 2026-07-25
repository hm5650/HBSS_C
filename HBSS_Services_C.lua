local Services = {}
local function getServices()
    local gameServices = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        VirtualUser = game:GetService("VirtualUser"),
        TweenService = game:GetService("TweenService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        Teams = game:GetService("Teams"),
        HttpService = game:GetService("HttpService"),
        SoundService = game:GetService("SoundService"),
        Workspace = game:GetService("Workspace"),
        Lighting = game:GetService("Lighting"),
        StarterGui = game:GetService("StarterGui"),
        ScriptContext = game:GetService("ScriptContext"),
        LogService = game:GetService("LogService"),
        CoreGui = game:GetService("CoreGui"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        ServerStorage = game:GetService("ServerStorage"),
        Debris = game:GetService("Debris"),
        CollectionService = game:GetService("CollectionService"),
        ContextActionService = game:GetService("ContextActionService"),
    }
    return gameServices
end
local allServices = getServices()
for name, service in pairs(allServices) do
    _G[name] = service
    Services[name] = service
end
function Services:getAll()
    return allServices
end
function Services:getPlayers()
    return allServices.Players
end
function Services:getRunService()
    return allServices.RunService
end
function Services:getUserInputService()
    return allServices.UserInputService
end
function Services:getWorkspace()
    return allServices.Workspace
end

return Services
