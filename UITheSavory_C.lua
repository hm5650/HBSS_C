
local module = {}
local SaveSystem = {
    Folder = "Gravel_Saves",
    AssetsFolder = "Gravel_Saves/assets",
    FileName = "SavedUI.json",
    SaveInterval = 0.5
}
local function getSavePath()
    return SaveSystem.Folder .. "/assets/" .. SaveSystem.FileName
end
local function ensureFoldersExist()
    if not isfolder(SaveSystem.Folder) then
        pcall(function() makefolder(SaveSystem.Folder) end)
    end
    if not isfolder(SaveSystem.AssetsFolder) then
        pcall(function() makefolder(SaveSystem.AssetsFolder) end)
    end
end
local function loadUIData()
    ensureFoldersExist()
    local path = getSavePath()
    if not isfile(path) then
        return nil
    end
    local success, data = pcall(function()
        return readfile(path)
    end)
    if not success or not data then
        return nil
    end
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if success and decoded then
        return decoded
    end
    return nil
end
local function saveUIData(data)
    ensureFoldersExist()
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    if not success then
        warn("Failed to encode UI data: " .. tostring(err))
        return false
    end
    local path = getSavePath()
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    if not success then
        warn("Failed to save UI data: " .. tostring(err))
        return false
    end
    return true
end
local function getCurrentUIState()
    local state = {
        theme = "Dark",
        transparency = 0.15
    }
    pcall(function()
        if WindUI and WindUI.Theme and WindUI.Theme.Name then
            state.theme = WindUI.Theme.Name
        end
    end)
    pcall(function()
        if WindUI and WindUI.TransparencyValue ~= nil then
            state.transparency = WindUI.TransparencyValue
        end
    end)
    return state
end
local function applyUIState(state)
    if not state then return false end
    local success = true
    if state.theme then
        pcall(function()
            if WindUI and WindUI.SetTheme then
                WindUI:SetTheme(state.theme)
            end
        end)
    end
    if state.transparency ~= nil then
        pcall(function()
            if WindUI then
                WindUI.TransparencyValue = state.transparency
                if WindUI.Transparent then
                    WindUI.Window:ToggleTransparency(true)
                end
            end
        end)
    end
    return success
end
function module.LoadUI()
    local data = loadUIData()
    if data then
        applyUIState(data)
        return true
    else
        local defaultState = {
            theme = "Dark",
            transparency = 0.15
        }
        saveUIData(defaultState)
        return false
    end
end
function module.SaveUI()
    local state = getCurrentUIState()
    return saveUIData(state)
end
function module.StartAutoSave(interval)
    interval = interval or SaveSystem.SaveInterval
    module.StopAutoSave()
    module._autoSaveConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if module._saveTimer and tick() - module._saveTimer >= interval then
            module._saveTimer = tick()
            module.SaveUI()
        end
    end)
    module._saveTimer = tick()
end
function module.StopAutoSave()
    if module._autoSaveConnection then
        module._autoSaveConnection:Disconnect()
        module._autoSaveConnection = nil
    end
    module._saveTimer = nil
end
function module.SetupThemeDetection()
    if module._themeDetectionSetup then
        return
    end
    module._themeDetectionSetup = true
    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(function()
                if WindUI and WindUI._themeDropdown then
                end
            end)
        end
    end)
end
function module.Init()
    ensureFoldersExist()
    module.SetupThemeDetection()
    module.LoadUI()
    module.StartAutoSave()
    return module
end
function module.Cleanup()
    module.StopAutoSave()
    module._themeDetectionSetup = false
end
module.Init()
return module
