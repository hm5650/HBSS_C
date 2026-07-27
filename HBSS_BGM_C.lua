local BGM = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBMG.json",
    CurrentSoundId = nil,
    CustomSounds = {},
    PresetSounds = {
        {id = "128586477335903", title = "PeanutButter"},
        {id = "93162865190777", title = "KwikFlip"}
    },
    Volume = 1,
    Pitch = 1,
    Enabled = false,
    SoundInstance = nil,
    _initialized = false,
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
    self._initialized = true
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
function BGM:getSoundService()
    return game:GetService("SoundService")
end
function BGM:playSound()
    if not self._initialized then
        warn("BGM: Module not initialized! Call :init() first.")
        return false
    end
    self:stopSound()
    if not self.Enabled or not self.CurrentSoundId then
        return false
    end
    local soundService = self:getSoundService()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. self.CurrentSoundId
    sound.Volume = self.Volume
    sound.Pitch = self.Pitch
    sound.Looped = true
    sound.Parent = soundService
    sound:Play()
    self.SoundInstance = sound
    return true
end
function BGM:stopSound()
    if self.SoundInstance then
        pcall(function()
            self.SoundInstance:Stop()
            self.SoundInstance:Destroy()
        end)
        self.SoundInstance = nil
    end
    return true
end
function BGM:updateSound()
    if self.Enabled and self.CurrentSoundId then
        return self:playSound()
    else
        self:stopSound()
        return false
    end
end
function BGM:getAllSounds()
    local all = {}
    for _, preset in ipairs(self.PresetSounds) do
        table.insert(all, preset)
    end
    for _, custom in ipairs(self.CustomSounds) do
        table.insert(all, custom)
    end
    return all
end
function BGM:getSoundTitles()
    local titles = {}
    for _, sound in ipairs(self:getAllSounds()) do
        if sound.title and sound.id then
            table.insert(titles, sound.title .. " (" .. sound.id .. ")")
        end
    end
    return titles
end
function BGM:findSoundById(id)
    for _, sound in ipairs(self:getAllSounds()) do
        if sound.id == id then
            return sound
        end
    end
    return nil
end
function BGM:findSoundByTitle(title)
    for _, sound in ipairs(self:getAllSounds()) do
        if sound.title == title then
            return sound
        end
    end
    return nil
end
function BGM:isPreset(id)
    for _, preset in ipairs(self.PresetSounds) do
        if preset.id == id then
            return true
        end
    end
    return false
end
function BGM:addCustomSound(id, title)
    if not id or id == "" then
        return false, "No ID provided"
    end
    if not title or title == "" then
        title = "Custom Sound"
    end
    if self:findSoundById(id) then
        return false, "Sound ID already exists"
    end
    table.insert(self.CustomSounds, {
        id = id,
        title = title
    })
    return true, "Added custom sound"
end
function BGM:deleteCustomSound(id)
    if self:isPreset(id) then
        return false, "Cannot delete preset sounds"
    end
    for i, sound in ipairs(self.CustomSounds) do
        if sound.id == id then
            table.remove(self.CustomSounds, i)
            if self.CurrentSoundId == id then
                self.CurrentSoundId = nil
                self:updateSound()
            end
            return true, "Deleted custom sound"
        end
    end
    return false, "Sound not found"
end
function BGM:save()
    if not self._initialized then
        warn("BGM: Module not initialized! Call :init() first.")
        return false
    end
    self:ensureFolder()
    local dataToSave = {
        enabled = self.Enabled,
        currentSoundId = self.CurrentSoundId,
        volume = self.Volume,
        pitch = self.Pitch,
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
    return success
end
function BGM:load()
    if not self._initialized then
        warn("BGM: Module not initialized! Call :init() first.")
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
        if decoded.enabled ~= nil then
            self.Enabled = decoded.enabled
        end
        if decoded.currentSoundId then
            self.CurrentSoundId = decoded.currentSoundId
        end
        if decoded.volume ~= nil then
            self.Volume = decoded.volume
        end
        if decoded.pitch ~= nil then
            self.Pitch = decoded.pitch
        end
        if decoded.customSounds and type(decoded.customSounds) == "table" then
            self.CustomSounds = decoded.customSounds
        end
        self:updateSound()
    end)
    return true
end
function BGM:autoLoad()
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
        if decoded.enabled ~= nil then
            self.Enabled = decoded.enabled
        end
        if decoded.currentSoundId then
            self.CurrentSoundId = decoded.currentSoundId
        end
        if decoded.volume ~= nil then
            self.Volume = decoded.volume
        end
        if decoded.pitch ~= nil then
            self.Pitch = decoded.pitch
        end
        if decoded.customSounds and type(decoded.customSounds) == "table" then
            self.CustomSounds = decoded.customSounds
        end
        self:updateSound()
    end)
    return true
end
function BGM:reset()
    self.CurrentSoundId = nil
    self.CustomSounds = {}
    self.Volume = 1
    self.Pitch = 1
    self.Enabled = false
    self:stopSound()
    return true
end
function BGM:delete()
    local path = self:getFilePath()
    if isfile(path) then
        pcall(function()
            delfile(path)
        end)
        return true
    end
    return false
end
function BGM:exists()
    return isfile(self:getFilePath())
end
return BGM
