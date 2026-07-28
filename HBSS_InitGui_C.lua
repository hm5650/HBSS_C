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
    self.typewriterTask = nil
    self.gui = nil
    self.bg = nil
    self.title = nil
    self.status = nil
    self.dots = nil
    self.codeBackground = nil
    self.codeScroller = nil
    self.currentLine = 0
    self.typedLines = {}
    self.isTypingComplete = false
    self.codeLines = {}
    self.textLabels = {}
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
    
    -- Add a subtle blur effect background
    local blur = Instance.new("BlurEffect")
    blur.Size = 8
    blur.Parent = game:GetService("Lighting")
    self.blurEffect = blur
    
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

    -- Define the config table with proper indentation and line breaks for typewriter effect
    local configLines = {
        "local config = {",
        "    confIg = \"Gravel\",",
        "    startsa = false,",
        "    fovsize = 120,",
        "    predic = 1,",
        "    hbtrans = 1,",
        "    scaleToScreen = false,",
        "    stsdistance = 0,",
        "    SA2_Enabled = false,",
        "    SA2_Method = \"Raycast\",",
        "    SA2_TeamTarget = \"Enemies\",",
        "    SA2_Wallcheck = false,",
        "    SA2_TargetPart = \"Head\",",
        "    SA2_HitChance = 100,",
        "    SA2_FovRadius = 100,",
        "    SA2_FovVisible = true,",
        "    SA2_FovTransparency = 0.90,",
        "    SA2_FovColor = Color3.new(0, 0, 0),",
        "    SA2_FovColourTarget = Color3.new(1, 1, 0),",
        "    SA2_FovIsTargeted = false,",
        "    SA2_ThreeSixtyMode = false,",
        "    SA2_GetTarget = \"Closest\",",
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
        "    bodypart = \"Head\",",
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
        "    lineStartPosition = \"Center\",",
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
        "    targetMode = \"Enemies\",",
        "    centerLocked = {},",
        "    hitchance = 100,",
        "    maxExpansion = math.huge,",
        "    aimbotEnabled = false,",
        "    aimbotFOVSize = 70,",
        "    aimbotStrength = 0.5,",
        "    aimbotWallCheck = false,",
        "    aimbotTargetPart = \"Head\",",
        "    aimbotTeamTarget = \"Enemies\",",
        "    aimbotCurrentTarget = nil,",
        "    aimbotFOVRing = nil,",
        "    hitboxEnabled = false,",
        "    hitboxSize = 10,",
        "    hitboxTeamTarget = \"Enemies\",",
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
        "    masterTeamTarget = \"Enemies\",",
        "    autoFarmEnabled = false,",
        "    autoFarmDistance = 10,",
        "    autoFarmSpeed = 1,",
        "    autoFarmTargets = {},",
        "    currentAutoFarmTarget = nil,",
        "    autoFarmLoop = nil,",
        "    autoFarmIndex = 1,",
        "    autoFarmCompleted = {},",
        "    autoFarmTargetPart = \"Head\",",
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
        "    masterTarget = \"Players\",",
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
        "    masterGetTarget = \"Closest\",",
        "    aimbotGetTarget = \"Closest\",",
        "    silentGetTarget = \"Closest\",",
        "    antiAimGetTarget = \"Closest\",",
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
        "    autorespawnType = \"SetSpawnPoint\",",
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
        "        type = \"Sphere\",",
        "        distance = 10,",
        "        autoSwing = {",
        "            enabled = false,",
        "            delay = 0.1",
        "        },",
        "    },",
        "    visualizer = {",
        "        enabled = false,",
        "        color = Color3.fromRGB(255, 0, 0),",
        "        material = \"ForceField\",",
        "        transparency = 0.6",
        "    },",
        "    materials = {",
        "        [\"ForceField\"] = Enum.Material.ForceField,",
        "        [\"Plastic\"] = Enum.Material.Plastic,",
        "        [\"Glass\"] = Enum.Material.Glass,",
        "        [\"Neon\"] = Enum.Material.Neon,",
        "        [\"SmoothPlastic\"] = Enum.Material.SmoothPlastic,",
        "        [\"Metal\"] = Enum.Material.Metal,",
        "        [\"DiamondPlate\"] = Enum.Material.DiamondPlate",
        "    },",
        "    LowRender = false,",
        "    tbot = {",
        "        enabled = false,",
        "        delay = 0.1,",
        "        fovRadius = 150,",
        "        fovVisible = true,",
        "        fovColor = Color3.fromRGB(255, 0, 0),",
        "        fovTransparency = 0.7,",
        "        targetPart = \"Head\",",
        "        wallCheck = false,",
        "        hitChance = 100,",
        "        holdToShoot = false,",
        "        holdKey = \"MouseButton1\"",
        "    },",
        "    KeybindsEnabled = true,",
        "    HoldKeysEnabled = false,",
        "    Keybinds = {",
        "        HoldKeybind = \"LeftAlt\",",
        "        silentaim = \"E\",",
        "        aimbot = \"Q\",",
        "        autofarm = \"F\",",
        "        antiaim = \"L\",",
        "        hitbox = \"G\",",
        "        esp = \"Z\",",
        "        client = \"N\",",
        "        silentaimwallcheck = \"B\",",
        "        aimbotwallcheck = \"H\",",
        "        silentaimhk = \"R\",",
        "        silentaimhkwallcheck = \"T\",",
        "        triggerbot = \"X\",",
        "        bhop = \"V\",",
        "        tbotwallcheck = \"Y\",",
        "    },",
        "}"
    }
    
    self.codeLines = configLines
    self.typedLines = {}
    self.textLabels = {}
    
    local lineHeight = 20
    local totalHeight = #configLines * lineHeight + 20
    codeScroller.CanvasSize = UDim2.fromOffset(0, totalHeight)
    codeScroller.CanvasPosition = Vector2.new(0, 0)

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

    -- Add a subtle progress indicator
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.fromScale(0.6, 0.03)
    progressBg.Position = UDim2.fromScale(0.5, 0.9)
    progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BackgroundTransparency = 0.5
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 3
    progressBg.Parent = center
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.BackgroundColor3 = Color3.fromRGB(144, 238, 144)
    progressFill.BackgroundTransparency = 0.3
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 4
    progressFill.Parent = progressBg
    self.progressFill = progressFill
    
    -- Add corner to progress bar
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBg
    
    self.progressBg = progressBg

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

    -- Start the typewriter effect
    self:startTypewriter()
end

function InitGui:startTypewriter()
    if self.typewriterTask then
        task.cancel(self.typewriterTask)
    end
    
    self.currentLine = 1
    self.typedLines = {}
    self.isTypingComplete = false
    
    -- Clear existing labels
    for _, label in ipairs(self.textLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    self.textLabels = {}
    
    local lineHeight = 20
    local startY = 10
    
    self.typewriterTask = task.spawn(function()
        while self.gui and self.gui.Parent and self.currentLine <= #self.codeLines do
            local lineText = self.codeLines[self.currentLine]
            
            -- Create a label for this line
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromOffset(self.codeBackground.AbsoluteSize.X - 20, lineHeight)
            label.Position = UDim2.fromOffset(10, startY + (#self.textLabels * lineHeight))
            label.Text = ""
            label.Font = Enum.Font.Code
            label.TextSize = 11
            label.TextColor3 = Color3.fromRGB(100, 255, 150)
            label.TextTransparency = 0.5
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.Parent = self.codeScroller
            table.insert(self.textLabels, label)
            
            -- Type out the line character by character
            local typed = ""
            local lineLength = #lineText
            
            for i = 1, lineLength do
                if not self.gui or not self.gui.Parent then
                    return
                end
                
                typed = typed .. lineText:sub(i, i)
                label.Text = typed
                
                -- Random typing speed for realism
                local delay
                local char = lineText:sub(i, i)
                if char == " " then
                    delay = 0.03 + math.random() * 0.02
                elseif char == "," or char == "{" or char == "}" or char == "=" then
                    delay = 0.04 + math.random() * 0.03
                elseif char == "\"" or char == "(" or char == ")" then
                    delay = 0.02 + math.random() * 0.02
                else
                    delay = 0.01 + math.random() * 0.04
                end
                
                -- Occasionally pause for dramatic effect
                if math.random() < 0.008 then
                    delay = delay + 0.05
                end
                
                task.wait(delay)
                
                -- Update progress
                local totalLines = #self.codeLines
                local progress = ((self.currentLine - 1) + (i / lineLength)) / totalLines
                if self.progressFill then
                    self.progressFill.Size = UDim2.fromScale(math.min(progress, 1), 1)
                end
            end
            
            -- Fade in the line
            local tween = game:GetService("TweenService"):Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 0
            })
            tween:Play()
            
            -- Scroll down as we type
            local canvasPos = self.codeScroller.CanvasPosition
            local newY = math.min((#self.textLabels - 3) * lineHeight, self.codeScroller.CanvasSize.Y.Offset - self.codeScroller.AbsoluteSize.Y + 20)
            if newY > 0 then
                self.codeScroller.CanvasPosition = Vector2.new(0, newY)
            end
            
            self.currentLine = self.currentLine + 1
            
            -- Small pause between lines
            if self.currentLine <= #self.codeLines then
                task.wait(0.02 + math.random() * 0.03)
            end
        end
        
        self.isTypingComplete = true
        
        -- Final animation: flash the closing brace
        if #self.textLabels > 0 then
            local lastLabel = self.textLabels[#self.textLabels]
            if lastLabel then
                for i = 1, 3 do
                    lastLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    task.wait(0.1)
                    lastLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
                    task.wait(0.1)
                end
            end
        end
        
        -- Done typing, start slow scroll
        self:startScrollLoop()
    end)
end

function InitGui:startScrollLoop()
    if self.scrollTask then
        task.cancel(self.scrollTask)
    end
    
    self.scrollTask = task.spawn(function()
        if not self.codeScroller then return end
        local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
        local startPos = 0
        local speed = 80 -- Much slower for a relaxed feel
        
        while self.gui and self.gui.Parent do
            startPos = startPos + speed * 0.03
            if startPos > canvasHeight - self.codeScroller.AbsoluteSize.Y + 20 then
                startPos = 0
                -- Pause at bottom before restarting
                task.wait(1.5)
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
        if self.typewriterTask then
            task.cancel(self.typewriterTask)
            self.typewriterTask = nil
        end
        
        -- Clean up blur effect
        if self.blurEffect and self.blurEffect.Parent then
            self.blurEffect:Destroy()
            self.blurEffect = nil
        end
        
        -- Slide out the code panel with a nice animation
        local slideOutTask = task.spawn(function()
            if not self.codeScroller then return end
            
            local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
            local startPos = self.codeScroller.CanvasPosition.Y or 0
            local speed = 120
            local slideSpeed = 1000
            local targetX = -(self.codeBackground.AbsoluteSize.X + 100)
            
            while self.codeScroller and self.codeScroller.Parent do
                startPos = startPos + speed * 0.03
                if startPos > canvasHeight - self.codeScroller.AbsoluteSize.Y then
                    startPos = 0
                end
                self.codeScroller.CanvasPosition = Vector2.new(0, startPos)
                
                local currentPos = self.codeBackground.Position
                if currentPos.X.Offset > targetX then
                    local newX = currentPos.X.Offset - slideSpeed * 0.03
                    self.codeBackground.Position = UDim2.fromOffset(newX, 0)
                else
                    break 
                end
                
                task.wait(0.03)
            end
        end)
        
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
        if self.progressBg then
            game:GetService("TweenService"):Create(self.progressBg, fadeOut, {BackgroundTransparency = 1}):Play()
        end
        
        task.wait(0.7)
        if slideOutTask then
            task.cancel(slideOutTask)
        end
        
        -- Clean up text labels
        for _, label in ipairs(self.textLabels) do
            if label and label.Parent then
                label:Destroy()
            end
        end
        self.textLabels = {}
        
        self.gui:Destroy()
        self.gui = nil
        self.bg = nil
        self.title = nil
        self.status = nil
        self.dots = nil
        self.codeBackground = nil
        self.codeScroller = nil
        self.progressFill = nil
        self.progressBg = nil
    end
end

local initGui = InitGui.new():create()
_G.destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
