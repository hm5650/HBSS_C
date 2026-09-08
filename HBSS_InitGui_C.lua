local InitGuiModule = {}
local InitGui = {}
InitGui.__index = InitGui
function InitGui.new()
    local self = setmetatable({}, InitGui)
    self.gui = nil
    self.bg = nil
    self.gravelVideo = nil
    self.icon = nil
    self.title = nil
    self.status = nil
    self.dots = nil
    self.blurEffect = nil
    self.floatOffset = 0
    self.floatDirection = 1
    self.gravelFrames = {
        "rbxassetid://77615568468059",
        "rbxassetid://134610085244549",
        "rbxassetid://96860104682417"
    }
    self.currentFrame = 1
    self.floatTask = nil
    self.gravelTask = nil
    self.frameTask = nil
    self.statusTask = nil
    self.dotTask = nil
    return self
end
function InitGui:create()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "InitializingGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    self.gui = gui
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")
    self.blurEffect = blurEffect
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.7
    bg.Parent = gui
    self.bg = bg
    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.4)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.Parent = bg
    local gravelVideo = Instance.new("ImageLabel")
    gravelVideo.Size = UDim2.fromScale(0.4, 0.45)
    gravelVideo.Position = UDim2.fromScale(0.5, 0.25)
    gravelVideo.AnchorPoint = Vector2.new(0.5, 0.5)
    gravelVideo.Image = self.gravelFrames[1]
    gravelVideo.BackgroundTransparency = 1
    gravelVideo.ImageTransparency = 0
    gravelVideo.ScaleType = Enum.ScaleType.Fit
    gravelVideo.Parent = center
    self.gravelVideo = gravelVideo
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromScale(0.15, 0.15)
    icon.Position = UDim2.fromScale(0.5, 0.35)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Image = "rbxassetid://96858797315175"
    icon.BackgroundTransparency = 1
    icon.ImageTransparency = 0
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = center
    self.icon = icon
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.15)
    title.Position = UDim2.fromScale(0.5, 0.6)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Text = "initializing"
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextTransparency = 0
    title.BackgroundTransparency = 1
    title.Parent = center
    self.title = title
    local status = Instance.new("TextLabel")
    status.Size = UDim2.fromScale(1, 0.15)
    status.Position = UDim2.fromScale(0.5, 0.78)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Text = ""
    status.Font = Enum.Font.Code
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextTransparency = 0
    status.BackgroundTransparency = 1
    status.Parent = center
    self.status = status
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.fromScale(1, 0.1)
    dots.Position = UDim2.fromScale(0.5, 0.92)
    dots.AnchorPoint = Vector2.new(0.5, 0.5)
    dots.Text = ""
    dots.Font = Enum.Font.Code
    dots.TextSize = 18
    dots.TextColor3 = Color3.fromRGB(200, 200, 200)
    dots.TextTransparency = 0
    dots.BackgroundTransparency = 1
    dots.Parent = center
    self.dots = dots
    local fadeIn = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()
    TweenService:Create(bg, fadeIn, {BackgroundTransparency = 0.4}):Play()
    self:startAnimations()
    return self
end
function InitGui:startAnimations()
    self.frameTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.currentFrame = self.currentFrame % #self.gravelFrames + 1
            self.gravelVideo.Image = self.gravelFrames[self.currentFrame]
            task.wait(0.1)
        end
    end)
    self.floatTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.floatOffset = self.floatOffset + (0.5 * self.floatDirection)
            if self.floatOffset > 15 then
                self.floatDirection = -1
            elseif self.floatOffset < -15 then
                self.floatDirection = 1
            end
            self.icon.Position = UDim2.fromScale(0.5, 0.35 + (self.floatOffset / 1000))
            task.wait(0.02)
        end
    end)
    self.gravelTask = task.spawn(function()
        local gravelFloat = 0
        local gravelDir = 1
        while self.gui and self.gui.Parent do
            gravelFloat = gravelFloat + (0.2 * gravelDir)
            if gravelFloat > 8 then
                gravelDir = -1
            elseif gravelFloat < -8 then
                gravelDir = 1
            end
            self.gravelVideo.Position = UDim2.fromScale(0.5, 0.25 + (gravelFloat / 1000))
            task.wait(0.02)
        end
    end)
    local dotCount = 0
    self.dotTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            dotCount = (dotCount % 3) + 1
            self.dots.Text = string.rep(".", dotCount)
            task.wait(0.35)
        end
    end)
end
function InitGui:setStatus(text)
    if self.status then
        self.status.Text = text
    end
end
function InitGui:destroy()
    if self.gui and self.gui.Parent then
        if self.frameTask then
            task.cancel(self.frameTask)
            self.frameTask = nil
        end
        if self.floatTask then
            task.cancel(self.floatTask)
            self.floatTask = nil
        end
        if self.gravelTask then
            task.cancel(self.gravelTask)
            self.gravelTask = nil
        end
        if self.dotTask then
            task.cancel(self.dotTask)
            self.dotTask = nil
        end
        if self.statusTask then
            task.cancel(self.statusTask)
            self.statusTask = nil
        end
        local TweenService = game:GetService("TweenService")
        local fadeOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if self.blurEffect then
            TweenService:Create(self.blurEffect, fadeOut, {Size = 0}):Play()
        end
        if self.bg then
            TweenService:Create(self.bg, fadeOut, {BackgroundTransparency = 1}):Play()
        end
        if self.gravelVideo then
            TweenService:Create(self.gravelVideo, fadeOut, {ImageTransparency = 1}):Play()
        end
        if self.icon then
            TweenService:Create(self.icon, fadeOut, {ImageTransparency = 1}):Play()
        end
        if self.title then
            TweenService:Create(self.title, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.status then
            TweenService:Create(self.status, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.dots then
            TweenService:Create(self.dots, fadeOut, {TextTransparency = 1}):Play()
        end
        task.wait(0.7)
        if self.blurEffect then
            self.blurEffect:Destroy()
        end
        if self.gui then
            self.gui:Destroy()
        end
        self.gui = nil
        self.bg = nil
        self.gravelVideo = nil
        self.icon = nil
        self.title = nil
        self.status = nil
        self.dots = nil
        self.blurEffect = nil
    end
end
local initGui = InitGui.new():create()
getgenv().destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
getgenv().setInitStatus = function(text)
    if initGui then
        initGui:setStatus(text)
    end
end
getgenv().InitGui_ = initGui
