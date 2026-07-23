local UISettings = {
    FolderPath = "Gravel_Saves/assets",
    FileName = "SavedUI.json",
    CurrentTheme = "Dark",
    CurrentTransparency = 0,
    init = function(self)
        if not isfolder(self.FolderPath) then
            pcall(function()
                makefolder(self.FolderPath)
            end)
        end
        self:loadSettings()
        self:applySettings()
        return self
    end,
    getFilePath = function(self)
        return self.FolderPath .. "/" .. self.FileName
    end,
    loadSettings = function(self)
        local filePath = self:getFilePath()
        if not isfile(filePath) then
            self.CurrentTheme = "Dark"
            self.CurrentTransparency = 0
            return false
        end
        local success, data = pcall(function()
            return readfile(filePath)
        end)
        if not success or not data then
            return false
        end
        local success, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if not success or not decoded then
            return false
        end
        self.CurrentTheme = decoded.theme or "Dark"
        self.CurrentTransparency = decoded.transparency or 0
        return true
    end,
    saveSettings = function(self, theme, transparency)
        if theme then self.CurrentTheme = theme end
        if transparency ~= nil then self.CurrentTransparency = transparency end
        if not isfolder(self.FolderPath) then
            pcall(function()
                makefolder(self.FolderPath)
            end)
        end
        
        local data = {
            theme = self.CurrentTheme,
            transparency = self.CurrentTransparency,
            saved_at = os.time()
        }
        
        local success, encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(data)
        end)
        
        if not success then
            return false
        end
        
        local filePath = self:getFilePath()
        local success, err = pcall(function()
            writefile(filePath, encoded)
        end)
        
        return success
    end,
    applySettings = function(self)
        local success = pcall(function()
            if WindUI and WindUI.SetTheme then
                WindUI:SetTheme(self.CurrentTheme)
            end
            if WindUI then
                WindUI.TransparencyValue = self.CurrentTransparency
                if WindUI.Transparent and WindUI.Window and WindUI.Window.ToggleTransparency then
                    WindUI.Window:ToggleTransparency(true)
                end
            end
            if config then
                if config.Gradow then
                    config.Gradow.transparency = self.CurrentTransparency
                end
                if config.varibz then
                    config.varibz.uitheme = self.CurrentTheme
                    config.varibz.uitraaans = self.CurrentTransparency
                end
            end
        end)
        
        return success
    end,
    onThemeChange = function(self, newTheme)
        self.CurrentTheme = newTheme
        self:saveSettings()
        if config and config.varibz then
            config.varibz.uitheme = newTheme
        end
    end,
    onTransparencyChange = function(self, newTransparency)
        self.CurrentTransparency = newTransparency
        self:saveSettings()
        if config and config.varibz then
            config.varibz.uitraaans = newTransparency
        end
        if config and config.Gradow then
            config.Gradow.transparency = newTransparency
        end
    end
}
local uiSettings = UISettings:init()
pcall(function()
    if WindUI then
        local originalOnThemeChange = WindUI.OnThemeChange
        local originalOnTransparencyChange = WindUI.OnTransparencyChange
        WindUI.OnThemeChange = function(theme)
            uiSettings:onThemeChange(theme)
            if originalOnThemeChange then
                originalOnThemeChange(theme)
            end
        end
        WindUI.OnTransparencyChange = function(transparency)
            uiSettings:onTransparencyChange(transparency)
            if originalOnTransparencyChange then
                originalOnTransparencyChange(transparency)
            end
        end
    end
end)
pcall(function()
    task.wait(0.5)
    if Window and Window.Tabs then
        for _, tab in ipairs(Window.Tabs) do
            if tab.Title == "Visuals" then
                for _, element in ipairs(tab.Elements or {}) do
                    if element.Type == "Dropdown" and element.Title == "UI Theme" then
                        local originalCallback = element.Callback
                        element.Callback = function(selectedTheme)
                            uiSettings:onThemeChange(selectedTheme)
                            if originalCallback then
                                originalCallback(selectedTheme)
                            end
                        end
                    end
                    
                    if element.Type == "Slider" and element.Title == "Transparency Value" then
                        local originalCallback = element.Callback
                        element.Callback = function(value)
                            uiSettings:onTransparencyChange(value)
                            if originalCallback then
                                originalCallback(value)
                            end
                        end
                    end
                end
            end
        end
    end
end)
return uiSettings
