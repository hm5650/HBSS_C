local BGM = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBGM.json",
    CurrentSoundId = nil,
    CurrentTitle = "None",
    CurrentVolume = 1,
    CurrentPitch = 1,
    IsPlaying = false,
    SoundInstance = nil,
    Presets = {
        { id = "128586477335903", title = "PeanutButter" },
        { id = "93162865190777", title = "KwikFlip" }
    },
    CustomSounds = {},
    _initialized = false,
    _windUI = nil,
    _config = nil,
    _currentDropDownValue = nil,
    _soundConnection = nil,
    _bgmToggleRef = nil,
    _bgmDropdownRef = nil,
    _currentInfoRef = nil
}
function BGM:init(windUI, config)
    if not windUI then
        warn("BGM: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    self._initialized = true
    self:ensureFolder()
    self:autoLoad()
    return true
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
function BGM:getAllSounds()
    local all = {}
    for _, preset in ipairs(self.Presets) do
        table.insert(all, { id = preset.id, title = preset.title, isPreset = true })
    end
    for _, custom in ipairs(self.CustomSounds) do
        table.insert(all, { id = custom.id, title = custom.title, isPreset = false })
    end
    return all
end
function BGM:getSoundById(id)
    if not id then return nil end
    for _, preset in ipairs(self.Presets) do
        if preset.id == id then
            return { id = preset.id, title = preset.title, isPreset = true }
        end
    end
    for _, custom in ipairs(self.CustomSounds) do
        if custom.id == id then
            return { id = custom.id, title = custom.title, isPreset = false }
        end
    end
    return nil
end
function BGM:getDropdownValues()
    local values = {}
    for _, sound in ipairs(self:getAllSounds()) do
        table.insert(values, sound.title .. " (" .. sound.id .. ")")
    end
    if #values == 0 then
        table.insert(values, "None")
    end
    return values
end
function BGM:getDropdownValueFromId(id)
    local sound = self:getSoundById(id)
    if sound then
        return sound.title .. " (" .. sound.id .. ")"
    end
    return nil
end
function BGM:addCustomSound(id, title)
    if not id or id == "" then
        return false, "ID cannot be empty!"
    end
    if not title or title == "" then
        title = "Custom_" .. id
    end
    for _, sound in ipairs(self:getAllSounds()) do
        if sound.id == id then
            return false, "Sound ID already exists!"
        end
    end
    table.insert(self.CustomSounds, { id = id, title = title })
    self:save()
    return true, "Added custom sound: " .. title
end
function BGM:deleteCustomSound(id)
    for i, sound in ipairs(self.CustomSounds) do
        if sound.id == id then
            table.remove(self.CustomSounds, i)
            if self.CurrentSoundId == id then
                self:stop()
                self.CurrentSoundId = nil
                self.CurrentTitle = "None"
            end
            self:save()
            return true, "Deleted: " .. sound.title
        end
    end
    return false, "Sound not found or is a preset!"
end
function BGM:play(id, volume, pitch)
    self:stop()
    local soundData = self:getSoundById(id)
    if not soundData then
        return false, "Sound not found!"
    end
    volume = volume or self.CurrentVolume or 1
    pitch = pitch or self.CurrentPitch or 1
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = volume
    sound.PlaybackSpeed = pitch
    sound.Looped = true
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    self.SoundInstance = sound
    self.CurrentSoundId = id
    self.CurrentTitle = soundData.title
    self.CurrentVolume = volume
    self.CurrentPitch = pitch
    self.IsPlaying = true
    if self._soundConnection then
        self._soundConnection:Disconnect()
    end
    self._soundConnection = sound.Stopped:Connect(function()
        if self.SoundInstance and self.SoundInstance == sound then
            self.SoundInstance = nil
            self.IsPlaying = false
        end
    end)
    self:save()
    return true, "Now playing: " .. soundData.title
end
function BGM:stop()
    if self.SoundInstance then
        self.SoundInstance:Stop()
        self.SoundInstance:Destroy()
        self.SoundInstance = nil
    end
    if self._soundConnection then
        self._soundConnection:Disconnect()
        self._soundConnection = nil
    end
    self.IsPlaying = false
end
function BGM:toggle(id, volume, pitch)
    if self.IsPlaying and self.CurrentSoundId == id then
        self:stop()
        self:save()
        return false, "Stopped"
    else
        return self:play(id, volume, pitch)
    end
end
function BGM:setVolume(volume)
    volume = math.clamp(volume, 0, 5)
    self.CurrentVolume = volume
    if self.SoundInstance then
        self.SoundInstance.Volume = volume
    end
    self:save()
    return true
end
function BGM:setPitch(pitch)
    pitch = math.clamp(pitch, 0.1, 3)
    self.CurrentPitch = pitch
    if self.SoundInstance then
        self.SoundInstance.PlaybackSpeed = pitch
    end
    self:save()
    return true
end
function BGM:refreshUI()
    if not self._initialized then return end
    pcall(function()
        if self._bgmToggleRef then
            self._bgmToggleRef:SetValue(self.IsPlaying)
        end
        if self._bgmDropdownRef then
            local values = self:getDropdownValues()
            self._bgmDropdownRef:SetValues(values)
            if self.CurrentSoundId then
                local value = self:getDropdownValueFromId(self.CurrentSoundId)
                if value then
                    self._bgmDropdownRef:SetValue(value)
                else
                    self._bgmDropdownRef:SetValue(values[1] or "None")
                end
            else
                self._bgmDropdownRef:SetValue(values[1] or "None")
            end
        end
        if self._currentInfoRef then
            if self.IsPlaying and self.CurrentSoundId then
                local soundData = self:getSoundById(self.CurrentSoundId)
                if soundData then
                    self._currentInfoRef:SetDesc("Title: " .. soundData.title .. "\nID: " .. soundData.id .. "\nVolume: " .. self.CurrentVolume .. "\nPitch: " .. self.CurrentPitch)
                end
            else
                self._currentInfoRef:SetDesc("None")
            end
        end
    end)
end
function BGM:setUIReferences(toggleRef, dropdownRef, infoRef)
    self._bgmToggleRef = toggleRef
    self._bgmDropdownRef = dropdownRef
    self._currentInfoRef = infoRef
end
function BGM:save()
    self:ensureFolder()
    local dataToSave = {
        currentSoundId = self.CurrentSoundId,
        currentTitle = self.CurrentTitle,
        currentVolume = self.CurrentVolume,
        currentPitch = self.CurrentPitch,
        isPlaying = self.IsPlaying,
        customSounds = self.CustomSounds,
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
    if success then
        self:refreshUI()
    end
    return success
end
function BGM:load()
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
        if decoded.customSounds then
            self.CustomSounds = decoded.customSounds
        end
        self.CurrentSoundId = decoded.currentSoundId
        self.CurrentTitle = decoded.currentTitle or "None"
        self.CurrentVolume = decoded.currentVolume or 1
        self.CurrentPitch = decoded.currentPitch or 1
        self.IsPlaying = decoded.isPlaying or false
        self:stop()
        if self.IsPlaying and self.CurrentSoundId then
            self:play(self.CurrentSoundId, self.CurrentVolume, self.CurrentPitch)
        end
        self:refreshUI()
    end)
    return true
end
function BGM:autoLoad()
    return self:load()
end
function BGM:reload()
    return self:load()
end
function BGM:reset()
    self:stop()
    self.CustomSounds = {}
    self.CurrentSoundId = nil
    self.CurrentTitle = "None"
    self.CurrentVolume = 1
    self.CurrentPitch = 1
    self.IsPlaying = false
    self:save()
    self:refreshUI()
    return true
end
return BGM
