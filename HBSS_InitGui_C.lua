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
    return self
end

function InitGui:create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InitializingGui"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    self.gui = gui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.7
    bg.Parent = gui
    self.bg = bg
    local codeBg = Instance.new("Frame")
    codeBg.Size = UDim2.fromScale(0.45, 1)
    codeBg.Position = UDim2.fromScale(0, 0)
    codeBg.BackgroundTransparency = 1
    codeBg.ClipsDescendants = true
    codeBg.Parent = bg
    self.codeBackground = codeBg

    local codeScroller = Instance.new("ScrollingFrame")
    codeScroller.Size = UDim2.fromScale(1, 1)
    codeScroller.BackgroundTransparency = 1
    codeScroller.BorderSizePixel = 0
    codeScroller.ScrollBarThickness = 0
    codeScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None
    codeScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    codeScroller.CanvasSize = UDim2.fromOffset(0, 0)
    codeScroller.Parent = codeBg
    self.codeScroller = codeScroller
    local configCode = [[
local config = {
    confIg = "Gravel",
    startsa = false,
    fovsize = 120,
    predic = 1,
    hbtrans = 1,
    scaleToScreen = false,
    stsdistance = 0,
    SA2_Enabled = false,
    SA2_Method = "Raycast",
    SA2_TeamTarget = "Enemies",
    SA2_Wallcheck = false,
    SA2_TargetPart = "Head",
    SA2_HitChance = 100,
    SA2_FovRadius = 100,
    SA2_FovVisible = true,
    SA2_FovTransparency = 0.90,
    SA2_FovColor = Color3.new(0, 0, 0),
    SA2_FovColourTarget = Color3.new(1, 1, 0),
    SA2_FovIsTargeted = false,
    SA2_ThreeSixtyMode = false,
    SA2_GetTarget = "Closest",
    SA2_currentTarget = nil,
    SA2_TArea = 35,
    SA2_TargetRange = 1000,
    SA2_Wallbang = false,
    SA2_BulletTeleport = false,
    currentTarget = nil,
    espc = Color3.fromRGB(255, 182, 193),
    esptargetc = Color3.fromRGB(255, 255, 0),
    espteamc = Color3.fromRGB(0, 255, 0),
    rfd = false,
    eme = true,
    wallc = false,
    bodypart = "Head",
    espon = false,
    prefTextESP = false,
    highlightesp = false,
    prefHighlightESP = false,
    prefBoxESP = false,
    prefHealthESP = false,
    prefColorByHealth = false,
    espMasterEnabled = false,
    prefHeadDotESP = false,
    lineESPEnabled = false,
    lineESPOnlyTarget = false,
    lineStartPosition = "Center",
    lineColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1,
    lineESPData = {},
    originalSizes = {},
    activeApplied = {},
    espData = {},
    highlightData = {},
    currentTarget = nil,
    targethbSizes = {},
    fovc = Color3.fromRGB(100, 0, 0),
    fovct = Color3.fromRGB(255, 255, 0),
    playerConnections = {},
    characterConnections = {},
    targetMode = "Enemies",
    centerLocked = {},
    hitchance = 100,
    maxExpansion = math.huge,
    aimbotEnabled = false,
    aimbotFOVSize = 70,
    aimbotStrength = 0.5,
    aimbotWallCheck = false,
    aimbotTargetPart = "Head",
    aimbotTeamTarget = "Enemies",
    aimbotCurrentTarget = nil,
    aimbotFOVRing = nil,
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxTeamTarget = "Enemies",
    hitboxExpandedParts = {},
    hitboxOriginalSizes = {},
    hitboxLastSize = {},
    hitboxColor = Color3.fromRGB(255, 255, 255),
    antiAimEnabled = false,
    raycastAntiAim = false,
    antiAimTPDistance = 3,
    antiAimAbovePlayer = false,
    antiAimAboveHeight = 10,
    antiAimBehindPlayer = false,
    antiAimBehindDistance = 5,
    originalPosition = nil,
    isTeleported = false,
    currentAntiAimTarget = nil,
    antiAimOrbitEnabled = false,
    antiAimOrbitSpeed = 5,
    antiAimOrbitRadius = 5,
    antiAimOrbitHeight = 0,
    masterTeamTarget = "Enemies",
    autoFarmEnabled = false,
    autoFarmDistance = 10,
    autoFarmSpeed = 1,
    autoFarmTargets = {},
    currentAutoFarmTarget = nil,
    autoFarmLoop = nil,
    autoFarmIndex = 1,
    autoFarmCompleted = {},
    autoFarmTargetPart = "Head",
    autoFarmAlignToCrosshair = true,
    autoFarmVerticalOffset = 0,
    autoFarmMinRange = 0,
    autoFarmMaxRange = 50,
    autoFarmOriginalPositions = {}, 
    autoFarmWallCheck = false,
    aimbot360Enabled = false,
    aimbot360OriginalFOV = 100,
    gp = 200,
    gp2 = 1,
    customFOVEnabled = false,
    customFOVValue = 70,
    fbenabled = false,
    targetSeenSwitchRate = 0.2,
    lastTargetSwitchTime = 0,
    targetSeenTargets = {},
    aimbot360Omnidirectional = true,
    aimbot360BehindRange = 180,
    aimbot360WasEnabled = false,
    masterTarget = "Players",
    clientMasterEnabled = false,
    clientWalkSpeed = 16,
    clientJumpPower = 50,
    clientNoclip = false,
    clientCFrameWalkEnabled = false,
    clientCFrameSpeed = 1,
    clientConnections = {},
    clientOriginals = {},
    _tpwalking = false,
    clientWalkEnabled = false,
    clientJumpEnabled = false,
    clientNoclipEnabled = false,
    clientCFrameWalkToggle = false,
    masterGetTarget = "Closest",
    aimbotGetTarget = "Closest",
    silentGetTarget = "Closest",
    antiAimGetTarget = "Closest",
    autoFarmPartClaimStarted = false,
    autoFarmLastRefresh = 0,
    ignoreForcefield = true,
    QuickToggles = false,
    QTDrag = true,
    trussEnabled = false,
    trussPart = nil,
    trussConnection = nil,
    airwalkEnabled = false,
    airwalkPart = nil,
    airwalkConnection = nil,
    autorespawnEnabled = false,
    autorespawnConnections = {},
    autorespawnDeathPosition = nil,
    autorespawnType = "SetSpawnPoint",
    SSEnabled = false,
    SpawnLocation = nil,
    SSConnection = nil,
    fastspawn = false,
    antiafk = false,
    Viewing = false,
    camYOffsetEnabled = false,
    camYOffsetValue = 0,
    camYOffsetOriginalCFrame = nil,
    camYOffsetConnection = nil,
    spinbot = {
        enabled = false,
        speed = 50,
    },
    bhop = {
        enabled = false,
        jumpDelay = 0.05,
        quickToggleEnabled = false,
        quickToggleDraggable = true
    },
    reach = {
        enabled = false,
        type = "Sphere",
        distance = 10,
        autoSwing = {
            enabled = false,
            delay = 0.1
        },
    },
    visualizer = {
        enabled = false,
        color = Color3.fromRGB(255, 0, 0),
        material = "ForceField",
        transparency = 0.6
    },
    materials = {
        ["ForceField"] = Enum.Material.ForceField,
        ["Plastic"] = Enum.Material.Plastic,
        ["Glass"] = Enum.Material.Glass,
        ["Neon"] = Enum.Material.Neon,
        ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
        ["Metal"] = Enum.Material.Metal,
        ["DiamondPlate"] = Enum.Material.DiamondPlate
    },
    LowRender = false,
    tbot = {
        enabled = false,
        delay = 0.1,
        fovRadius = 150,
        fovVisible = true,
        fovColor = Color3.fromRGB(255, 0, 0),
        fovTransparency = 0.7,
        targetPart = "Head",
        wallCheck = false,
        hitChance = 100,
        holdToShoot = false,
        holdKey = "MouseButton1"
    },
    KeybindsEnabled = true,
    HoldKeysEnabled = false,
    Keybinds = {
        HoldKeybind = "LeftAlt",
        silentaim = "E",
        aimbot = "Q",
        autofarm = "F",
        antiaim = "L",
        hitbox = "G",
        esp = "Z",
        client = "N",
        silentaimwallcheck = "B",
        aimbotwallcheck = "H",
        silentaimhk = "R",
        silentaimhkwallcheck = "T",
        triggerbot = "X",
        bhop = "V",
        tbotwallcheck = "Y",
    },
    varibz = {
        btntitle = {
            "hey y close me",
            "Gui size decreases",
            "dude",
            "yh",
            lp_info.lp_displayname,
            "how graveling of u",
            "rock solid ui",
            "what",
            "version: idk",
            "D:",
            "unclose me NOW!!! D:",
            "just simply cheat through it",
            "bowl",
            "gta 6 when?",
            "holy cow",
            "open4robuc",
            "me want to be open",
            "gravel is not sand",
            "is gravel just sand",
            "gl",
            "not full ban-proof",
            "bleh :p",
            ":3",
            ":o",
            ";]",
            "error code: 6967420",
            "🥀💔✌️🫩",
            "brochacho",
        },
        convo = {
            {
                typesp = "1.5",
                "HEY",
                "{displayname} HEY",
                "CAN YOU HEAR ME???",
                "Ok Ive got ur attention",
                "what I'm gonna say is",
                "pls read the InfoTab :(",
                "and credit me if u did a snippet :(",
            },
            {
                "sand.cc is an larper",
                "it's a actual gravel larper",
                "sand larps gravel",
            },
            {
                "Guys he's hacking REPORT",
                "EVERYBODY SPAM REPORT HIM",
                "HACKER REPORTTT",
            },
            {
                "steam",
                "stop tryna kill us :(",
                "hacker lives matter",
            },
            {
                typesp = "2",
                "I AM A SURGEON",
                "I AM A SURGEON",
                "I AM- IAM A SURGEON",
                "IAM A SURGEON",
            },
            {
                typesp = "2",
                "i am an fucking architect",
                "GOD DAMN IT, IM JUST STUCK",
                "SELLING SHIT FURNITURE",
                "BECAUSE SOMEONE WONT GET OFF",
                "THEIR FAT FUCKING ASS AND HELP ME.",
            },
            {
                typesp = "2",
                "Hikinuku kasetto, ohsi komu risetto",
                "Mayoi komu meiro",
                "Susume domo daruseenyo",
                "Doa no saki ni boku no senaka ga mieta\nfurimuita saki ni kibiu ga mieta",
                "Jigoku no hate nado doko ni aru no ka\nideguchi wa mada nano?",
                "Kuru, Kuru, Kuru,\nKurikaesu, Kurikaesu, Kurikaesu",
                "FuraFura, FuraFura,\nFurakutaru, Furakutaru, Furakutaru, Furakutaru",
                "looping the rooms\ntype shi 💔",
            },
            {
                "proto conversion",
                "tbh idk wat I'm saying",
            },
            {
                "alt+f4 = free robux",
                "trust me it works",
                "101% works I'm sure",
            },
            {
                "who are u",
                "yea like who r u",
                "r u a gravel user?",
                "hmmmmm ok then",
            },
            {
                typesp = "1.5",
                "My Rival,",
                "My Idol,",
                "You've got me suicidal",
                "My love, your rage",
                "Our dying claims to fame'",
                "Our battle legendary,",
                "Our fickle fraternizing,",
                "A war inside my heart.",
                "Until ###### it do us part",
                "Bang, Bang, Bang, Bang",
                "'Til I take you...",
                "Down, Down, Down, Down",
                "I want you in the ground!",
            },
            {
                "Ugh, this kitchen is\nso hard to clean",
                "If only there was a easier way!",
                "",
                "Hi, I'm DErek Baum,\nsay goodbye to daily stains & dirty surfaces",
                "with new KITCHEN GUN!!",
                "This sink is filthy",
                "but just 3 shots from KITCHEN GUN",
                "BANG!, BANG!, BANG!",
                "and it sparkles like new!",
            },
            {
                "This toilet is so hard to clean!",
                "There must be a easier way",
                "",
                "HI!, I'm DERek baum & i declare war\non toilets with new TOILET GRENADE",
                "just pull the pin, pop it in the bowl,\nput the lid down",
                "and let TOILET GRENADE do the rest!",
                "BAAAAANNNNGGG!!!!",
            },
            {
                "",
            },
            {
                typesp = "2",
                "My bread was\nburnt to a crisp",
                "It's not like it's inedible\nor anything, I guess...",
                "I wish it was fluffy like usual\nif only it didn't get burnt...",
                "I guess there's no use in wishing now...",
                "",
                "My bread was\nburnt to a crisp",
                "It's rock hard...",
                "Not that it's inedible\nor anything, I guess...",
                "I really hope its\nnot burnt tomorrow",
                "It's bound to be better, right?",
                "I guess there's no use in wishing now...",
            },
            {
                "ur retroslop score is {retroscore}",
                "ye I'm deaduzz",
                "tbh... idc lol ur fine {displayname}",
            },
            {
                "I'm lazier than lazytown",
                "that's literally how lazy iam",
                "it's true but also not true",
                "ok whatevski",
            },
            {
                typesp = "2.5",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "When I get home it better be clean!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "Did you do your chores?",
                "Yessirski!",
                "BOI WHY DID YA LIE TO ME",
                "AHHHHHH",
            },
            {
                typesp = "1.5",
                "Y-YO, {displayname} come over here",
                "come over here,\ncome over here",
                "Check out my new shoes,",
                "Theyre the brand new-",
                "1-2, Buckle my shoeeee",
                "3-4, Buckle some moreeeee",
                "5-6, Nike-y Kicks",
                "OH-OH-OhHH THAT IS SO FIRE",
            },
            {
                "''Hey it's me, it's verity''",
                "''Ask me ANYTHING!''",
                "I got a question",
                "''I know about million things''",
                "Well that's great!",
                "''I'll do EVERYTHING!",
                "Alright!",
                "What's the capital of france?",
                "''Oh oui oui oui''",
                "''It is Parii''",
                "",
                "Horror Skunx ur\nNOT cooking ts",
            },
            {
                typesp = "2.3",
                "I party like I'm 21! CX",
                "20?",
                "21!",
                "I party like I'm 21! :D",
                "20?",
                "21! :v",
                "20?",
                "20?",
                "21! :c",
                "20?",
                "20?",
                "21! D:",
                "20?",
                "20?",
                "21! D:",
                "2-2-2-2?",
                "21! o_O",
                "20?",
                "20?",
                "21! ^⁠_⁠^",
                "20?",
                "20?",
                "21! :3",
                "20?",
                "20?",
                "21? :p",
                "2-2-2-2?",
                "20?",
                "21?",
            },
            {
                typesp = "1.5",
                "Error: (can't find message)",
                "Error: (can't find message)",
                "Error: (can't find message)",
                "I'm not having errors actually",
                "or maybe I am, who knows??",
            },
            {
                "server authority",
                "is laggyyyy :c",
                "like bro??? y is it so laggy :(((",
            },
            {
                typesp = "2.5",
                ":o",
                ":)",
                ";)",
                ";D",
            },
            {
                "Mama, can I have cookie",
                "No diabeto, roll back to kitchen",
                "awwwwwwwww :(",
            },
            {
                typesp = "1.5",
                "I JUST HIT THE",
                "JACKPOTTTTTTT",
                "AY, AY, AY, AY, AY",
                "I JUST HIT THE JACKPOT",
            },
            {
                "I wouldn't say gravel is da best",
                "idk there might be other scripts",
                "that are hidden gems",
                "well maybe gravel is one of em :v",
            },
            {
                typesp = "2",
                "All your base are belong to us",
                "11113333777",
                "TEH EPIK DUCK IS COMING!!!",
                "GET OF MAH LAWN",
                "ROFL",
                "{userid}",
                "Muahahahaha!",
            },
            {
                "ur accountage is {accountage}",
                "idk even know why I'm saying ts",
            },
            {
                typesp = "1.5",
                "if you could listen closely",
                "you'll be a villain mostly",
                "you have to chase a hero",
                "and watch em' go from 1 to 0",
                "just follow my moves.",
                "and you'll be set-",
                "to go and sneak around",
                "just be careful",
                "to not make a single sound",
                "as this superhero will be going-",
                "on the around",
                "now let's go and chase him down!",
                "",
                "is that a sick song {displayname}?",
            },
            {
                "name me a fictional villian\nthat no-1 h8s",
                "it's Robbie Rotten",
            },
            {
                "du bist gut genug...",
                "Ich weiß nicht,",
                "was die welt die sagt",
                "bleib einfach nur du,",
                "du bist gut genug!",
                "du bist gut genug!",
                "du bist gut genug!",
                "du bist gut genug!",
                "*fire music*",
            },
            {
                typesp = "1.5",
                "shimmy ey, shimmy ey, yaaa~",
                "drake.. Swalalala.. drake",
                "swalalala.. swalalala *sick beat*",
                "*sick music*... keep streaking yah",
            },
            {
                "Bro ts code is 15000+ lines long :(",
                "I ''can't'' do dis shi :[",
                "plz heseelepp me {displayname}",
            },
            {
                "Cframe view is op",
                "pls try it out {displayname}",
                "you'll like it :3",
            },
            {
                "Aimware",
                "is this actually aimware??",
                "who knows",
                "maybe it is",
            },
            {
                typesp = "3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                ":3",
                ">:3",
                "^w^",
            },
            {
                "gravel cute :3",
                ":3 :3",
                ":3:3:3:3:3:3:3:3:3:3:3",
            },
            {
                typesp = "1.5",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
                "Didn't take that well.",
                "Didn't take that well.",
                "Felt like!",
            },
            {
                typesp = "1.5",
                "I somehow see what's beautiful,",
                "In things that are ephemeral",
                "Am I only friend of mine",
                "Love is just.. a piece of time\nin the world",
                "In the world",
                "And I couldn't help but fall\nin love again",
            },
            {
                "I'm not actually talking to u",
                "but i am talking to u",
                "does that make any sense :s",
                "probably not",
            },
            {
                "r u hacking??",
                "I think u hackin",
                "yea ur def hackin",
            },
            {
                "you got ratted.",
                "I'm serious",
                "you've got ratted",
                "I'm joking lol",
            },
            {
                "ur social security number\nis [{userid}]",
                "no but seriously it is",
                "I'm jk",
                "what even is {userid} :b",
                "oh wait that's ur userid mb",
            },
            {
                "is gravel js crushed rocks?",
                "like genuinely???",
                "gravel could be js crushed rocks",
            },
            {
                "hbss means:",
                "heybuddystopstealing",
                "ye dat what it means",
            },
            {
                "I'm 101% u'll like gravel :3",
                "like I'm dat sure",
                "(why am I self-glazing)",
            },
            {
                "I work best on generic shooters",
                "if it's not a generic shooter",
                "I might break",
            },
            {
                "why is http 429 my enemy",
                "I SWEAR TO GOD",
                "everytime i load gravel",
                "it hits me with 429",
                "like bro chill out",
            },
            {
                "renderstepped is for chuds",
                "heartbeat gang where u at",
                "renderstepped makes me lag",
                "heartbeat smooth like butter",
            },
            {
                "did someone say spaghetti",
                "my code is pasta",
                "al dente and tangled",
                "bon appetit",
            },
            {
                "synapse x users be like",
                "where my script at",
                "script got executed",
                "by a 2017 exploit",
                "those were the days",
            },
            {
                "nil errors are my passion",
                "attempt to index nil",
                "my favorite error",
                "gets me every time",
            },
            {
                "if u see a syntax error",
                "just run it again",
                "it'll fix itself",
                "trust me bro",
            },
            {
                "the 200 variable limit",
                "is my sleep paralysis demon",
                "i wake up screaming",
                "at 3am thinking about it",
            },
            {
                "when the ui library updates",
                "and everything breaks",
                "i ''love'' rewriting code",
                "said no one ever",
            },
            {
                "print() are too overrated",
                "like bro it's just... idk even know :/",
            },
            {
                "blox fruits players be like",
                "is this for blox fruits",
                "no it's for generic shooters",
                "please learn to read",
            },
            {
                "gaming chair diff fr",
                "i got the 4000$ chair",
                "that's why i never miss",
                "totally not aimbot",
                "or silentaim",
                "or hitbox",
                "or [insert feature here]",
            },
            {
                "csgo players malding",
                "when i hit a 360 no scope",
                "jokes on them",
                "i don't even play csgo",
                "I play Roblox shooters",
                "so as u {displayname}",
            },
            {
                "me and the boys",
                "running the script",
                "and getting banned",
                "worth it every time",
            },
            {
                "shoutout to the devs",
                "that make this possible",
                "we appreciate you",
                "oh wait that's me :v",
            },
            {
                "me debugging at 2am",
                "why isn't it working",
                "oh i forgot a comma",
                "i'm going to sleep",
            },
            {
                "half life 3 confirmed",
                "gravel confirmed it",
                "trust me bro",
                "my uncle works at valve",
            },
            {
                "the script is free",
                "and open source",
                "and has silent aim",
                "what more could you want",
            },
            {
                "i love when the script",
                "works on the first try",
                "that's a lie",
                "it never does",
            },
            {
                "200 variable limit is",
                "my arch nemesis",
                "we have beef",
                "it started in 2024",
            },
            {
                "the script is held together",
                "by pure spite",
                "and caffeine",
                "mostly caffeine",
            },
            {
                "Did you know",
                "Water contains oxygen",
                "so you could breath underwater",
            },
            {
                "is that a hack",
                "no it's a gaming chair",
                "my chair has aimbot",
                "you should get one",
            },
            {
                "Gravel has 0 calories 2 burn",
                "so yeh {displayname} dis is\nwhy gravel can do dis",
            },
            {
                "wait this isn't a virus",
                "i was told it was a virus",
                "it's open source",
                "you can literally read it",
            },
            {
                typesp = "1.5",
                "hey {displayname}",
                "yea u",
                "the one reading this",
                "how's ur day going?",
                "mine's gravely :p",
                "get it?",
                "gravely?",
                "like gravel?",
                "ok i'll stop",
            },
            {
                typesp = "1.5",
                "so uh",
                "{displayname} u ever just",
                "look at a rock",
                "and think 'wow'",
                "that's me",
                "i'm the rock",
                "gravel specifically",
                "nice 2 meet u :3",
            },
            {
                typesp = "2",
                "ur probably using this",
                "to destroy some kids",
                "in a roblox game",
                "i respect that",
                "get rekt nerd >:D",
                "haha i'm just joking",
                "or am i?",
                ";)",
            },
            {
                typesp = "1.5",
                "psst",
                "hey",
                "over here",
                "yea u",
                "wanna know a secret?",
                "gravel is made of",
                "crushed rocks",
                "mind blown :o",
            },
            {
                typesp = "1.5",
                "r u a hacker?",
                "cuz u seem sus",
                "wait i'm the script",
                "i'm literally hacking\nfor u",
                "i'm the sus one",
                "my bad :p",
            },
            {
                "mastermz plzzlz\nshowcase mAh script",
                "plzlzllzllzzzzz",
                "like super duper pleasszz",
            },
            {
                "u ever just",
                "open a script",
                "and it works",
                "first try?",
                "yea me neither",
                "this is like my 50th version",
                "we don't talk about v1\noh yea g.cc dont has versions...",
            },
            {
                typesp = "1.5",
                "if u get banned",
                "don't blame me",
                "i'm just a rock",
                "rocks can't be blamed",
                "it's the law",
                "i think",
                "i didn't read it",
            },
            {
                "what's ur favorite",
                "type of rock?",
                "mine's gravel obv",
                "but igneous is cool too",
                "pumice floats",
                "that's wild",
                "nature is crazy :o",
            },
            {
                typesp = "2",
                "u think ur ready",
                "for the gravel experience?",
                "u think ur ready",
                "for the SILENT AIM??",
                "u think ur ready",
                "for the HITBOX??",
                "probably not :P",
            },
            {
                "some people use aimbot",
                "some people use silent aim",
                "but real ones",
                "use gravel",
                "and a gaming chair",
                "obviously",
            },
            {
                typesp = "1.5",
                "warning:",
                "this script may cause",
                "excessive winning",
                "opponents crying",
                "and accusations",
                "of being a hacker",
                "u have been warned >:D",
            },
            {
                "what do u call",
                "a sad rock?",
                "a crying pebble :(",
                "what do u call",
                "a happy rock?",
                "a gravely boy :D",
            },
            {
                typesp = "1.5",
                "u ever think about",
                "how i'm talking to u",
                "through text",
                "on a screen",
                "in a game",
                "about rocks",
                "life is weird man",
            },
            {
                "if u read this far",
                "u deserve a medal",
                "or a rock",
                "here's a virtual rock",
                "🥔",
                "wait that's a potato",
                "close enough :p",
            },
            {
                typesp = "1.5",
                "gravel's motto:",
                "be rocky",
                "be rough",
                "be resilient",
                "and don't get kicked",
                "by the server",
                "or anticheat",
            },
            {
                "some people use",
                "expensive hacks",
                "we use free ones",
                "and they work better",
                "take that capitalism",
                ":v",
            },
            {
                typesp = "2",
                "u know what's underrated?",
                "the sound of gravel",
                "crunch crunch",
                "satisfying as heck",
                "u can't change my mind",
            },
            {
                "me: 'i'll make a clean script'",
                "also me:",
                "*15000+ lines later*",
                "what is organization?",
                "i don't know her",
                ":s",
            },
            {
                typesp = "1.5",
                "this script contains:",
                " - 100% pure gravel",
                " - premium aim",
                " - secret sauce",
                " - questionable code",
                " - the tears of enemies",
                "read the ingredients",
                "u won't :P",
            },
            {
                typesp = "0.2",
                "I'm typing soooo slowwwww",
                "like super slow",
                "to make u impatient",
            },
            {
                typesp = "5",
                "IM TYPING SUPER DUPER FAST",
                "IM TYPING SO FAST U CANT EVEN",
                "READ ALL OF IT >:D",
                "MWAHAHAHAHAHAHAH",
                "EUGEAUYIQHIFU82-2;1866646649",
                "IVE ALSO SMASHED MAH KEYBOARD",
            },
            {
                "can you tell me ur ssn",
                "like......",
                "I want ur ssn for like....",
                "no reason",
            },
            {
                typesp = "3",
                "i'm not a robot",
                "i'm a gravel",
                "robots are metal",
                "gravel is rock",
                "big difference",
                "checkmate atheists",
                ":v",
            },
            {
                "u ever get so bored",
                "u read script messages",
                "like these?",
                "same tbh",
                "i wrote them",
                "i have no life",
                "respect the grind",
            },
            {
                typesp = "2",
                "u ever try to explain",
                "what gravel is",
                "to someone?",
                " 'it's a script' ",
                " 'for roblox' ",
                " 'with aimbot' ",
                "they never understand",
                "sadge :(",
            },
            {
                "me trying to decide",
                "what feature to add next:",
                "*spins wheel*",
                "it lands on 'more jokes'",
                "so here we are",
                "u're welcome :D",
            },
            {
                typesp = "1.5",
                "if u enjoy this script",
                "tell a friend",
                "if u don't enjoy it",
                "tell a da Robloz support",
                "either way",
                "gravel supports u",
            },
            {
                typesp = "1.5",
                "i love it when",
                "the script loads",
                "and nothing breaks",
                "that's the best feeling",
                "better than winning",
                "better than robux",
                "pure joy",
            },
            {
                "u ever just",
                "silent aim someone",
                "and they go",
                " '??? how' ",
                "and then u say ping diff",
                "well I did that",
            },
            {
                "i'm not saying",
                "gravel is the best",
                "but i'm also not saying",
                "it's NOT the best",
                "so it's the bes but not da best-est",
                "llikee does that make sense?",
            },
            {
                typesp = "1.5",
                "u ever just",
                "accidentally write",
                "a really good feature",
                "and not know how",
                "u did it?",
                "that's most of gravel",
                "happy accidents",
                ":D",
            },
            {
                "i should probably",
                "document this code",
                "but that's future me's",
                "problem",
                "present me wants",
                "to add more jokes",
                "priorities :v",
            },
            {
                typesp = "1.5",
                "if u see me in game",
                "no u didn't",
                "if u see me hacking",
                "no u didn't",
                "if u see me winning",
                "that's just skill",
                "gravel skill",
                ";D",
            },
        },
        defaults = {
            minDelay = 25,
            maxDelay = 85,
            spaceExtraMin = 40,
            spaceExtraMax = 90,
            punctExtraMin = 120,
            punctExtraMax = 250,
            breakChance = 0.05,
            breakExtraMin = 100,
            breakExtraMax = 300,
            messageWaitMin = 10,
            messageWaitMax = 30,
            convoWaitMin = 15,
            convoWaitMax = 35,
            eraseWaitMin = 2,
            eraseWaitMax = 6,
            eraseDelayMin = 15,
            eraseDelayMax = 40,
            cursorBlink = 0.45,
            shuffleWaitMin = 20,
            shuffleWaitMax = 40,
        },
        popz = {
            ":0",
            ":7",
            "my name is gravel what's yours?????",
            "my zodiac sign is a shovel :p",
            "gravel is rocky :o",
            "graveeeeeeeelll",
            ":p",
            ">:3",
            "Gravel is not Sentient idk wat ur talking about",
            "sigmasigmaboug",
            "I'm a rng pop-up that picks random messages 24/7",
            "would dis script work on every gaem\nyh & noe",
            "this script is 10000+ lines... oml :s",
            "the UI ts using is WindUi and the notification is Alurt btw I just found it from ballmart",
            "a free?! keyless?! script?! and open source?! that has silentaim?! wtf",
            "the script is randomly picking messages your not freaking out :p",
            "sorry xeno users or solarara I don't have the supporty support",
            "nononononoonono this script ain't a virus so dat why I made it open src",
            "Is that a gubby?\n\n- kreek",
            "Error ur roblxo isn't support",
            "ooh, nice computer you got their, Can I have it\n\n- Mario virus",
            "something is coming in 3 days\n\n- verity",
            "real",
            "tuff",
            "guhby this guhby that",
            "2 atoms touch = big explosion",
            "you can noclip when your atoms aligned\ntrust",
            "I don't have DC btw",
            "my code is used to be 8000+ now 9000+ and then 15000+ lines long, I canf do dis sh on mobile D:",
            "flatgrass",
            "search free robux to get free robux",
            "alt-f4 = free rboux",
            "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.\n>\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.",
            "^_^",
            "^u^",
            "^v^",
            "half life 3 when?",
            "it's a game called HELLO NEIGHBOR -HEL -HEL -HELHEL-HELLO NE-NEIGH-BOR",
            "FORTYNIGHTY LA PABAJI\npabaji\nPABAJI LA EKES BOKES SERES EKES\npabaji\nPABAJI LA BALESTHONFAIV\nbalesteshon... faiv...\nBALESTHONFAIV LA LUKITIK\nlukitik\nLUKITTIK LA HAYBAR EKES EKES EKES EKES\nhybar ekes ekes ekes ekes\nHYBAR EKES EKES EKES EKES LA GIRANDIFIFDORIGINI\ngirandififdorigini",
            "Did you do your chores?\nyessirski!\nDid you do your chores?\nyessirski\nDid you do your chores?\nyessirski!\nDid you do your chores?\nyessirski\nWhen I get home it better be clean!\nDid you do your chores?\nyessirski!\nOH! BOI WHY DID U LIE TO ME!!!\nAHHHHH",
            "Homework?\nNah!\nHomework?\nNah!\nHomework?\nNah!\nHomework?\ni did it at school\nNah!\nHomework?\nNah!\nHomework?\nNah!\nWHY ARE YOU CLASSES PHAILING\n AHHH D:",
            "Turkey in the Straw!",
            "du bist gut genug...\ndu bist gut genug...\ndu bist gut genug\ndu bist gut genug\n*fire music*",
            "本当に出口はないのか、くる、くる、くる、くる、繰り返し、繰り返し、繰り返し…\n\n\ni ain't writing allat",
            "*Stranger Things Intro*\ndustin lucas will mike...\nBURP",
            "robloz where classic faces :‹",
            "I'm not taking my sneakers off, I'm sneakers O'Toole",
            "Gpssickle is a gps with a sickle",
            "da script reached 8000 lines to 15000 o_o",
            "just simply cheat through it\n\n quite literally",
            "just simply go under it",
            "just simply go over it",
            "just simply script to it",
            "just simply walk around it\n\n- Electracy",
            "You die\n\n- StromBrew",
            "sonion\ni learned this from meme culture don't ask me",
            "I like trains",
            "welcome to McDonald's.",
            "you are my sunshine, my only sunshine",
            "IS THAT SONIC WITH GRAY SHOES D:",
            "Atoms never touch so dat means I didn't steal ur chocolate",
            "Yeah, come gets some you freakin' wuss\n\n- Scout (not Taunt form dod)",
            "sybau 🥀💔",
            "these are meme reference ok",
            "water + ice + melt = water",
            "3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679",
            "1.61803398874989484820458683436563811772030917980576",
            "print(''*prints cutely*'')\nerror(''*errors cutely*'')\nwarn(''*warns cutely*'')",
            "Gravel.cc 🥀",
            "my imagination has been powered",
            "YOU NEVER SEE IT COMIIIIIIINNNG,\nyou'll see that my mind\nis to fast for eyes\nYOUR DONE INNNNNN\nBY THE\ntime is hit you, YOUR LAST SURPRISE",
            "Gpssssssssssssssssssssssssssssssssssssssssickle",
            "global positioning system with a sickle",
            "The golden dandelion which is the golden dandelion",
            "can u remind me the golden ratio next time",
            "y'all think he look like; Steve Harvey?\n *Screams*",
            "/kill @p",
            "HBSS doesn't mean anything lolz\ni typed it randomly...",
            "rbxm",
            "why 'Gravel' ya know how sand gets in ur shoes..\ngravel does the same but it's for games",
            "people barely use the bottab",
            "I hate renderstepped...\n(probably because I keep misusing it)",
            "is it Roblox or roadblocks or robloz who knows",
            "''Does this work in Minecraft''",
            "www.gravel.com ... why does this website exists?",
            "imagine ur script getting mogged by a script made fully on a phone",
            "dere is no Terraria final update D:",
            "da cake isnt a lie... trust",
            "iS ThAt ga hÆcker?????!?!?!!!?!???!?!",
            "y is this drooling cat meme all over my fyp D:",
            "tbh bro I'd go; [insert metalpipefalling.gif]",
            "gravel vs sand vs rock vs thingamajang",
            "GTA 6 when?",
            "if they said ur a hacker say 'Ping Diff' and they'll believe u",
            "w wedgeey 🥺\nw junglescripts 🥺",
            "sand.cc when?",
            "what version is this? well I don't fking know lol",
            "scirpotjg iz hard :(",
            "Roblox plz collabl",
            "helloworld(''print'')",
            "Markiplier & Larpiplier collab when?",
            "61? 67?\nit's time for the letters to have fun\nabcdefghijklmnop\nL-M-N-O-P\nP\nP\nP\nP",
            "hello whoever you are :D\ni don't have the capacity to see your usernames yet because I'm too lazy to script dat in\noh wait ur name is " .. lp_info.lp_displayname .. "\n cool name!",
            "me is want chat roblox not age verif",
            "this script isn't full ban proof so if you get banned DON'T blame on us when your using risky features :/",
            "deres like idk amount of random messages I contains lolz",
        },
        popz2 = {
            "wth is ts",
            "hell nah",
            "OHHHH HELLL NAH",
            "pop-up goes bye bye",
            "isn't phonk just noise?",
            "guys it's a-a, a-a h-hacker!?!?!",
            "tiki tiki",
            "Nosirski!",
            "[Eminem Throwing Meme.png]",
            "why am I writing ts?",
            "idk, sterling?",
            "is that a toby?",
            "click here or ur gay",
            "lolzer-fying",
        },
        popz3 = {
            "helohi",
            "meeeeeoow :3 .... MAW >:3",
            "Bang, Bang, Bang",
            "20-20-20 Gugu Gaga dropkick",
            "portal above portal below *jumps in*",
            "Gugu Gaga Ultimated Flex Works",
            "can gravel run doom?",
            "ipad kid vs ipad, who would win?",
            "ifone 90 proe max",
            "image me missing one ',' on a large table..",
            "Gravel supports Android 5-",
            "your bluetooth device is ready to pair",
            "why is there ai slop on my TikTok fyp....",
            ":3 >:3 ›:3 :3",
        },
        tinf = {
            "bombastic side eye",
            "oh shiddings nott gud D:",
            "67 vs 67",
            "what's yer zodiac sign",
            "hi I'm a rng",
            "what's a brainfuck :s",
            "Gravel.cc says be gravel",
            "tag ur it",
            "shimmy ey shimmy yaaa",
            "so many references :o",
            "me wants grabel :(",
            "life never made lemons...",
            "01001000 01101001",
            "whoz dat",
            "roblox is no longer robloz",
            "user :3",
            "water",
            "GRAVEL-MAN",
            "IM SKYLER WHITE, YO",
            "my diet is gravel",
            "6761694203602048",
            "ur definitely using delta cuz idk",
            "dab me up :>",
            "how much saves do u has",
            "O rly",
            ":3",
            "lololololooloo",
        },
        tinf2 = {
            "rbxassetid://128670966889578",
            "rbxassetid://132214308111067",
            "rbxassetid://72509803293342",
            "rbxassetid://130435138559679",
            "rbxassetid://127155823074936",
            "rbxassetid://126485931781624",
        },
        tinf3 = {
    	    "rbxassetid://72298953503422",
    	    "rbxassetid://17608357332",
           "rbxassetid://130776885039264",
           "rbxassetid://6303045144",
           "rbxassetid://101513669346450",
           "rbxassetid://17748195478",
           "rbxassetid://17517499979",
           "rbxassetid://119888856502065",
        },
        uwu = {
            "rbxassetid://72298953503422",
            "rbxassetid://17608357332",
            "rbxassetid://130776885039264",
            "rbxassetid://6303045144",
            "rbxassetid://101513669346450",
            "rbxassetid://17748195478",
            "rbxassetid://17517499979",
        },
        descs = {
            Main = {
                "y u touching my brain",
                "brain goes brrr",
                "main stuffz",
                "da core settings",
                "trust me i know what im doing",
                "settings go here!",
                "don't touch unless you know what ur doing",
                "gravels shovel",
                "the real tab",
                "where da magic happens",
                "hehe settings go brr",
                "u have no idea what ur doing",
                "baaa",
                "it's big brain time.",
                "pls be careful D:",
                "yolo toggle it all",
                "main main main main",
                "core settings 4 core ppl",
                "don't blame me if u break stuff",
                "folk",
                "read da text vro :1",
            },
            Visuals = {
                "4 the blind ppl",
                "oooh shiny",
                "make game look cool",
                "ESP go brrrrrr",
                "seeing ppl through walls :o",
                "visuals for da win",
                "colorful stuff",
                "vision 1+",
                "walls are just suggestion",
                "make em glow",
                "I can see china from here!1!",
                "see everything",
                "game looks different now",
                "seekify",
                "your eyes will thank u",
                "wallhack energy",
                "highlight da enemies",
                "rainbow vibes",
                "visibility is key",
                "what walls?",
                "xray vision activated",
                "visuals go crazy"
            },
            AntiAim = {
                "I suck at dodging tab",
                "dodge master 3000",
                "u cant hit me >:3",
                "evasion tactics",
                "why can't I hit u",
                "they cant touch this",
                "pew = miss",
                "anti-getting-shot",
                "hit me if u can",
                "can't touch this",
                "matrix mode",
                "teleports behind u",
                "nothing personnel kid",
                "dodgeball champion",
                "good luck hitting me",
                "disappear",
                "now u see me, now u dont",
                "trust im legit dodging",
            },
            Aimbot = {
                "aimware-ing",
                "lock on target",
                "no mouse movement aim tab",
                "i legit never miss",
                "accuracy 1+",
                "headshot da kidz",
                "gaming chair mode",
                "crosshair magnet",
                "technically aim assist",
                "aimlabs? never heard of her",
                "perfect aim every time",
                "aim at thing",
                "precision inc",
                "never miss u again",
                "ur aim is insane",
                "holeh aimbot",
                "aimbot go crazy"
            },
            ["SilentAim (HB)"] = {
                "hitbox x aimbot x silentaim x bullet tracker",
                "Hitbox cousin",
                "SilentAim & Hitbox made a baby",
                "ssshhh its a secret",
                "unaim-ful",
                "where are you aiming at??",
                "secret sauce"
            },
            ["SilentAim (HK)"] = {
                "I'm the better option sonionster",
                "hook-based baby",
                "the true silent aim",
                "raycast torture",
                "the better silentsilentaim",
                "raycast go brrr",
                "uncatchable",
                "legit looking I think..",
                "aimbot 2.0",
                "aim-ster",
            },
            Hitbox = {
                "it's hitbox not HURTBOX D:<",
                "size matters",
                "make em bigger",
                "expansion pack",
                "hitbox go chud mode",
                "bigger is better",
                "easy mode",
                "bro what's that hitbox",
                "sizely",
                "bigger hitbox bigger fun",
                "they cant dodge",
                "hurtbox",
                "making targets fatter",
                "hurt big box",
                "big blob",
            },
            Reach = {
                "1+1= √4",
                "long arms",
                "stretchy arms",
                "extendo reach",
                "touch things far away",
                "long distance relationship",
                "can i touch u from here :3",
                "extendo mode",
                "range extender",
                "COME TO BRAZIL",
                "touchy touchy",
                "stretch armstrong",
                "big reach modeldh",
                "reach around",
                "long arms gng🥀",
                "kill aura for sowrds"
            },
            Client = {
                "I don't hold the serverside blud",
                "GOTTA GO FAST",
                "I'm in a sugar rush",
                "due to my gaming chair",
                "client the client of client",
            },
            Miscellaneous = {
                "random bs go!!!🔥🔥🔥🔥",
                "the leftovers",
                "extra stuff",
                "bruh stuff",
                "random stuff my brain made",
                "the rest of em",
                "thingamabob",
                "experimental features",
                "za-silly",
                "wha",
                "hidden gems",
                "ragebait here",
                "randomness",
                "kiss me misc :3",
                "extra goodies",
            },
            BGM = {
                "musssiccc :3",
                "it's super loud here",
                "make g.cc louder",
                "[insert noises]",
                "bgm = background music",
                "y is there boss music?",
                "FIRE SONG >:D",
                "music player technically",
                "rbxassetid music",
                "my fav is kwikflip",
                "angry bird ear meme",
                "bgmmmm type shi",
                "I keep saying bmg",
                "gravel needs music fr",
                "nice music taste",
                ">:P",
                "me wants music :3",
            },
            Info = {
                "show me da papperz",
                "the knowledge",
                "read me.txt",
                "info-man",
                "VRO HELP ME OUT",
                "what is this",
                "guide time",
                "ENLIGHTEN ME",
                "*monkeg vs lion meme*",
                "i can't understand ts 🥀😔",
                "credits and stuff",
                "dictionary",
                "how to use roadblocked",
                "info urself",
                "wtf is this script",
                "SPY???"
            }
        },
        easterTitles = {
            "Gravel.egg",
            "gravel.easteeeeerrr",
            "Gravel.eggcellent",
            "Gravel.ILikeEgg",
            "hunting 4 da gravel",
            "easter shovel",
        },
        defaultTitles = {
            "Gravel.cc",
            "G.cc",
            "HBSS.cc",
            "Gravel-est",
            "Gravel-er",
            "Graaaavel.cc",
            "Gravelly.cc",
            "Gravel.com",
            "Hi! I'm Gravel.cc",
            "Gravel enjoyer",
            "GRAVEL.CC >:D",
            "holy gravel.cc",
            "GravelGravelGravel.cc",
            "I like gravel",
            "Gravel.cheatcheat",
            "Gravel.yes",
            "Gravel.no",
            "Gravel.lua",
            "GRAVEL GRAVEL.CC",
        },
        aprilFools = { 
            "Sand.cc",
            "Aimware",
            "Neverlose",
            "RIBLOX MOD MENU 🔥🔥🔥",
            "u got pranked",
            "Gravel is sand",
            "not gravel",
            "Dirt.cc",
            "Flour.cc",
            "Brick.cc 2.0",
            "I'm quitting (I think....)",
            "CrushedStone.cc",
            "cc.levarG",
            "grvel",
            "Enrique.cc",
            "Adrian.cc",
        },
        savesParagraph = nil,
        wasEnabledBeforeDeath = false,
        wasESPEnabledBeforeDeath = false,
        respawnLock = false,
        aimbot360LoopRunning = false,
        aimbot360LoopTask = nil,
        lastTargetUpdate = 0,
        triggerBotConnection = nil,
        sa2thing = 0,
        sa2stuff = 0.5,
        sa2this = false,
        spinbotConnection = nil,
        ViewConnection = nil,
        CameraDistance = 8,
        lowpatcherwait = 0.03,
        lowpatcher = true,
        patcherwait = 0.5,
        patcher = true,
        bhopConnection = nil,
        bhopQuickToggleUI = nil,
        lastJumpTime = 0,
        errors = true,
        Rng5stuff = nil,
        Rng3dis = {},
        orgfov = nil,
    },
    Gradow = {
        textcursor = "_",
        textcursor2 = "  ",
        uianimate = {
            connection = nil,
            basePosition = nil,
            lastPosition = Vector3.new(0, 0, 0),
            movementOffset = 0,
            smoothOffset = 0,
            pulseSpeed = 0.02,
            minThickness = 0.80,
            maxThickness = 2,
            targetRotation = 0,
            currentRotation = 0,
            windowTargetRotation = 0,
            windowCurrentRotation = 0,
            windowInitialThickness = nil,
            openButton = nil,
            windowFrame = nil,
            openStroke = nil,
            openGradient = nil,
            windowStroke = nil,
            windowGradient = nil
        },
        uicolor = {
            lightGreen = Color3.fromRGB(144, 238, 144),
            darkGray = Color3.fromRGB(40, 40, 40),
            lightGray = Color3.fromRGB(200, 200, 200),
            Red = Color3.fromRGB(255, 0, 0),
            Blue = Color3.fromRGB(175, 221, 255),
            Black = Color3.fromRGB(0, 0, 0)
        },
        windowSize = {
            mobile = UDim2.fromOffset(650, 79),
            tablet = UDim2.fromOffset(600, 80),
            pc = UDim2.fromOffset(800, 70)
        }
    }
}
]]

    local lines = {}
    for line in configCode:gmatch("[^\n]*\n?") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end

    local lineHeight = 18
    local totalHeight = #lines * lineHeight
    codeScroller.CanvasSize = UDim2.fromOffset(0, totalHeight + 100)

    local yPos = 10
    for _, line in ipairs(lines) do
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.fromScale(1, 0)
        textLabel.Position = UDim2.fromOffset(10, yPos)
        textLabel.Size = UDim2.fromOffset(self.codeBackground.AbsoluteSize.X - 20, lineHeight)
        textLabel.Text = line
        textLabel.Font = Enum.Font.Code
        textLabel.TextSize = 11
        textLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        textLabel.TextTransparency = 0.85
        textLabel.BackgroundTransparency = 1
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = codeScroller
        yPos = yPos + lineHeight
    end

    local center = Instance.new("Frame")
    center.Size = UDim2.fromScale(0.3, 0.25)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.BackgroundTransparency = 1
    center.ZIndex = 2
    center.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(1, 0.35)
    title.Position = UDim2.fromScale(0.5, 0.2)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Text = "initializing"
    title.Font = Enum.Font.Code
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextTransparency = 0
    title.BackgroundTransparency = 1
    title.ZIndex = 3
    title.Parent = center
    self.title = title

    local status = Instance.new("TextLabel")
    status.Size = UDim2.fromScale(1, 0.3)
    status.Position = UDim2.fromScale(0.5, 0.55)
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Text = "fetching random asset files..."
    status.Font = Enum.Font.Code
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(150, 150, 150)
    status.TextTransparency = 0
    status.BackgroundTransparency = 1
    status.ZIndex = 3
    status.Parent = center
    self.status = status

    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.fromScale(1, 0.3)
    dots.Position = UDim2.fromScale(0.5, 0.8)
    dots.AnchorPoint = Vector2.new(0.5, 0.5)
    dots.Text = ""
    dots.Font = Enum.Font.Code
    dots.TextSize = 18
    dots.TextColor3 = Color3.fromRGB(200, 200, 200)
    dots.TextTransparency = 0
    dots.BackgroundTransparency = 1
    dots.ZIndex = 3
    dots.Parent = center
    self.dots = dots

    self:startAnimations()
    return self
end

function InitGui:startAnimations()
    self.dotTask = task.spawn(function()
        while self.gui and self.gui.Parent do
            self.dotCount = (self.dotCount % 3) + 1
            self.dots.Text = string.rep(".", self.dotCount)
            task.wait(0.35)
        end
    end)

    self.statusTask = task.spawn(function()
        local lastChange = 0
        while self.gui and self.gui.Parent do
            local elapsed = tick() - lastChange
            if elapsed > math.random(8, 18) / 10 then
                local newMsg = self.statusMessages[math.random(1, #self.statusMessages)]
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
            end
            task.wait(0.1)
        end
    end)

    self.scrollTask = task.spawn(function()
        if not self.codeScroller then return end
        local canvasHeight = self.codeScroller.CanvasSize.Y.Offset
        local startPos = 0
        local speed = 500
        
        while self.gui and self.gui.Parent do
            startPos = startPos + speed * 0.03
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
    end
end
local initGui = InitGui.new():create()
getgenv().destroyInitGui = function()
    if initGui then
        initGui:destroy()
        initGui = nil
    end
end
getgenv().InitGui_ = initGui
