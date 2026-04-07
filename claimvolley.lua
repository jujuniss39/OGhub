-- Load OG-HUB Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jujuniss39/OGhub/refs/heads/main/library"))()

-- Window
local Window = Library:Window({
    Title = "DELTA AUTO REWARD",
    Footer = "Gems + Style/Ability",
    Image = "rbxassetid://97167558235554",
    Color = Color3.fromRGB(255, 0, 0),
    Theme = "9542022979",
    ThemeTransparency = 0.1,
    Version = 1
})

-- Remotes
local claimRemote
local claimRemoteFound = false

local function findRemotes()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local packages = rs:FindFirstChild("Packages")
        local index = packages and packages:FindFirstChild("_Index")
        local knit = index and index:FindFirstChild("sleitnick_knit@1.7.0")
        local services = knit and knit:FindFirstChild("knit") and knit.knit:FindFirstChild("Services")

        if services then
            local ch = services:FindFirstChild("ChallengeService")
            claimRemote = ch and ch:FindFirstChild("RF") and ch.RF:FindFirstChild("ClaimReward")
        end
    end)

    claimRemoteFound = claimRemote ~= nil
end

findRemotes()

-- Tabs (NAMA BARU)
local ClaimTab = Window:AddTab({Name = "CLAIM GEMS", Icon = "rbxassetid://6031280882"})
local StyleTab = Window:AddTab({Name = "STYLE & ABILITY", Icon = "rbxassetid://6031280882"})

-- ================= CLAIM =================
local ClaimSection = ClaimTab:AddSection("CLAIM GEMS", true)

local ClaimStatus = ClaimSection:AddParagraph({
    Title = "STATUS",
    Content = "Checking..."
})

local claimRunning = false
local claimCount = 0
local claimThread

task.spawn(function()
    task.wait(1)
    findRemotes()
    if claimRemoteFound then
        ClaimStatus:SetContent("OFF\nClaimed: 0")
    else
        ClaimStatus:SetContent("Remote Not Found")
    end
end)

ClaimSection:AddDivider()

local claimToggle = ClaimSection:AddToggle({
    Title = "CLAIM GEMS",
    Default = false,
    Callback = function(state)
        if state then
            if not claimRemoteFound then
                findRemotes()
                if not claimRemoteFound then
                    ClaimStatus:SetContent("Remote Not Found")
                    claimToggle:SetValue(false)
                    return
                end
            end

            claimRunning = true
            ClaimStatus:SetContent("ON\nClaimed: " .. claimCount)

            claimThread = task.spawn(function()
                local counter = claimCount
                while claimRunning do
                    if pcall(function()
                        claimRemote:InvokeServer(-(counter + 1))
                    end) then
                        counter += 1
                        claimCount = counter
                        ClaimStatus:SetContent("ON\nClaimed: " .. claimCount)
                    end
                    task.wait(0.05)
                end
            end)
        else
            claimRunning = false
            if claimThread then
                task.cancel(claimThread)
                claimThread = nil
            end
            ClaimStatus:SetContent("OFF\nClaimed: " .. claimCount)
        end
    end
})

-- ================= STYLE & ABILITY =================
local RewardSection = StyleTab:AddSection("STYLE & ABILITY", true)

local StyleStatus = RewardSection:AddParagraph({
    Title = "STYLE STATUS",
    Content = "OFF\nClaimed: 0"
})

local AbilityStatus = RewardSection:AddParagraph({
    Title = "ABILITY STATUS",
    Content = "OFF\nClaimed: 0"
})

RewardSection:AddDivider()

local styleRunning = false
local styleCount = 0
local styleThread

local abilityRunning = false
local abilityCount = 0
local abilityThread

-- STYLE (ARG 1)
RewardSection:AddToggle({
    Title = "STYLE REWARD",
    Default = false,
    Callback = function(state)
        styleRunning = state

        if state then
            StyleStatus:SetContent("ON\nClaimed: " .. styleCount)

            styleThread = task.spawn(function()
                while styleRunning do
                    if pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_knit@1.7.0")
                            :WaitForChild("knit")
                            :WaitForChild("Services")
                            :WaitForChild("SeasonService")
                            :WaitForChild("RF")
                            :WaitForChild("RequestRankedReward")
                            :InvokeServer(1)
                    end) then
                        styleCount += 1
                        StyleStatus:SetContent("ON\nClaimed: " .. styleCount)
                    end
                    task.wait(1)
                end
            end)
        else
            if styleThread then
                task.cancel(styleThread)
                styleThread = nil
            end
            StyleStatus:SetContent("OFF\nClaimed: " .. styleCount)
        end
    end
})

-- ABILITY (ARG 4)
RewardSection:AddToggle({
    Title = "ABILITY REWARD",
    Default = false,
    Callback = function(state)
        abilityRunning = state

        if state then
            AbilityStatus:SetContent("ON\nClaimed: " .. abilityCount)

            abilityThread = task.spawn(function()
                while abilityRunning do
                    if pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_knit@1.7.0")
                            :WaitForChild("knit")
                            :WaitForChild("Services")
                            :WaitForChild("SeasonService")
                            :WaitForChild("RF")
                            :WaitForChild("RequestRankedReward")
                            :InvokeServer(4)
                    end) then
                        abilityCount += 1
                        AbilityStatus:SetContent("ON\nClaimed: " .. abilityCount)
                    end
                    task.wait(1)
                end
            end)
        else
            if abilityThread then
                task.cancel(abilityThread)
                abilityThread = nil
            end
            AbilityStatus:SetContent("OFF\nClaimed: " .. abilityCount)
        end
    end
})

-- ================= CHECK =================
local CheckClaim = ClaimTab:AddSection("REMOTE", true)
CheckClaim:AddButton({
    Title = "CHECK",
    Callback = function()
        ClaimStatus:SetContent("Checking...")
        task.wait(0.5)
        findRemotes()
        if claimRemoteFound then
            ClaimStatus:SetContent("OFF\nClaimed: " .. claimCount)
        else
            ClaimStatus:SetContent("Remote Not Found")
            claimToggle:SetValue(false)
        end
    end
})