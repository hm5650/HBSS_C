
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

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
icon.Image = "rbxassetid://7734056878"
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

local fadeIn = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()
TweenService:Create(bg, fadeIn, {BackgroundTransparency = 0.4}):Play()
TweenService:Create(icon, fadeIn, {ImageTransparency = 0}):Play()
TweenService:Create(brand, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(loadingText, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(bar, fadeIn, {TextTransparency = 0}):Play()
TweenService:Create(filesText, fadeIn, {TextTransparency = 0}):Play()

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
        if math.random() < 0.3 then
            loadingText.Text = "Loading."
        elseif math.random() < 0.6 then
            loadingText.Text = "Loading.."
        else
            loadingText.Text = "Loading..."
        end
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

    task.wait(1)
    gui:Destroy()
    blurEffect:Destroy()
end)
