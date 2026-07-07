
local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local WorldToScreen = Camera.WorldToScreenPoint
local GetPlayers = plrs.GetPlayers
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local GetMouseLocation = UserInputService.GetMouseLocation
local RandomNew = Random.new()
local cachedGun = nil
local cachedGunCheck = 0
local gobin = 0.5 -- s
local functions = {}

functions.GetScreenPosition = function(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

functions.IsTool = function(Tool)
    return Tool:IsA("Tool")
end

functions.IsAlive = function(Plr)
    local Char = Plr.Character
    if not Char then return false end
    local Humanoid = Char:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health > 0
end

functions.TeamCheck = function(Plr)
    return Plr.Team ~= lplr.Team
end

functions.GetMousePosition = function()
    return GetMouseLocation(UserInputService)
end

functions.GetGun = function(Plr)
    local currentTime = tick()
    if cachedGun and cachedGunCheck + gobin > currentTime then
        if cachedGun and cachedGun.Parent and cachedGun.Parent == lplr.Character then
            return cachedGun
        end
    end
    
    local Character = lplr.Character
    if not Character then 
        cachedGun = nil
        return nil 
    end
    for _, v in ipairs(Character:GetChildren()) do
        if v:IsA("Tool") then
            cachedGun = v
            cachedGunCheck = currentTime
            return v
        end
    end
    
    cachedGun = nil
    return nil
end

functions.HitChance = function(Percentage)
    Percentage = math.floor(Percentage)
    local chance = RandomNew:NextNumber()
    return chance <= (Percentage / 100)
end

functions.Direction = function(Origin, Pos)
    return (Pos - Origin).Unit * 1000
end

local function onCharacterAdded()
    cachedGun = nil
    cachedGunCheck = 0
end

lplr.CharacterAdded:Connect(onCharacterAdded)
return functions
