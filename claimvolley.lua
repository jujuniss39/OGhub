-- Load OG-HUB Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/jujuniss39/OGhub/refs/heads/main/library"))()

-- Window
local Window = Library:Window({
    Title = "RCRR",
    Footer = "Reward Claim + Ranked Reward",
    Image = "rbxassetid://97167558235554",
    Color = Color3.fromRGB(255, 0, 0),
    Theme = "9542022979",
    ThemeTransparency = 0.1,
    Version = 1
})

-- Remotes
local claimRemote, rankedRemote
local claimRemoteFound = false
local rankedRemoteFound = false

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

            local ss = services:FindFirstChild("SeasonService")
            rankedRemote = ss and ss:FindFirstChild("RF") and ss.RF:FindFirstChild("RequestRankedReward")
        end
    end)

    claimRemoteFound = claimRemote ~= nil
    rankedRemoteFound = rankedRemote ~= nil
end

-- Tabs (ICON GEAR)
local ClaimTab = Window:AddTab({Name = "Claim Reward", Icon = "rbxassetid://6031280882"})
local RankedTab = Window:AddTab({Name = "Ranked Reward", Icon = "rbxassetid://6031280882"})

-- CLAIM
local ClaimSection = ClaimTab:AddSection("CLAIM REWARD", true)

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
    Title = "CLAIM REWARD",
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

-- RANKED
local RankedSection = RankedTab:AddSection("RANKED REWARD", true)

local RankedStatus = RankedSection:AddParagraph({
    Title = "STATUS",
    Content = "Checking..."
})

local rankedRunning = false
local rankedCount = 0
local rankedThread

task.spawn(function()
    task.wait(1)
    findRemotes()
    if rankedRemoteFound then
        RankedStatus:SetContent("OFF\nClaimed: 0")
    else
        RankedStatus:SetContent("Remote Not Found")
    end
end)

RankedSection:AddDivider()

local rankedToggle = RankedSection:AddToggle({
    Title = "RANKED REWARD",
    Default = false,
    Callback = function(state)
        if state then
            if not rankedRemoteFound then
                findRemotes()
                if not rankedRemoteFound then
                    RankedStatus:SetContent("Remote Not Found")
                    rankedToggle:SetValue(false)
                    return
                end
            end

            rankedRunning = true
            RankedStatus:SetContent("ON\nClaimed: " .. rankedCount)

            rankedThread = task.spawn(function()
                while rankedRunning do
                    if pcall(function()
                        rankedRemote:InvokeServer(4)
                    end) then
                        rankedCount += 1
                        RankedStatus:SetContent("ON\nClaimed: " .. rankedCount)
                    end
                    task.wait(1)
                end
            end)
        else
            rankedRunning = false
            if rankedThread then
                task.cancel(rankedThread)
                rankedThread = nil
            end
            RankedStatus:SetContent("OFF\nClaimed: " .. rankedCount)
        end
    end
})

-- CHECK BUTTONS
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

local CheckRanked = RankedTab:AddSection("REMOTE", true)
CheckRanked:AddButton({
    Title = "CHECK",
    Callback = function()
        RankedStatus:SetContent("Checking...")
        task.wait(0.5)
        findRemotes()
        if rankedRemoteFound then
            RankedStatus:SetContent("OFF\nClaimed: " .. rankedCount)
        else
            RankedStatus:SetContent("Remote Not Found")
            rankedToggle:SetValue(false)
        end
    end
})