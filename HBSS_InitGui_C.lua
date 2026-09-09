local InitGuiModule = {}
local InitGui = {}
InitGui.__index = InitGui
function InitGui.new()
    local self = setmetatable({}, InitGui)
    self.gui = nil
    self.bg = nil
    self.gravelVideo = nil
    self.blurEffect = nil
    self.gravelFrames = {
        "rbxassetid://77615568468059",
        "rbxassetid://134610085244549",
        "rbxassetid://96860104682417"
    }
    self.currentFrame = 1
    self.frameTask = nil
    self.gravelTask = nil
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
    gui.DisplayOrder = 2147483647
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")
    self.blurEffect = blurEffect
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.7
    bg.ZIndex = 2
    bg.Parent = gui
    self.bg = bg
    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.3)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.ZIndex = 3
    center.Parent = bg
    local gravelVideo = Instance.new("ImageLabel")
    gravelVideo.Size = UDim2.fromScale(0.67, 0.67)
    gravelVideo.Position = UDim2.fromScale(0.5, 0.5)
    gravelVideo.AnchorPoint = Vector2.new(0.5, 0.5)
    gravelVideo.Image = self.gravelFrames[1]
    gravelVideo.BackgroundTransparency = 1
    gravelVideo.ImageTransparency = 0
    gravelVideo.ScaleType = Enum.ScaleType.Fit
    gravelVideo.ZIndex = 4
    gravelVideo.Parent = center
    self.gravelVideo = gravelVideo
    local fadeIn = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(blurEffect, fadeIn, {Size = 24}):Play()
    TweenService:Create(bg, fadeIn, {BackgroundTransparency = 0.7}):Play()
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
    self.gravelTask = task.spawn(function()
        local gravelFloat = 0
        local gravelDir = 1
        while self.gui and self.gui.Parent do
            gravelFloat = gravelFloat + (0.15 * gravelDir)
            if gravelFloat > 10 then
                gravelDir = -1
            elseif gravelFloat < -10 then
                gravelDir = 1
            end
            self.gravelVideo.Position = UDim2.fromScale(0.5, 0.5 + (gravelFloat / 1000))
            task.wait(0.02)
        end
    end)
end
function InitGui:destroy()
    if self.gui and self.gui.Parent then
        if self.frameTask then
            task.cancel(self.frameTask)
            self.frameTask = nil
        end
        if self.gravelTask then
            task.cancel(self.gravelTask)
            self.gravelTask = nil
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
getgenv().InitGui_ = initGui
