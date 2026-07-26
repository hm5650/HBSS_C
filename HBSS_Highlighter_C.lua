local Highlights = {}
Highlights._connections = {}
Highlights._scanning = false
local function Highlights:init(configTable, WindUI)
    self.config = configTable
    self.WindUI = WindUI
    if not self.config.highlights then
        self.config.highlights = {
            fireTouchInterest = {
                enabled = false,
                color = Color3.fromRGB(255, 100, 100)
            },
            proximityPrompt = {
                enabled = false,
                color = Color3.fromRGB(100, 255, 100)
            },
            clickDetector = {
                enabled = false,
                color = Color3.fromRGB(100, 100, 255)
            },
            tools = {
                enabled = false,
                color = Color3.fromRGB(255, 255, 100)
            }
        }
    end
    if not self.config.highlightInstances then
        self.config.highlightInstances = {
            fireTouchInterest = {},
            proximityPrompt = {},
            clickDetector = {},
            tools = {}
        }
    end
    return self
end
    Create highlight for a single instance
]]
local function Highlights:createHighlight(instance, color, category)
    if not instance or not instance.Parent then return end
    if not self.config.highlights[category] or not self.config.highlights[category].enabled then return end
    self:removeHighlight(instance, category)
    local highlight = Instance.new("Highlight")
    highlight.Name = "GravelHighlight_" .. category
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.2
    pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    highlight.Parent = instance
    self.config.highlightInstances[category][instance] = highlight
    return highlight
end
local function Highlights:removeHighlight(instance, category)
    if not instance then return end
    local existing = self.config.highlightInstances[category] and self.config.highlightInstances[category][instance]
    if existing then
        pcall(function() existing:Destroy() end)
        self.config.highlightInstances[category][instance] = nil
    end
end
local function Highlights:clearCategory(category)
    if not category then
        for cat, _ in pairs(self.config.highlightInstances) do
            self:clearCategory(cat)
        end
        return
    end
    if self.config.highlightInstances[category] then
        for instance, highlight in pairs(self.config.highlightInstances[category]) do
            pcall(function() highlight:Destroy() end)
        end
        self.config.highlightInstances[category] = {}
    end
end

local function Highlights:getInstancesOfType(className)
    local results = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA(className) then
            table.insert(results, obj)
        end
    end
    return results
end
local function Highlights:getAllTools()
    local tools = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:IsDescendantOf(workspace) then
            table.insert(tools, obj)
        end
    end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj:IsA("Tool") then
                    table.insert(tools, obj)
                end
            end
        end
        if player.Backpack then
            for _, obj in ipairs(player.Backpack:GetChildren()) do
                if obj:IsA("Tool") then
                    table.insert(tools, obj)
                end
            end
        end
    end
    return tools
end
local function Highlights:getToolPart(tool)
    local handle = tool:FindFirstChild("Handle")
    if handle then return handle end
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return tool
end
local function Highlights:scanCategory(category)
    local config = self.config.highlights[category]
    if not config then return end
    if not config.enabled then
        self:clearCategory(category)
        return
    end
    local instances = {}
    if category == "fireTouchInterest" then
        instances = self:getInstancesOfType("FireTouchInterest")
    elseif category == "proximityPrompt" then
        instances = self:getInstancesOfType("ProximityPrompt")
    elseif category == "clickDetector" then
        instances = self:getInstancesOfType("ClickDetector")
    elseif category == "tools" then
        instances = self:getAllTools()
    end
    local processed = {}
    for _, instance in ipairs(instances) do
        local target = instance
        if category == "tools" then
            target = self:getToolPart(instance)
        end
        if target then
            self:createHighlight(target, config.color, category)
            processed[instance] = true
        end
    end
    local toRemove = {}
    for existingInstance, _ in pairs(self.config.highlightInstances[category] or {}) do
        local found = false
        for _, instance in ipairs(instances) do
            if instance == existingInstance then
                found = true
                break
            end
            if category == "tools" and existingInstance:IsA("BasePart") then
                local parent = existingInstance.Parent
                if parent and parent:IsA("Tool") and parent == instance then
                    found = true
                    break
                end
            end
        end
        if not found then
            table.insert(toRemove, existingInstance)
        end
    end
    for _, instance in ipairs(toRemove) do
        self:removeHighlight(instance, category)
    end
end
local function Highlights:scanAll()
    local categories = {"fireTouchInterest", "proximityPrompt", "clickDetector", "tools"}
    for _, category in ipairs(categories) do
        self:scanCategory(category)
    end
end
local function Highlights:startScanning(interval)
    interval = interval or 1.5
    if self._scanning then
        self:stopScanning()
    end
    self._scanning = true
    self:scanAll()
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self._scanning then
            connection:Disconnect()
            return
        end
        if not self._lastScan or tick() - self._lastScan > interval then
            self._lastScan = tick()
            self:scanAll()
        end
    end)
    table.insert(self._connections, connection)
end
local function Highlights:stopScanning()
    self._scanning = false
    for _, conn in ipairs(self._connections) do
        pcall(function() conn:Disconnect() end)
    end
    self._connections = {}
end
local function Highlights:toggleCategory(category, state)
    if not self.config.highlights[category] then
        return false
    end
    self.config.highlights[category].enabled = state
    self:scanCategory(category)
    if self.WindUI then
        self.WindUI:Notify({
            Title = "Highlights",
            Content = string.format("%s %s", category:gsub("(%l)(%w*)", function(a,b) return a:upper()..b end), state and "Enabled" or "Disabled"),
            Icon = state and "check" or "x",
            Duration = 1
        })
    end
    return true
end
local function Highlights:setColor(category, color)
    if not self.config.highlights[category] then
        return false
    end
    self.config.highlights[category].color = color
    if self.config.highlights[category].enabled then
        self:scanCategory(category)
    end
    return true
end
local function Highlights:getEnabledCategories()
    local enabled = {}
    for category, config in pairs(self.config.highlights) do
        if config.enabled then
            table.insert(enabled, category)
        end
    end
    return enabled
end
local function Highlights:cleanup()
    self:stopScanning()
    self:clearCategory()
    for category, _ in pairs(self.config.highlightInstances) do
        self.config.highlightInstances[category] = {}
    end
end
local function Highlights:getSaveData()
    return {
        highlights = self.config.highlights
    }
end
local function Highlights:loadSaveData(data)
    if data and data.highlights then
        for category, config in pairs(data.highlights) do
            if self.config.highlights[category] then
                self.config.highlights[category].enabled = config.enabled or false
                if config.color then
                    self.config.highlights[category].color = config.color
                end
            end
        end
        self:scanAll()
        return true
    end
    return false
end
local function Highlights:createUI(tab)
    if not tab then return end
    tab:Toggle({
        Title = "Highlight FireTouchInterest",
        Desc = "Highlight FireTouchInterest instances in the workspace",
        Value = self.config.highlights.fireTouchInterest.enabled or false,
        Callback = function(v)
            self:toggleCategory("fireTouchInterest", v)
        end
    })
    tab:Colorpicker({
        Title = "FireTouchInterest Color",
        Desc = "Color for FireTouchInterest highlights",
        Default = self.config.highlights.fireTouchInterest.color,
        Transparency = 0,
        Locked = false,
        Callback = function(color)
            self:setColor("fireTouchInterest", color)
        end
    })
    tab:Space()
    tab:Toggle({
        Title = "Highlight ProximityPrompts",
        Desc = "Highlight ProximityPrompt instances in the workspace",
        Value = self.config.highlights.proximityPrompt.enabled or false,
        Callback = function(v)
            self:toggleCategory("proximityPrompt", v)
        end
    })
    tab:Colorpicker({
        Title = "ProximityPrompt Color",
        Desc = "Color for ProximityPrompt highlights",
        Default = self.config.highlights.proximityPrompt.color,
        Transparency = 0,
        Locked = false,
        Callback = function(color)
            self:setColor("proximityPrompt", color)
        end
    })
    tab:Space()
    tab:Toggle({
        Title = "Highlight ClickDetectors",
        Desc = "Highlight ClickDetector instances in the workspace",
        Value = self.config.highlights.clickDetector.enabled or false,
        Callback = function(v)
            self:toggleCategory("clickDetector", v)
        end
    })
    tab:Colorpicker({
        Title = "ClickDetector Color",
        Desc = "Color for ClickDetector highlights",
        Default = self.config.highlights.clickDetector.color,
        Transparency = 0,
        Locked = false,
        Callback = function(color)
            self:setColor("clickDetector", color)
        end
    })
    tab:Space()
    tab:Toggle({
        Title = "Highlight Tools",
        Desc = "Highlight Tool instances in workspace and players",
        Value = self.config.highlights.tools.enabled or false,
        Callback = function(v)
            self:toggleCategory("tools", v)
        end
    })
    tab:Colorpicker({
        Title = "Tools Color",
        Desc = "Color for Tool highlights",
        Default = self.config.highlights.tools.color,
        Transparency = 0,
        Locked = false,
        Callback = function(color)
            self:setColor("tools", color)
        end
    })
    tab:Space()
    tab:Button({
        Title = "Refresh Highlights",
        Desc = "Force a refresh of all highlights",
        Icon = "refresh",
        Callback = function()
            self:scanAll()
            if self.WindUI then
                self.WindUI:Notify({
                    Title = "Highlights",
                    Content = "Refreshed all highlights",
                    Icon = "check",
                    Duration = 1
                })
            end
        end
    })
    tab:Button({
        Title = "Clear All Highlights",
        Desc = "Remove all highlight instances",
        Icon = "trash",
        Callback = function()
            self:clearCategory()
            if self.WindUI then
                self.WindUI:Notify({
                    Title = "Highlights",
                    Content = "Cleared all highlights",
                    Icon = "x",
                    Duration = 1
                })
            end
        end
    })
end
local function Highlights.new(configTable, WindUI)
    local self = setmetatable({}, {__index = Highlights})
    self:init(configTable, WindUI)
    return self
end
local function loadHighlightsModule(configTable, WindUI, autoStart)
    autoStart = autoStart ~= false
    local highlights = Highlights.new(configTable, WindUI)
    if autoStart then
        highlights:startScanning(1.5)
    end
    return highlights
end
return {
    Highlights = Highlights,
    loadHighlightsModule = loadHighlightsModule
}
