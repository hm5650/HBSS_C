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
        volume = 1,
        pitch = 1,
        currentId = "128586477335903",
        currentTitle = "Peanut Butter"
    },
    CustomMusic = {},
    _sound = nil,
    _isPlaying = false,
    _n = nil,
}
function BGM:init(windUI, config, notificationFunc)
    if not windUI then
        warn("BGM: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self._config = config
    self._n = notificationFunc or function() end
    self:autoLoad()
    self:setupSound()
    self._initialized = true
    return true
end
function BGM:setupSound()
    if self._sound then
        pcall(function()
            self._sound:Stop()
            self._sound:Destroy()
        end)
        self._sound = nil
    end
    self._sound = Instance.new("Sound")
    self._sound.Name = "BGMPlayer"
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusic.currentId
    self._sound.Volume = self.CurrentMusic.volume
    self._sound.PlayOnRemove = false
    self._sound.Looped = true
    self._sound.PlaybackSpeed = self.CurrentMusic.pitch
    self._sound.Parent = game:GetService("SoundService")
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
    self._sound.PlaybackSpeed = self.CurrentMusic.pitch
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
    self._sound.SoundId = "rbxassetid://" .. self.CurrentMusic.currentId
    self._sound.Volume = self.CurrentMusic.volume
    self._sound.PlaybackSpeed = self.CurrentMusic.pitch
    if not self._sound.Parent then
        self._sound.Parent = game:GetService("SoundService")
    end
    pcall(function()
        self._sound:Play()
        self._isPlaying = true
    end)
end
function BGM:stop()
    if self._sound then
        pcall(function()
            self._sound:Stop()
            self._isPlaying = false
        end)
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
function BGM:save()
    if not self._initialized then
        return false
    end
    self:ensureFolder()
    local dataToSave = {
        enabled = self.CurrentMusic.enabled,
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
        if self._n then
            self._n({
                Title = "BGM Error",
                Content = "Failed to encode BGM data!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
        return false
    end
    local path = self:getFilePath()
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    if success then
        if self._n then
            self._n({
                Title = "BGM Saved!",
                Content = "BGM settings saved successfully!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        end
        return true
    else
        if self._n then
            self._n({
                Title = "BGM Error",
                Content = "Failed to save BGM settings!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
        return false
    end
end
function BGM:load()
    if not self._initialized then
        warn("BGM: Module not initialized! Call :init() first.")
        return false
    end
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then
        if self._n then
            self._n({
                Title = "BGM Error",
                Content = "No saved BGM data found!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
        return false
    end
    local success, data = pcall(function()
        return readfile(path)
    end)
    if not success or not data then
        if self._n then
            self._n({
                Title = "BGM Error",
                Content = "Failed to read BGM data!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
        return false
    end
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if not success or not decoded then
        if self._n then
            self._n({
                Title = "BGM Error",
                Content = "Failed to parse BGM data!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(255, 0, 0)
            })
        end
        return false
    end
    if decoded.enabled ~= nil then self.CurrentMusic.enabled = decoded.enabled end
    if decoded.volume ~= nil then self.CurrentMusic.volume = decoded.volume end
    if decoded.pitch ~= nil then self.CurrentMusic.pitch = decoded.pitch end
    if decoded.currentId then self.CurrentMusic.currentId = decoded.currentId end
    if decoded.currentTitle then self.CurrentMusic.currentTitle = decoded.currentTitle end
    if decoded.customMusic then self.CustomMusic = decoded.customMusic end
    self:updateSound()
    if self._n then
        self._n({
            Title = "BGM Loaded!",
            Content = "BGM settings loaded successfully!",
            Audio = "rbxassetid://17208361335",
            Length = 2,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(0, 255, 0)
        })
    end
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
    if decoded.enabled ~= nil then self.CurrentMusic.enabled = decoded.enabled end
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
        if self._n then
            self._n({
                Title = "BGM Deleted",
                Content = "BGM save file deleted!",
                Audio = "rbxassetid://17208361335",
                Length = 2,
                Image = "rbxassetid://4483362458",
                BarColor = Color3.fromRGB(0, 255, 0)
            })
        end
        return true
    end
    if self._n then
        self._n({
            Title = "BGM Error",
            Content = "No BGM save file found!",
            Audio = "rbxassetid://17208361335",
            Length = 2,
            Image = "rbxassetid://4483362458",
            BarColor = Color3.fromRGB(255, 0, 0)
        })
    end
    return false
end
function BGM:reset()
    self.CurrentMusic.enabled = false
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
        pcall(function()
            self._sound:Stop()
            self._sound:Destroy()
        end)
        self._sound = nil
    end
    self._isPlaying = false
end
return BGM
