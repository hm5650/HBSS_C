-- lp_info.lua
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local lp_info = {
    lp_username = lp.Name,
    lp_displayname = lp.DisplayName,
    lp_id = lp.UserId,
    lp_accountage = lp.AccountAge,
    lp_retroslopscore = 0,
    lp_isitretroslop = false,
}

local keywords = {
    "gubby",
    "elliot",
    "noob",
    "retro",
    "classic",
    "builder",
    "guest",
    "oldschool",
    "2008",
    "2010",
    "2012",
    "2015",
}

local function dodacalc()
    local score = 0
    local character = lp.Character or lp.CharacterAdded:Wait()
    local accessoryCount = 0
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Accessory") then
            accessoryCount += 1
            local lowerName = string.lower(obj.Name)
            for _, keyword in ipairs(keywords) do
                if string.find(lowerName, keyword, 1, true) then
                    score += 12
                end
            end
        end
    end
    score += math.max(0, accessoryCount - 5) * 4
    if lp.AccountAge < 365 then
        score += 25
    elseif lp.AccountAge < (365 * 2) then
        score += 15
    elseif lp.AccountAge < (365 * 5) then
        score += 5
    end
    local display = string.lower(lp.DisplayName)
    for _, keyword in ipairs(keywords) do
        if string.find(display, keyword, 1, true) then
            score += 8
        end
    end
    score = math.clamp(score, 0, 100)
    lp_info.lp_retroslopscore = score
    lp_info.lp_isitretroslop = score >= 67
end

dodacalc()
return lp_info
-- fin
