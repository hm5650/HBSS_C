-- Errors be like: "Attempt to index nil" 🥀
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
local bg = Instance.new("Frame")
local center = Instance.new("Frame")
local brand = Instance.new("TextLabel")
local loadingText = Instance.new("TextLabel")
local bar = Instance.new("TextLabel")
local icon = Instance.new("ImageLabel")
local aspect = Instance.new("UIAspectRatioConstraint")
local plrs = game:GetService("Players")
local blurEffect = Instance.new("BlurEffect")
local plr = plrs.LocalPlayer
local filesText = Instance.new("TextLabel")
local memeText = Instance.new("TextLabel")
local floatOffset = 0
local floatDirection = 1
blurEffect.Size = 0
blurEffect.Parent = game:GetService("Lighting")
gui.Name = "load"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.Parent = PlayerGui
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 1
bg.Parent = gui
center.Size = UDim2.fromScale(0.3, 0.4)
center.Position = UDim2.fromScale(0.5, 0.5)
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.BackgroundTransparency = 1
center.Parent = bg
icon.Size = UDim2.fromScale(0.5, 0.5)
icon.Position = UDim2.fromScale(0.5, 0.10)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Image = "rbxassetid://96858797315175"
icon.BackgroundTransparency = 1
icon.ImageTransparency = 1
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = center
aspect.AspectRatio = 1
aspect.Parent = icon
brand.Size = UDim2.fromScale(1, 0.15)
brand.Position = UDim2.fromScale(0.5, 0.42)
brand.AnchorPoint = Vector2.new(0.5, 0.5)
brand.Text = "Gravel.cc"
brand.Font = Enum.Font.Code
brand.TextSize = 22
brand.TextColor3 = Color3.fromRGB(200, 200, 200)
brand.TextTransparency = 1
brand.BackgroundTransparency = 1
brand.Parent = center
loadingText.Size = UDim2.fromScale(1, 0.15)
loadingText.Position = UDim2.fromScale(0.5, 0.6)
loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
loadingText.Text = "Loading"
loadingText.Font = Enum.Font.Code
loadingText.TextSize = 18
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextTransparency = 1
loadingText.BackgroundTransparency = 1
loadingText.Parent = center
bar.Size = UDim2.fromScale(1, 0.15)
bar.Position = UDim2.fromScale(0.5, 0.75)
bar.AnchorPoint = Vector2.new(0.5, 0.5)
bar.Font = Enum.Font.Code
bar.TextSize = 18
bar.TextColor3 = Color3.fromRGB(255, 255, 255)
bar.TextTransparency = 1
bar.BackgroundTransparency = 1
bar.Text = "[                    ]"
bar.Parent = center
filesText.Size = UDim2.fromScale(1, 0.15)
filesText.Position = UDim2.fromScale(0.5, 0.88)
filesText.AnchorPoint = Vector2.new(0.5, 0.5)
filesText.Text = ""
filesText.Font = Enum.Font.Code
filesText.TextSize = 14
filesText.TextColor3 = Color3.fromRGB(180, 180, 180)
filesText.TextTransparency = 1
filesText.BackgroundTransparency = 1
filesText.Parent = center
memeText.Size = UDim2.fromScale(1, 0.12)
memeText.Position = UDim2.fromScale(0.5, 0.96)
memeText.AnchorPoint = Vector2.new(0.5, 0.5)
memeText.Text = ""
memeText.Font = Enum.Font.Code
memeText.TextSize = 12
memeText.TextColor3 = Color3.fromRGB(120, 120, 120)
memeText.TextTransparency = 1
memeText.BackgroundTransparency = 1
memeText.Parent = center

local rngTitles = {
    "Gravel.cc", "G.cc", "HBSS.cc", "Gravel-est", "Gravel-er", 
    "Graaaavel.cc", "Gravelly.cc", "Gravel.com", "Hi! I'm Gravel.cc",
    "Gravel enjoyer", "GRAVEL.CC >:D", "holy gravel.cc",
    "GravelGravelGravel.cc", "I like gravel", "Gravel.cheatcheat",
    "Gravel.yes", "Gravel.no", "Gravel.lua", "GRAVEL GRAVEL.CC",
    "rock solid ui", "gravel is not sand", "is gravel just sand",
    "gravel cute :3", "gravel go brr", "Gpssickle's child",
    "shovel upgrade 1+", "crushed rocks simulator",
    "the gravel experience", "Gravel :3", "gravel sim",
    "I'm feelin' gravelly"
}

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

local fadeIn = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()
TweenService:Create(bg, fadeIn, {BackgroundTransparency = 0.4}):Play()
TweenService:Create(icon, fadeIn, {ImageTransparency = 0}):Play()
TweenService:Create(brand, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(loadingText, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(bar, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(filesText, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(memeText, fadeIn, {TextTransparency = 0}):Play()

task.spawn(function()
    while gui and gui.Parent do
        floatOffset = floatOffset + (0.5 * floatDirection)
        if floatOffset > 15 then
            floatDirection = -1
        elseif floatOffset < -15 then
            floatDirection = 1
        end
        icon.Position = UDim2.fromScale(0.5, 0.10 + (floatOffset / 1000))
        task.wait(0.02)
    end
end)

task.spawn(function()
    local lastTitleChange = 0
    while gui and gui.Parent do
        local elapsed = tick() - lastTitleChange
        if elapsed > math.random(3, 7) then
            local newTitle = rngTitles[math.random(1, #rngTitles)]
            local tween = TweenService:Create(brand, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                TextTransparency = 1
            })
            tween:Play()
            tween.Completed:Wait()
            brand.Text = newTitle
            local tween2 = TweenService:Create(brand, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                TextTransparency = 0
            })
            tween2:Play()
            lastTitleChange = tick()
        end
        task.wait(0.5)
    end
end)

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
                memeText.Text = currentText .. (cursorVisible and "_" or " ")
                task.wait(math.random(3, 8) / 100)
            else
                task.wait(math.random(15, 35) / 10)
                isErasing = true
            end
        else
            if #currentText > 0 then
                currentText = currentText:sub(1, #currentText - 1)
                memeText.Text = currentText .. (cursorVisible and "_" or " ")
                task.wait(math.random(2, 5) / 100)
            else
                isErasing = false
                currentMessage = ""
                task.wait(math.random(5, 15) / 10)
            end
        end
        
        cursorVisible = not cursorVisible
        if not isErasing and currentText ~= "" then
            memeText.Text = currentText .. (cursorVisible and "_" or " ")
        end
    end
end)

task.spawn(function()
    local totalBars = 20
    local filled = 0
    local maxDuration = 3.25
    local startTime = tick()
    local elapsed = 0
    
    if not isfolder("Gravel_Saves") then
        makefolder("Gravel_Saves")
    end
    
    local saveFiles = {}
    local files = listfiles("Gravel_Saves")
    for _, file in ipairs(files) do
        if string.match(file, "%.json$") then
            table.insert(saveFiles, file)
        end
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9120299810"
    sound.Volume = 0.5
    sound.Parent = SoundService
    local extraDelay = #saveFiles * 0.15
    local adjustedMaxDuration = maxDuration + extraDelay
    local totalFiles = #saveFiles
    local processedFiles = 0
    local loadingStates = {"Loading.", "Loading..", "Loading...", "Loading...."}
    local stateIndex = 1
    
    while elapsed < adjustedMaxDuration do
        task.wait(math.random(10, 30) / 100)
        elapsed = tick() - startTime
        if totalFiles > 0 and processedFiles < totalFiles and elapsed > (processedFiles + 1) * (adjustedMaxDuration / (totalFiles + 2)) then
            processedFiles = processedFiles + 1
            local fileName = saveFiles[processedFiles]
            fileName = string.match(fileName, "([^/\\]+)%.json$") or "Unknown"
            filesText.Text = "Files: " .. fileName
            sound:Play()
        elseif totalFiles > 0 then
            local currentFile = saveFiles[math.min(processedFiles + 1, totalFiles)]
            local displayName = currentFile and string.match(currentFile, "([^/\\]+)%.json$") or ""
            if processedFiles > 0 then
                filesText.Text = "Files: " .. displayName
            end
        end
        local targetFilled = math.min(totalBars, math.floor((elapsed / adjustedMaxDuration) * totalBars))
        
        if targetFilled > filled then
            for i = filled + 1, targetFilled do
                sound:Play()
            end
            filled = targetFilled
        elseif math.random() < 0.75 and filled < totalBars then
            sound:Play()
            filled = math.min(totalBars, filled + 1)
        end

        local visual = string.rep("|", filled)
        local empty = string.rep(" ", totalBars - filled)
        bar.Text = "[" .. visual .. empty .. "]"
        
        stateIndex = (stateIndex % #loadingStates) + 1
        loadingText.Text = loadingStates[stateIndex]
    end
    filled = totalBars
    bar.Text = "[" .. string.rep("|", totalBars) .. "]"
    loadingText.Text = "Loaded"
    
    if totalFiles > 0 then
        filesText.Text = "Files: " .. totalFiles .. " saves loaded"
    else
        filesText.Text = "No Files: I checked for no reason 💔🥀"
    end

    task.wait(0.6)
    sound:Destroy()
    local fadeOut = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blurEffect, fadeOut, {Size = 0}):Play()
    TweenService:Create(bg, fadeOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(icon, fadeOut, {ImageTransparency = 1}):Play()
    TweenService:Create(brand, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(loadingText, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(bar, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(filesText, fadeOut, {TextTransparency = 1}):Play()
    TweenService:Create(memeText, fadeOut, {TextTransparency = 1}):Play()

    task.wait(1)
    gui:Destroy()
    blurEffect:Destroy()
end)
