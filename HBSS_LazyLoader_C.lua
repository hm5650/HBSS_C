local lzl = {
    loaded = {},
    loading = false,
    q = {},
    enabled = true,
    int = 3,
    maxQ = 50,
    lastT = 0,
    perf = true,
    _con = {},
    _clean = {},
    _proc = false
}
local lState = {
    pend = {},
    act = {},
    fail = {},
    retry = {},
    maxRet = 3,
    timeout = 5
}
local fCfg = {}
function lzl:isReady()
    local Players = game:GetService("Players")
    return game:IsLoaded() and Players.LocalPlayer and Players.LocalPlayer.Character
end
function lzl:getDeps(feature)
    local cfg = fCfg[feature]
    if not cfg then return {} end
    local deps = {}
    for _, dep in ipairs(cfg.dep or {}) do
        if not self.loaded[dep] then
            table.insert(deps, dep)
        end
    end
    return deps
end
function lzl:canLoad(feature)
    local cfg = fCfg[feature]
    if not cfg then return false end
    if cfg.reqGame and not self:isReady() then return false end
    local deps = self:getDeps(feature)
    return #deps == 0
end
function lzl:load(featureName)
    if not self.enabled then return false end
    if self.loaded[featureName] then return true end
    if lState.fail[featureName] then return false end
    local cfg = fCfg[featureName]
    if not cfg then return false end
    for _, dep in ipairs(cfg.dep or {}) do
        if not self.loaded[dep] then
            local success = self:load(dep)
            if not success then
                lState.fail[featureName] = true
                return false
            end
        end
    end
    local success = false
    local startTime = tick()
    local function attempt()
        local result = cfg.load()
        if result then
            self.loaded[featureName] = true
            lState.act[featureName] = true
            lState.fail[featureName] = nil
            lState.retry[featureName] = nil
            return true
        end
        return false
    end
    local co = coroutine.create(function()
        success = attempt()
    end)
    coroutine.resume(co)
    while coroutine.status(co) ~= "dead" do
        if tick() - startTime > lState.timeout then
            coroutine.close(co)
            break
        end
        task.wait(0.01)
    end
    if success then
        return true
    else
        lState.retry[featureName] = (lState.retry[featureName] or 0) + 1
        if lState.retry[featureName] >= lState.maxRet then
            lState.fail[featureName] = true
        end
        return false
    end
end
function lzl:unload(featureName)
    if not self.loaded[featureName] then return end
    for name, loaded in pairs(self.loaded) do
        if loaded and name ~= featureName then
            local cfg = fCfg[name]
            if cfg then
                for _, dep in ipairs(cfg.dep or {}) do
                    if dep == featureName then
                        return
                    end
                end
            end
        end
    end
    local cfg = fCfg[featureName]
    if cfg and cfg.unload then
        local success, err = pcall(cfg.unload)
        if not success then
            warn("Failed to unload " .. featureName .. ": " .. tostring(err))
        end
    end
    self.loaded[featureName] = nil
    lState.act[featureName] = nil
end
function lzl:queue(featureName)
    if not fCfg[featureName] then return false end
    if self.loaded[featureName] then return true end
    if #self.q >= self.maxQ then return false end
    for _, name in ipairs(self.q) do
        if name == featureName then return true end
    end
    table.insert(self.q, featureName)
    if not self._proc then
        self:start()
    end
    return true
end
function lzl:start()
    if self._proc or #self.q == 0 then return end
    self._proc = true
    task.spawn(function()
        while #self.q > 0 and self.enabled do
            local feature = table.remove(self.q, 1)
            if feature and not self.loaded[feature] then
                self:load(feature)
            end
            task.wait(self.int)
        end
        self._proc = false
    end)
end
function lzl:loadFeats(featureNames)
    if not self.enabled then return end
    if type(featureNames) == "string" then
        featureNames = {featureNames}
    end
    local sorted = {}
    for _, name in ipairs(featureNames) do
        local cfg = fCfg[name]
        if cfg then
            table.insert(sorted, {name = name, prio = cfg.prio or 5})
        end
    end
    table.sort(sorted, function(a, b) return a.prio < b.prio end)
    for _, item in ipairs(sorted) do
        self:queue(item.name)
    end
    self:start()
end
function lzl:loadEss()
    if not self.enabled then return end
    if not self:isReady() then
        local conn
        local Players = game:GetService("Players")
        conn = Players.LocalPlayer.CharacterAdded:Connect(function()
            conn:Disconnect()
            self:loadEss()
        end)
        return
    end
    local essential = {}
    for name, cfg in pairs(fCfg) do
        if cfg.ess then
            table.insert(essential, name)
        end
    end
    self:loadFeats(essential)
end
function lzl:cleanup()
    local features = {}
    for name in pairs(self.loaded) do
        local cfg = fCfg[name]
        if cfg and not cfg.ess then
            table.insert(features, name)
        end
    end
    table.sort(features, function(a, b)
        local pa = fCfg[a] and fCfg[a].prio or 5
        local pb = fCfg[b] and fCfg[b].prio or 5
        return pa > pb
    end)
    for _, name in ipairs(features) do
        self:unload(name)
    end
    self.q = {}
    lState.pend = {}
    lState.act = {}
    lState.fail = {}
    lState.retry = {}
    self._proc = false
    self._clean = {}
end
function lzl:setEnabled(enabled)
    self.enabled = enabled
    if not enabled then
        self:cleanup()
    else
        self:loadEss()
    end
end
function lzl:getStatus()
    local status = {
        loaded = {},
        loading = {},
        failed = {},
        queueSize = #self.q,
        isProcessing = self._proc
    }
    for name in pairs(self.loaded) do
        table.insert(status.loaded, name)
    end
    for name in pairs(lState.fail) do
        table.insert(status.failed, name)
    end
    return status
end
function lzl:setConfig(cfg)
    fCfg = cfg
end
function lzl:registerFeature(name, config)
    if type(name) ~= "string" or type(config) ~= "table" then
        return false
    end
    fCfg[name] = config
    return true
end
function lzl:unregisterFeature(name)
    if not fCfg[name] then return false end
    if self.loaded[name] then
        self:unload(name)
    end
    fCfg[name] = nil
    return true
end
function lzl:reset()
    self:cleanup()
    self.loaded = {}
    fCfg = {}
    self.enabled = true
    self.q = {}
    self._proc = false
end
return lzl
