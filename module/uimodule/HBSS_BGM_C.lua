-- BLLEHHH >:P
local _cr = cloneref or function(x) return x end
local function svc(n) return _cr(game:GetService(n)) end

local BMG = {
    Folder = "Gravel_Saves/assets",
    FileName = "SavedBMG.json",
    CustomIdsFile = "StoredAssetIDs.json",
    CurrentMusicId = "132061315707843",
    CurrentTitle = "Kazio Knight",
    SelectedMusicIds = { "132061315707843" },
    Volume = 1,
    Pitch = 1,
    MusicStrength = 1,
    IsPlaying = false,
    CustomMusicIds = {},
    PresetMusicIds = {
--        { id = "", title = "" },
        { id = "132061315707843", title = "Kazio Knight" },
        { id = "9048375035", title = "All Dropping" },
        { id = "120187702909985", title = "Still Alive" },
    },
    DeathEnabled = false,
    HitEnabled = false,
    DeathVolume = 1,
    HitVolume = 1,
    DeathRange = 150,
    HitRange = 150,
    DeathPos = true,
    HitPos = true,
    DeathLocal = false,
    HitLocal = false,
    DeathSelected = { "longoof.mp3" },
    HitSelected = { "12222058" },
    CustomDeathSounds = {},
    CustomHitSounds = {},
    PresetDeathSounds = {
        { id = "longoof.mp3", title = "Long Oof", file = "longoof.mp3" },
        { id = "100734018985600", title = "Scout Scream" },
        { id = "7768885975", title = "Score" },
        { id = "104065162435374", title = "Chicken Scream" },
        { id = "111291271210974", title = "Maifioso Scream" },
    },
    PresetHitSounds = {
        { id = "12222058", title = "OUCH" },
        { id = "12222152", title = "Splat.wav" },
        { id = "7233165872", title = "Tony Hawk Trick" },
        { id = "3020841054", title = "Money" },
        { id = "9068554227", title = "Quack" },
    },
    _initialized = false,
    _windUI = nil,
    _config = nil,
    _sound = nil,
    _connections = {},
    _bag = {},
    _lastPlayed = nil,
    _refs = {},
    _assetCache = {},
    _downloading = {},
    _hooks = {},
    _trackGen = 0,
    _tracking = false,
    _lastHit = 0,
}

local BANKS = {
    death = { presets = "PresetDeathSounds", custom = "CustomDeathSounds", selected = "DeathSelected", enabled = "DeathEnabled", volume = "DeathVolume", range = "DeathRange", localKey = "DeathLocal", posKey = "DeathPos" },
    hit = { presets = "PresetHitSounds", custom = "CustomHitSounds", selected = "HitSelected", enabled = "HitEnabled", volume = "HitVolume", range = "HitRange", localKey = "HitLocal", posKey = "HitPos" },
}

local function parseValue(str)
    if type(str) ~= "string" then return nil end
    return str:match("%(([^%(%)]+)%)%s*$")
end

local function toList(v)
    if type(v) == "table" then
        local out = {}
        for k, val in pairs(v) do
            if type(k) == "number" then
                out[#out + 1] = val
            elseif val == true then
                out[#out + 1] = k
            end
        end
        return out
    end
    if type(v) == "string" and v ~= "" then return { v } end
    return {}
end

local function setUI(ref, v)
    if not ref then return end
    pcall(function()
        if type(v) == "table" and ref.Select then
            ref:Select(v)
        elseif ref.Set then
            ref:Set(v)
        elseif ref.SetValue then
            ref:SetValue(v)
        end
    end)
end

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
        self.MusicStrength = config.BMG.MusicStrength or self.MusicStrength
        self.IsPlaying = config.BMG.IsPlaying or self.IsPlaying
        self.CustomMusicIds = config.BMG.CustomMusicIds or {}
    end

    self._initialized = true
    return true
end

function BMG:setDropdownRef(dropdown)
    self._refs.music = dropdown
end

function BMG:setStrengthRef(slider)
    self._strengthRef = slider
end

function BMG:setRef(name, ref)
    self._refs[name] = ref
end

function BMG:setMusicStrength(value, fromUI)
    value = math.clamp(tonumber(value) or 1, 0, 2)
    self.MusicStrength = value
    if self._config then
        if self._config.BMG then
            self._config.BMG.MusicStrength = value
        end
        local g = self._config.Gradow
        if g and g.ascii then
            g.ascii.musicStrength = value
        end
    end
    if not fromUI then setUI(self._strengthRef, value) end
end

function BMG:ensureFolder()
    pcall(function()
        if not isfolder("Gravel_Saves") then makefolder("Gravel_Saves") end
        if not isfolder(self.Folder) then makefolder(self.Folder) end
    end)
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
    for _, item in ipairs(self:getAllMusicIds()) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function BMG:getMusicIdByTitle(title)
    for _, item in ipairs(self:getAllMusicIds()) do
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
    return "Kazio Knight (132061315707843)"
end

function BMG:getSelectedValues()
    local out = {}
    for _, id in ipairs(self.SelectedMusicIds) do
        local item = self:getMusicIdById(id)
        if item then out[#out + 1] = item.title .. " (" .. item.id .. ")" end
    end
    return out
end

function BMG:getShuffleCount()
    return #self.SelectedMusicIds
end

function BMG:getShuffleText()
    local n = #self.SelectedMusicIds
    if n == 0 then return "Nothing selected" end
    if n == 1 then return "1 song selected (loops)" end
    return n .. " songs selected (shuffling)"
end

function BMG:_notifyShuffle()
    local cb = self.OnSelectionChanged
    if cb then pcall(cb, self:getShuffleCount(), self:getShuffleText()) end
end

function BMG:_syncConfig()
    if self._config and self._config.BMG then
        local c = self._config.BMG
        c.CurrentMusicId = self.CurrentMusicId
        c.CurrentTitle = self.CurrentTitle
        c.SelectedMusicIds = self.SelectedMusicIds
        c.Volume = self.Volume
        c.Pitch = self.Pitch
        c.IsPlaying = self.IsPlaying
        c.CustomMusicIds = self.CustomMusicIds
    end
end

function BMG:_normalizeSelection()
    local clean, seen = {}, {}
    for _, id in ipairs(self.SelectedMusicIds) do
        if not seen[id] and self:getMusicIdById(id) then
            seen[id] = true
            clean[#clean + 1] = id
        end
    end
    self.SelectedMusicIds = clean
    if #clean > 0 then
        local found = false
        for _, id in ipairs(clean) do
            if id == self.CurrentMusicId then found = true break end
        end
        if not found then
            self.CurrentMusicId = clean[1]
            local item = self:getMusicIdById(clean[1])
            if item then self.CurrentTitle = item.title end
            return true
        end
    end
    return false
end

function BMG:refreshDropdown()
    local dd = self._refs.music
    if dd and dd.Refresh then
        pcall(function() dd:Refresh(self:getDropdownValues()) end)
        setUI(dd, self:getSelectedValues())
        return true
    end
    return false
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
            local wasCurrent = self.CurrentMusicId == id
            for j = #self.SelectedMusicIds, 1, -1 do
                if self.SelectedMusicIds[j] == id then table.remove(self.SelectedMusicIds, j) end
            end
            if #self.SelectedMusicIds == 0 then
                self.SelectedMusicIds = { self.PresetMusicIds[1].id }
            end
            self:_normalizeSelection()
            table.clear(self._bag)
            if wasCurrent then self:playCurrent() end
            self:saveCustomIds()
            self:refreshDropdown()
            self:_notifyShuffle()
            return true, "Deleted music"
        end
    end

    return false, "Music not found"
end

function BMG:setSelectedMusic(list)
    local ids = {}
    for _, v in ipairs(toList(list)) do
        local id = parseValue(v) or v
        if self:getMusicIdById(id) then ids[#ids + 1] = id end
    end
    self.SelectedMusicIds = ids
    table.clear(self._bag)
    local changed = self:_normalizeSelection()
    if #ids == 0 then
        self:stop()
    elseif self.IsPlaying then
        if changed or not self._sound then
            self:playCurrent()
        else
            pcall(function() self._sound.Looped = (#ids <= 1) end)
        end
    end
    self:_syncConfig()
    self:_notifyShuffle()
    return true, self:getShuffleText()
end

function BMG:setCurrentMusic(id)
    local music = self:getMusicIdById(id)
    if not music then
        return false, "Music not found"
    end
    self.SelectedMusicIds = { id }
    self.CurrentMusicId = id
    self.CurrentTitle = music.title
    table.clear(self._bag)
    self:playCurrent()
    self:_notifyShuffle()
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

function BMG:_pickNext()
    local n = #self.SelectedMusicIds
    if n == 0 then return nil end
    if n == 1 then return self.SelectedMusicIds[1] end
    if #self._bag == 0 then
        for _, id in ipairs(self.SelectedMusicIds) do self._bag[#self._bag + 1] = id end
        for i = #self._bag, 2, -1 do
            local j = math.random(1, i)
            self._bag[i], self._bag[j] = self._bag[j], self._bag[i]
        end
        if self._bag[#self._bag] == self.CurrentMusicId and #self._bag > 1 then
            self._bag[1], self._bag[#self._bag] = self._bag[#self._bag], self._bag[1]
        end
    end
    return table.remove(self._bag)
end

function BMG:playNext()
    local id = self:_pickNext()
    if not id then return end
    local item = self:getMusicIdById(id)
    if not item then return end
    self.CurrentMusicId = id
    self.CurrentTitle = item.title
    self:_syncConfig()
    self:playCurrent()
end

function BMG:playCurrent()
    self:stop()

    if not self.IsPlaying then
        return
    end

    if not self.CurrentMusicId or self.CurrentMusicId == "" or #self.SelectedMusicIds == 0 then
        return
    end

    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://" .. self.CurrentMusicId
        snd.Volume = self.Volume
        snd.PlaybackSpeed = self.Pitch
        snd.Looped = (#self.SelectedMusicIds <= 1)
        snd.Parent = svc("SoundService")
        self._sound = snd
        snd:Play()

        self._connections.soundEnded = snd.Ended:Connect(function()
            if self.IsPlaying and self._sound == snd then
                self:playNext()
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
        self:_normalizeSelection()
        self:playCurrent()
    else
        self:stop()
    end

    return self.IsPlaying
end

function BMG:getBankItems(kind)
    local b = BANKS[kind]
    local all = {}
    for _, it in ipairs(self[b.presets]) do all[#all + 1] = it end
    for _, it in ipairs(self[b.custom]) do all[#all + 1] = it end
    return all
end

function BMG:getBankItem(kind, id)
    for _, it in ipairs(self:getBankItems(kind)) do
        if it.id == id then return it end
    end
    return nil
end

function BMG:getBankValues(kind)
    local out = {}
    for _, it in ipairs(self:getBankItems(kind)) do
        out[#out + 1] = it.title .. " (" .. it.id .. ")"
    end
    return out
end

function BMG:getBankSelectedValues(kind)
    local b = BANKS[kind]
    local out = {}
    for _, id in ipairs(self[b.selected]) do
        local it = self:getBankItem(kind, id)
        if it then out[#out + 1] = it.title .. " (" .. it.id .. ")" end
    end
    return out
end

function BMG:refreshBank(kind)
    local dd = self._refs[kind .. "Dropdown"]
    if dd and dd.Refresh then
        pcall(function() dd:Refresh(self:getBankValues(kind)) end)
        setUI(dd, self:getBankSelectedValues(kind))
    end
end

function BMG:setBankSelected(kind, list)
    local b = BANKS[kind]
    local ids = {}
    for _, v in ipairs(toList(list)) do
        local id = parseValue(v) or v
        if self:getBankItem(kind, id) then ids[#ids + 1] = id end
    end
    self[b.selected] = ids
    self:_prefetchBank(kind)
    return true
end

function BMG:setBankEnabled(kind, state)
    local b = BANKS[kind]
    self[b.enabled] = state and true or false
    if state then self:_prefetchBank(kind) end
    self:_updateTracking()
    return self[b.enabled]
end

function BMG:setBankVolume(kind, v)
    self[BANKS[kind].volume] = math.clamp(tonumber(v) or 1, 0, 5)
end

function BMG:setBankRange(kind, v)
    self[BANKS[kind].range] = math.max(0, tonumber(v) or 0)
end

function BMG:setBankPos(kind, state)
    self[BANKS[kind].posKey] = state and true or false
end

function BMG:setBankLocal(kind, state)
    self[BANKS[kind].localKey] = state and true or false
end

function BMG:addBankSound(kind, id, title)
    id = tostring(id or ""):gsub("%s+", "")
    if id == "" or not id:match("^%d+$") then return false, "Invalid sound ID" end
    if not title or title == "" then return false, "Invalid title" end
    if self:getBankItem(kind, id) then return false, "Sound ID already exists" end
    table.insert(self[BANKS[kind].custom], { id = id, title = title })
    self:saveCustomIds()
    self:refreshBank(kind)
    return true, "Added " .. title
end

function BMG:deleteBankSounds(kind, values)
    local b = BANKS[kind]
    local removed, skipped = 0, 0
    for _, v in ipairs(toList(values)) do
        local id = parseValue(v) or v
        local isPreset = false
        for _, p in ipairs(self[b.presets]) do
            if p.id == id then isPreset = true break end
        end
        if isPreset then
            skipped = skipped + 1
        else
            for i, c in ipairs(self[b.custom]) do
                if c.id == id then
                    table.remove(self[b.custom], i)
                    removed = removed + 1
                    break
                end
            end
            for j = #self[b.selected], 1, -1 do
                if self[b.selected][j] == id then table.remove(self[b.selected], j) end
            end
        end
    end
    if removed > 0 then
        self:saveCustomIds()
        self:refreshBank(kind)
    end
    return removed, skipped
end

local function suffix()
    local ok, v = pcall(function() return getgenv().nameeeitttttohhhhhhmahhhhhgahhhhhh_ end)
    return (ok and type(v) == "string") and v or ""
end

function BMG:_ensureFile(item)
    local file = item.file
    if not file then return nil end
    local cached = self._assetCache[file]
    if cached then return cached end
    local gca = getcustomasset or getsynasset
    if not (writefile and isfile and isfolder and makefolder and gca) then return nil end
    self:ensureFolder()
    local path = self.Folder .. "/" .. file
    if not isfile(path) then
        if self._downloading[file] then return nil end
        self._downloading[file] = true
        local url = "https://github.com/hm5650/HBSS" .. suffix() .. "/raw/refs/heads/main/assets/" .. file
        local body
        local req = request or http_request or (syn and syn.request)
        if req then
            local ok, res = pcall(req, { Url = url, Method = "GET" })
            if ok and type(res) == "table" and (res.StatusCode == nil or res.StatusCode == 200)
                and type(res.Body) == "string" and #res.Body > 0 then
                body = res.Body
            end
        end
        if not body then
            local ok, b = pcall(function() return game:HttpGet(url) end)
            if ok and type(b) == "string" and #b > 0 and b:sub(1, 4) ~= "404:" then body = b end
        end
        if body then pcall(writefile, path, body) end
        self._downloading[file] = nil
    end
    if isfile(path) then
        local ok, id = pcall(gca, path)
        if ok and id and id ~= "" then
            self._assetCache[file] = id
            return id
        end
    end
    return nil
end

function BMG:_prefetchBank(kind)
    local b = BANKS[kind]
    for _, id in ipairs(self[b.selected]) do
        local it = self:getBankItem(kind, id)
        if it and it.file and not self._assetCache[it.file] then
            task.spawn(function() self:_ensureFile(it) end)
        end
    end
end

function BMG:_targetPart(hum)
    local part = hum.RootPart
    local model = hum.Parent
    if not part and model then
        part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    end
    return part
end

function BMG:playBank(kind, part)
    local b = BANKS[kind]
    local sel = self[b.selected]
    if #sel == 0 then return end
    local it = self:getBankItem(kind, sel[math.random(1, #sel)])
    if not it then return end
    local soundId
    if it.file then
        soundId = self._assetCache[it.file]
        if not soundId then
            task.spawn(function() self:_ensureFile(it) end)
            return
        end
    else
        soundId = "rbxassetid://" .. it.id
    end
    local vol = self[b.volume]
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = soundId
        s.Volume = vol
        local holder = svc("SoundService")
        local emitter
        if part and self[b.posKey] and part.Parent then
            local range = self[b.range]
            s.RollOffMode = Enum.RollOffMode.Linear
            s.RollOffMinDistance = 8
            s.RollOffMaxDistance = (range and range > 0) and math.max(range, 9) or 500
            if kind == "death" then
                emitter = Instance.new("Part")
                emitter.Anchored = true
                emitter.CanCollide = false
                emitter.CanQuery = false
                emitter.CanTouch = false
                emitter.Transparency = 1
                emitter.Size = Vector3.new(0.2, 0.2, 0.2)
                emitter.CFrame = part.CFrame
                emitter.Parent = workspace
                holder = emitter
            else
                holder = part
            end
        end
        s.Parent = holder
        local function cleanup()
            if s.Parent then s:Destroy() end
            if emitter then emitter:Destroy() end
        end
        s.Ended:Once(cleanup)
        s:Play()
        task.delay(20, cleanup)
    end)
end

local function typeAllowed(cfg, isPlayer)
    local mt = cfg and cfg.masterTarget or "Players"
    if isPlayer then return mt == "Players" or mt == "Both" end
    return mt == "NPCs" or mt == "Both"
end

function BMG:_inRange(hum, range)
    if not range or range <= 0 then return true end
    local part = hum.RootPart
    local model = hum.Parent
    if not part and model then
        part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    end
    if not part then return false end
    local origin
    local lp = svc("Players").LocalPlayer
    local c = lp and lp.Character
    local root = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head"))
    if root then
        origin = root.Position
    else
        local cam = workspace.CurrentCamera
        origin = cam and cam.CFrame.Position
    end
    if not origin then return true end
    return (part.Position - origin).Magnitude <= range
end

function BMG:_hookHumanoid(hum, isPlayer, isLocal)
    local old = self._hooks[hum]
    if old then return end
    local rec = { last = hum.Health, dead = hum.Health <= 0, isPlayer = isPlayer, isLocal = isLocal }
    local function allowed(kind)
        local b = BANKS[kind]
        if not self[b.enabled] then return false end
        if rec.isLocal then return self[b.localKey] end
        if not typeAllowed(self._config, rec.isPlayer) then return false end
        return self:_inRange(hum, self[b.range])
    end
    rec.conn = hum.HealthChanged:Connect(function(hp)
        if hp <= 0 then
            if not rec.dead then
                rec.dead = true
                if allowed("death") then self:playBank("death", (not rec.isLocal) and self:_targetPart(hum) or nil) end
            end
        else
            rec.dead = false
            if hp < rec.last and allowed("hit") then
                local now = os.clock()
                if now - self._lastHit >= 0.08 then
                    self._lastHit = now
                    self:playBank("hit", (not rec.isLocal) and self:_targetPart(hum) or nil)
                end
            end
        end
        rec.last = hp
    end)
    self._hooks[hum] = rec
end

function BMG:_unhookAll()
    for hum, rec in pairs(self._hooks) do
        pcall(function() rec.conn:Disconnect() end)
        self._hooks[hum] = nil
    end
end

function BMG:_startTracking()
    if self._tracking then return end
    self._tracking = true
    self._trackGen = self._trackGen + 1
    local gen = self._trackGen
    task.spawn(function()
        local lp = svc("Players").LocalPlayer
        while self._tracking and self._trackGen == gen do
            local cfg = self._config
            local getT = cfg and cfg.funcs and cfg.funcs.getAllTargets
            if getT then
                local ok, list = pcall(getT)
                if ok and type(list) == "table" then
                    for i = 1, #list do
                        local t = list[i]
                        if typeof(t) == "Instance" then
                            local isPlayer = t:IsA("Player")
                            local char = isPlayer and t.Character or (t:IsA("Model") and t or nil)
                            if char and t ~= lp and char ~= lp.Character then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then self:_hookHumanoid(hum, isPlayer) end
                            end
                        end
                    end
                end
            end
            if (self.DeathLocal or self.HitLocal) and lp.Character then
                local lh = lp.Character:FindFirstChildOfClass("Humanoid")
                if lh then self:_hookHumanoid(lh, true, true) end
            end
            for hum, rec in pairs(self._hooks) do
                if hum.Parent == nil then
                    pcall(function() rec.conn:Disconnect() end)
                    self._hooks[hum] = nil
                end
            end
            local scale = (cfg and cfg.perf and cfg.perf.scale) or 1
            task.wait(0.25 * scale)
        end
    end)
end

function BMG:_stopTracking()
    self._tracking = false
    self._trackGen = self._trackGen + 1
    self:_unhookAll()
end

function BMG:_updateTracking()
    if self.DeathEnabled or self.HitEnabled then
        self:_startTracking()
    else
        self:_stopTracking()
    end
end

local function http() return svc("HttpService") end

function BMG:saveCustomIds()
    self:ensureFolder()

    local dataToSave = {
        customMusicIds = self.CustomMusicIds,
        customDeathSounds = self.CustomDeathSounds,
        customHitSounds = self.CustomHitSounds,
        savedAt = os.time()
    }

    local success, encoded = pcall(function()
        return http():JSONEncode(dataToSave)
    end)

    if not success then
        return false
    end

    local ok = pcall(function()
        writefile(self:getCustomIdsPath(), encoded)
    end)

    return ok
end

function BMG:loadCustomIds()
    self:ensureFolder()
    local path = self:getCustomIdsPath()

    if not isfile(path) then
        return false
    end

    local success, data = pcall(readfile, path)
    if not success or not data then
        return false
    end

    local ok, decoded = pcall(function()
        return http():JSONDecode(data)
    end)

    if not ok or type(decoded) ~= "table" then
        return false
    end

    if decoded.customMusicIds then
        self.CustomMusicIds = decoded.customMusicIds
        if self._config and self._config.BMG then
            self._config.BMG.CustomMusicIds = self.CustomMusicIds
        end
    end
    if type(decoded.customDeathSounds) == "table" then
        self.CustomDeathSounds = decoded.customDeathSounds
    end
    if type(decoded.customHitSounds) == "table" then
        self.CustomHitSounds = decoded.customHitSounds
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
        selectedMusicIds = self.SelectedMusicIds,
        volume = self.Volume,
        pitch = self.Pitch,
        musicStrength = self.MusicStrength,
        isPlaying = self.IsPlaying,
        deathEnabled = self.DeathEnabled,
        hitEnabled = self.HitEnabled,
        deathVolume = self.DeathVolume,
        hitVolume = self.HitVolume,
        deathRange = self.DeathRange,
        hitRange = self.HitRange,
        deathLocal = self.DeathLocal,
        deathPos = self.DeathPos,
        hitPos = self.HitPos,
        hitLocal = self.HitLocal,
        deathSelected = self.DeathSelected,
        hitSelected = self.HitSelected,
        savedAt = os.time()
    }

    local success, encoded = pcall(function()
        return http():JSONEncode(dataToSave)
    end)

    if not success then
        return false
    end

    local ok = pcall(function()
        writefile(self:getFilePath(), encoded)
    end)

    return ok
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

    local success, data = pcall(readfile, path)
    if not success or not data then
        return false
    end

    local ok, decoded = pcall(function()
        return http():JSONDecode(data)
    end)

    if not ok or type(decoded) ~= "table" then
        return false
    end

    pcall(function()
        if decoded.currentMusicId then
            self.CurrentMusicId = decoded.currentMusicId
        end
        if decoded.currentTitle then
            self.CurrentTitle = decoded.currentTitle
        end
        if type(decoded.selectedMusicIds) == "table" then
            self.SelectedMusicIds = decoded.selectedMusicIds
        elseif decoded.currentMusicId then
            self.SelectedMusicIds = { decoded.currentMusicId }
        end
        if decoded.volume ~= nil then
            self.Volume = math.clamp(decoded.volume, 0, 5)
        end
        if decoded.pitch ~= nil then
            self.Pitch = math.clamp(decoded.pitch, 0.5, 2)
        end
        if decoded.musicStrength ~= nil then
            self:setMusicStrength(decoded.musicStrength)
        end
        if decoded.isPlaying ~= nil then
            self.IsPlaying = decoded.isPlaying
        end

        if type(decoded.deathSelected) == "table" then self.DeathSelected = decoded.deathSelected end
        if type(decoded.hitSelected) == "table" then self.HitSelected = decoded.hitSelected end
        if decoded.deathVolume ~= nil then self.DeathVolume = math.clamp(decoded.deathVolume, 0, 5) end
        if decoded.hitVolume ~= nil then self.HitVolume = math.clamp(decoded.hitVolume, 0, 5) end
        if decoded.deathRange ~= nil then self.DeathRange = math.max(0, tonumber(decoded.deathRange) or 0) end
        if decoded.hitRange ~= nil then self.HitRange = math.max(0, tonumber(decoded.hitRange) or 0) end
        if decoded.deathPos ~= nil then self.DeathPos = decoded.deathPos and true or false end
        if decoded.hitPos ~= nil then self.HitPos = decoded.hitPos and true or false end
        if decoded.deathLocal ~= nil then self.DeathLocal = decoded.deathLocal and true or false end
        if decoded.hitLocal ~= nil then self.HitLocal = decoded.hitLocal and true or false end
        if decoded.deathEnabled ~= nil then self.DeathEnabled = decoded.deathEnabled and true or false end
        if decoded.hitEnabled ~= nil then self.HitEnabled = decoded.hitEnabled and true or false end

        self:_normalizeSelection()
        table.clear(self._bag)
        self:_syncConfig()

        self:playCurrent()
        self:refreshDropdown()
        self:refreshBank("death")
        self:refreshBank("hit")
        setUI(self._refs.deathToggle, self.DeathEnabled)
        setUI(self._refs.hitToggle, self.HitEnabled)
        setUI(self._refs.deathVolume, self.DeathVolume)
        setUI(self._refs.hitVolume, self.HitVolume)
        setUI(self._refs.deathRange, self.DeathRange)
        setUI(self._refs.hitRange, self.HitRange)
        setUI(self._refs.deathPos, self.DeathPos)
        setUI(self._refs.hitPos, self.HitPos)
        setUI(self._refs.deathLocal, self.DeathLocal)
        setUI(self._refs.hitLocal, self.HitLocal)
        self:_prefetchBank("death")
        self:_prefetchBank("hit")
        self:_updateTracking()
        self:_notifyShuffle()
    end)

    return true
end

function BMG:autoLoad()
    if not self._initialized then
        return false
    end
    return self:load()
end

function BMG:cleanup()
    self:stop()
    self:_stopTracking()
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
