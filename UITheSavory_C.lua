local UISaver = {}
local SAVE_FOLDER = "Gravel_Saves/assets"
local SAVE_FILE = "SavedUI.json"
local SAVE_PATH = SAVE_FOLDER .. "/" .. SAVE_FILE
local DEFAULT_SETTINGS = {
    theme = "Dark",
    transparency = 0.15
}
local function ensureFolder()
    if not isfolder(SAVE_FOLDER) then
        pcall(function()
            makefolder(SAVE_FOLDER)
        end)
    end
end
local function loadUISettings()
    ensureFolder()
    if not isfile(SAVE_PATH) then
        return nil
    end
    local success, data = pcall(function()
        return readfile(SAVE_PATH)
    end)
    if not success or not data then
        return nil
    end
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if not success or not decoded then
        return nil
    end
    return decoded
end
local function saveUISettings(settings)
    ensureFolder()
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(settings)
    end)
    if not success then
        warn("Failed to encode settings: " .. tostring(success))
        return false
    end
    local success, err = pcall(function()
        writefile(SAVE_PATH, encoded)
    end)
    if not success then
        warn("Failed to save settings: " .. tostring(err))
        return false
    end
    return true
end
local function applyUISettings(settings)
    if not settings then
        settings = DEFAULT_SETTINGS
    end
    local success, err = pcall(function()
        if settings.theme and WindUI and WindUI.SetTheme then
            local themes = {}
            for themeName, _ in pairs(WindUI.Themes or {}) do
                table.insert(themes, themeName)
            end
            local themeExists = false
            for _, themeName in ipairs(themes) do
                if themeName == settings.theme then
                    themeExists = true
                    break
                end
            end
            if themeExists then
                WindUI:SetTheme(settings.theme)
            else
                WindUI:SetTheme("Dark")
            end
        end
        if settings.transparency and WindUI then
            WindUI.TransparencyValue = settings.transparency
            if WindUI.Transparent then
                WindUI.Window:ToggleTransparency(true)
            end
        end
    end)
    if not success then
        warn("Failed to apply settings: " .. tostring(err))
    end
    return success
end
local function setupAutoSave()
    local WindUI = WindUI
    if not WindUI then
        warn("WindUI not found, auto-save disabled")
        return false
    end
    if WindUI.OnThemeChanged then
        local oldCallback = WindUI.OnThemeChanged
        WindUI.OnThemeChanged = function(newTheme)
            if oldCallback then
                pcall(oldCallback, newTheme)
            end
            local settings = loadUISettings() or DEFAULT_SETTINGS
            settings.theme = newTheme or "Dark"
            saveUISettings(settings)
        end
    end
    if WindUI.Window and WindUI.Window.UIElements then
        task.spawn(function()
            local lastTransparency = WindUI.TransparencyValue or 0.15
            while true do
                task.wait(2)
                local currentTransparency = WindUI.TransparencyValue or 0.15
                if currentTransparency ~= lastTransparency then
                    lastTransparency = currentTransparency
                    local settings = loadUISettings() or DEFAULT_SETTINGS
                    settings.transparency = currentTransparency
                    saveUISettings(settings)
                end
            end
        end)
    end
    return true
end
local function init()
    ensureFolder()
    local savedSettings = loadUISettings()
    if savedSettings then
        applyUISettings(savedSettings)
        print("UI settings loaded successfully")
    else
        saveUISettings(DEFAULT_SETTINGS)
        applyUISettings(DEFAULT_SETTINGS)
        print("Default UI settings saved and applied")
    end
    task.spawn(function()
        task.wait(0.5)
        setupAutoSave()
    end)
    return {
        load = loadUISettings,
        save = saveUISettings,
        apply = applyUISettings,
        defaults = DEFAULT_SETTINGS,
        path = SAVE_PATH
    }
end
local UIModule = init()

return UIModule
