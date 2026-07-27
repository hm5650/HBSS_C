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
    self.gui = nil
    self.bg = nil
    self.title = nil
    self.status = nil
    self.dots = nil
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
    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.25)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
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
        task.wait(0.7)
        self.gui:Destroy()
        self.gui = nil
        self.bg = nil
        self.title = nil
        self.status = nil
        self.dots = nil
    end
end
local initGui = InitGui.new():create()
_G.destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
