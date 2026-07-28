local InitGuiModule = {}
local InitGui = {}
InitGui.__index = InitGui

function InitGui.new()
    local self = setmetatable({}, InitGui)
    self.statusMessages = {
        "fetching random asset files...",
        "getting urls...",
        "doing stuff...",
        "compiling spaghetti code...",
        "asking Gpssickle for help...",
        "loading the funny...",
        "gravel.exe is doing something...",
        "checking if gravel is just crushed rocks...",
        "summoning the shovel...",
        "eating sand...",
        "crushing rocks...",
        "this definitely isn't a virus...",
        "praying to the rng gods...",
        "finding the nearest enemy...",
        "this is fine... everything is fine...",
        "rendering the funny...",
        "initializing quantum gravel...",
        "loading the secret sauce...",
        "hacking the mainframe...",
        "turning rocks into aimbot...",
        "idk what i'm doing...",
        "please wait... i'm doing my best...",
        "ok i'm just gonna load now...",
        "sending a 3.5gb update... just kidding",
        "graveling...",
        "this is the 100th status message btw...",
        "staring at the code...",
        "hoping it works...",
        "it's not a virus i promise...",
        "praying to the gps sickle...",
        "my code is pasta...",
        "al dente and tangled...",
        "bon appetit..."
    }
    self.dotCount = 0
    self.dotTask = nil
    self.statusTask = nil
    self.scrollTask = nil
    self.gui = nil
    self.bg = nil
    self.title = nil
    self.status = nil
    self.dots = nil
    self.codeBackground = nil
    self.codeScroller = nil
    return self
end

function InitGui:create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InitializingGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.7
    bg.Parent = gui
    self.bg = bg
    local codeBg = Instance.new("Frame")
    codeBg.Size = UDim2.fromScale(0.45, 1)
    codeBg.Position = UDim2.fromScale(0, 0)
    codeBg.BackgroundTransparency = 1
    codeBg.ClipsDescendants = true
    codeBg.Parent = bg
    self.codeBackground = codeBg

    local codeScroller = Instance.new("ScrollingFrame")
    codeScroller.Size = UDim2.fromScale(1, 1)
    codeScroller.BackgroundTransparency = 1
    codeScroller.BorderSizePixel = 0
    codeScroller.ScrollBarThickness = 0
    codeScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None
    codeScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    codeScroller.CanvasSize = UDim2.fromOffset(0, 0)
    codeScroller.Parent = codeBg
    self.codeScroller = codeScroller
    local configCode = [[
local config = {
    confIg = "Gravel",
    startsa = false,
    fovsize = 120,
    predic = 1,
    hbtrans = 1,
    scaleToScreen = false,
    stsdistance = 0,
    SA2_Enabled = false,
    SA2_Method = "Raycast",
    SA2_TeamTarget = "Enemies",
    SA2_Wallcheck = false,
    SA2_TargetPart = "Head",
    SA2_HitChance = 100,
    SA2_FovRadius = 100,
    SA2_FovVisible = true,
    SA2_FovTransparency = 0.90,
    SA2_FovColor = Color3.new(0, 0, 0),
    SA2_FovColourTarget = Color3.new(1, 1, 0),
    SA2_FovIsTargeted = false,
    SA2_ThreeSixtyMode = false,
    SA2_GetTarget = "Closest",
    SA2_currentTarget = nil,
    SA2_TArea = 35,
    SA2_TargetRange = 1000,
    SA2_Wallbang = false,
    SA2_BulletTeleport = false,
    currentTarget = nil,
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    rfd = false,
    eme = true,
    wallc = false,
    bodypart = "Head",
    espon = false,
    prefTextESP = false,
    highlightesp = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefColorByHealth = false,
    espMasterEnabled = false,
    prefHeadDotESP = false,
    lineESPEnabled = false,
    lineESPOnlyTarget = false,
    lineStartPosition = "Center",
    lineColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1,
    lineESPData = {},
    originalSizes = {},
    activeApplied = {},
    espData = {},
    highlightData = {},
    currentTarget = nil,
    targethbSizes = {},
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    playerConnections = {},
    characterConnections = {},
    targetMode = "Enemies",
    centerLocked = {},
    hitchance = 100,
    maxExpansion = math.huge,
    aimbotEnabled = false,
    aimbotFOVSize = 70,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Enemies",
    hitboxExpandedParts = {},
    hitboxOriginalSizes = {},
    hitboxLastSize = {},
    hitboxColor = Color3.fromRGB(255, 255, 255),
    antiAimEnabled = false,
    raycastAntiAim = false,
    antiAimTPDistance = 3,
    antiAimAbovePlayer = false,
    antiAimAboveHeight = 10,
    antiAimBehindPlayer = false,
    antiAimBehindDistance = 5,
    originalPosition = nil,
    isTeleported = false,
    currentAntiAimTarget = nil,
    antiAimOrbitEnabled = false,
    antiAimOrbitSpeed = 5,
    antiAimOrbitRadius = 5,
    antiAimOrbitHeight = 0,
    masterTeamTarget = "Enemies",
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargets = {},
    currentAutoFarmTarget = nil,
    autoFarmLoop = nil,
    autoFarmIndex = 1,
    autoFarmCompleted = {},
    autoFarmTargetPart = "Head",
    autoFarmAlignToCrosshair = true,
    autoFarmVerticalOffset = 0,
    autoFarmMinRange = 0,
    autoFarmMaxRange = 50,
    autoFarmOriginalPositions = {}, 
    autoFarmWallCheck = false,
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    gp = 200,
    gp2 = 1,
    customFOVEnabled = false,
    customFOVValue = 70,
    fbenabled = false,
    targetSeenSwitchRate = 0.2,
    lastTargetSwitchTime = 0,
    targetSeenTargets = {},
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    aimbot360WasEnabled = false,
    masterTarget = "Players",
    clientMasterEnabled = false,
    clientWalkSpeed = 16,
    clientJumpPower = 50,
    clientNoclip = false,
    clientCFrameWalkEnabled = false,
    clientCFrameSpeed = 1,
    clientConnections = {},
    clientOriginals = {},
    _tpwalking = false,
    clientWalkEnabled = false,
    clientJumpEnabled = false,
    clientNoclipEnabled = false,
    clientCFrameWalkToggle = false,
    masterGetTarget = "Closest",
    aimbotGetTarget = "Closest",
    silentGetTarget = "Closest",
    antiAimGetTarget = "Closest",
    autoFarmPartClaimStarted = false,
    autoFarmLastRefresh = 0,
    ignoreForcefield = true,
    QuickToggles = false,
    QTDrag = true,
    trussEnabled = false,
    trussPart = nil,
    trussConnection = nil,
    airwalkEnabled = false,
    airwalkPart = nil,
    airwalkConnection = nil,
    autorespawnEnabled = false,
    autorespawnConnections = {},
    autorespawnDeathPosition = nil,
    autorespawnType = "SetSpawnPoint",
    SSEnabled = false,
    SpawnLocation = nil,
    SSConnection = nil,
    fastspawn = false,
    antiafk = false,
    Viewing = false,
    camYOffsetEnabled = false,
    camYOffsetValue = 0,
    camYOffsetOriginalCFrame = nil,
    camYOffsetConnection = nil,
    spinbot = {
        enabled = false,
        speed = 50,
    },
    bhop = {
        enabled = false,
        jumpDelay = 0.05,
        quickToggleEnabled = false,
        quickToggleDraggable = true
    },
    reach = {
        enabled = false,
        type = "Sphere",
        distance = 10,
        autoSwing = {
            enabled = false,
            delay = 0.1
        },
    },
    visualizer = {
        enabled = false,
        color = Color3.fromRGB(255, 0, 0),
        material = "ForceField",
        transparency = 0.6
    },
    materials = {
        ["ForceField"] = Enum.Material.ForceField,
        ["Plastic"] = Enum.Material.Plastic,
        ["Glass"] = Enum.Material.Glass,
        ["Neon"] = Enum.Material.Neon,
        ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
        ["Metal"] = Enum.Material.Metal,
        ["DiamondPlate"] = Enum.Material.DiamondPlate
    },
    LowRender = false,
    tbot = {
        enabled = false,
        delay = 0.1,
        fovRadius = 150,
        fovVisible = true,
        fovColor = Color3.fromRGB(255, 0, 0),
        fovTransparency = 0.7,
        targetPart = "Head",
        wallCheck = false,
        hitChance = 100,
        holdToShoot = false,
        holdKey = "MouseButton1"
    },
    KeybindsEnabled = true,
    HoldKeysEnabled = false,
    Keybinds = {
        HoldKeybind = "LeftAlt",
        silentaim = "E",
        aimbot = "Q",
        autofarm = "F",
        antiaim = "L",
        hitbox = "G",
        esp = "Z",
        client = "N",
        silentaimwallcheck = "B",
        aimbotwallcheck = "H",
        silentaimhk = "R",
        silentaimhkwallcheck = "T",
        triggerbot = "X",
        bhop = "V",
        tbotwallcheck = "Y",
    },
    Gradow = {
        textcursor = "_",
        textcursor2 = "  ",
        uianimate = {
            connection = nil,
            basePosition = nil,
            lastPosition = Vector3.new(0, 0, 0),
            movementOffset = 0,
            smoothOffset = 0,
            pulseSpeed = 0.02,
            minThickness = 0.80,
            maxThickness = 2,
            targetRotation = 0,
            currentRotation = 0,
            windowTargetRotation = 0,
            windowCurrentRotation = 0,
            windowInitialThickness = nil,
            openButton = nil,
            windowFrame = nil,
            openStroke = nil,
            openGradient = nil,
            windowStroke = nil,
            windowGradient = nil
        },
        uicolor = {
            lightGreen = Color3.fromRGB(144, 238, 144),
            darkGray = Color3.fromRGB(40, 40, 40),
            lightGray = Color3.fromRGB(200, 200, 200),
            Red = Color3.fromRGB(255, 0, 0),
            Blue = Color3.fromRGB(175, 221, 255),
            Black = Color3.fromRGB(0, 0, 0)
        },
        windowSize = {
            mobile = UDim2.fromOffset(650, 79),
            tablet = UDim2.fromOffset(600, 80),
            pc = UDim2.fromOffset(800, 70)
        }
    }
}
]]

    local lines = {}
    for line in configCode:gmatch("[^\n]*\n?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end

    local lineHeight = 18
    local totalHeight = #lines * lineHeight
    codeScroller.CanvasSize = UDim2.fromOffset(0, totalHeight + 100)

    local yPos = 10
    for _, line in ipairs(lines) do
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.fromScale(1, 0)
        textLabel.Position = UDim2.fromOffset(10, yPos)
        textLabel.Size = UDim2.fromOffset(self.codeBackground.AbsoluteSize.X - 20, lineHeight)
        textLabel.Text = line
        textLabel.Font = Enum.Font.Code
        textLabel.TextSize = 11
        textLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        textLabel.TextTransparency = 0.85
        textLabel.BackgroundTransparency = 1
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = codeScroller
        yPos = yPos + lineHeight
    end

    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.25)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.ZIndex = 2
    center.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.35)
    title.Position = UDim2.fromScale(0.5, 0.2)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Text = "initializing"
    title.Font = Enum.Font.Code
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextTransparency = 0
    title.BackgroundTransparency = 1
    title.ZIndex = 3
    title.Parent = center
    self.title = title

    local status = Instance.new("TextLabel")
    status.Size = UDim2.fromScale(1, 0.3)
    status.Position = UDim2.fromScale(0.5, 0.55)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Text = "fetching random asset files..."
    status.Font = Enum.Font.Code
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextTransparency = 0
    status.BackgroundTransparency = 1
    status.ZIndex = 3
    status.Parent = center
    self.status = status

    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.fromScale(1, 0.3)
    dots.Position = UDim2.fromScale(0.5, 0.8)
    dots.AnchorPoint = Vector2.new(0.5, 0.5)
    dots.Text = ""
    dots.Font = Enum.Font.Code
    dots.TextSize = 18
    dots.TextColor3 = Color3.fromRGB(200, 200, 200)
    dots.TextTransparency = 0
    dots.BackgroundTransparency = 1
    dots.ZIndex = 3
    dots.Parent = center
    self.dots = dots

    self:startAnimations()
    return self
end

function InitGui:startAnimations()
    self.dotTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.dotCount = (self.dotCount % 3) + 1
            self.dots.Text = string.rep(".", self.dotCount)
            task.wait(0.35)
        end
    end)

    self.statusTask = task.spawn(function()
        local lastChange = 0
        while self.gui and self.gui.Parent do
            local elapsed = tick() - lastChange
            if elapsed > math.random(8, 18) / 10 then
                local newMsg = self.statusMessages[math.random(1, #self.statusMessages)]
                local tween = game:GetService("TweenService"):Create(self.status, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextTransparency = 1
                })
                tween:Play()
                tween.Completed:Wait()
                self.status.Text = newMsg
                local tween2 = game:GetService("TweenService"):Create(self.status, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextTransparency = 0
                })
                tween2:Play()
                lastChange = tick()
            end
            task.wait(0.1)
        end
    end)

    self.scrollTask = task.spawn(function()
        if not self.codeScroller then return end
        local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
        local startPos = 0
        local speed = 500
        
        while self.gui and self.gui.Parent do
            startPos = startPos + speed * 0.03
            if startPos > canvasHeight - self.codeScroller.AbsoluteSize.Y then
                startPos = 0
            end
            self.codeScroller.CanvasPosition = Vector2.new(0, startPos)
            task.wait(0.03)
        end
    end)
end

function InitGui:destroy()
    if self.gui and self.gui.Parent then
        if self.dotTask then
            task.cancel(self.dotTask)
            self.dotTask = nil
        end
        if self.statusTask then
            task.cancel(self.statusTask)
            self.statusTask = nil
        end
        if self.scrollTask then
            task.cancel(self.scrollTask)
            self.scrollTask = nil
        end

        local fadeOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if self.bg then
            game:GetService("TweenService"):Create(self.bg, fadeOut, {BackgroundTransparency = 1}):Play()
        end
        if self.title then
            game:GetService("TweenService"):Create(self.title, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.status then
            game:GetService("TweenService"):Create(self.status, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.dots then
            game:GetService("TweenService"):Create(self.dots, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.codeBackground then
            game:GetService("TweenService"):Create(self.codeBackground, fadeOut, {BackgroundTransparency = 1}):Play()
        end

        task.wait(0.7)
        self.gui:Destroy()
        self.gui = nil
        self.bg = nil
        self.title = nil
        self.status = nil
        self.dots = nil
        self.codeBackground = nil
        self.codeScroller = nil
    end
end

local initGui = InitGui.new():create()
_G.destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
