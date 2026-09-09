-- Errors be like: "Attempt to index nil" 🥀
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local originalPositions = {
    filelabel = UDim2.new(0,7,0,4),
    barlabel = UDim2.new(0,302,0,203),
    percentagelabel = UDim2.new(0,329,0,189),
    gravelmeme = UDim2.new(0,7,0,35)
}
local gui = Instance.new("ScreenGui")
local bg = Instance.new("Frame")
local UIObject1 = Instance.new("ImageLabel")
local UIObject2 = Instance.new("TextLabel")
local UIObject3 = Instance.new("TextLabel")
local UIObject4 = Instance.new("TextLabel")
local UIObject5 = Instance.new("TextLabel")
local blurEffect = Instance.new("BlurEffect")
local sounds = {
    start = "rbxassetid://120092757126147",
    hum = "rbxassetid://84642398160400",
    endBSOD = "rbxassetid://121769472475128",
    flash = "rbxassetid://85431715800788",
    bar = "rbxassetid://6856723345",
    glitch = {
        "rbxassetid://131507757356742",
        "rbxassetid://140043289814504",
        "rbxassetid://129687541350237"
    }
}
local startSound = Instance.new("Sound")
local humSound = Instance.new("Sound")
local endSound = Instance.new("Sound")
local flashSound = Instance.new("Sound")
local barSound = Instance.new("Sound")
local glitchSounds = {}

gui.Name = "water"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = CoreGui

bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0
bg.Parent = gui

UIObject1.Name = "UIimage"
UIObject1.ImageColor3 = Color3.fromRGB(255,255,255)
UIObject1.BorderMode = Enum.BorderMode.Outline
UIObject1.AnchorPoint = Vector2.new(0.5, 0.5)
UIObject1.Image = "rbxassetid://111829430881220"
UIObject1.ImageRectSize = Vector2.new(0,0)
UIObject1.ZIndex = 1
UIObject1.BorderSizePixel = 0
UIObject1.Size = UDim2.new(0,557,0,254)
UIObject1.ScaleType = Enum.ScaleType.Stretch
UIObject1.ClipsDescendants = false
UIObject1.BorderColor3 = Color3.fromRGB(0,0,0)
UIObject1.AutomaticSize = Enum.AutomaticSize.None
UIObject1.LayoutOrder = 0
UIObject1.Rotation = 0
UIObject1.ResampleMode = Enum.ResamplerMode.Default
UIObject1.BackgroundTransparency = 1
UIObject1.Position = UDim2.new(0.5,0,0.5,0)
UIObject1.Visible = true
UIObject1.ImageRectOffset = Vector2.new(0,0)
UIObject1.ImageTransparency = 0
UIObject1.BackgroundColor3 = Color3.fromRGB(246,247,249)
UIObject1.Parent = bg

UIObject2.Name = "filelabel"
UIObject2.Visible = true
UIObject2.TextWrapped = true
UIObject2.BorderMode = Enum.BorderMode.Outline
UIObject2.TextTransparency = 0
UIObject2.TextStrokeTransparency = 1
UIObject2.AnchorPoint = Vector2.new(0,0)
UIObject2.AutomaticSize = Enum.AutomaticSize.None
UIObject2.ClipsDescendants = true
UIObject2.LayoutOrder = 0
UIObject2.ZIndex = 1
UIObject2.BorderSizePixel = 0
UIObject2.Size = UDim2.new(0,553,0,54)
UIObject2.Selectable = false
UIObject2.RichText = false
UIObject2.Active = true
UIObject2.TextColor3 = Color3.fromRGB(255,255,255)
UIObject2.BorderColor3 = Color3.fromRGB(0,0,0)
UIObject2.Text = "[Files]: ..."
UIObject2.TextStrokeColor3 = Color3.fromRGB(0,0,0)
UIObject2.TextSize = 10
UIObject2.Rotation = 0
UIObject2.Font = Enum.Font.Code
UIObject2.BackgroundTransparency = 1
UIObject2.Position = UDim2.new(0,7,0,4)
UIObject2.TextXAlignment = Enum.TextXAlignment.Left
UIObject2.TextYAlignment = Enum.TextYAlignment.Center
UIObject2.TextScaled = false
UIObject2.BackgroundColor3 = Color3.fromRGB(255,255,255)
UIObject2.Parent = UIObject1

UIObject3.Name = "Barlabel"
UIObject3.Visible = true
UIObject3.TextWrapped = true
UIObject3.BorderMode = Enum.BorderMode.Outline
UIObject3.TextTransparency = 0
UIObject3.TextStrokeTransparency = 1
UIObject3.AnchorPoint = Vector2.new(0,0)
UIObject3.AutomaticSize = Enum.AutomaticSize.None
UIObject3.ClipsDescendants = false
UIObject3.LayoutOrder = 0
UIObject3.ZIndex = 1
UIObject3.BorderSizePixel = 0
UIObject3.Size = UDim2.new(0,280,0,55)
UIObject3.Selectable = false
UIObject3.RichText = false
UIObject3.Active = true
UIObject3.TextColor3 = Color3.fromRGB(255,255,255)
UIObject3.BorderColor3 = Color3.fromRGB(0,0,0)
UIObject3.Text = "[                                       ]"
UIObject3.TextStrokeColor3 = Color3.fromRGB(0,0,0)
UIObject3.TextSize = 10
UIObject3.Rotation = 0
UIObject3.Font = Enum.Font.Code
UIObject3.BackgroundTransparency = 1
UIObject3.Position = originalPositions.barlabel
UIObject3.TextXAlignment = Enum.TextXAlignment.Center
UIObject3.TextYAlignment = Enum.TextYAlignment.Center
UIObject3.TextScaled = false
UIObject3.BackgroundColor3 = Color3.fromRGB(255,255,255)
UIObject3.Parent = UIObject1

UIObject4.Name = "Percentagelabel"
UIObject4.Visible = true
UIObject4.TextWrapped = true
UIObject4.BorderMode = Enum.BorderMode.Outline
UIObject4.TextTransparency = 0
UIObject4.TextStrokeTransparency = 1
UIObject4.AnchorPoint = Vector2.new(0,0)
UIObject4.AutomaticSize = Enum.AutomaticSize.None
UIObject4.ClipsDescendants = false
UIObject4.LayoutOrder = 0
UIObject4.ZIndex = 1
UIObject4.BorderSizePixel = 0
UIObject4.Size = UDim2.new(0,220,0,55)
UIObject4.Selectable = false
UIObject4.RichText = false
UIObject4.Active = true
UIObject4.TextColor3 = Color3.fromRGB(255,255,255)
UIObject4.BorderColor3 = Color3.fromRGB(0,0,0)
UIObject4.Text = "0%"
UIObject4.TextStrokeColor3 = Color3.fromRGB(0,0,0)
UIObject4.TextSize = 10
UIObject4.Rotation = 0
UIObject4.Font = Enum.Font.Code
UIObject4.BackgroundTransparency = 1
UIObject4.Position = originalPositions.percentagelabel
UIObject4.TextXAlignment = Enum.TextXAlignment.Center
UIObject4.TextYAlignment = Enum.TextYAlignment.Center
UIObject4.TextScaled = false
UIObject4.BackgroundColor3 = Color3.fromRGB(255,255,255)
UIObject4.Parent = UIObject1

UIObject5.Name = "Gravelmeme"
UIObject5.Visible = true
UIObject5.TextWrapped = true
UIObject5.BorderMode = Enum.BorderMode.Outline
UIObject5.TextTransparency = 0
UIObject5.TextStrokeTransparency = 1
UIObject5.AnchorPoint = Vector2.new(0,0)
UIObject5.AutomaticSize = Enum.AutomaticSize.None
UIObject5.ClipsDescendants = false
UIObject5.LayoutOrder = 0
UIObject5.ZIndex = 1
UIObject5.BorderSizePixel = 0
UIObject5.Size = UDim2.new(0,564,0,72)
UIObject5.Selectable = false
UIObject5.RichText = false
UIObject5.Active = true
UIObject5.TextColor3 = Color3.fromRGB(255,255,255)
UIObject5.BorderColor3 = Color3.fromRGB(0,0,0)
UIObject5.Text = "[G.cc] ..."
UIObject5.TextStrokeColor3 = Color3.fromRGB(0,0,0)
UIObject5.TextSize = 10
UIObject5.Rotation = 0
UIObject5.Font = Enum.Font.Code
UIObject5.BackgroundTransparency = 1
UIObject5.Position = originalPositions.gravelmeme
UIObject5.TextXAlignment = Enum.TextXAlignment.Left
UIObject5.TextYAlignment = Enum.TextYAlignment.Center
UIObject5.TextScaled = false
UIObject5.BackgroundColor3 = Color3.fromRGB(255,255,255)
UIObject5.Parent = UIObject1

blurEffect.Size = 0
blurEffect.Parent = game:GetService("Lighting")

startSound.SoundId = sounds.start
startSound.Volume = 0.5
startSound.Parent = SoundService

humSound.SoundId = sounds.hum
humSound.Volume = 0.3
humSound.Looped = true
humSound.Parent = SoundService

endSound.SoundId = sounds.endBSOD
endSound.Volume = 0.5
endSound.Parent = SoundService

flashSound.SoundId = sounds.flash
flashSound.Volume = 0.5
flashSound.Parent = SoundService

barSound.SoundId = sounds.bar
barSound.Volume = 0.4
barSound.Parent = SoundService

for i, id in ipairs(sounds.glitch) do
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = 0.3
    sound.Parent = SoundService
    table.insert(glitchSounds, sound)
end

startSound:Play()
humSound:Play()

local glitchVersions = {
    {id = "rbxassetid://94264734340895", weight = 30, offset = 2},   -- 1 - least glitchy
    {id = "rbxassetid://73199835850160", weight = 25, offset = 4},   -- 2
    {id = "rbxassetid://111659265884052", weight = 20, offset = 6},  -- 3
    {id = "rbxassetid://135403100516021", weight = 15, offset = 8},  -- 4
    {id = "rbxassetid://108402549365872", weight = 10, offset = 12}  -- 5 - most glitchy
}

local totalWeight = 0
for _, v in ipairs(glitchVersions) do
    totalWeight = totalWeight + v.weight
end

function getRandomGlitch()
    local rand = math.random(1, totalWeight)
    local cumulative = 0
    for _, v in ipairs(glitchVersions) do
        cumulative = cumulative + v.weight
        if rand <= cumulative then
            return v
        end
    end
    return glitchVersions[1]
end

function applyGlitchPositions(offset)
    if not offset or offset == 0 then
        UIObject2.Position = originalPositions.filelabel
        UIObject3.Position = originalPositions.barlabel
        UIObject4.Position = originalPositions.percentagelabel
        UIObject5.Position = originalPositions.gravelmeme
        return
    end
    
    local dirX1 = math.random(0, 1) == 0 and -1 or 1
    local dirY1 = math.random(0, 1) == 0 and -1 or 1
    local dirX2 = math.random(0, 1) == 0 and -1 or 1
    local dirY2 = math.random(0, 1) == 0 and -1 or 1
    local dirX3 = math.random(0, 1) == 0 and -1 or 1
    local dirY3 = math.random(0, 1) == 0 and -1 or 1
    local dirX4 = math.random(0, 1) == 0 and -1 or 1
    local dirY4 = math.random(0, 1) == 0 and -1 or 1
    
    UIObject2.Position = UDim2.new(
        originalPositions.filelabel.X.Scale,
        originalPositions.filelabel.X.Offset + (dirX1 * offset * 2),
        originalPositions.filelabel.Y.Scale,
        originalPositions.filelabel.Y.Offset + (dirY1 * offset)
    )
    
    UIObject3.Position = UDim2.new(
        originalPositions.barlabel.X.Scale,
        originalPositions.barlabel.X.Offset + (dirX2 * offset * 2),
        originalPositions.barlabel.Y.Scale,
        originalPositions.barlabel.Y.Offset + (dirY2 * offset)
    )
    
    UIObject4.Position = UDim2.new(
        originalPositions.percentagelabel.X.Scale,
        originalPositions.percentagelabel.X.Offset + (dirX3 * offset * 2),
        originalPositions.percentagelabel.Y.Scale,
        originalPositions.percentagelabel.Y.Offset + (dirY3 * offset)
    )
    
    UIObject5.Position = UDim2.new(
        originalPositions.gravelmeme.X.Scale,
        originalPositions.gravelmeme.X.Offset + (dirX4 * offset * 2),
        originalPositions.gravelmeme.Y.Scale,
        originalPositions.gravelmeme.Y.Offset + (dirY4 * offset)
    )
end

local bsodImage = "rbxassetid://119715944001369"

local rngMemes = {
    "did someone say spaghetti",
    "my code is pasta",
    "al dente and tangled",
    "bon appetit",
    "gaming chair diff fr",
    "i got the 4000$ chair",
    "that's why i never miss",
    "totally not aimbot",
    "me and the boys",
    "running the script",
    "and getting banned",
    "worth it every time",
    "the script is free",
    "and open source",
    "and has silent aim",
    "what more could you want",
    "Error: can't find message",
    "i'm not having errors actually",
    "or maybe I am, who knows??",
    "is that a hack?",
    "no it's a gaming chair",
    "my chair has aimbot",
    "you should get one",
    "please read the InfoTab",
    "and credit me if u did a snippet",
    "i'm not a robot",
    "i'm a gravel",
    "robots are metal",
    "gravel is rock",
    "big difference",
    "checkmate atheists",
    "u ever just",
    "silent aim someone",
    "and they go '??? how'",
    "and then u say ping diff",
    "well I did that",
    "i love when the script",
    "works on the first try",
    "that's a lie",
    "it never does",
    "Gravel has 0 calories 2 burn",
    "wait this isn't a virus",
    "i was told it was a virus",
    "it's open source",
    "you can literally read it",
    "is that a toby?",
    "meow :3 .... MAW >:3",
    "This loader is definitely 100% not a inspiration from redliner's mercy.os",
    "Gugu Gaga Ultimated Flex Works",
    "can gravel run doom?",
    "ipad kid vs ipad, who would win?",
    "why is there ai slop on my TikTok fyp",
    "bombastic side eye",
    "oh shiddings nott gud D:",
    "what's a brainfuck :s",
    "Gravel.cc says be gravel",
    "me wants grabel :(",
    "life never made lemons...",
    "01001000 01101001",
    "roblox is no longer robloz",
    "GRAVEL-MAN",
    "IM SKYLER WHITE, YO",
    "my diet is gravel",
    "ur definitely using delta cuz idk",
    "dab me up :>",
    "how much saves do u has",
    "O rly",
    ":3",
    "lololololooloo",
    "wth is ts",
    "hell nah",
    "OHHHH HELLL NAH",
    "pop-up goes bye bye",
    "isn't phonk just noise?",
    "guys it's a-a, a-a h-hacker!?!?!",
    "tiki tiki",
    "Nosirski!",
    "click here or ur gay",
    "lolzer-fying",
    "helohi",
    "portal above portal below *jumps in*",
    "ifone 90 proe max"
}

local function playGlitchStartAnimation()
    local blackFrame = Instance.new("Frame")
    UIObject2.Visible = false
    UIObject3.Visible = false
    UIObject4.Visible = false
    UIObject5.Visible = false
    
    blackFrame.Size = UDim2.fromScale(1, 1)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BackgroundTransparency = 0
    blackFrame.ZIndex = 100
    blackFrame.Parent = gui
    
    local startGlitchSequence = {
        {type = "glitch", image = glitchVersions[5].id, duration = 0.05, offset = 12},
        {type = "glitch", image = glitchVersions[3].id, duration = 0.08, offset = 6},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.03, offset = 12},
        {type = "glitch", image = glitchVersions[2].id, duration = 0.06, offset = 4},
        {type = "glitch", image = glitchVersions[4].id, duration = 0.07, offset = 8},
        {type = "glitch", image = glitchVersions[1].id, duration = 0.04, offset = 2},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.05, offset = 12},
        {type = "glitch", image = glitchVersions[3].id, duration = 0.06, offset = 6},
        {type = "normal", duration = 0.1},
        {type = "glitch", image = glitchVersions[4].id, duration = 0.04, offset = 8},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.07, offset = 12},
        {type = "glitch", image = glitchVersions[2].id, duration = 0.05, offset = 4},
        {type = "normal", duration = 0.08},
        {type = "glitch", image = glitchVersions[3].id, duration = 0.06, offset = 6},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.04, offset = 12},
        {type = "normal", duration = 0.1},
        {type = "glitch", image = glitchVersions[1].id, duration = 0.05, offset = 2},
        {type = "glitch", image = glitchVersions[4].id, duration = 0.07, offset = 8},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.03, offset = 12},
        {type = "normal", duration = 0.15},
        {type = "glitch", image = glitchVersions[2].id, duration = 0.06, offset = 4},
        {type = "glitch", image = glitchVersions[5].id, duration = 0.05, offset = 12},
        {type = "glitch", image = glitchVersions[3].id, duration = 0.04, offset = 6},
        {type = "normal", duration = 0.2}
    }
    
    for _, step in ipairs(startGlitchSequence) do
        if step.type == "glitch" then
            UIObject1.Image = step.image
            UIObject1.Visible = true
            applyGlitchPositions(step.offset)
            
            local glitchSound = glitchSounds[math.random(1, #glitchSounds)]
            glitchSound:Play()
            
            UIObject2.Visible = true
            UIObject3.Visible = true
            UIObject4.Visible = true
            UIObject5.Visible = true
            
            task.wait(step.duration)
        else
            UIObject1.Image = "rbxassetid://111829430881220"
            applyGlitchPositions(0)
            task.wait(step.duration)
        end
        
        if math.random() < 0.3 then
            blackFrame.BackgroundTransparency = 0
            task.wait(0.02)
            blackFrame.BackgroundTransparency = 1
        end
    end
    
    UIObject1.Image = "rbxassetid://111829430881220"
    applyGlitchPositions(0)
    UIObject2.Visible = true
    UIObject3.Visible = true
    UIObject4.Visible = true
    UIObject5.Visible = true
    
    local fadeBlack = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(blackFrame, fadeBlack, {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    blackFrame:Destroy()
end

playGlitchStartAnimation()
task.wait(0.3)

local fadeIn = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()

task.spawn(function()
    local currentText = ""
    local cursorVisible = true
    local charIndex = 1
    local isErasing = false
    local currentMessage = ""
    
    while gui and gui.Parent do
        if not isErasing and (not currentMessage or currentMessage == "") then
            currentMessage = rngMemes[math.random(1, #rngMemes)]
            charIndex = 1
            currentText = ""
        end
        
        if not isErasing then
            if charIndex <= #currentMessage then
                currentText = currentText .. currentMessage:sub(charIndex, charIndex)
                charIndex = charIndex + 1
                UIObject5.Text = "[G.cc] " .. currentText .. (cursorVisible and "_" or " ")
                task.wait(math.random(3, 8) / 100)
            else
                task.wait(math.random(15, 35) / 10)
                isErasing = true
            end
        else
            if #currentText > 0 then
                currentText = currentText:sub(1, #currentText - 1)
                UIObject5.Text = "[G.cc] " .. currentText .. (cursorVisible and "_" or " ")
                task.wait(math.random(2, 5) / 100)
            else
                isErasing = false
                currentMessage = ""
                task.wait(math.random(5, 15) / 10)
            end
        end
        
        cursorVisible = not cursorVisible
        if not isErasing and currentText ~= "" then
            UIObject5.Text = "[G.cc] " .. currentText .. (cursorVisible and "_" or " ")
        end
    end
end)

local isBSODActive = false

task.spawn(function()
    while gui and gui.Parent do
        if not isBSODActive then
            if math.random() < 0.30 then
                local glitchData = getRandomGlitch()
                UIObject1.Image = glitchData.id
                applyGlitchPositions(glitchData.offset)
                
                local glitchSound = glitchSounds[math.random(1, #glitchSounds)]
                glitchSound:Play()
                
                local glitchDuration = math.random(1, 4) / 10
                task.wait(glitchDuration)
                
                UIObject1.Image = "rbxassetid://111829430881220"
                applyGlitchPositions(0)
            end
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    local totalBars = 39
    local filled = 0
    local maxDuration = 3.25
    local startTime = tick()
    local elapsed = 0
    
    if not isfolder("Gravel_Saves") then
        makefolder("Gravel_Saves")
    end
    
    if not isfolder("Gravel_Saves/assets") then
        makefolder("Gravel_Saves/assets")
    end
    
    local saveFiles = {}
    local files = listfiles("Gravel_Saves")
    for _, file in ipairs(files) do
        if string.match(file, "%.json$") then
            table.insert(saveFiles, file)
        end
    end
    local assetFiles = listfiles("Gravel_Saves/assets")
    for _, file in ipairs(assetFiles) do
        if string.match(file, "%.json$") then
            table.insert(saveFiles, file)
        end
    end
    
    local extraDelay = #saveFiles * 0.15
    local adjustedMaxDuration = maxDuration + extraDelay
    local totalFiles = #saveFiles
    local processedFiles = 0
    
    while elapsed < adjustedMaxDuration do
        task.wait(math.random(10, 30) / 100)
        elapsed = tick() - startTime
        
        if totalFiles > 0 and processedFiles < totalFiles and elapsed > (processedFiles + 1) * (adjustedMaxDuration / (totalFiles + 2)) then
            processedFiles = processedFiles + 1
            local fileName = saveFiles[processedFiles]
            fileName = string.match(fileName, "([^/\\]+)%.json$") or "Unknown"
            if string.find(saveFiles[processedFiles], "/assets/") or string.find(saveFiles[processedFiles], "\\assets\\") then
                UIObject2.Text = "Files: assets/" .. fileName
            else
                UIObject2.Text = "Files: " .. fileName
            end
            barSound:Play()
        elseif totalFiles > 0 then
            local currentFile = saveFiles[math.min(processedFiles + 1, totalFiles)]
            local displayName = currentFile and string.match(currentFile, "([^/\\]+)%.json$") or ""
            if currentFile and (string.find(currentFile, "/assets/") or string.find(currentFile, "\\assets\\")) then
                UIObject2.Text = "Files: assets/" .. displayName
            elseif currentFile then
                UIObject2.Text = "Files: " .. displayName
            end
        end
        
        local targetFilled = math.min(totalBars, math.floor((elapsed / adjustedMaxDuration) * totalBars))
        
        if targetFilled > filled then
            for i = filled + 1, targetFilled do
                barSound:Play()
            end
            filled = targetFilled
        elseif math.random() < 0.75 and filled < totalBars then
            barSound:Play()
            filled = math.min(totalBars, filled + 1)
        end
        
        local visual = string.rep("|", filled)
        local empty = string.rep(" ", totalBars - filled)
        UIObject3.Text = "[" .. visual .. empty .. "]"
        
        local percentage = math.floor((filled / totalBars) * 100)
        UIObject4.Text = percentage .. "%"
        
        task.wait()
    end
    
    filled = totalBars
    UIObject3.Text = "[" .. string.rep("|", totalBars) .. "]"
    UIObject4.Text = "100%"
    
    if totalFiles > 0 then
        local mainCount = 0
        local assetCount = 0
        for _, file in ipairs(saveFiles) do
            if string.find(file, "/assets/") or string.find(file, "\\assets\\") then
                assetCount = assetCount + 1
            else
                mainCount = mainCount + 1
            end
        end
        if assetCount > 0 and mainCount > 0 then
            UIObject2.Text = "Files: " .. mainCount .. " saves + " .. assetCount .. " assets loaded"
        elseif assetCount > 0 then
            UIObject2.Text = "Files: " .. assetCount .. " assets loaded"
        else
            UIObject2.Text = "Files: " .. totalFiles .. " saves loaded"
        end
    else
        UIObject2.Text = "No Files: I checked for no reason 💔🥀"
    end
    
    task.wait(1.2)
    
    humSound:Stop()
    isBSODActive = true
    
    local glitchSequence = {
        {type = "glitch", duration = 0.05},
        {type = "glitch", duration = 0.08},
        {type = "bsod", duration = 0.1},
        {type = "glitch", duration = 0.06},
        {type = "bsod", duration = 0.1},
        {type = "glitch", duration = 0.04},
        {type = "bsod", duration = 0.08},
        {type = "glitch", duration = 0.05},
        {type = "bsod", duration = 0.15}
    }
    
    -- Play BSOD sound once at the start of the transition
    endSound:Play()
    
    for _, step in ipairs(glitchSequence) do
        if step.type == "glitch" then
            local glitchData = getRandomGlitch()
            UIObject1.Image = glitchData.id
            applyGlitchPositions(glitchData.offset)
            task.wait(step.duration)
        else
            UIObject1.Image = bsodImage
            applyGlitchPositions(0)
            task.wait(step.duration)
        end
    end
    
    UIObject1.Image = bsodImage
    applyGlitchPositions(0)
    UIObject2.Visible = false
    UIObject3.Visible = false
    UIObject4.Visible = false
    UIObject5.Visible = false
    
    task.wait(1.2)
    
    flashSound:Play()
    
    local flash = Instance.new("Frame")
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flash.BackgroundTransparency = 0
    flash.ZIndex = 1000
    flash.Parent = gui
    
    local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blurEffect, fadeOut, {Size = 0}):Play()
    
    task.wait(0.3)
    
    startSound:Destroy()
    humSound:Destroy()
    endSound:Destroy()
    flashSound:Destroy()
    barSound:Destroy()
    for _, sound in ipairs(glitchSounds) do
        sound:Destroy()
    end
    gui:Destroy()
    blurEffect:Destroy()
end)
