local InitGuiModule = {}
local InitGui = {}
InitGui.__index = InitGui
local gravelCodeSnippets = {
    "local config = {",
    "    startsa = false,",
    "    fovsize = 120,",
    "    predic = 1,",
    "    hbtrans = 1,",
    "    scaleToScreen = false,",
    "    stsdistance = 0,",
    "    SA2_Enabled = false,",
    "    SA2_Method = 'Raycast',",
    "    SA2_TeamTarget = 'Enemies',",
    "    SA2_Wallcheck = false,",
    "    SA2_TargetPart = 'Head',",
    "    SA2_HitChance = 100,",
    "    SA2_FovRadius = 100,",
    "    SA2_FovVisible = true,",
    "    SA2_FovTransparency = 0.90,",
    "    SA2_FovColor = Color3.new(0, 0, 0),",
    "    SA2_FovColourTarget = Color3.new(1, 1, 0),",
    "    SA2_FovIsTargeted = false,",
    "    SA2_ThreeSixtyMode = false,",
    "    SA2_GetTarget = 'Closest',",
    "    SA2_currentTarget = nil,",
    "    SA2_TArea = 35,",
    "    SA2_TargetRange = 1000,",
    "    SA2_Wallbang = false,",
    "    SA2_BulletTeleport = false,",
    "    currentTarget = nil,",
    "    espc = Color3.fromRGB(255, 182, 193),",
    "    esptargetc = Color3.fromRGB(255, 255, 0),",
    "    espteamc = Color3.fromRGB(0, 255, 0),",
    "    rfd = false,",
    "    eme = true,",
    "    wallc = false,",
    "    bodypart = 'Head',",
    "    espon = false,",
    "    prefTextESP = false,",
    "    highlightesp = false,",
    "    prefHighlightESP = false,",
    "    prefBoxESP = false,",
    "    prefHealthESP = false,",
    "    prefColorByHealth = false,",
    "    espMasterEnabled = false,",
    "    prefHeadDotESP = false,",
    "    lineESPEnabled = false,",
    "    lineESPOnlyTarget = false,",
    "    lineStartPosition = 'Center',",
    "    lineColor = Color3.fromRGB(255, 255, 255),",
    "    lineThickness = 1,",
    "    lineESPData = {},",
    "    originalSizes = {},",
    "    activeApplied = {},",
    "    espData = {},",
    "    highlightData = {},",
    "    currentTarget = nil,",
    "    targethbSizes = {},",
    "    fovc = Color3.fromRGB(100, 0, 0),",
    "    fovct = Color3.fromRGB(255, 255, 0),",
    "    playerConnections = {},",
    "    characterConnections = {},",
    "    targetMode = 'Enemies',",
    "    centerLocked = {},",
    "    hitchance = 100,",
    "    maxExpansion = math.huge,",
    "    aimbotEnabled = false,",
    "    aimbotFOVSize = 70,",
    "    aimbotStrength = 0.5,",
    "    aimbotWallCheck = false,",
    "    aimbotTargetPart = 'Head',",
    "    aimbotTeamTarget = 'Enemies',",
    "    aimbotCurrentTarget = nil,",
    "    aimbotFOVRing = nil,",
    "    hitboxEnabled = false,",
    "    hitboxSize = 10,",
    "    hitboxTeamTarget = 'Enemies',",
    "    hitboxExpandedParts = {},",
    "    hitboxOriginalSizes = {},",
    "    hitboxLastSize = {},",
    "    hitboxColor = Color3.fromRGB(255, 255, 255),",
    "    antiAimEnabled = false,",
    "    raycastAntiAim = false,",
    "    antiAimTPDistance = 3,",
    "    antiAimAbovePlayer = false,",
    "    antiAimAboveHeight = 10,",
    "    antiAimBehindPlayer = false,",
    "    antiAimBehindDistance = 5,",
    "    originalPosition = nil,",
    "    isTeleported = false,",
    "    currentAntiAimTarget = nil,",
    "    antiAimOrbitEnabled = false,",
    "    antiAimOrbitSpeed = 5,",
    "    antiAimOrbitRadius = 5,",
    "    antiAimOrbitHeight = 0,",
    "    masterTeamTarget = 'Enemies',",
    "    autoFarmEnabled = false,",
    "    autoFarmDistance = 10,",
    "    autoFarmSpeed = 1,",
    "    autoFarmTargets = {},",
    "    currentAutoFarmTarget = nil,",
    "    autoFarmLoop = nil,",
    "    autoFarmIndex = 1,",
    "    autoFarmCompleted = {},",
    "    autoFarmTargetPart = 'Head',",
    "    autoFarmAlignToCrosshair = true,",
    "    autoFarmVerticalOffset = 0,",
    "    autoFarmMinRange = 0,",
    "    autoFarmMaxRange = 50,",
    "    autoFarmOriginalPositions = {},",
    "    autoFarmWallCheck = false,",
    "    aimbot360Enabled = false,",
    "    aimbot360OriginalFOV = 100,",
    "    gp = 200,",
    "    gp2 = 1,",
    "    customFOVEnabled = false,",
    "    customFOVValue = 70,",
    "    fbenabled = false,",
    "    targetSeenSwitchRate = 0.2,",
    "    lastTargetSwitchTime = 0,",
    "    targetSeenTargets = {},",
    "    aimbot360Omnidirectional = true,",
    "    aimbot360BehindRange = 180,",
    "    aimbot360WasEnabled = false,",
    "    masterTarget = 'Players',",
    "    clientMasterEnabled = false,",
    "    clientWalkSpeed = 16,",
    "    clientJumpPower = 50,",
    "    clientNoclip = false,",
    "    clientCFrameWalkEnabled = false,",
    "    clientCFrameSpeed = 1,",
    "    clientConnections = {},",
    "    clientOriginals = {},",
    "    _tpwalking = false,",
    "    clientWalkEnabled = false,",
    "    clientJumpEnabled = false,",
    "    clientNoclipEnabled = false,",
    "    clientCFrameWalkToggle = false,",
    "    masterGetTarget = 'Closest',",
    "    aimbotGetTarget = 'Closest',",
    "    silentGetTarget = 'Closest',",
    "    antiAimGetTarget = 'Closest',",
    "    autoFarmPartClaimStarted = false,",
    "    autoFarmLastRefresh = 0,",
    "    ignoreForcefield = true,",
    "    QuickToggles = false,",
    "    QTDrag = true,",
    "    trussEnabled = false,",
    "    trussPart = nil,",
    "    trussConnection = nil,",
    "    airwalkEnabled = false,",
    "    airwalkPart = nil,",
    "    airwalkConnection = nil,",
    "    autorespawnEnabled = false,",
    "    autorespawnConnections = {},",
    "    autorespawnDeathPosition = nil,",
    "    autorespawnType = 'SetSpawnPoint',",
    "    SSEnabled = false,",
    "    SpawnLocation = nil,",
    "    SSConnection = nil,",
    "    fastspawn = false,",
    "    antiafk = false,",
    "    Viewing = false,",
    "    camYOffsetEnabled = false,",
    "    camYOffsetValue = 0,",
    "    camYOffsetOriginalCFrame = nil,",
    "    camYOffsetConnection = nil,",
    "    spinbot = {",
    "        enabled = false,",
    "        speed = 50,",
    "    },",
    "    bhop = {",
    "        enabled = false,",
    "        jumpDelay = 0.05,",
    "        quickToggleEnabled = false,",
    "        quickToggleDraggable = true",
    "    },",
    "    reach = {",
    "        enabled = false,",
    "        type = 'Sphere',",
    "        distance = 10,",
    "        autoSwing = {",
    "            enabled = false,",
    "            delay = 0.1",
    "        },",
    "    },",
    "    visualizer = {",
    "        enabled = false,",
    "        color = Color3.fromRGB(255, 0, 0),",
    "        material = 'ForceField',",
    "        transparency = 0.6",
    "    },",
    "    materials = {",
    "        ['ForceField'] = Enum.Material.ForceField,",
    "        ['Plastic'] = Enum.Material.Plastic,",
    "        ['Glass'] = Enum.Material.Glass,",
    "        ['Neon'] = Enum.Material.Neon,",
    "        ['SmoothPlastic'] = Enum.Material.SmoothPlastic,",
    "        ['Metal'] = Enum.Material.Metal,",
    "        ['DiamondPlate'] = Enum.Material.DiamondPlate",
    "    },",
    "    LowRender = false,",
    "    tbot = {",
    "        enabled = false,",
    "        delay = 0.1,",
    "        fovRadius = 150,",
    "        fovVisible = true,",
    "        fovColor = Color3.fromRGB(255, 0, 0),",
    "        fovTransparency = 0.7,",
    "        targetPart = 'Head',",
    "        wallCheck = false,",
    "        hitChance = 100,",
    "        holdToShoot = false,",
    "        holdKey = 'MouseButton1'",
    "    },",
    "    KeybindsEnabled = true,",
    "    HoldKeysEnabled = false,",
    "    Keybinds = {",
    "        HoldKeybind = 'LeftAlt',",
    "        silentaim = 'E',",
    "        aimbot = 'Q',",
    "        autofarm = 'F',",
    "        antiaim = 'L',",
    "        hitbox = 'G',",
    "        esp = 'Z',",
    "        client = 'N',",
    "        silentaimwallcheck = 'B',",
    "        aimbotwallcheck = 'H',",
    "        silentaimhk = 'R',",
    "        silentaimhkwallcheck = 'T',",
    "        triggerbot = 'X',",
    "        bhop = 'V',",
    "        tbotwallcheck = 'Y',",
    "    },",
    "    varibz = {",
    "        btntitle = {",
    "            'hey y close me',",
    "            'Gui size decreases',",
    "            'dude',",
    "            'yh',",
    "            'how graveling of u',",
    "            'rock solid ui',",
    "            'what',",
    "            'version: idk',",
    "            'D:',",
    "            'unclose me NOW!!! D:',",
    "            'just simply cheat through it',",
    "            'bowl',",
    "            'gta 6 when?',",
    "            'holy cow',",
    "            'open4robuc',",
    "            'me want to be open',",
    "            'gravel is not sand',",
    "            'is gravel just sand',",
    "            'gl',",
    "            'not full ban-proof',",
    "            'bleh :p',",
    "            ':3',",
    "            ':o',",
    "            ';]',",
    "            'error code: 6967420',",
    "            '🥀💔✌️🫩',",
    "            'brochacho',",
    "        },",
    "        convo = {",
    "            {",
    "                typesp = '1.5',",
    "                'HEY',",
    "                'CAN YOU HEAR ME???',",
    "                'Ok Ive got ur attention',",
    "                'what I'm gonna say is',",
    "                'pls read the InfoTab :(',",
    "                'and credit me if u did a snippet :(',",
    "            },",
    "            {",
    "                'sand.cc is an larper',",
    "                'it's a actual gravel larper',",
    "                'sand larps gravel',",
    "            },",
    "            {",
    "                'Guys he's hacking REPORT',",
    "                'EVERYBODY SPAM REPORT HIM',",
    "                'HACKER REPORTTT',",
    "            },",
    "            {",
    "                'steam',",
    "                'stop tryna kill us :(',",
    "                'hacker lives matter',",
    "            },",
    "            {",
    "                typesp = '2',",
    "                'I AM A SURGEON',",
    "                'I AM A SURGEON',",
    "                'I AM- IAM A SURGEON',",
    "                'IAM A SURGEON',",
    "            },",
    "            {",
    "                typesp = '2',",
    "                'i am an fucking architect',",
    "                'GOD DAMN IT, IM JUST STUCK',",
    "                'SELLING SHIT FURNITURE',",
    "                'BECAUSE SOMEONE WONT GET OFF',",
    "                'THEIR FAT FUCKING ASS AND HELP ME.',",
    "            },",
    "        },",
    "    },",
    "}",
}
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
    self.codeScrollTask = nil
    self.gui = nil
    self.bg = nil
    self.title = nil
    self.status = nil
    self.dots = nil
    self.codeContainer = nil
    self.codeLabels = {}
    self.scrollOffset = 0
    self.codeSnippetIndex = 1
    self.totalCodeLines = #gravelCodeSnippets
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
    bg.BackgroundTransparency = 0.75
    bg.Parent = gui
    self.bg = bg
    local codeContainer = Instance.new("Frame")
    codeContainer.Size = UDim2.fromScale(0.45, 1)
    codeContainer.Position = UDim2.fromScale(0.55, 0)
    codeContainer.BackgroundTransparency = 1
    codeContainer.ClipsDescendants = true
    codeContainer.Parent = bg
    self.codeContainer = codeContainer
    local codeColor = Color3.fromRGB(80, 100, 120)
    local codeColor2 = Color3.fromRGB(100, 80, 120)
    local codeColor3 = Color3.fromRGB(70, 110, 100)
    for i = 1, 50 do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 0)
        label.BackgroundTransparency = 1
        label.Text = ""
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.TextColor3 = codeColor
        label.TextTransparency = 0.6 + (math.random() * 0.3)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = codeContainer
        table.insert(self.codeLabels, label)
    end
    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.4, 0.35)
    center.Position = UDim2.fromScale(0.25, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.Parent = bg
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.35)
    title.Position = UDim2.fromScale(0.5, 0.15)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Text = "gravel.cc"
    title.Font = Enum.Font.Code
    title.TextSize = 32
    title.TextColor3 = Color3.fromRGB(180, 220, 200)
    title.TextTransparency = 0
    title.BackgroundTransparency = 1
    title.Parent = center
    self.title = title
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.fromScale(1, 0.2)
    subtitle.Position = UDim2.fromScale(0.5, 0.38)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.Text = "loading..."
    subtitle.Font = Enum.Font.Code
    subtitle.TextSize = 14
    subtitle.TextColor3 = Color3.fromRGB(130, 160, 150)
    subtitle.TextTransparency = 0
    subtitle.BackgroundTransparency = 1
    subtitle.Parent = center
    self.subtitle = subtitle
    local status = Instance.new("TextLabel")
    status.Size = UDim2.fromScale(1, 0.25)
    status.Position = UDim2.fromScale(0.5, 0.6)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Text = "fetching random asset files..."
    status.Font = Enum.Font.Code
    status.TextSize = 13
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextTransparency = 0
    status.BackgroundTransparency = 1
    status.Parent = center
    self.status = status
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.fromScale(1, 0.2)
    dots.Position = UDim2.fromScale(0.5, 0.8)
    dots.AnchorPoint = Vector2.new(0.5, 0.5)
    dots.Text = ""
    dots.Font = Enum.Font.Code
    dots.TextSize = 18
    dots.TextColor3 = Color3.fromRGB(200, 200, 200)
    dots.TextTransparency = 0
    dots.BackgroundTransparency = 1
    dots.Parent = center
    self.dots = dots
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.fromScale(0.6, 0.025)
    progressBg.Position = UDim2.fromScale(0.5, 0.9)
    progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = center
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBg
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.fromScale(0.01, 1)
    progressFill.BackgroundColor3 = Color3.fromRGB(100, 200, 150)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = progressFill
    self.progressFill = progressFill
    self.progressValue = 0.01
    self.progressTarget = 0.01
    self:startAnimations()
    self:startCodeScroll()
    self:startProgressUpdate()
    return self
end
function InitGui:startProgressUpdate()
    task.spawn(function()
        while self.gui and self.gui.Parent do
            if self.progressValue < self.progressTarget then
                self.progressValue = self.progressValue + (self.progressTarget - self.progressValue) * 0.05
                if self.progressValue < 0.01 then self.progressValue = 0.01 end
                if self.progressFill then
                    self.progressFill.Size = UDim2.fromScale(math.min(self.progressValue, 1), 1)
                end
            end
            task.wait(0.02)
        end
    end)
end
function InitGui:updateProgress(target)
    self.progressTarget = math.min(target, 1)
end
function InitGui:startCodeScroll()
    self.codeScrollTask = task.spawn(function()
        local lineHeight = 16
        local totalHeight = #gravelCodeSnippets * lineHeight
        local containerHeight = self.codeContainer and self.codeContainer.AbsoluteSize.Y or 400
        for i, label in ipairs(self.codeLabels) do
            local idx = ((i - 1) % self.totalCodeLines) + 1
            local snippet = gravelCodeSnippets[idx]
            local randomColor = Color3.fromRGB(
                60 + math.random(0, 40),
                70 + math.random(0, 40),
                90 + math.random(0, 40)
            )
            label.Text = "    " .. snippet
            label.TextColor3 = randomColor
            label.TextTransparency = 0.4 + (math.random() * 0.3)
            label.Size = UDim2.fromScale(1, 0)
            local yPos = (i - 1) * lineHeight
            label.Position = UDim2.fromScale(0, yPos / containerHeight)
        end
        local scrollSpeed = 0.4
        local accumulator = 0
        while self.gui and self.gui.Parent do
            local dt = 0.016
            accumulator = accumulator + dt * scrollSpeed
            if accumulator >= 1 then
                accumulator = accumulator - 1
                self.scrollOffset = self.scrollOffset + 1
                local containerHeight = self.codeContainer and self.codeContainer.AbsoluteSize.Y or 400
                local visibleLines = math.floor(containerHeight / lineHeight) + 5
                for i, label in ipairs(self.codeLabels) do
                    local codeIndex = ((i - 1 + self.scrollOffset) % self.totalCodeLines) + 1
                    local snippet = gravelCodeSnippets[codeIndex]
                    local randomColor = Color3.fromRGB(
                        60 + math.random(0, 40),
                        70 + math.random(0, 40),
                        90 + math.random(0, 40)
                    )
                    label.Text = "    " .. snippet
                    label.TextColor3 = randomColor
                    label.TextTransparency = 0.4 + (math.random() * 0.3)
                end
            end
            task.wait(0.016)
        end
    end)
end
function InitGui:startAnimations()
    self.dotTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.dotCount = (self.dotCount % 3) + 1
            if self.dots then
                self.dots.Text = string.rep(".", self.dotCount)
            end
            task.wait(0.35)
        end
    end)
    self.statusTask = task.spawn(function()
        local lastChange = 0
        local progressStep = 0
        while self.gui and self.gui.Parent do
            local elapsed = tick() - lastChange
            if elapsed > math.random(8, 18) / 10 then
                local newMsg = self.statusMessages[math.random(1, #self.statusMessages)]
                if self.status then
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
                end
                progressStep = progressStep + 0.015 + (math.random() * 0.02)
                self:updateProgress(math.min(0.95, progressStep))
                lastChange = tick()
            end
            task.wait(0.1)
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
        if self.codeScrollTask then
            task.cancel(self.codeScrollTask)
            self.codeScrollTask = nil
        end
        self:updateProgress(1)
        task.wait(0.3)
        local fadeOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if self.bg then
            game:GetService("TweenService"):Create(self.bg, fadeOut, {BackgroundTransparency = 1}):Play()
        end
        if self.title then
            game:GetService("TweenService"):Create(self.title, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.subtitle then
            game:GetService("TweenService"):Create(self.subtitle, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.status then
            game:GetService("TweenService"):Create(self.status, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.dots then
            game:GetService("TweenService"):Create(self.dots, fadeOut, {TextTransparency = 1}):Play()
        end
        task.wait(0.7)
        self.gui:Destroy()
        self.gui = nil
        self.bg = nil
        self.title = nil
        self.subtitle = nil
        self.status = nil
        self.dots = nil
        self.codeContainer = nil
        self.codeLabels = {}
        self.progressFill = nil
    end
end
local initGui = InitGui.new():create()
_G.destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
_G.updateInitProgress = function(progress)
    if initGui then
        initGui:updateProgress(progress)
    end
end
