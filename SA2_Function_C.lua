local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local Camera = workspace.CurrentCamera
local WorldToScreen = Camera.WorldToScreenPoint
local GetPlayers = plrs.GetPlayers
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local mouse = lplr:GetMouse()
local UserInputService = game:GetService("UserInputService")
local GetMouseLocation = UserInputService.GetMouseLocation

local functions = {}
local cachedCharacter = nil
local cachedGun = nil
local cachedTeam = nil
local cachedMousePosition = nil
local mousePositionCacheTime = 0
local characterCacheTime = 0
local screenPositionCache = {}
local cacheClearTime = 0

functions.GetScreenPosition = function(Vector)
    local key = tostring(Vector.X) .. "," .. tostring(Vector.Y) .. "," .. tostring(Vector.Z)
    if screenPositionCache[key] then
        return screenPositionCache[key][1], screenPositionCache[key][2]
    end
    
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    local result = Vector2.new(Vec3.X, Vec3.Y), OnScreen
    screenPositionCache[key] = {result, OnScreen}
    return result, OnScreen
end

functions.ClearCache = function()
    screenPositionCache = {}
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
    if Plr == lplr then return false end
    return Plr.Team ~= lplr.Team
end

functions.GetMousePosition = function()
    -- Cache mouse position (update every 2 frames to reduce overhead)
    local currentTime = tick()
    if currentTime - mousePositionCacheTime < 0.033 then -- ~30ms
        return cachedMousePosition
    end
    
    cachedMousePosition = GetMouseLocation(UserInputService)
    mousePositionCacheTime = currentTime
    return cachedMousePosition
end

functions.GetGun = function(Plr)
    local Character = lplr.Character
    if Character == cachedCharacter and cachedGun then
        -- Check if cached gun still exists and is valid
        if cachedGun.Parent == Character then
            return cachedGun
        end
    end
    cachedCharacter = Character
    cachedGun = nil
    
    if not Character then return end
    
    for _,v in ipairs(Character:GetChildren()) do
        if functions.IsTool(v) then
            cachedGun = v
            return v
        end
    end
end
local randomGen = Random.new()
functions.HitChance = function(Percentage)
    Percentage = math.floor(Percentage)
    local chance = randomGen:NextNumber(0, 1)
    return chance <= Percentage / 100
end
functions.Direction = function(Origin, Pos)
    return (Pos - Origin).Unit * 1000
end
local function precalculate()
    cachedTeam = lplr.Team
end
precalculate()
lplr:GetPropertyChangedSignal("Team"):Connect(function()
    cachedTeam = lplr.Team
end)

return functions
