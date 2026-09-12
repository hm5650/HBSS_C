local SaveUI = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedUI.json",
    CurrentTheme = "Dark",
    CurrentTransparency = 0.15,
    TextCursor1 = "_",
    TextCursor2 = "  ",
    _initialized = false,
    _windUI = nil,
    _config = nil
}

function SaveUI:init(windUI, config)
    if not windUI then
        warn("SaveUI: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    
    if config and config.Gradow then
        self.Folder = config.Gradow.uiThemeSave and config.Gradow.uiThemeSave.Folder or self.Folder
        self.FileName = config.Gradow.uiThemeSave and config.Gradow.uiThemeSave.FileName or self.FileName
        self.CurrentTheme = config.Gradow.uiThemeSave and config.Gradow.uiThemeSave.CurrentTheme or self.CurrentTheme
        self.CurrentTransparency = config.Gradow.uiThemeSave and config.Gradow.uiThemeSave.CurrentTransparency or self.CurrentTransparency
        if config.Gradow.textcursor then
            self.TextCursor1 = config.Gradow.textcursor
        end
        if config.Gradow.textcursor2 then
            self.TextCursor2 = config.Gradow.textcursor2
        end
    end
    
    self._initialized = true
    return true
end

function SaveUI:ensureFolder()
    if not isfolder(self.Folder) then
        pcall(function()
            makefolder(self.Folder)
        end)
    end
end

function SaveUI:getFilePath()
    return self.Folder .. "/" .. self.FileName
end

function SaveUI:save(theme, transparency)
    if not self._initialized then
        warn("SaveUI: Module not initialized! Call :init() first.")
        return false
    end
    
    self:ensureFolder()
    
    local dataToSave = {
        theme = theme or self.CurrentTheme,
        transparency = transparency or self.CurrentTransparency,
        textcursor = self:getTextCursor1(),
        textcursor2 = self:getTextCursor2(),
        savedAt = os.time()
    }
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(dataToSave)
    end)
    
    if not success then
        if self._windUI then
            self._windUI:Notify({
                Title = "UI Save Error",
                Content = "Failed to encode UI settings! :c",
                Icon = "x",
                Duration = 2
            })
        end
        return false
    end
    
    local path = self:getFilePath()
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    
    if success then
        if self._windUI then
            self._windUI:Notify({
                Title = "UI Saved!",
                Content = ":D",
                Icon = "check",
                Duration = 2
            })
        end
        return true
    else
        if self._windUI then
            self._windUI:Notify({
                Title = "UI Save Error",
                Content = "Failed to save D:",
                Icon = "x",
                Duration = 2
            })
        end
        return false
    end
end

function SaveUI:load()
    if not self._initialized then
        warn("SaveUI: Module not initialized! Call :init() first.")
        return false
    end
    
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then
        return false
    end
    
    local success, data = pcall(function()
        return readfile(path)
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
    
    pcall(function()
        if decoded.theme and self._windUI and self._windUI.SetTheme then
            self.CurrentTheme = decoded.theme
            self._windUI:SetTheme(decoded.theme)
        end
        
        if decoded.transparency ~= nil then
            self.CurrentTransparency = decoded.transparency
            self._windUI.TransparencyValue = decoded.transparency
            if self._windUI.Transparent then
                self._windUI.Window:ToggleTransparency(true)
            end
        end
        
        if decoded.textcursor ~= nil then
            self.TextCursor1 = decoded.textcursor
            self:setTextCursor1(decoded.textcursor)
        end
        
        if decoded.textcursor2 ~= nil then
            self.TextCursor2 = decoded.textcursor2
            self:setTextCursor2(decoded.textcursor2)
        end
        
        if self._config and self._config.Gradow then
            if not self._config.Gradow.uiThemeSave then
                self._config.Gradow.uiThemeSave = {}
            end
            self._config.Gradow.uiThemeSave.CurrentTheme = self.CurrentTheme
            self._config.Gradow.uiThemeSave.CurrentTransparency = self.CurrentTransparency
        end
    end)
    
    return true
end

function SaveUI:autoLoad()
    if not self._initialized then
        return false
    end
    
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then
        return false
    end
    
    local success, data = pcall(function()
        return readfile(path)
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
    
    pcall(function()
        if decoded.theme and self._windUI and self._windUI.SetTheme then
            self.CurrentTheme = decoded.theme
            self._windUI:SetTheme(decoded.theme)
        end
        
        if decoded.transparency ~= nil then
            self.CurrentTransparency = decoded.transparency
            self._windUI.TransparencyValue = decoded.transparency
            if self._windUI.Transparent then
                self._windUI.Window:ToggleTransparency(true)
            end
        end
        
        if decoded.textcursor ~= nil then
            self.TextCursor1 = decoded.textcursor
            self:setTextCursor1(decoded.textcursor)
        end
        
        if decoded.textcursor2 ~= nil then
            self.TextCursor2 = decoded.textcursor2
            self:setTextCursor2(decoded.textcursor2)
        end
        
        if self._config and self._config.Gradow then
            if not self._config.Gradow.uiThemeSave then
                self._config.Gradow.uiThemeSave = {}
            end
            self._config.Gradow.uiThemeSave.CurrentTheme = self.CurrentTheme
            self._config.Gradow.uiThemeSave.CurrentTransparency = self.CurrentTransparency
        end
    end)
    
    return true
end
function SaveUI:getTextCursor1()
    if self._config and self._config.Gradow and self._config.Gradow.textcursor then
        return self._config.Gradow.textcursor
    end
    return self.TextCursor1 or "_"
end

function SaveUI:getTextCursor2()
    if self._config and self._config.Gradow and self._config.Gradow.textcursor2 then
        return self._config.Gradow.textcursor2
    end
    return self.TextCursor2 or "  "
end

function SaveUI:setTextCursor1(value)
    self.TextCursor1 = value or "_"
    if self._config and self._config.Gradow then
        self._config.Gradow.textcursor = value or "_"
    end
    pcall(function()
        if self._config and self._config.varibz and self._config.varibz.rng4 and self._config.varibz.rng4.tag then
            local tag = self._config.varibz.rng4.tag
            if tag.SetTitle then
                local currentText = self._config.varibz.rng4.currentText or ""
                local cursor = self._config.varibz.rng4.cursorVisible and value or "  "
                tag:SetTitle(currentText .. cursor)
            end
        end
    end)
end

function SaveUI:setTextCursor2(value)
    self.TextCursor2 = value or "  "
    if self._config and self._config.Gradow then
        self._config.Gradow.textcursor2 = value or "  "
    end
    pcall(function()
        if self._config and self._config.varibz and self._config.varibz.rng4 and self._config.varibz.rng4.tag then
            local tag = self._config.varibz.rng4.tag
            if tag.SetTitle then
                local currentText = self._config.varibz.rng4.currentText or ""
                local cursor = self._config.varibz.rng4.cursorVisible and self.TextCursor1 or value
                tag:SetTitle(currentText .. cursor)
            end
        end
    end)
end
function SaveUI:getTheme()
    return self.CurrentTheme
end

function SaveUI:getTransparency()
    return self.CurrentTransparency
end

function SaveUI:setTheme(theme)
    self.CurrentTheme = theme
    if self._config and self._config.Gradow and self._config.Gradow.uiThemeSave then
        self._config.Gradow.uiThemeSave.CurrentTheme = theme
    end
    return true
end

function SaveUI:setTransparency(transparency)
    self.CurrentTransparency = transparency
    if self._config and self._config.Gradow and self._config.Gradow.uiThemeSave then
        self._config.Gradow.uiThemeSave.CurrentTransparency = transparency
    end
    return true
end

function SaveUI:reset()
    self.CurrentTheme = "Dark"
    self.CurrentTransparency = 0.15
    self.TextCursor1 = "_"
    self.TextCursor2 = "  "
    
    if self._config and self._config.Gradow then
        if not self._config.Gradow.uiThemeSave then
            self._config.Gradow.uiThemeSave = {}
        end
        self._config.Gradow.uiThemeSave.CurrentTheme = self.CurrentTheme
        self._config.Gradow.uiThemeSave.CurrentTransparency = self.CurrentTransparency
        self._config.Gradow.textcursor = "_"
        self._config.Gradow.textcursor2 = "  "
    end
    
    if self._windUI then
        self._windUI:SetTheme(self.CurrentTheme)
        self._windUI.TransparencyValue = self.CurrentTransparency
        if self._windUI.Transparent then
            self._windUI.Window:ToggleTransparency(true)
        end
    end
    pcall(function()
        if self._config and self._config.varibz and self._config.varibz.rng4 and self._config.varibz.rng4.tag then
            local tag = self._config.varibz.rng4.tag
            if tag.SetTitle then
                tag:SetTitle("TextCursor Reset")
                task.wait(0.5)
                local currentText = self._config.varibz.rng4.currentText or ""
                tag:SetTitle(currentText .. "_")
            end
        end
    end)
    
    return true
end

function SaveUI:delete()
    local path = self:getFilePath()
    if isfile(path) then
        pcall(function()
            delfile(path)
        end)
        return true
    end
    return false
end

function SaveUI:exists()
    return isfile(self:getFilePath())
end

return SaveUI
