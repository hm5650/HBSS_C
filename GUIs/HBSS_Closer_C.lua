-- 999% not redliner inspired
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local startSound = Instance.new("Sound")
startSound.SoundId = "rbxassetid://121769472475128"
startSound.Volume = 0.5
startSound.Parent = SoundService
local flashSound = Instance.new("Sound")
flashSound.SoundId = "rbxassetid://85431715800788"
flashSound.Volume = 0.5
flashSound.Parent = SoundService
local glitchSoundIds = {
    "rbxassetid://131507757356742",
    "rbxassetid://140043289814504",
    "rbxassetid://129687541350237"
}
local glitchSounds = {}
for i, id in ipairs(glitchSoundIds) do
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = 0.3
    sound.Parent = SoundService
    glitchSounds[i] = sound
end
local closeGui = Instance.new("ScreenGui")
closeGui.Name = "CloseAnimation"
closeGui.ResetOnSpawn = false
closeGui.IgnoreGuiInset = true
closeGui.DisplayOrder = 2147483647
closeGui.Parent = CoreGui
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0
bg.ZIndex = 1
bg.Parent = closeGui
local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "ImageLabel"
imageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
imageLabel.BorderMode = Enum.BorderMode.Outline
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Image = "rbxassetid://90883814387167"
imageLabel.ImageRectSize = Vector2.new(0, 0)
imageLabel.ZIndex = 2
imageLabel.BorderSizePixel = 0
imageLabel.Size = UDim2.new(0, 412, 0, 413)
imageLabel.ScaleType = Enum.ScaleType.Stretch
imageLabel.ClipsDescendants = false
imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
imageLabel.AutomaticSize = Enum.AutomaticSize.None
imageLabel.LayoutOrder = 0
imageLabel.Rotation = 0
imageLabel.ResampleMode = Enum.ResamplerMode.Default
imageLabel.BackgroundTransparency = 1
imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
imageLabel.Visible = true
imageLabel.ImageRectOffset = Vector2.new(0, 0)
imageLabel.ImageTransparency = 0
imageLabel.BackgroundColor3 = Color3.fromRGB(246, 247, 249)
imageLabel.Parent = closeGui
local byeLabel = Instance.new("TextLabel")
byeLabel.Name = "goodbyelabel"
byeLabel.Visible = true
byeLabel.TextWrapped = true
byeLabel.BorderMode = Enum.BorderMode.Outline
byeLabel.TextTransparency = 0
byeLabel.TextStrokeTransparency = 1
byeLabel.AnchorPoint = Vector2.new(0, 0)
byeLabel.AutomaticSize = Enum.AutomaticSize.None
byeLabel.ClipsDescendants = false
byeLabel.LayoutOrder = 0
byeLabel.ZIndex = 3
byeLabel.BorderSizePixel = 0
byeLabel.Size = UDim2.new(0, 231, 0, 25)
byeLabel.Selectable = false
byeLabel.RichText = false
byeLabel.Active = true
byeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
byeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
byeLabel.Text = "water"
byeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
byeLabel.TextSize = 15
byeLabel.Rotation = 0
byeLabel.Font = Enum.Font.Code
byeLabel.BackgroundTransparency = 1
byeLabel.Position = UDim2.new(0, 93, 0, 199)
byeLabel.TextXAlignment = Enum.TextXAlignment.Center
byeLabel.TextYAlignment = Enum.TextYAlignment.Center
byeLabel.TextScaled = false
byeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
byeLabel.Parent = imageLabel
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting
local goodbyeMessages = {
    "alr vro",
    "not redliner 100%",
    "yesszierski",
    "haks in ur mainframe",
    "gravel > sand",
    "uhh tuff outro :p",
    "buh bye",
    "dopamine inducing outro",
    "WAHHHHHH",
    "BLEHH >:p",
    "*hacks u*",
    "[insert byemsg here]",
    "happy 20th bday rblx",
    "cool circle ASCII art",
    "wait wat",
    "how DARE u >:(",
    "why unload me",
    "never unload me again",
    "67 kid h8s 67",
    "u shan't unload me",
}
local frames = {
    "90883814387167",
    "131613602673348",
    "86081363842574",
    "103806077565616",
    "134652450383698"
}
local currentFrame = 1
local frameCount = #frames
local loopCount = 0
byeLabel.Text = "[G.cc]: " .. goodbyeMessages[math.random(1, #goodbyeMessages)]
startSound:Play()
local fadeIn = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()
while loopCount < 3 do
    for i = 1, frameCount do
        imageLabel.Image = "rbxassetid://" .. frames[i]
        if math.random() < 0.3 then
            glitchSounds[math.random(1, #glitchSounds)]:Play()
        end
        local offsetX = math.random(-8, 8)
        local offsetY = math.random(-5, 5)
        imageLabel.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
        task.wait(0.1)
    end
    loopCount = loopCount + 1
    if loopCount < 3 then
        for _ = 1, math.random(2, 5) do
            local randomFrame = frames[math.random(1, frameCount)]
            imageLabel.Image = "rbxassetid://" .. randomFrame
            glitchSounds[math.random(1, #glitchSounds)]:Play()
            local offsetX = math.random(-15, 15)
            local offsetY = math.random(-10, 10)
            imageLabel.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
            task.wait(0.03)
        end
        byeLabel.Text = "[G.cc]: " .. goodbyeMessages[math.random(1, #goodbyeMessages)]
    end
end
for i = 1, 10 do
    local randomFrame = frames[math.random(1, frameCount)]
    imageLabel.Image = "rbxassetid://" .. randomFrame
    if i % 2 == 0 then
        glitchSounds[math.random(1, #glitchSounds)]:Play()
    end
    local offsetX = math.random(-20, 20)
    local offsetY = math.random(-15, 15)
    imageLabel.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
    if i % 2 == 0 then
        byeLabel.TextTransparency = 0.5
    else
        byeLabel.TextTransparency = 0
    end
    task.wait(0.05)
end
local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
flash.BackgroundTransparency = 0
flash.ZIndex = 100
flash.Parent = closeGui
flashSound:Play()
local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TweenService:Create(blurEffect, fadeOut, {Size = 0}):Play()
TweenService:Create(flash, fadeOut, {BackgroundTransparency = 1}):Play()
task.wait(0.1)
closeGui:Destroy()
blurEffect:Destroy()
startSound:Destroy()
flashSound:Destroy()
for _, sound in ipairs(glitchSounds) do
    sound:Destroy()
end
