local TargetIndicator = {}
TargetIndicator.__index = TargetIndicator
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local C = {
    DefaultPosition = UDim2.new(0, 459, 0, 5),
    FrameSize = UDim2.new(0, 250, 0, 142),
    Slots = 43,
    HealthBarBasePos = UDim2.new(0, 58, 0, 104),
    HealthBarSize = UDim2.new(0, 181, 0, 25),
    BaseImgTransparency = 0.2,
    BaseTxtTransparency = 0,
    FadeInDuration = 0.20,
    FadeOutDuration = 0.12,
    FadeInStyle = Enum.EasingStyle.Quad,
    FadeOutStyle = Enum.EasingStyle.Quad,
    DamageFlashDuration = 1.5,
    DamageRestoreTime = 0.3,
    ShakeDuration = 0.4,
    ShakeMin = 4,
    ShakeMax = 12,
    DamageRed = Color3.fromRGB(255, 70, 70),
    NormalWhite = Color3.fromRGB(255, 255, 255),
    UpdateInterval = 1/30,
    PlaceholderImage = "rbxassetid://125957552249539",
    FrameImage = "rbxassetid://125957552249539",
}
local function TargetIndicator.new(opts)
    opts = opts or {}
    local self = setmetatable({}, TargetIndicator)
    self.Config = nil
    self.Enabled = false
    self.Draggable = false
    self.Visible = false
    self._targetId = nil
    self._lastHealth = nil
    self._lastMaxHealth = nil
    self._damageTimer = 0
    self._shakeTimer = 0
    self._shakeIntensity= 0
    self._accum = 0
    self._conns = {}
    self:_buildGui(opts.position or C.DefaultPosition)
    self:setDraggable(opts.draggable == true)
    self:_startLoop()
    return self
end
local function TargetIndicator:_buildGui(position)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "indicator"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483646
    screenGui.Parent = PlayerGui
    self.ScreenGui = screenGui
    local main = Instance.new("ImageLabel")
    main.Name = "MainFrame"
    main.ImageColor3 = Color3.fromRGB(255, 255, 255)
    main.BorderMode = Enum.BorderMode.Outline
    main.AnchorPoint = Vector2.new(0, 0)
    main.Image = C.FrameImage
    main.ImageRectSize = Vector2.new(0, 0)
    main.ZIndex = 1
    main.BorderSizePixel = 0
    main.Size = C.FrameSize
    main.ScaleType = Enum.ScaleType.Fit
    main.ClipsDescendants = true
    main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    main.AutomaticSize = Enum.AutomaticSize.None
    main.LayoutOrder = 0
    main.Rotation = 0
    main.ResampleMode = Enum.ResamplerMode.Default
    main.BackgroundTransparency = 1
    main.Position = position
    main.Visible = true
    main.ImageRectOffset = Vector2.new(0, 0)
    main.ImageTransparency = 1
    main.BackgroundColor3 = Color3.fromRGB(246, 247, 249)
    main.Active = true
    main.Draggable = false
    main.Parent = screenGui
    self.MainImage = main
    local healthBar = Instance.new("TextLabel")
    healthBar.Name = "HealthBar"
    healthBar.Visible = true
    healthBar.TextWrapped = true
    healthBar.BorderMode = Enum.BorderMode.Outline
    healthBar.TextTransparency = 1
    healthBar.TextStrokeTransparency = 1
    healthBar.AnchorPoint = Vector2.new(0, 0)
    healthBar.AutomaticSize = Enum.AutomaticSize.None
    healthBar.ClipsDescendants = false
    healthBar.LayoutOrder = 0
    healthBar.ZIndex = 1
    healthBar.BorderSizePixel = 0
    healthBar.Size = C.HealthBarSize
    healthBar.Selectable = false
    healthBar.RichText = false
    healthBar.Active = true
    healthBar.TextColor3 = C.NormalWhite
    healthBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    healthBar.Text = "[" .. string.rep(" ", C.Slots) .. "]"
    healthBar.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthBar.TextSize = 8
    healthBar.Rotation = 0
    healthBar.Font = Enum.Font.Code
    healthBar.BackgroundTransparency = 1
    healthBar.Position = C.HealthBarBasePos
    healthBar.TextXAlignment = Enum.TextXAlignment.Left
    healthBar.TextYAlignment = Enum.TextYAlignment.Center
    healthBar.TextScaled = false
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    healthBar.Parent = main
    self.HealthBar = healthBar
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Visible = true
    healthLabel.TextWrapped = true
    healthLabel.BorderMode = Enum.BorderMode.Outline
    healthLabel.TextTransparency = 1
    healthLabel.TextStrokeTransparency = 1
    healthLabel.AnchorPoint = Vector2.new(0, 0)
    healthLabel.AutomaticSize = Enum.AutomaticSize.None
    healthLabel.ClipsDescendants = false
    healthLabel.LayoutOrder = 0
    healthLabel.ZIndex = 1
    healthLabel.BorderSizePixel = 0
    healthLabel.Size = UDim2.new(0, 67, 0, 35)
    healthLabel.Selectable = false
    healthLabel.RichText = false
    healthLabel.Active = true
    healthLabel.TextColor3 = C.NormalWhite
    healthLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Text = "Health"
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.TextSize = 10
    healthLabel.Rotation = 0
    healthLabel.Font = Enum.Font.Code
    healthLabel.BackgroundTransparency = 1
    healthLabel.Position = UDim2.new(0, 118, 0, 88)
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.TextYAlignment = Enum.TextYAlignment.Center
    healthLabel.TextScaled = false
    healthLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.Parent = main
    self.HealthLabel = healthLabel
    local profile = Instance.new("ImageLabel")
    profile.Name = "Profile"
    profile.ImageColor3 = C.NormalWhite
    profile.BorderMode = Enum.BorderMode.Outline
    profile.AnchorPoint = Vector2.new(0, 0)
    profile.Image = C.PlaceholderImage
    profile.ImageRectSize = Vector2.new(0, 0)
    profile.ZIndex = 1
    profile.BorderSizePixel = 0
    profile.Size = UDim2.new(0, 41, 0, 40)
    profile.ScaleType = Enum.ScaleType.Stretch
    profile.ClipsDescendants = false
    profile.BorderColor3 = Color3.fromRGB(0, 0, 0)
    profile.AutomaticSize = Enum.AutomaticSize.None
    profile.LayoutOrder = 0
    profile.Rotation = 0
    profile.ResampleMode = Enum.ResamplerMode.Default
    profile.BackgroundTransparency = 1
    profile.Position = UDim2.new(0, 20, 0, 22)
    profile.Visible = true
    profile.ImageRectOffset = Vector2.new(0, 0)
    profile.ImageTransparency = 1
    profile.BackgroundColor3 = Color3.fromRGB(246, 247, 249)
    profile.Parent = main
    self.ProfileImage = profile
    local corner = Instance.new("UICorner")
    corner.Name = "UICorner"
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = profile
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Visible = true
    nameLabel.TextWrapped = true
    nameLabel.BorderMode = Enum.BorderMode.Outline
    nameLabel.TextTransparency = 1
    nameLabel.TextStrokeTransparency = 1
    nameLabel.AnchorPoint = Vector2.new(0, 0)
    nameLabel.AutomaticSize = Enum.AutomaticSize.None
    nameLabel.ClipsDescendants = false
    nameLabel.LayoutOrder = 0
    nameLabel.ZIndex = 1
    nameLabel.BorderSizePixel = 0
    nameLabel.Size = UDim2.new(0, 147, 0, 26)
    nameLabel.Selectable = false
    nameLabel.RichText = false
    nameLabel.Active = true
    nameLabel.TextColor3 = C.NormalWhite
    nameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = "< name"
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize = 10
    nameLabel.Rotation = 0
    nameLabel.Font = Enum.Font.Code
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 61, 0, 29)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextYAlignment = Enum.TextYAlignment.Center
    nameLabel.TextScaled = false
    nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Parent = main
    self.NameLabel = nameLabel
end
local function TargetIndicator:_startLoop()
    local conn = RunService.Heartbeat:Connect(function(dt)
        self:_tick(dt)
    end)
    table.insert(self._conns, conn)
end
local function TargetIndicator:_tick(dt)
    self:_updateShake(dt)
    self:_updateDamageFlash(dt)
    self._accum = self._accum + dt
    if self._accum < C.UpdateInterval then return end
    self._accum = 0
    if not self.Enabled or not self.Config then
        if self.Visible then self:hide() end
        return
    end
    local target = self:_resolveTarget()
    local char, humanoid = self:_getCharHumanoid(target)
    if not humanoid or humanoid.Health <= 0 then
        if self.Visible then self:hide() end
        return
    end
    if not self.Visible then self:show() end
    self:_updateDisplay(target, humanoid)
    self:_handleHealthChange(target, humanoid)
end
local function TargetIndicator:_resolveTarget()
    local cfg = self.Config
    if not cfg then return nil end
    if cfg.SA2_Enabled and cfg.SA2_currentTarget then
        return cfg.SA2_currentTarget
    end
    if cfg.startsa and cfg.currentTarget then
        return cfg.currentTarget
    end
    if cfg.aimbotEnabled and cfg.aimbotCurrentTarget then
        return cfg.aimbotCurrentTarget
    end
    if cfg.tbot and cfg.tbot.enabled and cfg.tbotcurrenttarget then
        return cfg.tbotcurrenttarget
    end
    return nil
end
local function TargetIndicator:_getCharHumanoid(target)
    if not target or typeof(target) ~= "Instance" then return nil, nil end
    local char
    if target:IsA("Player") then
        char = target.Character
    elseif target:IsA("Model") then
        char = target
    else
        return nil, nil
    end
    if not char then return nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid")
end
local function TargetIndicator:_updateDisplay(target, humanoid)
    local name
    if typeof(target) == "Instance" and target:IsA("Player") then
        name = target.DisplayName or target.Name
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        name = target.Name
    else
        name = "Unknown"
    end
    self.NameLabel.Text = "< " .. tostring(name)
    if typeof(target) == "Instance" and target:IsA("Player") and target.UserId and target.UserId > 0 then
        local thumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(target.UserId)
        if self.ProfileImage.Image ~= thumb then
            self.ProfileImage.Image = thumb
        end
    else
        if self.ProfileImage.Image ~= C.PlaceholderImage then
            self.ProfileImage.Image = C.PlaceholderImage
        end
    end
    local maxHealth = math.max(humanoid.MaxHealth or 100, 1)
    local health    = math.clamp(humanoid.Health, 0, maxHealth)
    local ratio     = health / maxHealth
    local filled = math.floor(ratio * C.Slots + 0.5)
    filled = math.clamp(filled, 0, C.Slots)
    local empty = C.Slots - filled
    self.HealthBar.Text = "[" .. string.rep("|", filled) .. string.rep(" ", empty) .. "]"
end
local function TargetIndicator:_handleHealthChange(target, humanoid)
    local id
    if typeof(target) == "Instance" and target:IsA("Player") then
        id = "p_" .. tostring(target.UserId)
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        id = "n_" .. tostring(target)
    else
        id = tostring(target)
    end
    if self._targetId ~= id then
        self._targetId      = id
        self._lastHealth    = humanoid.Health
        self._lastMaxHealth = humanoid.MaxHealth
        return
    end
    if self._lastHealth and humanoid.Health < self._lastHealth then
        local damage = self._lastHealth - humanoid.Health
        local maxHp  = math.max(humanoid.MaxHealth or 100, 1)
        self:_triggerDamage(damage, maxHp)
    end
    self._lastHealth    = humanoid.Health
    self._lastMaxHealth = humanoid.MaxHealth
end
local function TargetIndicator:_triggerDamage(damage, maxHealth)
    local ratio     = math.clamp(damage / maxHealth, 0.05, 1)
    local intensity = C.ShakeMin + ratio * (C.ShakeMax - C.ShakeMin)
    self._shakeIntensity = intensity
    self._shakeTimer     = C.ShakeDuration
    self._damageTimer    = C.DamageFlashDuration
    self.ProfileImage.ImageColor3 = C.DamageRed
    self.NameLabel.TextColor3     = C.DamageRed
end
local function TargetIndicator:_updateShake(dt)
    if self._shakeTimer <= 0 then
        if self.HealthBar.Position ~= C.HealthBarBasePos then
            self.HealthBar.Position = C.HealthBarBasePos
        end
        return
    end
    self._shakeTimer = self._shakeTimer - dt
    local ratio     = math.clamp(self._shakeTimer / C.ShakeDuration, 0, 1)
    local intensity = self._shakeIntensity * ratio
    local ox = (math.random() - 0.5) * 2 * intensity
    local oy = (math.random() - 0.5) * 2 * intensity
    self.HealthBar.Position = UDim2.new(
        0, C.HealthBarBasePos.X.Offset + ox,
        0, C.HealthBarBasePos.Y.Offset + oy
    )
end
local function TargetIndicator:_updateDamageFlash(dt)
    if self._damageTimer <= 0 then return end
    self._damageTimer = self._damageTimer - dt
    if self._damageTimer <= 0 then
        local info = TweenInfo.new(C.DamageRestoreTime, Enum.EasingStyle.Quad)
        TweenService:Create(self.ProfileImage, info, { ImageColor3 = C.NormalWhite }):Play()
        TweenService:Create(self.NameLabel,    info, { TextColor3  = C.NormalWhite }):Play()
    end
end
local function TargetIndicator:_fadeTargets()
    return {
        { obj = self.MainImage,    prop = "ImageTransparency", base = C.BaseImgTransparency },
        { obj = self.ProfileImage, prop = "ImageTransparency", base = C.BaseImgTransparency },
        { obj = self.HealthBar,    prop = "TextTransparency",  base = C.BaseTxtTransparency },
        { obj = self.HealthLabel,  prop = "TextTransparency",  base = C.BaseTxtTransparency },
        { obj = self.NameLabel,    prop = "TextTransparency",  base = C.BaseTxtTransparency },
    }
end
local function TargetIndicator:_fadeTo(visible, duration, style)
    for _, entry in ipairs(self:_fadeTargets()) do
        local targetVal = visible and entry.base or 1
        TweenService:Create(
            entry.obj,
            TweenInfo.new(duration, style),
            { [entry.prop] = targetVal }
        ):Play()
    end
end
local function TargetIndicator:show()
    if self.Visible then return end
    self.Visible = true
    self:_fadeTo(true, C.FadeInDuration, C.FadeInStyle)
end
local function TargetIndicator:hide()
    if not self.Visible then return end
    self.Visible = false
    self:_fadeTo(false, C.FadeOutDuration, C.FadeOutStyle)
    self._targetId      = nil
    self._lastHealth    = nil
    self._lastMaxHealth = nil
    self._damageTimer   = 0
    self._shakeTimer    = 0
end
local function TargetIndicator:setEnabled(v)
    self.Enabled = v == true
    if not self.Enabled and self.Visible then
        self:hide()
    end
end
local function TargetIndicator:setDraggable(v)
    self.Draggable = v == true
    if self.MainImage then
        self.MainImage.Active    = true
        self.MainImage.Draggable = self.Draggable
    end
end
local function TargetIndicator:setConfig(cfg)
    self.Config = cfg
end
local function TargetIndicator:setPosition(pos)
    if self.MainImage and pos then
        self.MainImage.Position = pos
    end
end
local function TargetIndicator:getTarget()
    return self:_resolveTarget()
end
local function TargetIndicator:destroy()
    for _, conn in ipairs(self._conns) do
        pcall(function() conn:Disconnect() end)
    end
    self._conns = {}
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    self.Enabled = false
    self.Visible = false
    self.Config  = nil
end
return TargetIndicator
