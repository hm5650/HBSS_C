--me wants 2 choose dat a 1
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local normiee = "rbxassetid://107415934558527"
local glitchy = {
    "rbxassetid://126903901230171",
    "rbxassetid://108334175828481",
    "rbxassetid://76083829320576",
    "rbxassetid://77937445438901",
}
local soundhover = "rbxassetid://9120299810"
local soundclick = "rbxassetid://139246456147301"
local glitchsounds = {
    "rbxassetid://131507757356742",
    "rbxassetid://140043289814504",
    "rbxassetid://129687541350237",
}
local random = math.random
local rngTitles = {
    "Gravel.cc", "G.cc", "HBSS.cc", "Gravel-est", "Gravel-er",
    "Graaaavel.cc", "Gravelly.cc", "Gravel.com", "Hi! I'm Gravel.cc",
    "Gravel :3", "GRAVEL.CC >:D", "holy gravel.cc",
    "GravelGravelGravel.cc", "I like gravel", "Gravel.cheatcheat",
    "Gravel.yes", "Gravel.no", "Gravel.lua", "GRAVEL GRAVEL.CC",
    "rock solid ui", "gravel is not sand", "is gravel just sand",
    "gravel cute :3", "gravel go brr", "Gpssickle's child",
    "shovel upgrade 1+", "crushed rocks simulator", "the gravel experience"
}
local ScreenGui = Instance.new("ScreenGui")
local blur = Instance.new("BlurEffect")
local bg = Instance.new("Frame")
local glitchFrame = Instance.new("Frame")
local mainImg = Instance.new("ImageLabel")
ScreenGui.Name = "option"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 2147483646
ScreenGui.Parent = CoreGui
blur.Size = 0
blur.Parent = Lighting
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0
bg.BorderSizePixel = 0
bg.ZIndex = 0
bg.Parent = ScreenGui
glitchFrame.Size = UDim2.fromScale(1, 1)
glitchFrame.BackgroundColor3 = Color3.new(0, 0, 0)
glitchFrame.BackgroundTransparency = 1
glitchFrame.ZIndex = 100
glitchFrame.Parent = ScreenGui
mainImg.Name = "MainImage"
mainImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
mainImg.AnchorPoint = Vector2.new(0.5, 0.5)
mainImg.Image = normiee
mainImg.ZIndex = 1
mainImg.BorderSizePixel = 0
mainImg.Size = UDim2.new(0, 370, 0, 320)
mainImg.Position = UDim2.new(0.5, 0, 0.5, 0)
mainImg.ScaleType = Enum.ScaleType.Fit
mainImg.BackgroundTransparency = 1
mainImg.ImageTransparency = 1
mainImg.Parent = ScreenGui
local originalPos = UDim2.new(0.5, 0, 0.5, 0)
local function glitch(offset)
    if offset and offset > 0 then
        mainImg.Position = UDim2.new(
            0.5,
            (random(0, 1) == 0 and -offset or offset),
            0.5,
            (random(0, 1) == 0 and -offset or offset)
        )
        mainImg.Image = glitchy[random(1, #glitchy)]
    else
        mainImg.Position = originalPos
        mainImg.Image = normiee
    end
end
local soundPool = {}
for i, id in ipairs(glitchsounds) do
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = 0.12
    s.Parent = ScreenGui
    soundPool[i] = s
end
local function playGlitch()
    local s = soundPool[random(1, #soundPool)]
    if s then s:Play() end
end
local hoverSoundPool = {}
for i, id in ipairs(glitchsounds) do
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = 0.04
    s.Parent = ScreenGui
    hoverSoundPool[i] = s
end
local hoverIndex = 0
local function playHoverGlitch()
    hoverIndex = hoverIndex + 1
    if hoverIndex > #hoverSoundPool then
        hoverIndex = 1
    end
    local s = hoverSoundPool[hoverIndex]
    if s then
        s:Stop()
        s:Play()
    end
end
local function playSound(id, vol)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 0.2
    s.Parent = ScreenGui
    s:Play()
    task.delay(3, function() s:Destroy() end)
end
local function makeLabel(name, pos, size, text, align)
    local l = Instance.new("TextLabel")
    l.Name = name
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 12
    l.Font = Enum.Font.Code
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    l.Text = text
    l.TextTransparency = 1
    l.Size = UDim2.new(0, size.X, 0, size.Y)
    l.Position = UDim2.new(0, pos.X, 0, pos.Y)
    l.ZIndex = 2
    l.Parent = mainImg
    return l
end
local titleLabel = makeLabel(
    "Title",
    Vector2.new(120, 26),
    Vector2.new(200, 16),
    "Gravel.cc",
    Enum.TextXAlignment.Right
)
titleLabel.TextSize = 14
local subtitleLabel = makeLabel(
    "Subtitle",
    Vector2.new(80, 44),
    Vector2.new(240, 14),
    "choose ur adventure or smth",
    Enum.TextXAlignment.Right
)
subtitleLabel.TextSize = 10
subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "TextButton"
closeBtn.Visible = true
closeBtn.TextWrapped = true
closeBtn.BorderMode = Enum.BorderMode.Outline
closeBtn.TextTransparency = 1
closeBtn.TextStrokeTransparency = 1
closeBtn.AnchorPoint = Vector2.new(0, 0)
closeBtn.AutomaticSize = Enum.AutomaticSize.None
closeBtn.ClipsDescendants = false
closeBtn.LayoutOrder = 0
closeBtn.Selectable = false
closeBtn.ZIndex = 5
closeBtn.BorderSizePixel = 0
closeBtn.Size = UDim2.new(0, 43, 0, 25)
closeBtn.Active = true
closeBtn.RichText = false
closeBtn.TextSize = 15
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.Text = "X"
closeBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.AutoButtonColor = true
closeBtn.Rotation = 0
closeBtn.Font = Enum.Font.Code
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(0, 315, 0, 15)
closeBtn.TextXAlignment = Enum.TextXAlignment.Center
closeBtn.TextYAlignment = Enum.TextYAlignment.Center
closeBtn.TextScaled = false
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = mainImg
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn
local closeGradient = Instance.new("UIGradient")
closeGradient.Enabled = true
closeGradient.Transparency = NumberSequence.new(0)
closeGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
closeGradient.Rotation = 180
closeGradient.Parent = closeBtn
local function makeOptionButton(text, desc, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = "Option_" .. text
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.ZIndex = 3
    btn.TextTransparency = 1
    btn.Parent = mainImg
    local line1 = Instance.new("TextLabel")
    line1.BackgroundTransparency = 1
    line1.Text = "> " .. text
    line1.TextColor3 = Color3.fromRGB(255, 255, 255)
    line1.TextSize = 12
    line1.Font = Enum.Font.Code
    line1.TextXAlignment = Enum.TextXAlignment.Left
    line1.TextYAlignment = Enum.TextYAlignment.Top
    line1.Size = UDim2.new(1, 0, 0, 14)
    line1.Position = UDim2.new(0, 0, 0, 0)
    line1.TextTransparency = 1
    line1.ZIndex = 4
    line1.Parent = btn
    local line2 = Instance.new("TextLabel")
    line2.BackgroundTransparency = 1
    line2.Text = "  " .. desc
    line2.TextColor3 = Color3.fromRGB(140, 140, 140)
    line2.TextSize = 10
    line2.Font = Enum.Font.Code
    line2.TextXAlignment = Enum.TextXAlignment.Left
    line2.TextYAlignment = Enum.TextYAlignment.Top
    line2.Size = UDim2.new(1, 0, 0, 24)
    line2.Position = UDim2.new(0, 0, 0, 16)
    line2.TextWrapped = true
    line2.TextTransparency = 1
    line2.ZIndex = 4
    line2.Parent = btn
    return btn, line1, line2
end
local legacyBtn, lLegacy1, lLegacy2 = makeOptionButton(
    "LEGACY VERSION",
    "Good old days, won't be updated\n(bad injectors work here)",
    80
)
local newBtn, lNew1, lNew2 = makeOptionButton(
    "NEW VERSION",
    "New bs & updated regularly\n(bad injectors NOT recommended)",
    170
)
local function onHover(l1, l2, hovered)
    TweenService:Create(l1, TweenInfo.new(0.15), {
        TextColor3 = hovered and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 255, 255)
    }):Play()
    TweenService:Create(l2, TweenInfo.new(0.15), {
        TextColor3 = hovered and Color3.fromRGB(180, 255, 180) or Color3.fromRGB(140, 140, 140)
    }):Play()
end
legacyBtn.MouseEnter:Connect(function()
    onHover(lLegacy1, lLegacy2, true)
    playSound(soundhover, 0.15)
    playHoverGlitch()
    glitch(random(2, 6))
    task.delay(0.1, function() glitch(0) end)
end)
legacyBtn.MouseLeave:Connect(function() onHover(lLegacy1, lLegacy2, false) end)
newBtn.MouseEnter:Connect(function()
    onHover(lNew1, lNew2, true)
    playSound(soundhover, 0.15)
    playHoverGlitch()
    glitch(random(2, 6))
    task.delay(0.1, function() glitch(0) end)
end)
newBtn.MouseLeave:Connect(function() onHover(lNew1, lNew2, false) end)
closeBtn.MouseEnter:Connect(function()
    playSound(soundhover, 0.15)
    playHoverGlitch()
    glitch(random(2, 6))
    task.delay(0.1, function() glitch(0) end)
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.7
    }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 1
    }):Play()
end)
task.spawn(function()
    local last = 0
    while ScreenGui and ScreenGui.Parent do
        if tick() - last > random(4, 9) then
            local t = TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1})
            t:Play()
            t.Completed:Wait()
            titleLabel.Text = rngTitles[random(1, #rngTitles)]
            TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            last = tick()
        end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if random() < 0.55 then
            glitch(random(2, 8))
            playGlitch()
            task.wait(random(1, 4) / 10)
            glitch(0)
        end
        task.wait(1.5)
    end
end)
local function idk()
    blur.Size = 24
    glitchFrame.BackgroundTransparency = 0
    task.wait(0.05)
    for i = 1, 6 do
        glitch(random(4, 12))
        playGlitch()
        task.wait(0.05)
        glitch(0)
        task.wait(0.03)
    end
    TweenService:Create(glitchFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    TweenService:Create(mainImg, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
    task.wait(0.1)
    TweenService:Create(titleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(subtitleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.4), {TextTransparency = 0, BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    TweenService:Create(lLegacy1, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(lLegacy2, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(lNew1, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(lNew2, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
end
local function get(url)
    local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blur, info, {Size = 0}):Play()
    TweenService:Create(mainImg, info, {ImageTransparency = 1}):Play()
    TweenService:Create(bg, info, {BackgroundTransparency = 1}):Play()
    for _, v in ipairs(mainImg:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            TweenService:Create(v, info, {TextTransparency = 1}):Play()
        end
    end
    task.wait(0.5)
    ScreenGui:Destroy()
    blur:Destroy()
    loadstring(game:HttpGet(url))()
end
local function closeGui()
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blur, info, {Size = 0}):Play()
    TweenService:Create(mainImg, info, {ImageTransparency = 1}):Play()
    TweenService:Create(bg, info, {BackgroundTransparency = 1}):Play()
    for _, v in ipairs(mainImg:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            TweenService:Create(v, info, {TextTransparency = 1}):Play()
        end
    end
    task.wait(0.4)
    ScreenGui:Destroy()
    blur:Destroy()
end
legacyBtn.MouseButton1Click:Connect(function()
    playSound(soundclick, 0.3)
    get("https://raw.githubusercontent.com/hm5650/HBSS/refs/heads/main/HBSS_Old.lua")
end)
newBtn.MouseButton1Click:Connect(function()
    playSound(soundclick, 0.3)
    get("https://raw.githubusercontent.com/hm5650/HBSS_C/refs/heads/main/HBSS_C.lua")
end)
closeBtn.MouseButton1Click:Connect(function()
    playSound(soundclick, 0.3)
    closeGui()
end)
idk()
