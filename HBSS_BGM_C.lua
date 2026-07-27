local BGM = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBGM.json",
    _initialized = false,
    _windUI = nil,
    _config = nil,
    DefaultMusic = {
        { id = "128586477335903", title = "Peanut Butter" },
        { id = "93162865190777", title = "KwikFlip" }
    },
    CurrentMusic = {
        enabled = false,
        onlyMaximized = true,
        volume = 1,
        pitch = 1,
        currentId = "128586477335903",
        currentTitle = "Peanut Butter"
    },
    CustomMusic = {},
    _sound = nil,
    _isPlaying = false,
    _isPaused = false,
}
function BGM:init(windUI, config)
    if not windUI then
        warn("BGM: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    self:load()
    self:setupSound()
    self._initialized = true
    return true
end
function BGM:setupSound()
    if self._sound then
        self._sound:Stop()
        self._sound:Destroy()
        self._sound = nil
    end
    self._sound = Instance.new("Sound")
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusic.currentId
    self._sound.Volume = self.CurrentMusic.volume
    self._sound.PlayOnRemove = false
    self._sound.Looped = true
    if self.CurrentMusic.enabled then
        self:play()
    end
    return self._sound
end
function BGM:getSoundId()
    return "rbxassetid://" .. self.CurrentMusic.currentId
end
function BGM:updateSound()
    if not self._sound then
        self:setupSound()
        return
    end
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusic.currentId
    self._sound.Volume = self.CurrentMusic.volume
    if self.CurrentMusic.enabled then
        self:play()
    else
        self:stop()
    end
end
function BGM:getAllMusic()
    local all = {}
    for _, music in ipairs(self.DefaultMusic) do
        table.insert(all, { id = music.id, title = music.title })
    end
    for _, music in ipairs(self.CustomMusic) do
        table.insert(all, { id = music.id, title = music.title })
    end
    return all
end
function BGM:getMusicById(id)
    for _, music in ipairs(self:getAllMusic()) do
        if music.id == id then
            return music
        end
    end
    return nil
end
function BGM:getCurrentTitle()
    local music = self:getMusicById(self.CurrentMusic.currentId)
    return music and music.title or "Unknown"
end
function BGM:addCustomMusic(id, title)
    if not id or id == "" then
        return false, "Please enter a music ID!"
    end
    if not title or title == "" then
        return false, "Please enter a title for the music!"
    end
    for _, music in ipairs(self:getAllMusic()) do
        if music.id == id then
            return false, "Music ID already exists!"
        end
    end
    table.insert(self.CustomMusic, { id = id, title = title })
    self:save()
    return true, "Added '" .. title .. "' successfully!"
end
function BGM:deleteCustomMusic(id)
    for i, music in ipairs(self.CustomMusic) do
        if music.id == id then
            table.remove(self.CustomMusic, i)
            if self.CurrentMusic.currentId == id then
                self.CurrentMusic.currentId = self.DefaultMusic[1].id
                self.CurrentMusic.currentTitle = self.DefaultMusic[1].title
                self:updateSound()
            end
            self:save()
            return true, "Deleted '" .. music.title .. "' successfully!"
        end
    end
    return false, "Music not found!"
end
function BGM:setCurrentMusic(id)
    local music = self:getMusicById(id)
    if not music then
        return false, "Music not found!"
    end
    self.CurrentMusic.currentId = id
    self.CurrentMusic.currentTitle = music.title
    self:updateSound()
    self:save()
    return true, "Switched to '" .. music.title .. "'"
end
function BGM:play()
    if not self._sound then
        self:setupSound()
        if not self._sound then return end
    end
    if self.CurrentMusic.onlyMaximized then
        if self:isWindowMinimized() then
            return
        end
    end
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusic.currentId
    self._sound.Volume = self.CurrentMusic.volume
    pcall(function()
        self._sound:Play()
        self._isPlaying = true
        self._isPaused = false
    end)
end
function BGM:stop()
    if self._sound then
        pcall(function()
            self._sound:Stop()
            self._isPlaying = false
            self._isPaused = false
        end)
    end
end
function BGM:pause()
    if self._sound and self._sound.IsPlaying then
        pcall(function()
            self._sound:Pause()
            self._isPaused = true
        end)
    end
end
function BGM:resume()
    if self._sound and self._isPaused then
        pcall(function()
            self._sound:Play()
            self._isPaused = false
        end)
    end
end
function BGM:isWindowMinimized()
    if not self._windUI or not self._windUI.UIElements or not self._windUI.UIElements.Main then
        return true
    end
    local sizeY = self._windUI.UIElements.Main.Size.Y.Offset
    return sizeY < 50
end
function BGM:updateWindowState()
    if not self.CurrentMusic.enabled then
        if self._isPlaying then
            self:stop()
        end
        return
    end
    if self.CurrentMusic.onlyMaximized then
        if self:isWindowMinimized() then
            if self._isPlaying then
                self:pause()
            end
        else
            if self._isPaused or not self._isPlaying then
                self:resume()
            end
        end
    else
        if self._isPaused then
            self:resume()
        elseif not self._isPlaying then
            self:play()
        end
    end
end
function BGM:setEnabled(enabled)
    self.CurrentMusic.enabled = enabled
    if enabled then
        self:updateSound()
    else
        self:stop()
    end
    self:save()
end
function BGM:setVolume(volume)
    self.CurrentMusic.volume = math.clamp(volume, 0, 5)
    if self._sound then
        self._sound.Volume = self.CurrentMusic.volume
    end
    self:save()
end
function BGM:setPitch(pitch)
    self.CurrentMusic.pitch = math.clamp(pitch, 0.5, 3)
    if self._sound then
        self._sound.PlaybackSpeed = self.CurrentMusic.pitch
    end
    self:save()
end
function BGM:setOnlyMaximized(onlyMaximized)
    self.CurrentMusic.onlyMaximized = onlyMaximized
    self:updateWindowState()
    self:save()
end
function BGM:save()
    if not self._initialized then
        return false
    end
    self:ensureFolder()
    local dataToSave = {
        enabled = self.CurrentMusic.enabled,
        onlyMaximized = self.CurrentMusic.onlyMaximized,
        volume = self.CurrentMusic.volume,
        pitch = self.CurrentMusic.pitch,
        currentId = self.CurrentMusic.currentId,
        currentTitle = self.CurrentMusic.currentTitle,
        customMusic = self.CustomMusic,
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
    if decoded.enabled ~= nil then self.CurrentMusic.enabled = decoded.enabled end
    if decoded.onlyMaximized ~= nil then self.CurrentMusic.onlyMaximized = decoded.onlyMaximized end
    if decoded.volume ~= nil then self.CurrentMusic.volume = decoded.volume end
    if decoded.pitch ~= nil then self.CurrentMusic.pitch = decoded.pitch end
    if decoded.currentId then self.CurrentMusic.currentId = decoded.currentId end
    if decoded.currentTitle then self.CurrentMusic.currentTitle = decoded.currentTitle end
    if decoded.customMusic then self.CustomMusic = decoded.customMusic end
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
function BGM:reset()
    self.CurrentMusic.enabled = false
    self.CurrentMusic.onlyMaximized = true
    self.CurrentMusic.volume = 1
    self.CurrentMusic.pitch = 1
    self.CurrentMusic.currentId = self.DefaultMusic[1].id
    self.CurrentMusic.currentTitle = self.DefaultMusic[1].title
    self.CustomMusic = {}
    self:updateSound()
    self:save()
    return true
end
function BGM:cleanup()
    if self._sound then
        self._sound:Stop()
        self._sound:Destroy()
        self._sound = nil
    end
    self._isPlaying = false
    self._isPaused = false
end
return BGM
