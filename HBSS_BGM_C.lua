local BGM = {
    Folder = "Gravel_Saves/assets",
    FileName = "Assetids.json",
    CurrentMusicId = "128586477335903",
    CurrentTitle = "PeanutButter",
    Volume = 1,
    Pitch = 1,
    IsPlaying = false,
    Presets = {
        { id = "128586477335903", title = "PeanutButter" },
        { id = "93162865190777", title = "KwikFlip" }
    },
    CustomIds = {},
    _initialized = false,
    _sound = nil,
    _soundService = nil,
    _windUI = nil,
    _config = nil
}
function BGM:init(windUI, config)
    if not windUI then
        warn("BGM: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    self._soundService = game:GetService("SoundService")
    self:load()
    self:setupSound()
    self._initialized = true
    return true
end
function BGM:setupSound()
    if self._sound then
        self._sound:Destroy()
        self._sound = nil
    end
    self._sound = Instance.new("Sound")
    self._sound.Name = "BGM_Sound"
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusicId
    self._sound.Volume = self.Volume
    self._sound.PlayOnRemove = false
    self._sound.Looped = true
    self._sound.Parent = self._soundService
    if self.IsPlaying then
        self:play()
    end
end
function BGM:ensureFolder()
    if not isfolder(self.Folder) then
        pcall(function()
            makefolder(self.Folder)
        end)
    end
end
function BGM:getFilePath()
    return self.Folder .. "/" .. self.FileName
end
function BGM:getAllIds()
    local all = {}
    for _, preset in ipairs(self.Presets) do
        table.insert(all, { id = preset.id, title = preset.title, isPreset = true })
    end
    for _, custom in ipairs(self.CustomIds) do
        table.insert(all, { id = custom.id, title = custom.title, isPreset = false })
    end
    return all
end
function BGM:getMusicTitles()
    local titles = {}
    for _, preset in ipairs(self.Presets) do
        table.insert(titles, preset.title)
    end
    for _, custom in ipairs(self.CustomIds) do
        table.insert(titles, custom.title)
    end
    return titles
end
function BGM:getMusicIdByTitle(title)
    for _, preset in ipairs(self.Presets) do
        if preset.title == title then
            return preset.id
        end
    end
    for _, custom in ipairs(self.CustomIds) do
        if custom.title == title then
            return custom.id
        end
    end
    return nil
end
function BGM:getTitleById(id)
    for _, preset in ipairs(self.Presets) do
        if preset.id == id then
            return preset.title
        end
    end
    for _, custom in ipairs(self.CustomIds) do
        if custom.id == id then
            return custom.title
        end
    end
    return nil
end
function BGM:isPreset(id)
    for _, preset in ipairs(self.Presets) do
        if preset.id == id then
            return true
        end
    end
    return false
end
function BGM:addCustomId(id, title)
    if not id or id == "" then
        return false, "Invalid ID"
    end
    if not title or title == "" then
        return false, "Invalid title"
    end
    for _, custom in ipairs(self.CustomIds) do
        if custom.id == id then
            return false, "ID already exists"
        end
    end
    for _, preset in ipairs(self.Presets) do
        if preset.title == title then
            return false, "Title already exists in presets"
        end
    end
    for _, custom in ipairs(self.CustomIds) do
        if custom.title == title then
            return false, "Title already exists"
        end
    end
    table.insert(self.CustomIds, { id = id, title = title })
    self:save()
    return true, "Added successfully"
end
function BGM:deleteCustomId(title)
    if not title or title == "" then
        return false, "Invalid title"
    end
    for _, preset in ipairs(self.Presets) do
        if preset.title == title then
            return false, "Cannot delete preset music"
        end
    end
    for i, custom in ipairs(self.CustomIds) do
        if custom.title == title then
            table.remove(self.CustomIds, i)
            self:save()
            return true, "Deleted successfully"
        end
    end
    return false, "Custom music not found"
end
function BGM:setCurrentMusic(title)
    local id = self:getMusicIdByTitle(title)
    if not id then
        return false, "Music not found"
    end
    self.CurrentMusicId = id
    self.CurrentTitle = title
    if self._sound then
        self._sound.SoundId = "rbxassetid://" .. id
        if self.IsPlaying then
            self:play()
        end
    end
    self:save()
    return true, "Music changed"
end
function BGM:play()
    self.IsPlaying = true
    if self._sound then
        self._sound:Play()
    end
    self:save()
end
function BGM:stop()
    self.IsPlaying = false
    if self._sound then
        self._sound:Stop()
    end
    self:save()
end
function BGM:setVolume(volume)
    self.Volume = math.clamp(volume, 0, 5)
    if self._sound then
        self._sound.Volume = self.Volume
    end
    self:save()
end
function BGM:setPitch(pitch)
    self.Pitch = math.clamp(pitch, 0.1, 5)
    if self._sound then
        self._sound.PlaybackSpeed = self.Pitch
    end
    self:save()
end
function BGM:getCurrentDisplay()
    local title = self:getTitleById(self.CurrentMusicId) or self.CurrentTitle
    return string.format("%s (%s)", title, self.CurrentMusicId)
end
function BGM:save()
    self:ensureFolder()
    local dataToSave = {
        currentId = self.CurrentMusicId,
        currentTitle = self.CurrentTitle,
        volume = self.Volume,
        pitch = self.Pitch,
        isPlaying = self.IsPlaying,
        customIds = self.CustomIds,
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
function BGM:load()
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then
        self:save()
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
        if decoded.currentId then
            self.CurrentMusicId = decoded.currentId
        end
        if decoded.currentTitle then
            self.CurrentTitle = decoded.currentTitle
        end
        if decoded.volume ~= nil then
            self.Volume = math.clamp(decoded.volume, 0, 5)
        end
        if decoded.pitch ~= nil then
            self.Pitch = math.clamp(decoded.pitch, 0.1, 5)
        end
        if decoded.isPlaying ~= nil then
            self.IsPlaying = decoded.isPlaying
        end
        if decoded.customIds and type(decoded.customIds) == "table" then
            self.CustomIds = decoded.customIds
        end
    end)
    return true
end
function BGM:deleteSave()
    local path = self:getFilePath()
    if isfile(path) then
        pcall(function()
            delfile(path)
        end)
        return true
    end
    return false
end
function BGM:reset()
    self:stop()
    self.CurrentMusicId = "128586477335903"
    self.CurrentTitle = "PeanutButter"
    self.Volume = 1
    self.Pitch = 1
    self.IsPlaying = false
    self.CustomIds = {}
    if self._sound then
        self._sound.SoundId = "rbxassetid://128586477335903"
        self._sound.Volume = 1
        self._sound.PlaybackSpeed = 1
    end
    self:save()
    return true
end
function BGM:exists()
    return isfile(self:getFilePath())
end
function BGM:cleanup()
    if self._sound then
        self._sound:Destroy()
        self._sound = nil
    end
end
return BGM
