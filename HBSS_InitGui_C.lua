local InitGuiModule = {}
local InitGui = {}
InitGui.__index = InitGui

function InitGui.new()
    local self = setmetatable({}, InitGui)
    self.statusMessages = {
        "fetching random asset files...",
        "getting urls...",
        "doing stuff...",
        "compiling spaghetti code...",
        "asking Gpssickle for help...",
        "loading the funny...",
        "gravel.exe is doing something...",
        "checking if gravel is just crushed rocks...",
        "summoning the shovel...",
        "eating sand...",
        "crushing rocks...",
        "this definitely isn't a virus...",
        "praying to the rng gods...",
        "finding the nearest enemy...",
        "this is fine... everything is fine...",
        "rendering the funny...",
        "initializing quantum gravel...",
        "loading the secret sauce...",
        "hacking the mainframe...",
        "turning rocks into aimbot...",
        "idk what i'm doing...",
        "please wait... i'm doing my best...",
        "ok i'm just gonna load now...",
        "sending a 3.5gb update... just kidding",
        "graveling...",
        "this is the 100th status message btw...",
        "staring at the code...",
        "hoping it works...",
        "it's not a virus i promise...",
        "praying to the gps sickle...",
        "my code is pasta...",
        "al dente and tangled...",
        "bon appetit..."
    }
    self.dotCount = 0
    self.dotTask = nil
    self.statusTask = nil
    self.scrollTask = nil
    self.gui = nil
    self.bg = nil
    self.title = nil
    self.status = nil
    self.dots = nil
    self.codeBackground = nil
    self.codeScroller = nil
    
    -- Real-time code animation state
    self.codeLines = {}
    self.lineStates = {} -- Each line: {text, color, transparency, charIndex, isComplete, highlightType}
    self.animationSpeed = 0.03
    self.codeTypingTask = nil
    self.currentLineIndex = 0
    self.charIndex = 0
    self.isTypingComplete = false
    self.lineHeight = 18
    
    return self
end

-- Full code with syntax highlighting segments
function InitGui:getCodeSegments()
    return {
        -- Keywords (cyan)
        {text = "local", type = "keyword"},
        {text = " ", type = "space"},
        {text = "config", type = "variable"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "confIg", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Gravel"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "startsa", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "fovsize", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "120", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "predic", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hbtrans", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "scaleToScreen", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "stsdistance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_Enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_Method", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Raycast"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_TeamTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Enemies"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_Wallcheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_TargetPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Head"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_HitChance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "100", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovRadius", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "100", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovVisible", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovTransparency", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.90", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovColor", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.new(0, 0, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovColourTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.new(1, 1, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_FovIsTargeted", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_ThreeSixtyMode", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_GetTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Closest"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_currentTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_TArea", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "35", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_TargetRange", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1000", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_Wallbang", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SA2_BulletTeleport", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "currentTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "espc", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 182, 193)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "esptargetc", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 255, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "espteamc", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(0, 255, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "rfd", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "eme", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "wallc", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "bodypart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Head"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "espon", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefTextESP", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "highlightesp", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefHighlightESP", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefBoxESP", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefHealthESP", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefColorByHealth", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "espMasterEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "prefHeadDotESP", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineESPEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineESPOnlyTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineStartPosition", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Center"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineColor", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 255, 255)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineThickness", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lineESPData", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "originalSizes", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "activeApplied", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "espData", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "highlightData", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "targethbSizes", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "fovc", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(100, 0, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "fovct", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 255, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "playerConnections", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "characterConnections", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "targetMode", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Enemies"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "centerLocked", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitchance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "100", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "maxExpansion", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "math.huge", type = "math"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotFOVSize", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "70", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotStrength", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.5", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotWallCheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotTargetPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Head"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotTeamTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Enemies"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotCurrentTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotFOVRing", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxSize", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "10", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxTeamTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Enemies"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxExpandedParts", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxOriginalSizes", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxLastSize", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "hitboxColor", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 255, 255)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "raycastAntiAim", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimTPDistance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "3", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimAbovePlayer", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimAboveHeight", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "10", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimBehindPlayer", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimBehindDistance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "5", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "originalPosition", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "isTeleported", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "currentAntiAimTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimOrbitEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimOrbitSpeed", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "5", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimOrbitRadius", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "5", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimOrbitHeight", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "masterTeamTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Enemies"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmDistance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "10", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmSpeed", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmTargets", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "currentAutoFarmTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmLoop", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmIndex", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmCompleted", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmTargetPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Head"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmAlignToCrosshair", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmVerticalOffset", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmMinRange", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmMaxRange", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "50", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmOriginalPositions", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmWallCheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbot360Enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbot360OriginalFOV", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "100", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "gp", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "200", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "gp2", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "customFOVEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "customFOVValue", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "70", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "fbenabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "targetSeenSwitchRate", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.2", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "lastTargetSwitchTime", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "targetSeenTargets", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbot360Omnidirectional", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbot360BehindRange", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "180", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbot360WasEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "masterTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Players"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientMasterEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientWalkSpeed", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "16", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientJumpPower", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "50", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientNoclip", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientCFrameWalkEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientCFrameSpeed", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientConnections", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientOriginals", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "_tpwalking", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientWalkEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientJumpEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientNoclipEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "clientCFrameWalkToggle", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "masterGetTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Closest"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "aimbotGetTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Closest"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "silentGetTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Closest"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiAimGetTarget", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Closest"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmPartClaimStarted", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autoFarmLastRefresh", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "ignoreForcefield", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "QuickToggles", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "QTDrag", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "trussEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "trussPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "trussConnection", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "airwalkEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "airwalkPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "airwalkConnection", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autorespawnEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autorespawnConnections", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{}", type = "table"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autorespawnDeathPosition", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "autorespawnType", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"SetSpawnPoint"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SSEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SpawnLocation", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "SSConnection", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "fastspawn", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "antiafk", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "Viewing", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "camYOffsetEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "camYOffsetValue", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "camYOffsetOriginalCFrame", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "camYOffsetConnection", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "nil", type = "nil"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "spinbot", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "speed", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "50", type = "number"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "bhop", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "jumpDelay", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.05", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "quickToggleEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "quickToggleDraggable", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "reach", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "type", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Sphere"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "distance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "10", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "autoSwing", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "            ", type = "indent3"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "            ", type = "indent3"},
        {text = "delay", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.1", type = "number"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "}", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "visualizer", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "color", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 0, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "material", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"ForceField"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "transparency", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.6", type = "number"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "materials", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["ForceField"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.ForceField", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["Plastic"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.Plastic", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["Glass"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.Glass", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["Neon"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.Neon", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["SmoothPlastic"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.SmoothPlastic", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["Metal"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.Metal", type = "enum"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = '["DiamondPlate"]', type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Enum.Material.DiamondPlate", type = "enum"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "LowRender", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "tbot", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "enabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "delay", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.1", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "fovRadius", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "150", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "fovVisible", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "fovColor", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "Color3.fromRGB(255, 0, 0)", type = "function"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "fovTransparency", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "0.7", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "targetPart", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Head"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "wallCheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "hitChance", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "100", type = "number"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "holdToShoot", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "holdKey", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"MouseButton1"', type = "string"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "KeybindsEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "true", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "HoldKeysEnabled", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "false", type = "boolean"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "Keybinds", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = "{", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "HoldKeybind", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"LeftAlt"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "silentaim", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"E"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "aimbot", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Q"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "autofarm", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"F"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "antiaim", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"L"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "hitbox", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"G"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "esp", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Z"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "client", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"N"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "silentaimwallcheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"B"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "aimbotwallcheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"H"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "silentaimhk", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"R"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "silentaimhkwallcheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"T"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "triggerbot", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"X"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "bhop", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"V"', type = "string"},
        {text = ",", type = "punctuation"},
        {text = "\n", type = "newline"},
        
        {text = "        ", type = "indent2"},
        {text = "tbotwallcheck", type = "key"},
        {text = " ", type = "space"},
        {text = "=", type = "operator"},
        {text = " ", type = "space"},
        {text = '"Y"', type = "string"},
        {text = "\n", type = "newline"},
        
        {text = "    ", type = "indent"},
        {text = "}", type = "bracket"},
        {text = "\n", type = "newline"},
        
        {text = "}", type = "bracket"},
        {text = "\n", type = "newline"},
    }
end

function InitGui:getColorForType(typeName)
    local colors = {
        keyword = Color3.fromRGB(100, 200, 255),
        variable = Color3.fromRGB(200, 200, 200),
        operator = Color3.fromRGB(255, 200, 100),
        bracket = Color3.fromRGB(255, 200, 200),
        indent = Color3.fromRGB(80, 80, 80),
        indent2 = Color3.fromRGB(70, 70, 70),
        indent3 = Color3.fromRGB(60, 60, 60),
        key = Color3.fromRGB(255, 180, 100),
        string = Color3.fromRGB(100, 255, 150),
        number = Color3.fromRGB(255, 150, 150),
        boolean = Color3.fromRGB(255, 150, 255),
        nil = Color3.fromRGB(150, 150, 150),
        function = Color3.fromRGB(100, 200, 255),
        table = Color3.fromRGB(200, 180, 100),
        math = Color3.fromRGB(100, 200, 200),
        enum = Color3.fromRGB(150, 150, 255),
        punctuation = Color3.fromRGB(200, 200, 200),
        space = Color3.fromRGB(80, 80, 80),
        newline = Color3.fromRGB(40, 40, 40),
        comment = Color3.fromRGB(100, 150, 100),
        default = Color3.fromRGB(200, 200, 200)
    }
    return colors[typeName] or colors.default
end

function InitGui:buildCodeLines()
    local segments = self:getCodeSegments()
    local lines = {}
    local currentLine = ""
    local currentColors = {}
    local currentTypes = {}
    local lineIndex = 1
    
    for _, seg in ipairs(segments) do
        if seg.type == "newline" then
            if #currentLine > 0 then
                table.insert(lines, {
                    text = currentLine,
                    colors = currentColors,
                    types = currentTypes,
                    fullText = currentLine,
                    displayText = "",
                    charIndex = 0,
                    isComplete = false
                })
                currentLine = ""
                currentColors = {}
                currentTypes = {}
                lineIndex = lineIndex + 1
            end
        else
            for char in seg.text:gmatch(".") do
                currentLine = currentLine .. char
                table.insert(currentColors, self:getColorForType(seg.type))
                table.insert(currentTypes, seg.type)
            end
        end
    end
    
    if #currentLine > 0 then
        table.insert(lines, {
            text = currentLine,
            colors = currentColors,
            types = currentTypes,
            fullText = currentLine,
            displayText = "",
            charIndex = 0,
            isComplete = false
        })
    end
    
    return lines
end

function InitGui:create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InitializingGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui
    
    -- Blur background effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 10
    blur.Parent = game:GetService("Lighting")
    
    -- Main background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0.05, 0.05, 0.08)
    bg.BackgroundTransparency = 0.1
    bg.Parent = gui
    self.bg = bg
    
    -- Animated gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 10, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 35))
    })
    gradient.Parent = bg
    
    -- Code container with modern style
    local codeBg = Instance.new("Frame")
    codeBg.Size = UDim2.fromScale(0.5, 0.85)
    codeBg.Position = UDim2.fromScale(0.25, 0.07)
    codeBg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    codeBg.BackgroundTransparency = 0.3
    codeBg.BorderSizePixel = 0
    codeBg.ClipsDescendants = true
    codeBg.Parent = bg
    self.codeBackground = codeBg
    
    -- Rounded corners with glow
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = codeBg
    
    local glowStroke = Instance.new("UIStroke")
    glowStroke.Thickness = 1
    glowStroke.Color = Color3.fromRGB(50, 150, 255)
    glowStroke.Transparency = 0.7
    glowStroke.LineJoinMode = Enum.LineJoinMode.Round
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Parent = codeBg
    
    -- Top bar with code info
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 28)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    topBar.BackgroundTransparency = 0.5
    topBar.BorderSizePixel = 0
    topBar.Parent = codeBg
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar
    
    -- Window controls
    local dotColors = {Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}
    local dotPositions = {15, 32, 49}
    
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(0, dotPositions[i], 0, 8)
        dot.BackgroundColor3 = dotColors[i]
        dot.BorderSizePixel = 0
        dot.Parent = topBar
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
    end
    
    -- "config.lua" title
    local fileTitle = Instance.new("TextLabel")
    fileTitle.Size = UDim2.new(1, -80, 1, 0)
    fileTitle.Position = UDim2.new(0, 60, 0, 0)
    fileTitle.BackgroundTransparency = 1
    fileTitle.Text = "config.lua — Gravel.cc"
    fileTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    fileTitle.Font = Enum.Font.GothamMedium
    fileTitle.TextSize = 12
    fileTitle.TextXAlignment = Enum.TextXAlignment.Center
    fileTitle.Parent = topBar
    
    -- Line numbers and code scroller
    local codeScroller = Instance.new("ScrollingFrame")
    codeScroller.Size = UDim2.new(1, 0, 1, -28)
    codeScroller.Position = UDim2.new(0, 0, 0, 28)
    codeScroller.BackgroundTransparency = 1
    codeScroller.BorderSizePixel = 0
    codeScroller.ScrollBarThickness = 3
    codeScroller.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 80)
    codeScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None
    codeScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    codeScroller.CanvasSize = UDim2.fromOffset(0, 0)
    codeScroller.Parent = codeBg
    self.codeScroller = codeScroller
    
    -- Line number container
    local lineNumFrame = Instance.new("Frame")
    lineNumFrame.Size = UDim2.new(0, 40, 1, 0)
    lineNumFrame.BackgroundTransparency = 1
    lineNumFrame.Parent = codeScroller
    
    -- Build code lines for typing animation
    self.codeLines = self:buildCodeLines()
    self.lineStates = {}
    
    -- Store line labels for dynamic updates
    self.lineLabels = {}
    self.lineNumberLabels = {}
    
    -- Calculate total height
    local lineHeight = 20
    local totalHeight = #self.codeLines * lineHeight + 20
    codeScroller.CanvasSize = UDim2.fromOffset(0, totalHeight)
    
    -- Create initial line labels with blank text
    for i, lineData in ipairs(self.codeLines) do
        local yPos = 10 + (i - 1) * lineHeight
        
        -- Line number
        local numLabel = Instance.new("TextLabel")
        numLabel.Size = UDim2.new(0, 35, 0, lineHeight)
        numLabel.Position = UDim2.fromOffset(5, yPos)
        numLabel.Text = tostring(i)
        numLabel.Font = Enum.Font.Code
        numLabel.TextSize = 10
        numLabel.TextColor3 = Color3.fromRGB(60, 60, 80)
        numLabel.BackgroundTransparency = 1
        numLabel.TextXAlignment = Enum.TextXAlignment.Right
        numLabel.TextYAlignment = Enum.TextYAlignment.Top
        numLabel.Parent = codeScroller
        self.lineNumberLabels[i] = numLabel
        
        -- Code text with colored characters
        local codeLabel = Instance.new("TextLabel")
        codeLabel.Size = UDim2.new(1, -45, 0, lineHeight)
        codeLabel.Position = UDim2.fromOffset(45, yPos)
        codeLabel.Text = ""
        codeLabel.Font = Enum.Font.Code
        codeLabel.TextSize = 11
        codeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        codeLabel.BackgroundTransparency = 1
        codeLabel.TextXAlignment = Enum.TextXAlignment.Left
        codeLabel.TextYAlignment = Enum.TextYAlignment.Top
        codeLabel.RichText = true
        codeLabel.Parent = codeScroller
        self.lineLabels[i] = codeLabel
    end
    
    -- Center UI elements
    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.2)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.ZIndex = 2
    center.Parent = bg
    
    -- Title with glow
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.4)
    title.Position = UDim2.fromScale(0.5, 0.15)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Text = "INITIALIZING"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextTransparency = 0
    title.BackgroundTransparency = 1
    title.ZIndex = 3
    title.Parent = center
    self.title = title
    
    -- Glow under title
    local titleGlow = Instance.new("TextLabel")
    titleGlow.Size = UDim2.fromScale(1, 0.4)
    titleGlow.Position = UDim2.fromScale(0.5, 0.17)
    titleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    titleGlow.Text = "INITIALIZING"
    titleGlow.Font = Enum.Font.GothamBold
    titleGlow.TextSize = 32
    titleGlow.TextColor3 = Color3.fromRGB(50, 100, 200)
    titleGlow.TextTransparency = 0.8
    titleGlow.BackgroundTransparency = 1
    titleGlow.ZIndex = 1
    titleGlow.Parent = center
    
    -- Status with typing effect
    local status = Instance.new("TextLabel")
    status.Size = UDim2.fromScale(1, 0.3)
    status.Position = UDim2.fromScale(0.5, 0.55)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Text = "› fetching random asset files..."
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(150, 150, 180)
    status.TextTransparency = 0
    status.BackgroundTransparency = 1
    status.ZIndex = 3
    status.Parent = center
    self.status = status
    
    -- Dots with glow
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.fromScale(1, 0.3)
    dots.Position = UDim2.fromScale(0.5, 0.8)
    dots.AnchorPoint = Vector2.new(0.5, 0.5)
    dots.Text = ""
    dots.Font = Enum.Font.GothamBold
    dots.TextSize = 20
    dots.TextColor3 = Color3.fromRGB(100, 200, 255)
    dots.TextTransparency = 0
    dots.BackgroundTransparency = 1
    dots.ZIndex = 3
    dots.Parent = center
    self.dots = dots
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.fromScale(0.6, 0.025)
    progressBg.Position = UDim2.fromScale(0.2, 0.92)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = bg
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.fromScale(0, 1)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    self.progressBar = progressBar
    
    local progressCorner2 = Instance.new("UICorner")
    progressCorner2.CornerRadius = UDim.new(1, 0)
    progressCorner2.Parent = progressBar
    
    -- Start animations
    self:startAnimations()
    
    return self
end

function InitGui:startAnimations()
    -- Dot animation
    self.dotTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.dotCount = (self.dotCount % 3) + 1
            self.dots.Text = string.rep(".", self.dotCount)
            task.wait(0.35)
        end
    end)
    
    -- Status message cycling with smooth transitions
    self.statusTask = task.spawn(function()
        local lastChange = 0
        while self.gui and self.gui.Parent do
            local elapsed = tick() - lastChange
            if elapsed > math.random(8, 18) / 10 then
                local newMsg = "› " .. self.statusMessages[math.random(1, #self.statusMessages)]
                local tween = game:GetService("TweenService"):Create(self.status, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextTransparency = 1
                })
                tween:Play()
                tween.Completed:Wait()
                self.status.Text = newMsg
                local tween2 = game:GetService("TweenService"):Create(self.status, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    TextTransparency = 0
                })
                tween2:Play()
                lastChange = tick()
                
                -- Update progress bar
                local progress = math.random(20, 40) / 100
                local tween3 = game:GetService("TweenService"):Create(self.progressBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.fromScale(progress, 1)
                })
                tween3:Play()
            end
            task.wait(0.1)
        end
    end)
    
    -- Code typing animation with syntax highlighting
    self.codeTypingTask = task.spawn(function()
        local lineIndex = 1
        local charIndex = 1
        local currentLine = self.codeLines[lineIndex]
        if not currentLine then return end
        
        -- Initial delay
        task.wait(0.5)
        
        while self.gui and self.gui.Parent do
            if not currentLine then
                break
            end
            
            if not currentLine.isComplete then
                charIndex = charIndex + 1
                
                if charIndex > #currentLine.text then
                    currentLine.isComplete = true
                    currentLine.displayText = currentLine.text
                    lineIndex = lineIndex + 1
                    charIndex = 1
                    
                    if lineIndex > #self.codeLines then
                        -- All lines typed, start over with a new code segment
                        local newLines = self:buildCodeLines()
                        -- Add visual refresh effect
                        for i, label in pairs(self.lineLabels) do
                            if label then
                                local tween = game:GetService("TweenService"):Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                    TextTransparency = 0.3
                                })
                                tween:Play()
                                tween.Completed:Wait()
                            end
                        end
                        -- Reset
                        self.codeLines = newLines
                        self.lineStates = {}
                        lineIndex = 1
                        charIndex = 1
                        currentLine = self.codeLines[lineIndex]
                        
                        -- Clear and recreate line labels
                        for i, label in pairs(self.lineLabels) do
                            if label then
                                label.Text = ""
                                local tween = game:GetService("TweenService"):Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                    TextTransparency = 0
                                })
                                tween:Play()
                            end
                        end
                        continue
                    end
                    
                    currentLine = self.codeLines[lineIndex]
                    continue
                end
                
                -- Build colored text with RichText
                local displayText = ""
                for i = 1, charIndex do
                    local char = currentLine.text:sub(i, i)
                    local color = currentLine.colors[i] or Color3.fromRGB(200, 200, 200)
                    local hexColor = string.format("#%02X%02X%02X", 
                        math.floor(color.R * 255), 
                        math.floor(color.G * 255), 
                        math.floor(color.B * 255))
                    displayText = displayText .. string.format('<font color="%s">%s</font>', hexColor, char)
                end
                currentLine.displayText = displayText
                if self.lineLabels[lineIndex] then
                    self.lineLabels[lineIndex].Text = displayText
                end
                
                -- Random speed variation for natural typing
                local delay = 0.02 + math.random() * 0.03
                task.wait(delay)
            else
                -- Move to next line if current is complete
                lineIndex = lineIndex + 1
                if lineIndex > #self.codeLines then
                    -- Reset with new code
                    local newLines = self:buildCodeLines()
                    self.codeLines = newLines
                    self.lineStates = {}
                    lineIndex = 1
                    charIndex = 1
                    currentLine = self.codeLines[lineIndex]
                    
                    for i, label in pairs(self.lineLabels) do
                        if label then
                            label.Text = ""
                        end
                    end
                    continue
                end
                currentLine = self.codeLines[lineIndex]
                charIndex = 1
                task.wait(0.05)
            end
        end
    end)
    
    -- Smooth scroll animation
    self.scrollTask = task.spawn(function()
        if not self.codeScroller then return end
        local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
        local startPos = 0
        local speed = 35
        local targetLine = 0
        
        while self.gui and self.gui.Parent do
            -- Auto-scroll to follow typing
            local targetPos = (self.currentLineIndex or 0) * self.lineHeight - self.codeScroller.AbsoluteSize.Y / 3
            if targetPos > 0 then
                startPos = startPos + (targetPos - startPos) * 0.02
            else
                startPos = startPos + speed * 0.03
            end
            
            if startPos > canvasHeight - self.codeScroller.AbsoluteSize.Y then
                startPos = 0
            end
            self.codeScroller.CanvasPosition = Vector2.new(0, startPos)
            task.wait(0.03)
        end
    end)
end

function InitGui:destroy()
    if self.gui and self.gui.Parent then
        if self.dotTask then
            task.cancel(self.dotTask)
            self.dotTask = nil
        end
        if self.statusTask then
            task.cancel(self.statusTask)
            self.statusTask = nil
        end
        if self.scrollTask then
            task.cancel(self.scrollTask)
            self.scrollTask = nil
        end
        if self.codeTypingTask then
            task.cancel(self.codeTypingTask)
            self.codeTypingTask = nil
        end
        
        -- Clean up blur
        local blur = game:GetService("Lighting"):FindFirstChild("BlurEffect")
        if blur then blur:Destroy() end
        
        -- Clean up line labels
        self.lineLabels = {}
        self.lineNumberLabels = {}
        
        -- Slide out animation
        local slideOutTask = task.spawn(function()
            if not self.codeScroller then return end
            
            local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
            local startPos = self.codeScroller.CanvasPosition.Y or 0
            local speed = 500
            local slideSpeed = 800
            local targetX = -(self.codeBackground.AbsoluteSize.X + 100)
            while self.codeScroller and self.codeScroller.Parent do
                startPos = startPos + speed * 0.03
                if startPos > canvasHeight - self.codeScroller.AbsoluteSize.Y then
                    startPos = 0
                end
                self.codeScroller.CanvasPosition = Vector2.new(0, startPos)
                
                local currentPos = self.codeBackground.Position
                if currentPos.X.Offset > targetX then
                    local newX = currentPos.X.Offset - slideSpeed * 0.03
                    self.codeBackground.Position = UDim2.fromOffset(newX, 0)
                else
                    break 
                end
                
                task.wait(0.03)
            end
        end)
        
        -- Fade out
        local fadeOut = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if self.bg then
            game:GetService("TweenService"):Create(self.bg, fadeOut, {BackgroundTransparency = 1}):Play()
        end
        if self.title then
            game:GetService("TweenService"):Create(self.title, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.status then
            game:GetService("TweenService"):Create(self.status, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.dots then
            game:GetService("TweenService"):Create(self.dots, fadeOut, {TextTransparency = 1}):Play()
        end
        if self.progressBar then
            game:GetService("TweenService"):Create(self.progressBar, fadeOut, {Size = UDim2.fromScale(1, 1)}):Play()
        end
        
        task.wait(0.7)
        if slideOutTask then
            task.cancel(slideOutTask)
        end
        self.gui:Destroy()
        self.gui = nil
        self.bg = nil
        self.title = nil
        self.status = nil
        self.dots = nil
        self.codeBackground = nil
        self.codeScroller = nil
        self.progressBar = nil
    end
end

local initGui = InitGui.new():create()
_G.destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
