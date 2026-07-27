local BMG = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBMG.json",
    CurrentMusic = nil,
    Volume = 1,
    Pitch = 1,
    Enabled = false,
    CustomMusic = {},
    PresetMusic = {
        { id = "128586477335903", title = "PeanutButter" },
        { id = "93162865190777",  title = "KwikFlip" }
    },
    _sound = nil,
    _gui = nil,
    _initialized = false,
    _windUI = nil,
}
function BMG:init(windUI)
    if not windUI then
        warn("BMG: WindUI reference required!")
        return false
    end
    self._windUI = windUI
    self:ensureFolder()
    self._initialized = true
    return true
end
function BMG:ensureFolder()
    if not isfolder(self.Folder) then
        pcall(function() makefolder(self.Folder) end)
    end
end
function BMG:getFilePath()
    return self.Folder .. "/" .. self.FileName
end
function BMG:getCurrentMusic()   return self.CurrentMusic end
function BMG:getVolume()         return self.Volume end
function BMG:getPitch()          return self.Pitch end
function BMG:isEnabled()         return self.Enabled end
function BMG:setCurrentMusic(id)
    self.CurrentMusic = id
    if self.Enabled then
        self:playMusic(id)
    end
    return true
end
function BMG:setVolume(vol)
    self.Volume = math.clamp(vol, 0, 5)
    if self._sound then
        self._sound.Volume = self.Volume
    end
    return true
end
function BMG:setPitch(pitch)
    self.Pitch = math.clamp(pitch, 0.5, 2)
    if self._sound then
        self._sound.PlaybackSpeed = self.Pitch
    end
    return true
end
function BMG:setEnabled(enabled)
    self.Enabled = enabled
    if enabled then
        if self.CurrentMusic then
            self:playMusic(self.CurrentMusic)
        end
    else
        self:stopMusic()
    end
    return true
end
function BMG:getCustomMusicList()
    return self.CustomMusic
end
function BMG:getAllMusic()
    local all = {}
    for _, p in ipairs(self.PresetMusic) do
        table.insert(all, p)
    end
    for _, c in ipairs(self.CustomMusic) do
        table.insert(all, c)
    end
    return all
end
function BMG:addCustomMusic(id, title)
    if not id or id == "" then return false end
    for _, item in ipairs(self.CustomMusic) do
        if item.id == id then
            return false
        end
    end
    table.insert(self.CustomMusic, { id = id, title = title or "Custom" })
    return true
end
function BMG:removeCustomMusic(id)
    if not id then return false end
    for _, p in ipairs(self.PresetMusic) do
        if p.id == id then
            return false
        end
    end
    for i, item in ipairs(self.CustomMusic) do
        if item.id == id then
            table.remove(self.CustomMusic, i)
            if self.CurrentMusic == id then
                self:stopMusic()
                self.CurrentMusic = nil
            end
            return true
        end
    end
    return false
end
function BMG:playMusic(id)
    self:stopMusic()
    if not id then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "BMG_Gui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Looped = true
    sound.Volume = self.Volume
    sound.PlaybackSpeed = self.Pitch
    sound.Parent = gui
    sound:Play()
    self._sound = sound
    self._gui = gui
    self.CurrentMusic = id
end
function BMG:stopMusic()
    if self._sound then
        self._sound:Stop()
        self._sound:Destroy()
        self._sound = nil
    end
    if self._gui then
        self._gui:Destroy()
        self._gui = nil
    end
end
function BMG:refreshMusic()
    if self.Enabled and self.CurrentMusic then
        self:playMusic(self.CurrentMusic)
    elseif self.Enabled and not self.CurrentMusic then
        self:stopMusic()
    else
        self:stopMusic()
    end
end
function BMG:save()
    if not self._initialized then
        warn("BMG: not initialized")
        return false
    end
    self:ensureFolder()
    local data = {
        currentMusic = self.CurrentMusic,
        volume = self.Volume,
        pitch = self.Pitch,
        enabled = self.Enabled,
        customMusic = self.CustomMusic,
        savedAt = os.time()
    }
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    if not success then
        if self._windUI then
            self._windUI:Notify({
                Title = "BMG Save Error",
                Content = "Failed to encode BGM data!",
                Icon = "x",
                Duration = 2
            })
        end
        return false
    end
    local path = self:getFilePath()
    local success2, err = pcall(function()
        writefile(path, encoded)
    end)
    if success2 then
        return true
    else
        if self._windUI then
            self._windUI:Notify({
                Title = "BMG Save Error",
                Content = "Failed to save BGM: " .. tostring(err),
                Icon = "x",
                Duration = 2
            })
        end
        return false
    end
end
function BMG:load()
    if not self._initialized then return false end
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then return false end
    local success, raw = pcall(function() return readfile(path) end)
    if not success or not raw then return false end
    local success2, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(raw)
    end)
    if not success2 or not data then return false end
    pcall(function()
        if data.currentMusic ~= nil then self.CurrentMusic = data.currentMusic end
        if data.volume ~= nil then self.Volume = math.clamp(data.volume, 0, 5) end
        if data.pitch ~= nil then self.Pitch = math.clamp(data.pitch, 0.5, 2) end
        if data.enabled ~= nil then self.Enabled = data.enabled end
        if data.customMusic and type(data.customMusic) == "table" then
            self.CustomMusic = {}
            for _, item in ipairs(data.customMusic) do
                if item.id and item.title then
                    table.insert(self.CustomMusic, { id = item.id, title = item.title })
                end
            end
        end
    end)
    return true
end
function BMG:autoLoad()
    if not self._initialized then return false end
    local loaded = self:load()
    if loaded then
        self:refreshMusic()
    end
    return loaded
end
function BMG:getDropdownOptions()
    local options = {}
    local all = self:getAllMusic()
    for _, item in ipairs(all) do
        table.insert(options, item.id .. "|" .. item.title)
    end
    return options
end
function BMG:extractIdFromDisplay(display)
    if not display then return nil end
    local pipe = display:find("|")
    if pipe then
        return display:sub(1, pipe - 1)
    end
    return display
end
function BMG:getDisplayForId(id)
    local all = self:getAllMusic()
    for _, item in ipairs(all) do
        if item.id == id then
            return item.id .. "|" .. item.title
        end
    end
    return nil
end
return BMG
