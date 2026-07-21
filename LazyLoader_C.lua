local LazyLoader = {}
LazyLoader.__index = LazyLoader

function LazyLoader.new(opts)
    local self = setmetatable({}, LazyLoader)
    self.loaded = {}
    self.loading = false
    self.q = {}
    self.enabled = opts and opts.enabled ~= nil and opts.enabled or true
    self.int = opts and opts.int or 3
    self.maxQ = opts and opts.maxQ or 50
    self.lastT = 0
    self.perf = true
    self._con = {}
    self._clean = {}
    self._proc = false
    self._state = {
        pend = {},
        act = {},    
        fail = {},
        retry = {},
        maxRet = opts and opts.maxRet or 3,
        timeout = opts and opts.timeout or 5
    }
    self.features = {}
    
    return self
end
function LazyLoader:registerFeature(name, cfg)
    if not name or not cfg then return false end
    self.features[name] = {
        dep = cfg.dep or {},
        load = cfg.load or function() return true end,
        unload = cfg.unload or function() end,
        prio = cfg.prio or 1,
        ess = cfg.ess or false,
        reqGame = cfg.reqGame or false
    }
    return true
end
function LazyLoader:registerFeatures(features)
    for name, cfg in pairs(features) do
        self:registerFeature(name, cfg)
    end
end
function LazyLoader:isReady()
    local Players = game:GetService("Players")
    return game:IsLoaded() and Players.LocalPlayer and Players.LocalPlayer.Character
end
function LazyLoader:getDeps(feature)
    local cfg = self.features[feature]
    if not cfg then return {} end
    local deps = {}
    for _, dep in ipairs(cfg.dep) do
        if not self.loaded[dep] then
            table.insert(deps, dep)
        end
    end
    return deps
end
function LazyLoader:canLoad(feature)
    local cfg = self.features[feature]
    if not cfg then return false end
    if cfg.reqGame and not self:isReady() then return false end
    local deps = self:getDeps(feature)
    return #deps == 0
end
function LazyLoader:load(featureName)
    if not self.enabled then return false end
    if self.loaded[featureName] then return true end
    if self._state.fail[featureName] then return false end
    local cfg = self.features[featureName]
    if not cfg then return false end
    for _, dep in ipairs(cfg.dep) do
        if not self.loaded[dep] then
            local success = self:load(dep)
            if not success then
                self._state.fail[featureName] = true
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
            self._state.act[featureName] = true
            self._state.fail[featureName] = nil
            self._state.retry[featureName] = nil
            return true
        end
        return false
    end
    local co = coroutine.create(function()
        success = attempt()
    end)
    
    coroutine.resume(co)
    while coroutine.status(co) ~= "dead" do
        if tick() - startTime > self._state.timeout then
            coroutine.close(co)
            break
        end
        task.wait(0.01)
    end
    
    if success then
        return true
    else
        self._state.retry[featureName] = (self._state.retry[featureName] or 0) + 1
        if self._state.retry[featureName] >= self._state.maxRet then
            self._state.fail[featureName] = true
        end
        return false
    end
end
function LazyLoader:unload(featureName)
    if not self.loaded[featureName] then return end
    
    for name, loaded in pairs(self.loaded) do
        if loaded and name ~= featureName then
            local cfg = self.features[name]
            if cfg then
                for _, dep in ipairs(cfg.dep) do
                    if dep == featureName then
                        return
                    end
                end
            end
        end
    end
    
    local cfg = self.features[featureName]
    if cfg and cfg.unload then
        local success, err = pcall(cfg.unload)
        if not success then
            warn("Failed to unload " .. featureName .. ": " .. tostring(err))
        end
    end
    
    self.loaded[featureName] = nil
    self._state.act[featureName] = nil
end
function LazyLoader:queue(featureName)
    if not self.features[featureName] then return false end
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
function LazyLoader:start()
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
function LazyLoader:loadFeats(featureNames)
    if not self.enabled then return end
    if type(featureNames) == "string" then
        featureNames = {featureNames}
    end
    
    local sorted = {}
    for _, name in ipairs(featureNames) do
        local cfg = self.features[name]
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
function LazyLoader:loadEss()
    if not self.enabled then return end
    if not self:isReady() then
        local Players = game:GetService("Players")
        local conn
        conn = Players.LocalPlayer.CharacterAdded:Connect(function()
            conn:Disconnect()
            self:loadEss()
        end)
        return
    end
    
    local essential = {}
    for name, cfg in pairs(self.features) do
        if cfg.ess then
            table.insert(essential, name)
        end
    end
    self:loadFeats(essential)
end
function LazyLoader:cleanup()
    local features = {}
    for name in pairs(self.loaded) do
        local cfg = self.features[name]
        if cfg and not cfg.ess then
            table.insert(features, name)
        end
    end
    table.sort(features, function(a, b)
        local pa = self.features[a] and self.features[a].prio or 5
        local pb = self.features[b] and self.features[b].prio or 5
        return pa > pb
    end)
    
    for _, name in ipairs(features) do
        self:unload(name)
    end
    
    self.q = {}
    self._state.pend = {}
    self._state.act = {}
    self._state.fail = {}
    self._state.retry = {}
    self._proc = false
    self._clean = {}
end
function LazyLoader:setEnabled(enabled)
    self.enabled = enabled
    if not enabled then
        self:cleanup()
    else
        self:loadEss()
    end
end
function LazyLoader:getStatus()
    local status = {
        loaded = {},
        loading = {},
        failed = {},
        queueSize = #self.q,
        isProcessing = self._proc,
        enabled = self.enabled
    }
    
    for name in pairs(self.loaded) do
        table.insert(status.loaded, name)
    end
    
    for name in pairs(self._state.fail) do
        table.insert(status.failed, name)
    end
    
    return status
end
function LazyLoader:createToggle(featureName, getter, setter)
    return {
        get = function() return getter() end,
        set = function(v)
            setter(v)
            if v then
                self:queue(featureName)
            else
                self:unload(featureName)
            end
        end,
        toggle = function()
            local newState = not getter()
            setter(newState)
            if newState then
                self:queue(featureName)
            else
                self:unload(featureName)
            end
            return newState
        end
    }
end
function LazyLoader:createToggles(bindings)
    local result = {}
    for name, binding in pairs(bindings) do
        result[name] = self:createToggle(name, binding.get, binding.set)
    end
    return result
end
function LazyLoader:waitForReady(timeout)
    timeout = timeout or 10
    local start = tick()
    while not self:isReady() do
        if tick() - start > timeout then
            return false
        end
        task.wait(0.1)
    end
    return true
end

return LazyLoader
