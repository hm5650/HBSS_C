-- BLLEHHH >:P
local BMG = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBMG.json",
    CustomIdsFile = "StoredAssetIDs.json",
    CurrentMusicId = "128586477335903",
    CurrentTitle = "PeanutButter",
    Volume = 1,
    Pitch = 1,
    IsPlaying = false,
    CustomMusicIds = {},
    PresetMusicIds = {
--        { id = "", title = "" },
        { id = "128586477335903", title = "PeanutButter" },
        { id = "93162865190777", title = "KwikFlip" },
        { id = "123584554132464", title = "Horizons" },
        { id = "136438088630687", title = "MEGALOVANIA" },
        { id = "1848354536", title = "Nostalgic" },
        { id = "120187702909985", title = "Still Alive" },
        { id = "108483365019009", title = "Unslept" },
    },
    _initialized = false,
    _windUI = nil,
    _config = nil,
    _sound = nil,
    _connections = {},
    _dropdownRef = nil
}

function BMG:init(windUI, config)
    if not windUI then
        warn("BMG: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    
    if config and config.BMG then
        self.Folder = config.BMG.Folder or self.Folder
        self.FileName = config.BMG.FileName or self.FileName
        self.CustomIdsFile = config.BMG.CustomIdsFile or self.CustomIdsFile
        self.CurrentMusicId = config.BMG.CurrentMusicId or self.CurrentMusicId
        self.CurrentTitle = config.BMG.CurrentTitle or self.CurrentTitle
        self.Volume = config.BMG.Volume or self.Volume
        self.Pitch = config.BMG.Pitch or self.Pitch
        self.IsPlaying = config.BMG.IsPlaying or self.IsPlaying
        self.CustomMusicIds = config.BMG.CustomMusicIds or {}
    end
    
    self._initialized = true
    return true
end

function BMG:setDropdownRef(dropdown)
    self._dropdownRef = dropdown
end

function BMG:refreshDropdown()
    if self._dropdownRef and self._dropdownRef.Refresh then
        local values = self:getDropdownValues()
        self._dropdownRef:Refresh(values)
        self._dropdownRef:SetValue(self:getSelectedValue())
        return true
    end
    return false
end

function BMG:ensureFolder()
    if not isfolder(self.Folder) then
        pcall(function()
            makefolder(self.Folder)
        end)
    end
end

function BMG:getFilePath()
    return self.Folder .. "/" .. self.FileName
end

function BMG:getCustomIdsPath()
    return self.Folder .. "/" .. self.CustomIdsFile
end

function BMG:getAllMusicIds()
    local all = {}
    for _, preset in ipairs(self.PresetMusicIds) do
        table.insert(all, preset)
    end
    for _, custom in ipairs(self.CustomMusicIds) do
        table.insert(all, custom)
    end
    return all
end

function BMG:getMusicIdById(id)
    local all = self:getAllMusicIds()
    for _, item in ipairs(all) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function BMG:getMusicIdByTitle(title)
    local all = self:getAllMusicIds()
    for _, item in ipairs(all) do
        if item.title == title then
            return item
        end
    end
    return nil
end

function BMG:getDropdownValues()
    local values = {}
    for _, item in ipairs(self:getAllMusicIds()) do
        table.insert(values, item.title .. " (" .. item.id .. ")")
    end
    return values
end

function BMG:getSelectedValue()
    local current = self:getMusicIdById(self.CurrentMusicId)
    if current then
        return current.title .. " (" .. current.id .. ")"
    end
    return "PeanutButter (128586477335903)"
end

function BMG:addCustomMusic(id, title)
    if not id or id == "" then
        return false, "Invalid music ID"
    end
    if not title or title == "" then
        return false, "Invalid title"
    end
    
    if self:getMusicIdById(id) then
        return false, "Music ID already exists"
    end
    
    table.insert(self.CustomMusicIds, { id = id, title = title })
    self:saveCustomIds()
    self:refreshDropdown()
    return true, "Added " .. title
end

function BMG:deleteMusic(id)
    if not id or id == "" then
        return false, "No music ID selected"
    end
    
    for _, preset in ipairs(self.PresetMusicIds) do
        if preset.id == id then
            return false, "Cannot delete preset music"
        end
    end
    
    for i, custom in ipairs(self.CustomMusicIds) do
        if custom.id == id then
            table.remove(self.CustomMusicIds, i)
            if self.CurrentMusicId == id then
                self.CurrentMusicId = self.PresetMusicIds[1].id
                self.CurrentTitle = self.PresetMusicIds[1].title
                self:playCurrent()
            end
            self:saveCustomIds()
            self:refreshDropdown()
            return true, "Deleted music"
        end
    end
    
    return false, "Music not found"
end

function BMG:setCurrentMusic(id)
    local music = self:getMusicIdById(id)
    if not music then
        return false, "Music not found"
    end
    
    self.CurrentMusicId = id
    self.CurrentTitle = music.title
    self:playCurrent()
    return true, "Switched to " .. music.title
end

function BMG:setVolume(volume)
    self.Volume = math.clamp(volume or 1, 0, 5)
    if self._sound then
        pcall(function()
            self._sound.Volume = self.Volume
        end)
    end
    return true
end

function BMG:setPitch(pitch)
    self.Pitch = math.clamp(pitch or 1, 0.5, 2)
    if self._sound then
        pcall(function()
            self._sound.PlaybackSpeed = self.Pitch
        end)
    end
    return true
end

function BMG:playCurrent()
    self:stop()
    
    if not self.IsPlaying then
        return
    end
    
    if not self.CurrentMusicId or self.CurrentMusicId == "" then
        return
    end
    
    pcall(function()
        self._sound = Instance.new("Sound")
        self._sound.SoundId = "rbxassetid://" .. self.CurrentMusicId
        self._sound.Volume = self.Volume
        self._sound.PlaybackSpeed = self.Pitch
        self._sound.Looped = true
        self._sound.Parent = game:GetService("SoundService")
        self._sound:Play()
        
        self._connections.soundEnded = self._sound.Stopped:Connect(function()
            if self.IsPlaying and self._sound then
                self._sound:Play()
            end
        end)
    end)
end

function BMG:stop()
    if self._sound then
        pcall(function()
            self._sound:Stop()
            self._sound:Destroy()
        end)
        self._sound = nil
    end
    
    for _, conn in pairs(self._connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    self._connections = {}
end

function BMG:togglePlay(state)
    if state == nil then
        state = not self.IsPlaying
    end
    
    self.IsPlaying = state
    
    if state then
        self:playCurrent()
    else
        self:stop()
    end
    
    return self.IsPlaying
end

function BMG:saveCustomIds()
    self:ensureFolder()
    
    local dataToSave = {
        customMusicIds = self.CustomMusicIds,
        savedAt = os.time()
    }
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(dataToSave)
    end)
    
    if not success then
        return false
    end
    
    local path = self:getCustomIdsPath()
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    
    return success
end

function BMG:loadCustomIds()
    self:ensureFolder()
    local path = self:getCustomIdsPath()
    
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
    
    if decoded.customMusicIds then
        self.CustomMusicIds = decoded.customMusicIds
        if self._config and self._config.BMG then
            self._config.BMG.CustomMusicIds = self.CustomMusicIds
        end
    end
    
    return true
end

function BMG:save()
    if not self._initialized then
        warn("BMG: Module not initialized! Call :init() first.")
        return false
    end
    
    self:ensureFolder()
    self:saveCustomIds()
    
    local dataToSave = {
        currentMusicId = self.CurrentMusicId,
        currentTitle = self.CurrentTitle,
        volume = self.Volume,
        pitch = self.Pitch,
        isPlaying = self.IsPlaying,
        savedAt = os.time()
    }
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(dataToSave)
    end)
    
    if not success then
        return false
    end
    
    local path = self:getFilePath()
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    
    return success
end

function BMG:load()
    if not self._initialized then
        warn("BMG: Module not initialized! Call :init() first.")
        return false
    end
    
    self:ensureFolder()
    self:loadCustomIds()
    
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
        if decoded.currentMusicId then
            self.CurrentMusicId = decoded.currentMusicId
        end
        if decoded.currentTitle then
            self.CurrentTitle = decoded.currentTitle
        end
        if decoded.volume ~= nil then
            self.Volume = math.clamp(decoded.volume, 0, 5)
        end
        if decoded.pitch ~= nil then
            self.Pitch = math.clamp(decoded.pitch, 0.5, 2)
        end
        if decoded.isPlaying ~= nil then
            self.IsPlaying = decoded.isPlaying
        end
        
        if self._config and self._config.BMG then
            self._config.BMG.CurrentMusicId = self.CurrentMusicId
            self._config.BMG.CurrentTitle = self.CurrentTitle
            self._config.BMG.Volume = self.Volume
            self._config.BMG.Pitch = self.Pitch
            self._config.BMG.IsPlaying = self.IsPlaying
            self._config.BMG.CustomMusicIds = self.CustomMusicIds
        end
        
        self:playCurrent()
        self:refreshDropdown()
    end)
    
    return true
end

function BMG:autoLoad()
    if not self._initialized then
        return false
    end
    
    self:ensureFolder()
    self:loadCustomIds()
    
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
        if decoded.currentMusicId then
            self.CurrentMusicId = decoded.currentMusicId
        end
        if decoded.currentTitle then
            self.CurrentTitle = decoded.currentTitle
        end
        if decoded.volume ~= nil then
            self.Volume = math.clamp(decoded.volume, 0, 5)
        end
        if decoded.pitch ~= nil then
            self.Pitch = math.clamp(decoded.pitch, 0.5, 2)
        end
        if decoded.isPlaying ~= nil then
            self.IsPlaying = decoded.isPlaying
        end
        
        if self._config and self._config.BMG then
            self._config.BMG.CurrentMusicId = self.CurrentMusicId
            self._config.BMG.CurrentTitle = self.CurrentTitle
            self._config.BMG.Volume = self.Volume
            self._config.BMG.Pitch = self.Pitch
            self._config.BMG.IsPlaying = self.IsPlaying
            self._config.BMG.CustomMusicIds = self.CustomMusicIds
        end
        
        self:playCurrent()
        self:refreshDropdown()
    end)
    
    return true
end

function BMG:cleanup()
    self:stop()
    return true
end

function BMG:getMusicRefresher()
    return function()
        if self.IsPlaying then
            self:playCurrent()
        end
    end
end

return BMG
