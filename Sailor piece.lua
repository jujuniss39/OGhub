--[[
    Script Name: Sailor Piece Utility
    Version: 2.0 (Improved)
    Note: Use at your own risk
]]

if getgenv().taolao_Running then
    warn("Script already running!")
    return
end

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0

-- ========== UTILITY FUNCTIONS ==========
local function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
getgc = missing("function", getgc or get_gc_objects)
getconnections = missing("function", getconnections or get_signal_cons)

-- ========== SERVICES ==========
local Services = setmetatable({}, {
    __index = function(self, name)
        local success, cache = pcall(function()
            return cloneref(game:GetService(name))
        end)
        if success then
            rawset(self, name, cache)
            return cache
        else
            error("Invalid Service: " .. tostring(name))
        end
    end
})

local Players = Services.Players
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local PGui = Plr:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")
local RS = Services.ReplicatedStorage
local RunService = Services.RunService
local HttpService = Services.HttpService
local TeleportService = Services.TeleportService
local Marketplace = Services.MarketplaceService
local UIS = Services.UserInputService
local VirtualUser = Services.VirtualUser

-- ========== EXECUTOR DETECTION ==========
local executorName = (identifyexecutor and identifyexecutor() or "Unknown"):lower()
local isXeno = string.find(executorName, "xeno") ~= nil

-- ========== LIBRARY LOAD ==========
local repo = "https://raw.githubusercontent.com/gix314/arigato/refs/heads/main/Utilities/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

getgenv().taolao_Running = true

-- ========== CONFIGURATION ==========
local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

-- ========== SUPPORT CHECK ==========
local Support = {
    Webhook = (typeof(request) == "function" or typeof(http_request) == "function"),
    Clipboard = (typeof(setclipboard) == "function"),
    FileIO = (typeof(writefile) == "function" and typeof(isfile) == "function"),
    QueueOnTeleport = (typeof(queue_on_teleport) == "function"),
    Connections = (typeof(getconnections) == "function"),
    FPS = (typeof(setfpscap) == "function"),
    Proximity = (typeof(fireproximityprompt) == "function"),
}

-- ========== SHARED VARIABLES ==========
local Shared = {
    GlobalPrio = "FARM",
    Farm = true,
    Recovering = false,
    MovingIsland = false,
    Island = "",
    Target = nil,
    KillTick = 0,
    TargetValid = false,
    QuestNPC = "",
    MobIdx = 1,
    AllMobIdx = 1,
    WeapRotationIdx = 1,
    ComboIdx = 1,
    ParsedCombo = {},
    RawWeapCache = { Sword = {}, Melee = {} },
    ActiveWeap = "",
    ArmHaki = false,
    InventorySynced = false,
    Stats = {},
    Settings = {},
    GemStats = {},
    SkillTree = { Nodes = {}, Points = 0 },
    Passives = {},
    UpBlacklist = {},
    MerchantBusy = false,
    LocalMerchantTime = 0,
    LastTimerTick = tick(),
    MerchantExecute = false,
    FirstMerchantSync = false,
    CurrentStock = {},
    LastM1 = 0,
    LastWRSwitch = 0,
    LastSwitch = { Title = "", Rune = "" },
    LastBuildSwitch = 0,
    LastDungeon = 0,
    AltDamage = {},
    AltActive = false,
    TradeState = {},
}

-- ========== TABLES ==========
local Tables = {
    AscendLabels = {},
    DiffList = {"Normal", "Medium", "Hard", "Extreme"},
    MobList = {},
    MiniBossList = {"ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss"},
    BossList = {},
    AllBossList = {},
    AllNPCList = {},
    SummonList = {},
    OtherSummonList = {"StrongestHistory", "StrongestToday", "Rimuru", "Anos", "TrueAizen"},
    Weapon = {"Melee", "Sword", "Power"},
    MerchantList = {},
    ValentineMerchantList = {},
    Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"},
    CraftItemList = {"SlimeKey", "DivineGrail"},
    UnlockedTitle = {},
    TitleCategory = {"None", "Best EXP", "Best Money & Gem", "Best Luck", "Best DMG"},
    TitleList = {},
    BuildList = {"1", "2", "3", "4", "5", "None"},
    TraitList = {},
    RaceList = {},
    ClanList = {},
    RuneList = {"None"},
    SpecPassive = {},
    GemStat = {},
    GemRank = {},
    OwnedWeapon = {},
    AllOwnedWeapons = {},
    OwnedAccessory = {},
    QuestlineList = {},
    OwnedItem = {},
    IslandList = {"Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", "HuecoMundo", "Boss", "Dungeon", "Shinjuku", "Valentine", "Slime", "Academy", "Judgement", "SoulSociety"},
    NPC_QuestList = {"DungeonUnlock", "SlimeKeyUnlock"},
    NPC_MiscList = {"Artifacts", "Blessing", "Enchant", "SkillTree", "Cupid", "ArmHaki", "Observation", "Conqueror"},
    DungeonList = {"CidDungeon", "RuneDungeon", "DoubleDungeon", "BossRush"},
    MobToIsland = {}
}

-- ========== HELPER FUNCTIONS ==========
local function GetCharacter()
    local c = Plr.Character
    return (c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid")) and c or nil
end

local function GetServiceNPC(name)
    local path = workspace:WaitForChild('ServiceNPCs')
    return path:FindFirstChild(name)
end

local function SafeTeleportToNPC(targetName)
    local character = GetCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local target = workspace:FindFirstChild(targetName) or GetServiceNPC(targetName)
    if target then
        root.CFrame = target:GetPivot() * CFrame.new(0, 3, 0)
        root.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0)
    end
end

local function GetRemote(parent, pathString)
    local current = parent
    for _, name in ipairs(pathString:split(".")) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

-- ========== REMOTES ==========
local Remotes = {
    TP_Portal = GetRemote(RS, "Remotes.TeleportToPortal"),
    UseItem = GetRemote(RS, "Remotes.UseItem"),
    EquipWeapon = GetRemote(RS, "Remotes.EquipWeapon"),
    M1 = GetRemote(RS, "CombatSystem.Remotes.RequestHit"),
    UseSkill = GetRemote(RS, "AbilitySystem.Remotes.RequestAbility"),
    ArmHaki = GetRemote(RS, "RemoteEvents.HakiRemote"),
    ObserHaki = GetRemote(RS, "RemoteEvents.ObservationHakiRemote"),
    ConquerorHaki = GetRemote(RS, "Remotes.ConquerorHakiRemote"),
    AddStat = GetRemote(RS, "RemoteEvents.AllocateStat"),
    QuestAccept = GetRemote(RS, "RemoteEvents.QuestAccept"),
    QuestAbandon = GetRemote(RS, "RemoteEvents.QuestAbandon"),
    ReqInventory = GetRemote(RS, "Remotes.RequestInventory"),
    OpenMerchant = GetRemote(RS, "Remotes.MerchantRemotes.OpenMerchantUI"),
    MerchantBuy = GetRemote(RS, "Remotes.MerchantRemotes.PurchaseMerchantItem"),
    SummonBoss = GetRemote(RS, "Remotes.RequestSummonBoss"),
    RerollSingleStat = GetRemote(RS, "Remotes.RerollSingleStat"),
    Roll_Trait = GetRemote(RS, "RemoteEvents.TraitReroll"),
    TraitAutoSkip = GetRemote(RS, "RemoteEvents.TraitUpdateAutoSkip"),
    TraitConfirm = GetRemote(RS, "RemoteEvents.TraitConfirm"),
    Enchant = GetRemote(RS, "Remotes.EnchantAccessory"),
    Blessing = GetRemote(RS, "Remotes.BlessWeapon"),
    SkillTreeUpgrade = GetRemote(RS, "RemoteEvents.SkillTreeUpgrade"),
    Ascend = GetRemote(RS, "RemoteEvents.RequestAscend"),
    ReqAscend = GetRemote(RS, "RemoteEvents.GetAscendData"),
    CloseAscend = GetRemote(RS, "RemoteEvents.CloseAscendUI"),
    EquipTitle = GetRemote(RS, "RemoteEvents.TitleEquip"),
    TitleUnequip = GetRemote(RS, "RemoteEvents.TitleUnequip"),
    EquipRune = GetRemote(RS, "Remotes.EquipRune"),
    LoadoutLoad = GetRemote(RS, "RemoteEvents.LoadoutLoad"),
    OpenDungeon = GetRemote(RS, "Remotes.RequestDungeonPortal"),
    SpecPassiveReroll = GetRemote(RS, "RemoteEvents.SpecPassiveReroll"),
    SpecPassiveSkip = GetRemote(RS, "RemoteEvents.SpecPassiveUpdateAutoSkip"),
    ArtifactUnequip = GetRemote(RS, "RemoteEvents.ArtifactUnequip"),
    ArtifactEquip = GetRemote(RS, "RemoteEvents.ArtifactEquip"),
    ArtifactLock = GetRemote(RS, "RemoteEvents.ArtifactLock"),
    ArtifactClaim = GetRemote(RS, "RemoteEvents.ArtifactMilestoneClaimReward"),
    MassDelete = GetRemote(RS, "RemoteEvents.ArtifactMassDeleteByUUIDs"),
    MassUpgrade = GetRemote(RS, "RemoteEvents.ArtifactMassUpgrade"),
}

-- ========== MODULES ==========
local Modules = {
    Quests = require(RS.Modules.QuestConfig),
    Trait = require(RS.Modules.TraitConfig),
    Race = require(RS.Modules.RaceConfig),
    Clan = require(RS.Modules.ClanConfig),
    Stats = require(RS.Modules.StatRerollConfig),
    ItemRarity = require(RS.Modules.ItemRarityConfig),
    Title = require(RS.Modules.TitlesConfig),
    SpecPassive = require(RS.Modules.SpecPassiveConfig),
}

-- ========== UPDATE FUNCTIONS ==========
local function UpdateNPCLists()
    local path = workspace:WaitForChild('NPCs')
    table.clear(Tables.MobList)
    
    for _, v in pairs(path:GetChildren()) do
        local cleanName = v.Name:gsub("%d+$", "")
        if not cleanName:find("Boss") then
            table.insert(Tables.MobList, cleanName)
        end
    end
    table.sort(Tables.MobList)
    
    if Options.SelectedMob then
        Options.SelectedMob:SetValues(Tables.MobList)
    end
end

local function UpdateAllEntities()
    table.clear(Tables.AllEntitiesList)
    local path = workspace:WaitForChild('NPCs')
    local unique = {}
    
    for _, v in pairs(path:GetChildren()) do
        local cleanName = v.Name:gsub("%d+$", "")
        if not unique[cleanName] then
            unique[cleanName] = true
            table.insert(Tables.AllEntitiesList, cleanName)
        end
    end
    table.sort(Tables.AllEntitiesList)
end

-- ========== POPULATE LISTS ==========
Tables.GemStat = Modules.Stats.StatKeys
Tables.GemRank = Modules.Stats.RankOrder

for name, _ in pairs(Modules.Trait.Traits) do 
    table.insert(Tables.TraitList, name) 
end
table.sort(Tables.TraitList)

for name, _ in pairs(Modules.Race.Races) do 
    table.insert(Tables.RaceList, name) 
end
table.sort(Tables.RaceList)

for name, _ in pairs(Modules.Clan.Clans) do 
    table.insert(Tables.ClanList, name) 
end
table.sort(Tables.ClanList)

for name, _ in pairs(Modules.SpecPassive.Passives) do
    table.insert(Tables.SpecPassive, name)
end
table.sort(Tables.SpecPassive)

for k, _ in pairs(Modules.Quests.Questlines) do
    table.insert(Tables.QuestlineList, k)
end
table.sort(Tables.QuestlineList)

-- ========== REMOTE EVENT HANDLERS ==========
if Remotes.ReqInventory then
    Remotes.ReqInventory.OnClientEvent:Connect(function(category, data)
        Shared.InventorySynced = true
        if category == "Items" then
            Shared.CachedInv = data or {}
            table.clear(Tables.OwnedItem)
            for _, item in pairs(data) do
                table.insert(Tables.OwnedItem, item.name)
            end
            table.sort(Tables.OwnedItem)
        elseif category == "Runes" then
            table.clear(Tables.RuneList)
            table.insert(Tables.RuneList, "None")
            for name, _ in pairs(data) do
                table.insert(Tables.RuneList, name)
            end
            table.sort(Tables.RuneList)
        end
    end)
end

if Remotes.SpecPassiveSkip then
    Remotes.SpecPassiveSkip.OnClientEvent:Connect(function(data)
        if type(Shared.Passives) ~= "table" then Shared.Passives = {} end
        if data and data.Passives then
            for weaponName, info in pairs(data.Passives) do
                Shared.Passives[weaponName] = info
            end
        end
    end)
end

-- ========== CORE FUNCTIONS ==========
local function GetBestMobCluster(mobNamesDictionary)
    local allMobs = {}
    local path = workspace:WaitForChild('NPCs')
    
    for _, npc in pairs(path:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            local cleanName = npc.Name:gsub("%d+$", "")
            if mobNamesDictionary[cleanName] then
                table.insert(allMobs, npc)
            end
        end
    end
    
    if #allMobs == 0 then return nil end
    
    local bestMob = allMobs[1]
    local maxNearby = 0
    
    for _, mobA in ipairs(allMobs) do
        local nearbyCount = 0
        local posA = mobA:GetPivot().Position
        
        for _, mobB in ipairs(allMobs) do
            if (posA - mobB:GetPivot().Position).Magnitude <= 35 then
                nearbyCount = nearbyCount + 1
            end
        end
        
        if nearbyCount > maxNearby then
            maxNearby = nearbyCount
            bestMob = mobA
        end
    end
    
    return bestMob
end

local function GetMobTarget()
    if not Toggles.MobFarm.Value then return nil end
    
    local selectedDict = Options.SelectedMob.Value or {}
    local enabledMobs = {}
    
    for mob, enabled in pairs(selectedDict) do
        if enabled then table.insert(enabledMobs, mob) end
    end
    table.sort(enabledMobs)
    
    if #enabledMobs == 0 then return nil end
    
    if Shared.MobIdx > #enabledMobs then Shared.MobIdx = 1 end
    
    local targetMobName = enabledMobs[Shared.MobIdx]
    local target = GetBestMobCluster({[targetMobName] = true})
    
    if target then
        return target
    else
        Shared.MobIdx = Shared.MobIdx + 1
        return nil
    end
end

local function ExecuteFarmLogic(target)
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not target or Shared.Recovering or not root then return end
    
    local targetPos = target:GetPivot().Position
    local distVal = tonumber(Options.Distance.Value) or 12
    local finalPos = (target:GetPivot() * CFrame.new(0, 0, distVal)).Position
    
    if (root.Position - finalPos).Magnitude > 5 then
        root.CFrame = CFrame.lookAt(finalPos, targetPos)
    end
    
    root.AssemblyLinearVelocity = Vector3.zero
    
    local m1Delay = tonumber(Options.M1Speed.Value) or 0.2
    if tick() - Shared.LastM1 >= m1Delay then
        pcall(function()
            Remotes.M1:FireServer()
        end)
        Shared.LastM1 = tick()
    end
end

local function EquipWeapon()
    local char = GetCharacter()
    if not char then return end
    
    local weapons = {}
    for _, tool in pairs(Plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(weapons, tool.Name)
        end
    end
    
    if #weapons == 0 then return end
    
    if Shared.WeapRotationIdx > #weapons then Shared.WeapRotationIdx = 1 end
    Shared.ActiveWeap = weapons[Shared.WeapRotationIdx]
    
    if not char:FindFirstChild(Shared.ActiveWeap) then
        local tool = Plr.Backpack:FindFirstChild(Shared.ActiveWeap)
        if tool and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:EquipTool(tool)
        end
    end
    
    Shared.WeapRotationIdx = Shared.WeapRotationIdx + 1
end

-- ========== UI CREATION ==========
local Window = Library:CreateWindow({
    Title = "Sailor Piece Utility",
    Footer = "Improved Version | Use Responsibly",
    NotifySide = "Right",
    ShowCustomCursor = false,
    AutoShow = true,
    Center = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "box"),
    Player = Window:AddTab("Player", "user"),
    Teleport = Window:AddTab("Teleport", "map-pin"),
    Misc = Window:AddTab("Misc", "apple"),
    Config = Window:AddTab("Config", "cog"),
}

-- ========== MAIN TAB ==========
local MainGroup = Tabs.Main:AddLeftGroupbox("Autofarm", "target")

MainGroup:AddDropdown("SelectedMob", {
    Text = "Select Mob (s)",
    Values = Tables.MobList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

MainGroup:AddButton("Refresh Mobs", UpdateNPCLists)

MainGroup:AddToggle("MobFarm", {
    Text = "Auto Farm Selected Mob",
    Default = false,
})

MainGroup:AddToggle("AllMobFarm", {
    Text = "Auto Farm All Mobs",
    Default = false,
})

MainGroup:AddDivider()

MainGroup:AddToggle("LevelFarm", {
    Text = "Auto Farm Level",
    Default = false,
})

MainGroup:AddDivider()

MainGroup:AddSlider("M1Speed", {
    Text = "M1 Attack Speed (seconds)",
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
})

MainGroup:AddSlider("Distance", {
    Text = "Farm Distance",
    Default = 12,
    Min = 5,
    Max = 30,
    Rounding = 0,
})

MainGroup:AddToggle("IslandTP", {
    Text = "Auto Island Teleport",
    Default = true,
})

-- ========== SKILL TAB ==========
local SkillGroup = Tabs.Main:AddRightGroupbox("Skills", "sword")

SkillGroup:AddToggle("AutoM1", {
    Text = "Auto Attack",
    Default = false,
})

SkillGroup:AddToggle("AutoSkill", {
    Text = "Auto Use Skills",
    Default = false,
})

SkillGroup:AddDropdown("SelectedSkills", {
    Text = "Select Skills",
    Values = {"Z", "X", "C", "V", "F"},
    Default = {"Z", "X", "C", "V"},
    Multi = true,
})

SkillGroup:AddToggle("OnlyTarget", {
    Text = "Use Skills Only When Targeting",
    Default = true,
})

SkillGroup:AddDivider()

SkillGroup:AddToggle("AutoHaki", {
    Text = "Auto Armament Haki",
    Default = false,
})

-- ========== PLAYER TAB ==========
local PlayerGroup = Tabs.Player:AddLeftGroupbox("Movement", "running")

local ws_toggle, ws_slider = PlayerGroup:AddSliderToggle("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 250,
})

local jp_toggle, jp_slider = PlayerGroup:AddSliderToggle("JumpPower", {
    Text = "Jump Power",
    Default = 50,
    Min = 0,
    Max = 500,
})

PlayerGroup:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
})

PlayerGroup:AddToggle("AntiKnockback", {
    Text = "Anti Knockback",
    Default = false,
})

local PlayerVisualGroup = Tabs.Player:AddRightGroupbox("Visual", "eye")

PlayerVisualGroup:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
})

PlayerVisualGroup:AddToggle("NoFog", {
    Text = "No Fog",
    Default = false,
})

local fps_toggle, fps_slider = PlayerVisualGroup:AddSliderToggle("FPSLimit", {
    Text = "Set Max FPS",
    Default = 60,
    Min = 30,
    Max = 360,
    Disabled = not Support.FPS,
})

PlayerVisualGroup:AddToggle("FPSBoost", {
    Text = "FPS Boost",
    Default = false,
})

-- ========== TELEPORT TAB ==========
local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("Island Teleport", "map")

TeleportGroup:AddDropdown("SelectedIsland", {
    Text = "Select Island",
    Values = Tables.IslandList,
    Default = nil,
    Callback = function(value)
        if value and Remotes.TP_Portal then
            Remotes.TP_Portal:FireServer(value)
        end
    end
})

TeleportGroup:AddDivider()

TeleportGroup:AddDropdown("SelectedNPC", {
    Text = "Select NPC",
    Values = Tables.NPC_QuestList,
    Default = nil,
    Callback = function(value)
        if value then SafeTeleportToNPC(value) end
    end
})

-- ========== MISC TAB ==========
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Auto Rolls", "dice")

MiscGroup:AddDropdown("SelectedTrait", {
    Text = "Target Trait (s)",
    Values = Tables.TraitList,
    Default = nil,
    Multi = true,
})

MiscGroup:AddToggle("AutoTrait", {
    Text = "Auto Roll Trait",
    Default = false,
})

MiscGroup:AddDropdown("SelectedRace", {
    Text = "Target Race (s)",
    Values = Tables.RaceList,
    Default = nil,
    Multi = true,
})

MiscGroup:AddToggle("AutoRace", {
    Text = "Auto Roll Race",
    Default = false,
})

MiscGroup:AddDropdown("SelectedClan", {
    Text = "Target Clan (s)",
    Values = Tables.ClanList,
    Default = nil,
    Multi = true,
})

MiscGroup:AddToggle("AutoClan", {
    Text = "Auto Roll Clan",
    Default = false,
})

MiscGroup:AddSlider("RollDelay", {
    Text = "Roll Delay (seconds)",
    Default = 0.3,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
})

-- ========== AUTO STATS ==========
local StatsGroup = Tabs.Misc:AddRightGroupbox("Auto Stats", "chart-line")

StatsGroup:AddDropdown("SelectedStats", {
    Text = "Select Stats",
    Values = {"Melee", "Defense", "Sword", "Power"},
    Default = {"Melee", "Defense", "Sword", "Power"},
    Multi = true,
})

StatsGroup:AddToggle("AutoStats", {
    Text = "Auto Allocate Stats",
    Default = false,
})

StatsGroup:AddDivider()

StatsGroup:AddToggle("AutoSkillTree", {
    Text = "Auto Skill Tree",
    Default = false,
})

-- ========== ANTI AFK ==========
local AntiGroup = Tabs.Misc:AddLeftGroupbox("Anti", "shield")

AntiGroup:AddToggle("AntiAFK", {
    Text = "Anti AFK",
    Default = true,
})

AntiGroup:AddToggle("AutoReconnect", {
    Text = "Auto Reconnect",
    Default = false,
})

-- ========== PANIC BUTTON ==========
local PanicGroup = Tabs.Misc:AddRightGroupbox("Emergency", "alert-triangle")

PanicGroup:AddLabel("Press to stop all features")
PanicGroup:AddButton("Panic Stop", function()
    Shared.Farm = false
    Shared.Target = nil
    
    for _, toggle in pairs(Toggles) do
        if toggle.SetValue then
            toggle:SetValue(false)
        end
    end
    
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
    
    task.delay(0.5, function()
        Shared.Farm = true
    end)
    
    Library:Notify("All features stopped!", 5)
end)

-- ========== CONFIG TAB ==========
local ConfigGroup = Tabs.Config:AddLeftGroupbox("Settings", "wrench")

ConfigGroup:AddToggle("AutoShowUI", {
    Text = "Auto Show UI on Load",
    Default = true,
})

ConfigGroup:AddDivider()

ConfigGroup:AddLabel("Menu Keybind")
:AddKeyPicker("MenuKeybind", { Default = "U", NoUI = true })

ConfigGroup:AddButton("Unload Script", function()
    getgenv().taolao_Running = false
    Shared.Farm = false
    Library:Unload()
end)

-- ========== SETUP CALLBACKS ==========
ws_toggle:OnChanged(function(state)
    ws_slider:SetVisible(state)
end)

jp_toggle:OnChanged(function(state)
    jp_slider:SetVisible(state)
end)

fps_toggle:OnChanged(function(state)
    fps_slider:SetVisible(state)
    if not state and Support.FPS then
        setfpscap(999)
    end
end)

-- ========== MOVEMENT LOOP ==========
task.spawn(function()
    while getgenv().taolao_Running do
        task.wait()
        local hum = GetCharacter() and GetCharacter():FindFirstChildOfClass("Humanoid")
        
        if hum then
            if ws_toggle.Value then
                hum.WalkSpeed = ws_slider.Value
            end
            if jp_toggle.Value then
                hum.JumpPower = jp_slider.Value
                hum.UseJumpPower = true
            end
        end
        
        if fps_toggle.Value and Support.FPS then
            setfpscap(fps_slider.Value)
        end
        
        if Toggles.Fullbright.Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        end
        
        if Toggles.NoFog.Value then
            Lighting.FogEnd = 9e9
        end
    end
end)

-- ========== ANTI AFK LOOP ==========
task.spawn(function()
    while getgenv().taolao_Running do
        task.wait(60)
        if Toggles.AntiAFK.Value then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- ========== AUTO STATS LOOP ==========
task.spawn(function()
    while getgenv().taolao_Running do
        task.wait(1)
        if Toggles.AutoStats.Value then
            local pointsPath = Plr:FindFirstChild("Data") and Plr.Data:FindFirstChild("StatPoints")
            if pointsPath and pointsPath.Value > 0 then
                local selected = Options.SelectedStats.Value or {}
                local activeStats = {}
                
                for stat, enabled in pairs(selected) do
                    if enabled then
                        table.insert(activeStats, stat)
                    end
                end
                
                if #activeStats > 0 then
                    local pointsPerStat = math.floor(pointsPath.Value / #activeStats)
                    if pointsPerStat > 0 then
                        for _, stat in ipairs(activeStats) do
                            pcall(function()
                                Remotes.AddStat:FireServer(stat, pointsPerStat)
                            end)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- ========== AUTO ROLL LOOP ==========
task.spawn(function()
    while getgenv().taolao_Running do
        task.wait()
        
        if Toggles.AutoTrait.Value then
            local traitUI = PGui:FindFirstChild("TraitRerollUI")
            if traitUI then
                local currentTrait = traitUI:FindFirstChild("MainFrame", true)
                if currentTrait then
                    local selected = Options.SelectedTrait.Value or {}
                    if selected[currentTrait.Text] then
                        Library:Notify("Got target trait: " .. currentTrait.Text, 5)
                        Toggles.AutoTrait:SetValue(false)
                    else
                        pcall(function()
                            if Remotes.TraitAutoSkip then Remotes.TraitAutoSkip:FireServer() end
                            if Remotes.Roll_Trait then Remotes.Roll_Trait:FireServer() end
                        end)
                        task.wait(Options.RollDelay.Value)
                    end
                end
            end
        end
        
        if Toggles.AutoRace.Value then
            local currentRace = Plr:GetAttribute("CurrentRace")
            local selected = Options.SelectedRace.Value or {}
            
            if selected[currentRace] then
                Library:Notify("Got target race: " .. currentRace, 5)
                Toggles.AutoRace:SetValue(false)
            else
                pcall(function()
                    if Remotes.UseItem then
                        Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                    end
                end)
                task.wait(Options.RollDelay.Value)
            end
        end
        
        if Toggles.AutoClan.Value then
            local currentClan = Plr:GetAttribute("CurrentClan")
            local selected = Options.SelectedClan.Value or {}
            
            if selected[currentClan] then
                Library:Notify("Got target clan: " .. currentClan, 5)
                Toggles.AutoClan:SetValue(false)
            else
                pcall(function()
                    if Remotes.UseItem then
                        Remotes.UseItem:FireServer("Use", "Clan Reroll", 1)
                    end
                end)
                task.wait(Options.RollDelay.Value)
            end
        end
        
        if not (Toggles.AutoTrait.Value or Toggles.AutoRace.Value or Toggles.AutoClan.Value) then
            task.wait(1)
        end
    end
end)

-- ========== FARM LOOP ==========
task.spawn(function()
    while getgenv().taolao_Running do
        task.wait(0.1)
        
        if not Shared.Farm then 
            Shared.Target = nil
            continue 
        end
        
        local char = GetCharacter()
        if not char then continue end
        
        if Toggles.MobFarm.Value or Toggles.AllMobFarm.Value then
            local target = GetMobTarget()
            if target then
                Shared.Target = target
                EquipWeapon()
                ExecuteFarmLogic(target)
            end
        end
    end
end)

-- ========== INITIALIZATION ==========
task.spawn(function()
    -- Wait for game to fully load
    repeat task.wait(0.5) until game:IsLoaded()
    task.wait(2)
    
    -- Update lists
    UpdateNPCLists()
    UpdateAllEntities()
    
    -- Request inventory
    if Remotes.ReqInventory then
        Remotes.ReqInventory:FireServer()
    end
    
    -- Load config
    SaveManager:LoadAutoloadConfig()
    ThemeManager:LoadDefault()
    
    -- Auto show UI based on setting
    task.wait(0.5)
    if Toggles.AutoShowUI.Value == false then
        Library:Toggle()
    end
    
    Library:Notify("Script loaded successfully!", 3)
    Library:Notify("Press " .. Options.MenuKeybind.Value .. " to toggle UI", 5)
end)

-- ========== THEME & SAVE MANAGER ==========
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

ThemeManager:SetFolder("SailorPiece")
SaveManager:SetFolder("SailorPiece")

SaveManager:BuildConfigSection(Tabs.Config)
ThemeManager:ApplyToTab(Tabs.Config)

-- ========== END ==========
print("Script loaded successfully!")