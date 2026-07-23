if getgenv().Gravel_UIAutoSave then
    return
end
getgenv().Gravel_UIAutoSave = true
local function ensureAssetFolder()
    local folderPath = "Gravel_Saves/assets"
    if not isfolder(folderPath) then
        pcall(function()
            makefolder(folderPath)
        end)
    end
    return folderPath
end
local function getUISavePath()
    local assetFolder = ensureAssetFolder()
    return assetFolder .. "/SavedUI.json"
end
local function loadUISettings()
    local path = getUISavePath()
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
local function saveUISettings(themeName, transparency)
    local path = getUISavePath()
    local data = {
        version = "1.0",
        timestamp = os.time(),
        theme = themeName or "Dark",
        transparency = transparency or 0.15
    }
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    if not success then
        warn("Failed to encode UI data:", tostring(err))
        return false
    end
    local success, err = pcall(function()
        writefile(path, encoded)
    end)
    if success then
        return true
    else
        warn("Failed to save UI data:", tostring(err))
        return false
    end
end
local function LoadUI()
    local settings = loadUISettings()
    if not settings then
        return false
    end
    local success = pcall(function()
        if Window and WindUI then
            if settings.theme and settings.theme ~= "" then
                local themes = WindUI.Themes
                if themes and themes[settings.theme] then
                    WindUI:SetTheme(settings.theme)
                end
            end
            if settings.transparency ~= nil then
                WindUI.TransparencyValue = settings.transparency
                if WindUI.Transparent then
                    WindUI.Window:ToggleTransparency(true)
                end
            end
        end
    end)
    return success
end
local function setupAutoSave()
    if not Window or not WindUI then
        return
    end
    local currentTheme = WindUI.Theme and WindUI.Theme.Name or "Dark"
    local currentTransparency = WindUI.TransparencyValue or 0.15
    saveUISettings(currentTheme, currentTransparency)
end
local function startAutoSaveLoop()
    local lastTheme = WindUI.Theme and WindUI.Theme.Name or "Dark"
    local lastTransparency = WindUI.TransparencyValue or 0.15
    task.spawn(function()
        while getgenv().Gravel_UIAutoSave do
            pcall(function()
                if Window and WindUI then
                    local currentTheme = WindUI.Theme and WindUI.Theme.Name or "Dark"
                    local currentTransparency = WindUI.TransparencyValue or 0.15
                    if currentTheme ~= lastTheme or currentTransparency ~= lastTransparency then
                        saveUISettings(currentTheme, currentTransparency)
                        lastTheme = currentTheme
                        lastTransparency = currentTransparency
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end
pcall(function()
    local success = LoadUI()
    if success then
        print("ui loaded")
    else
        print("ui didnt even have anything to load 🥀")
    end
end)
setupAutoSave()
startAutoSaveLoop()
getgenv().Gravel_LoadUI = LoadUI
getgenv().Gravel_SaveUI = saveUISettings
return {
    LoadUI = LoadUI,
    SaveUI = saveUISettings,
    getUISavePath = getUISavePath
}
