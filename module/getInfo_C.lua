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
    "gubbies",
    "elliot",
    "noob",
    "noob jacket",
    "retro",
    "classic",
    "oldschool",
    "old school",
    "builder",
    "guest",
    "2006",
    "2007",
    "2008",
    "2009",
    "2010",
    "2011",
    "2012",
    "2013",
    "2014",
    "2015",
    "doodle",
    "doodle face",
    "scribble",
    "bandage",
    "bandages",
    "glove",
    "gloves",
    "confetti",
    "sparkle",
    "star",
    "stars",
    "cat",
    "furry",
    "kitty",
    "kitten",
    "wolf",
    "fox",
    "bunny",
    "rabbit",
    "bear",
    "paw",
    "tail",
    "ears",
    "fluff",
    "fluffy",
    "messy",
    "scene",
    "scenecore",
    "weirdcore",
    "dreamcore",
    "nostalgia",
    "nostalgic",
    "brick",
    "stud",
    "brickbattle",
    "doomspire",
    "epic face",
    "awesome face",
    "super super happy",
    "check it",
    "cartoony",
    "goober",
    "silly",
    "goofy",
    "derp",
    "derpy",
    "autism",
    "tbh",
    ":3",
    "x3",
    "forsaken",
    "regretevator",
    "block tales",
    "something evil",
    "npc",
    "gnarpy",
    "pilby",
    "bive",
    "split",
    "infected",
    "rainbow",
    "pixel",
    "8bit",
    "8-bit"
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
