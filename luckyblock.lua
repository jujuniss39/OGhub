-- Load Library Chloe X
local Chloex = loadstring(game:HttpGet("https://raw.githubusercontent.com/jujuniss39/XORN/refs/heads/main/library"))()

-- Buat Window
local Window = Chloex:Window({
    Title = "Be a Lucky Block",
    Footer = "Xorn",
    Color = Color3.fromRGB(255, 50, 100),
    ["Tab Width"] = 120,
    Version = 1
})

-- Buat Tabs
local MainTab = Window:AddTab({ Name = "Main", Icon = "star" })
local UpgradesTab = Window:AddTab({ Name = "Upgrades", Icon = "stat" })
local BrainrotsTab = Window:AddTab({ Name = "Brainrots", Icon = "boss" })
local StatsTab = Window:AddTab({ Name = "Stats", Icon = "user" })

-- ==================== MAIN TAB ====================
local MainSection = MainTab:AddSection("Auto Features", false, Color3.fromRGB(255, 100, 100))

-- Variables
local autoClaiming = false
local autoRebirth = false
local autoEventPass = false
local autoBuyBest = false

-- Auto Claim Playtime Rewards
local claimGift = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")

local ACPR_Toggle = MainSection:AddToggle("Auto Claim Playtime", false, function(state)
    autoClaiming = state
    if not state then return end
    task.spawn(function()
        while autoClaiming do
            for reward = 1, 12 do
                if not autoClaiming then break end
                pcall(function()
                    claimGift:InvokeServer(reward)
                end)
                task.wait(0.25)
            end
            task.wait(1)
        end
    end)
end)

-- Auto Rebirth
local rebirth = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")

local AR_Toggle = MainSection:AddToggle("Auto Rebirth", false, function(state)
    autoRebirth = state
    if not state then return end
    task.spawn(function()
        while autoRebirth do
            pcall(function()
                rebirth:InvokeServer()
            end)
            task.wait(1)
        end
    end)
end)

-- Auto Buy Best Luckyblock
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local buy = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SkinService"):WaitForChild("RF"):WaitForChild("BuySkin")

local skins = {
    "prestige_mogging_luckyblock",
    "mogging_luckyblock",
    "colossus _luckyblock",
    "inferno_luckyblock",
    "divine_luckyblock",
    "spirit_luckyblock",
    "cyborg_luckyblock",
    "void_luckyblock",
    "gliched_luckyblock",
    "lava_luckyblock",
    "freezy_luckyblock",
    "fairy_luckyblock"
}

local suffix = {
    K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qa = 1e15, Qi = 1e18,
    Sx = 1e21, Sp = 1e24, Oc = 1e27, No = 1e30, Dc = 1e33
}

local function parseCash(text)
    text = text:gsub("%$", ""):gsub(",", ""):gsub("%s+", "")
    local num = tonumber(text:match("[%d%.]+"))
    local suf = text:match("%a+")
    if not num then return 0 end
    if suf and suffix[suf] then return num * suffix[suf] end
    return num
end

local ABL_Toggle = MainSection:AddToggle("Auto Buy Best Luckyblock", false, function(state)
    autoBuyBest = state
    if not state then return end
    task.spawn(function()
        while autoBuyBest do
            local gui = player.PlayerGui:FindFirstChild("Windows")
            if gui then
                local pickaxeShop = gui:FindFirstChild("PickaxeShop")
                if pickaxeShop then
                    local shopContainer = pickaxeShop:FindFirstChild("ShopContainer")
                    if shopContainer then
                        local scrollingFrame = shopContainer:FindFirstChild("ScrollingFrame")
                        if scrollingFrame then
                            local cash = player.leaderstats.Cash.Value
                            local bestSkin = nil
                            local bestPrice = 0
                            for i = 1, #skins do
                                local name = skins[i]
                                local item = scrollingFrame:FindFirstChild(name)
                                if item and item:FindFirstChild("Main") then
                                    local main = item.Main
                                    if main and main:FindFirstChild("Buy") then
                                        local buyFolder = main.Buy
                                        if buyFolder then
                                            local buyButton = buyFolder:FindFirstChild("BuyButton")
                                            if buyButton and buyButton.Visible then
                                                local cashLabel = buyButton:FindFirstChild("Cash")
                                                if cashLabel then
                                                    local price = parseCash(cashLabel.Text)
                                                    if cash >= price and price > bestPrice then
                                                        bestSkin = name
                                                        bestPrice = price
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if bestSkin then
                                pcall(function()
                                    buy:InvokeServer(bestSkin)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- Redeem Codes Button
MainSection:AddButton("Redeem All Codes", function()
    local redeem = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("CodesService"):WaitForChild("RF"):WaitForChild("RedeemCode")
    local codes = {"release"}
    for _, code in ipairs(codes) do
        pcall(function()
            redeem:InvokeServer(code)
        end)
        task.wait(1)
    end
    Chloex:MakeNotify({
        Title = "Codes",
        Description = "Success!",
        Content = "All codes redeemed!",
        Delay = 3
    })
end)

-- Sell Brainrot Button
MainSection:AddButton("Sell Held Brainrot", function()
    local confirm = Window:Dialog("Confirm Sale", "Are you sure you want to sell this held Brainrot?")
    if confirm then
        local character = player.Character or player.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            Chloex:MakeNotify({
                Title = "Error",
                Description = "ERROR!",
                Content = "Equip the Brainrot you want to Sell",
                Delay = 5
            })
            return
        end
        local entityId = tool:GetAttribute("EntityId")
        if entityId then
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("SellBrainrot"):InvokeServer(entityId)
            Chloex:MakeNotify({
                Title = "Sold!",
                Description = "SOLD!",
                Content = "Sold: " .. tool.Name,
                Delay = 3
            })
        end
    end
end)

-- Pickup Brainrots Button
MainSection:AddButton("Pickup All Brainrots", function()
    local confirm = Window:Dialog("Confirm Pickup", "Pick up all Brainrots?")
    if confirm then
        local username = player.Name
        local plotsFolder = workspace:WaitForChild("Plots")
        local myPlot = nil
        for i = 1, 5 do
            local plot = plotsFolder:FindFirstChild(tostring(i))
            if plot and plot:FindFirstChild(tostring(i)) then
                local inner = plot[tostring(i)]
                for _, v in pairs(inner:GetDescendants()) do
                    if v:IsA("BillboardGui") and string.find(v.Name, username) then
                        myPlot = inner
                        break
                    end
                end
            end
            if myPlot then break end
        end
        if myPlot then
            local containers = myPlot:FindFirstChild("Containers")
            if containers then
                for i = 1, 30 do
                    local containerFolder = containers:FindFirstChild(tostring(i))
                    if containerFolder and containerFolder:FindFirstChild(tostring(i)) then
                        local container = containerFolder[tostring(i)]
                        local innerModel = container:FindFirstChild("InnerModel")
                        if innerModel and #innerModel:GetChildren() > 0 then
                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("ContainerService"):WaitForChild("RF"):WaitForChild("PickupBrainrot"):InvokeServer(tostring(i))
                            task.wait(0.1)
                        end
                    end
                end
                Chloex:MakeNotify({
                    Title = "Done!",
                    Description = "Done!",
                    Content = "Picked up all Brainrots",
                    Delay = 3
                })
            end
        end
    end
end)

-- ==================== UPGRADES TAB ====================
local SpeedSection = UpgradesTab:AddSection("Speed Upgrades", false, Color3.fromRGB(100, 255, 100))

local upgrade = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("UpgradesService"):WaitForChild("RF"):WaitForChild("Upgrade")

local speedAmount = 1
local speedDelay = 0.5
local autoUpgradeSpeed = false

local SpeedAmountInput = SpeedSection:AddInput("Speed Amount", "1", true, function(value)
    speedAmount = tonumber(value) or 1
end)

local SpeedSlider = SpeedSection:AddSlider("Upgrade Interval", 1, 0, 5, 1, function(value)
    speedDelay = value
end)

local AutoSpeedToggle = SpeedSection:AddToggle("Auto Upgrade Speed", false, function(state)
    autoUpgradeSpeed = state
    if not state then return end
    task.spawn(function()
        while autoUpgradeSpeed do
            pcall(function()
                upgrade:InvokeServer("MovementSpeed", speedAmount)
            end)
            task.wait(speedDelay)
        end
    end)
end)

-- ==================== BRAINROTS TAB ====================
local BossSection = BrainrotsTab:AddSection("Boss Settings", false, Color3.fromRGB(255, 255, 100))

local storedParts = {}
local folder = workspace:WaitForChild("BossTouchDetectors")
local removeBoss = false

local RemoveBossToggle = BossSection:AddToggle("Remove Bad Boss Detectors", false, function(state)
    removeBoss = state
    if state then
        storedParts = {}
        for _, obj in ipairs(folder:GetChildren()) do
            if obj.Name ~= "base14" then
                table.insert(storedParts, obj)
                obj.Parent = nil
            end
        end
    else
        for _, obj in ipairs(storedParts) do
            if obj then obj.Parent = folder end
        end
        storedParts = {}
    end
end)

BossSection:AddButton("Teleport to End", function()
    local modelsFolder = workspace:WaitForChild("RunningModels")
    local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
    for _, obj in ipairs(modelsFolder:GetChildren()) do
        if obj:IsA("Model") then
            if obj.PrimaryPart then
                obj:SetPrimaryPartCFrame(target.CFrame)
            else
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then part.CFrame = target.CFrame end
            end
        elseif obj:IsA("BasePart") then
            obj.CFrame = target.CFrame
        end
    end
end)

local FarmSection = BrainrotsTab:AddSection("Farming", false, Color3.fromRGB(100, 255, 255))

local autoFarm = false
local AutoFarmToggle = FarmSection:AddToggle("Auto Farm Best Brainrots", false, function(state)
    autoFarm = state
    if state then
        task.spawn(function()
            while autoFarm do
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                local humanoid = character:WaitForChild("Humanoid")
                local userId = player.UserId
                local modelsFolder = workspace:WaitForChild("RunningModels")
                local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
                
                root.CFrame = CFrame.new(715, 39, -2122)
                task.wait(0.3)
                humanoid:MoveTo(Vector3.new(710, 39, -2122))
                
                local ownedModel = nil
                repeat
                    task.wait(0.3)
                    for _, obj in ipairs(modelsFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:GetAttribute("OwnerId") == userId then
                            ownedModel = obj
                            break
                        end
                    end
                until ownedModel ~= nil or not autoFarm
                
                if not autoFarm then break end
                
                if ownedModel.PrimaryPart then
                    ownedModel:SetPrimaryPartCFrame(target.CFrame)
                else
                    local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                    if part then part.CFrame = target.CFrame end
                end
                task.wait(0.7)
                
                if ownedModel and ownedModel.Parent == modelsFolder then
                    if ownedModel.PrimaryPart then
                        ownedModel:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, -5, 0))
                    else
                        local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                        if part then part.CFrame = target.CFrame * CFrame.new(0, -5, 0) end
                    end
                end
                
                repeat
                    task.wait(0.3)
                until not autoFarm or (ownedModel == nil or ownedModel.Parent ~= modelsFolder)
                
                if not autoFarm then break end
                
                local oldCharacter = player.Character
                repeat
                    task.wait(0.2)
                until not autoFarm or (player.Character ~= oldCharacter and player.Character ~= nil)
                
                if not autoFarm then break end
                
                task.wait(0.4)
                local newChar = player.Character
                local newRoot = newChar:WaitForChild("HumanoidRootPart")
                newRoot.CFrame = CFrame.new(737, 39, -2118)
                task.wait(2.1)
            end
        end)
    end
end)

-- ==================== STATS TAB ====================
local SpeedStatSection = StatsTab:AddSection("Lucky Block Speed", false, Color3.fromRGB(255, 150, 255))

local customSpeed = false
local speedValue = 1000
local originalSpeed = nil
local currentModel = nil

local function getMyModel()
    local folder = workspace:FindFirstChild("RunningModels")
    if not folder then return nil end
    for _, model in ipairs(folder:GetChildren()) do
        if model:GetAttribute("OwnerId") == player.UserId then
            return model
        end
    end
    return nil
end

local function applySpeed()
    local model = getMyModel()
    if not then
        currentModel = nil
        return
    end
    if model ~= currentModel then
        currentModel = model
        originalSpeed = model:GetAttribute("MovementSpeed")
    end
    if customSpeed then
        if originalSpeed == nil then
            originalSpeed = model:GetAttribute("MovementSpeed")
        end
        model:SetAttribute("MovementSpeed", speedValue)
    end
end

task.spawn(function()
    while true do
        if customSpeed then applySpeed() end
        task.wait(0.2)
    end
end)

local SpeedToggle = SpeedStatSection:AddToggle("Enable Custom Speed", false, function(state)
    customSpeed = state
    if not state then
        local model = getMyModel()
        if model and originalSpeed ~= nil then
            model:SetAttribute("MovementSpeed", originalSpeed)
        end
        originalSpeed = nil
        currentModel = nil
    end
end)

local SpeedSliderStat = SpeedStatSection:AddSlider("Lucky Block Speed", 1000, 50, 3000, 0, function(value)
    speedValue = value
end)

Chloex:MakeNotify({
    Title = "Loaded",
    Description = "Success!",
    Content = "Script loaded successfully!",
    Delay = 3
})