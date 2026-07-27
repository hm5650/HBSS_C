local BGM = {
    Folder = "Gravel_Saves/BGM",
    FileName = "SavedBMG.json",
    Data = {
        enabled = false,
        currentID = "128586477335903",
        customIDs = {},
        volume = 1,
        pitch = 1,
    },
    _windUI = nil,
    _config = nil,
    _sound = nil,
    _initialized = false,
    _presets = {
        {id = "128586477335903", title = "PeanutButter"},
        {id = "93162865190777", title = "KwikFlip"}
    },
    _dropdownRef = nil,
}
function BGM:init(windUI, config)
    if not windUI then return false end
    self._windUI = windUI
    self._config = config
    self._initialized = true
    self:ensureFolder()
    self:createSound()
    return true
end
function BGM:ensureFolder()
    if not isfolder(self.Folder) then
        pcall(makefolder, self.Folder)
    end
end
function BGM:getFilePath()
    return self.Folder .. "/" .. self.FileName
end
function BGM:createSound()
    if self._sound and self._sound.Parent then
        self._sound:Destroy()
    end
    local sound = Instance.new("Sound")
    sound.Looped = true
    sound.Volume = self.Data.volume
    sound.Pitch = self.Data.pitch
    sound.Parent = game:GetService("CoreGui")
    self._sound = sound
end
function BGM:refreshMusic()
    if not self._initialized or not self._sound then return end
    local data = self.Data
    local id = data.currentID
    if id and id ~= "" then
        self._sound.SoundId = "rbxassetid://" .. id
    else
        self._sound.SoundId = ""
    end
    self._sound.Volume = data.volume
    self._sound.Pitch = data.pitch
    if data.enabled and self._sound.SoundId ~= "" then
        self._sound:Play()
    else
        self._sound:Stop()
    end
end
function BGM:getMusicList()
    local list = {}
    for _, p in ipairs(self._presets) do
        table.insert(list, {id = p.id, title = p.title, isPreset = true})
    end
    for _, c in ipairs(self.Data.customIDs) do
        table.insert(list, {id = c.id, title = c.title, isPreset = false})
    end
    return list
end
function BGM:getCurrentID()
    return self.Data.currentID
end
function BGM:setCurrentID(id)
    if not id or id == "" then return end
    self.Data.currentID = id
    self:refreshMusic()
end
function BGM:addCustomID(id, title)
    if not id or id == "" or not title or title == "" then return false end
    for _, c in ipairs(self.Data.customIDs) do
        if c.id == id then return false end
    end
    table.insert(self.Data.customIDs, {id = id, title = title})
    self:refreshDropdown()
    return true
end
function BGM:removeCustomID(id)
    for _, p in ipairs(self._presets) do
        if p.id == id then return false end
    end
    for i, c in ipairs(self.Data.customIDs) do
        if c.id == id then
            table.remove(self.Data.customIDs, i)
            self:refreshDropdown()
            return true
        end
    end
    return false
end
function BGM:setVolume(val)
    self.Data.volume = math.clamp(val, 0, 5)
    self:refreshMusic()
end
function BGM:setPitch(val)
    self.Data.pitch = math.clamp(val, 0.5, 2)
    self:refreshMusic()
end
function BGM:toggleEnabled(val)
    self.Data.enabled = val
    self:refreshMusic()
end
function BGM:refreshDropdown()
    if not self._dropdownRef then return end
    local list = self:getMusicList()
    local values = {}
    local titles = {}
    for _, item in ipairs(list) do
        table.insert(values, item.id)
        table.insert(titles, item.title .. (item.isPreset and "" or " (custom)"))
    end
    pcall(function()
        self._dropdownRef:SetValues(values, titles)
        self._dropdownRef:SetValue(self.Data.currentID)
    end)
end
function BGM:save()
    if not self._initialized then return false end
    self:ensureFolder()
    local dataToSave = {
        enabled = self.Data.enabled,
        currentID = self.Data.currentID,
        customIDs = self.Data.customIDs,
        volume = self.Data.volume,
        pitch = self.Data.pitch,
        savedAt = os.time()
    }
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(dataToSave)
    end)
    if not success then return false end
    local path = self:getFilePath()
    local ok, err = pcall(writefile, path, encoded)
    return ok
end
function BGM:load()
    if not self._initialized then return false end
    self:ensureFolder()
    local path = self:getFilePath()
    if not isfile(path) then return false end
    local data = readfile(path)
    local decoded = game:GetService("HttpService"):JSONDecode(data)
    if not decoded then return false end
    self.Data.enabled = decoded.enabled or false
    self.Data.currentID = decoded.currentID or self._presets[1].id
    self.Data.customIDs = decoded.customIDs or {}
    self.Data.volume = decoded.volume or 1
    self.Data.pitch = decoded.pitch or 1
    self:refreshMusic()
    self:refreshDropdown()
    return true
end
function BGM:autoLoad()
    return self:load()
end
