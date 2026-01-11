-- ==============================================
-- Bloodmoon UI Library v1.0
-- Red & Black Theme - Mirip Chloe X
-- ==============================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Red & Black Theme Colors
local Theme = {
    Primary = Color3.fromRGB(255, 50, 50),     -- Blood Red
    Secondary = Color3.fromRGB(220, 20, 20),   -- Dark Red
    Background = Color3.fromRGB(10, 10, 10),   -- Pure Black
    Surface = Color3.fromRGB(20, 20, 20),      -- Dark Gray
    Accent = Color3.fromRGB(40, 40, 40),       -- Medium Gray
    Text = Color3.fromRGB(255, 255, 255),      -- White
    TextSecondary = Color3.fromRGB(200, 200, 200), -- Light Gray
    TextMuted = Color3.fromRGB(150, 150, 150), -- Gray
    Success = Color3.fromRGB(0, 255, 100),     -- Green for contrast
    Warning = Color3.fromRGB(255, 150, 0),     -- Orange
    Danger = Color3.fromRGB(255, 0, 0),        -- Red
}

-- Icons Library (Red-themed)
local Icons = {
    player = "rbxassetid://12120698352",
    sword = "rbxassetid://82472368671405",
    skull = "rbxassetid://17313330026",
    fire = "rbxassetid://13321880293",
    blood = "rbxassetid://14321059114",
    shield = "rbxassetid://12094445329",
    heart = "rbxassetid://108483430622128",
    crosshair = "rbxassetid://12614416478",
    gamepad = "rbxassetid://84173963561612",
    settings = "rbxassetid://70386228443175",
    star = "rbxassetid://107005941750079",
    bolt = "rbxassetid://73186275216515",
    crown = "rbxassetid://13132186360",
    gem = "rbxassetid://18747025078",
    lock = "rbxassetid://9886659671",
    unlock = "rbxassetid://9886659276",
    close = "rbxassetid://9886659671",
    minimize = "rbxassetid://9886659276",
    arrow = "rbxassetid://16851841101",
    check = "rbxassetid://6031068426",
    cancel = "rbxassetid://6031068421",
}

-- Config System
local Config = {
    Version = 1,
    Data = {},
    Path = "Bloodmoon_Config.json"
}

local Elements = {}
local DraggableWindows = {}

-- Utility Functions
local function Create(className, properties)
    local obj = Instance.new(className)
    for prop, val in pairs(properties) do
        if pcall(function() return obj[prop] end) then
            obj[prop] = val
        end
    end
    return obj
end

local function Tween(obj, props, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local pos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Tween(object, {Position = pos}, 0.1)
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

local function RippleEffect(button, x, y)
    button.ClipsDescendants = true
    
    local circle = Create("ImageLabel", {
        Image = "rbxassetid://266543268",
        ImageColor3 = Color3.fromRGB(255, 50, 50),
        ImageTransparency = 0.7,
        BackgroundTransparency = 1,
        ZIndex = 10,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Parent = button
    })
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    local time = 0.5
    
    Tween(circle, {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    }, time)
    
    for i = 1, 10 do
        circle.ImageTransparency = circle.ImageTransparency + 0.03
        task.wait(time/10)
    end
    
    circle:Destroy()
end

-- Notification System
local function Notify(title, message, duration)
    duration = duration or 5
    
    if not CoreGui:FindFirstChild("BloodmoonNotifications") then
        local notifGui = Create("ScreenGui", {
            Name = "BloodmoonNotifications",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        notifGui.Parent = CoreGui
    end
    
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -320, 1, -80),
        ClipsDescendants = true,
        Parent = CoreGui.BloodmoonNotifications
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notification})
    
    Create("UIStroke", {
        Color = Theme.Primary,
        Thickness = 2,
        Parent = notification
    })
    
    local titleLabel = Create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local messageLabel = Create("TextLabel", {
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 35),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notification
    })
    
    local closeBtn = Create("TextButton", {
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5),
        Parent = notification
    })
    
    -- Calculate height based on message
    local textHeight = math.min(messageLabel.TextBounds.Y + 50, 150)
    notification.Size = UDim2.new(0, 300, 0, textHeight)
    notification.Position = UDim2.new(1, 320, 1, -80)
    
    -- Slide in
    Tween(notification, {Position = UDim2.new(1, -320, 1, -80)}, 0.3)
    
    closeBtn.MouseButton1Click:Connect(function()
        Tween(notification, {Position = UDim2.new(1, 320, 1, -80)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
    
    task.wait(duration)
    Tween(notification, {Position = UDim2.new(1, 320, 1, -80)}, 0.3)
    task.wait(0.3)
    notification:Destroy()
end

-- Main Library
local Bloodmoon = {}

function Bloodmoon:Window(options)
    options = options or {}
    local windowTitle = options.Title or "Bloodmoon UI"
    local windowSize = options.Size or UDim2.new(0, 600, 0, 400)
    local accentColor = options.Color or Theme.Primary
    
    -- Create Main GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "BloodmoonUI_" .. windowTitle,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Window
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        Size = windowSize,
        Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
        ClipsDescendants = true
    })
    MainWindow.Parent = ScreenGui
    
    -- Rounded corners
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainWindow
    })
    
    -- Red border
    Create("UIStroke", {
        Color = accentColor,
        Thickness = 2,
        Parent = MainWindow
    })
    
    -- Drop shadow
    local shadow = Create("ImageLabel", {
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, -15, 0.5, -15),
        BackgroundTransparency = 1,
        ZIndex = -1,
        Parent = MainWindow
    })
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2,
        Parent = MainWindow
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8, 0, 0),
        Parent = TitleBar
    })
    
    local TitleLabel = Create("TextLabel", {
        Text = windowTitle,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = accentColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Window Controls
    local CloseButton = Create("TextButton", {
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        Name = "CloseButton",
        Parent = TitleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = CloseButton
    })
    
    local MinimizeButton = Create("TextButton", {
        Text = "─",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        Name = "MinimizeButton",
        Parent = TitleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MinimizeButton
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -55),
        Position = UDim2.new(0, 5, 0, 45),
        Parent = MainWindow
    })
    
    -- Tab System
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Size = UDim2.new(0, 140, 1, 0),
        Parent = ContentArea
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1,
        Parent = TabContainer
    })
    
    local TabScroller = Create("ScrollingFrame", {
        Name = "TabScroller",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = TabContainer
    })
    
    local TabListLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = TabScroller
    })
    
    -- Page Container
    local PageContainer = Create("Frame", {
        Name = "PageContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        Parent = ContentArea
    })
    
    local PageFolder = Create("Folder", {
        Name = "Pages",
        Parent = PageContainer
    })
    
    -- Make draggable
    MakeDraggable(TitleBar, MainWindow)
    
    -- Window Controls
    local isMinimized = false
    local originalSize = MainWindow.Size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        RippleEffect(MinimizeButton, Mouse.X, Mouse.Y)
        isMinimized = not isMinimized
        if isMinimized then
            Tween(ContentArea, {Size = UDim2.new(1, 0, 0, 0)})
            Tween(MainWindow, {Size = UDim2.new(MainWindow.Size.X.Scale, MainWindow.Size.X.Offset, 0, 40)})
        else
            Tween(ContentArea, {Size = UDim2.new(1, -10, 1, -55)})
            Tween(MainWindow, {Size = originalSize})
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        RippleEffect(CloseButton, Mouse.X, Mouse.Y)
        
        -- Confirmation dialog
        local Overlay = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 50,
            Parent = MainWindow
        })
        
        local Dialog = Create("Frame", {
            BackgroundColor3 = Theme.Background,
            Size = UDim2.new(0, 300, 0, 150),
            Position = UDim2.new(0.5, -150, 0.5, -75),
            ZIndex = 51,
            Parent = Overlay
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = Dialog
        })
        
        Create("UIStroke", {
            Color = Theme.Primary,
            Thickness = 2,
            Parent = Dialog
        })
        
        local DialogTitle = Create("TextLabel", {
            Text = "Bloodmoon UI",
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Theme.Primary,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 10),
            Parent = Dialog
        })
        
        local DialogMessage = Create("TextLabel", {
            Text = "Close the window?",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 50),
            Position = UDim2.new(0, 10, 0, 40),
            Parent = Dialog
        })
        
        local YesButton = Create("TextButton", {
            Text = "YES",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Color3.fromRGB(255, 50, 50),
            Size = UDim2.new(0.4, -10, 0, 35),
            Position = UDim2.new(0.05, 0, 1, -50),
            Parent = Dialog
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = YesButton
        })
        
        local NoButton = Create("TextButton", {
            Text = "NO",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0.4, -10, 0, 35),
            Position = UDim2.new(0.55, 10, 1, -50),
            Parent = Dialog
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = NoButton
        })
        
        YesButton.MouseButton1Click:Connect(function()
            Tween(MainWindow, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            task.wait(0.3)
            ScreenGui:Destroy()
        end)
        
        NoButton.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end)
    
    -- Toggle hotkey
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F4 then
            MainWindow.Visible = not MainWindow.Visible
            Notify("Bloodmoon UI", "UI " .. (MainWindow.Visible and "shown" or "hidden"), 2)
        end
    end)
    
    -- Toggle button
    local ToggleButton = Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 20, 0, 100),
        Parent = ScreenGui
    })
    
    local ToggleIcon = Create("ImageLabel", {
        Image = Icons.skull,
        ImageColor3 = Theme.Primary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = ToggleButton
    })
    
    ToggleButton.MouseButton1Click:Connect(function()
        MainWindow.Visible = not MainWindow.Visible
    end)
    
    -- Make toggle button draggable
    MakeDraggable(ToggleButton, ToggleButton)
    
    -- Window API
    local WindowAPI = {}
    local tabs = {}
    local currentTab = nil
    
    function WindowAPI:CreateTab(tabName, tabIcon)
        local tabIconImg = tabIcon and Icons[tabIcon] or Icons.settings
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Text = "  " .. tabName,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BackgroundTransparency = 0.2,
            Size = UDim2.new(1, -10, 0, 40),
            AutoButtonColor = false,
            Parent = TabScroller
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })
        
        Create("UIStroke", {
            Color = Theme.Accent,
            Thickness = 1,
            Parent = TabButton
        })
        
        -- Tab Icon
        local Icon = Create("ImageLabel", {
            Image = tabIconImg,
            ImageColor3 = Theme.Primary,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 8, 0.5, -10),
            Parent = TabButton
        })
        
        -- Tab Page
        local Page = Create("ScrollingFrame", {
            Name = "Page_" .. tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Primary,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = PageFolder
        })
        
        local PageLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = Page
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab selection
        TabButton.MouseButton1Click:Connect(function()
            RippleEffect(TabButton, Mouse.X, Mouse.Y)
            
            -- Deselect previous tab
            if currentTab then
                Tween(currentTab.Button, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                currentTab.Page.Visible = false
            end
            
            -- Select new tab
            Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 0, 0)})
            Page.Visible = true
            currentTab = {Button = TabButton, Page = Page}
        end)
        
        -- Select first tab
        if not currentTab then
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
            Page.Visible = true
            currentTab = {Button = TabButton, Page = Page}
        end
        
        -- Update tab scroller size
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroller.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab API
        local TabAPI = {}
        
        function TabAPI:CreateSection(sectionName)
            local sectionFrame = Create("Frame", {
                BackgroundColor3 = Theme.Surface,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 40),
                LayoutOrder = #Page:GetChildren(),
                Parent = Page
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = sectionFrame
            })
            
            Create("UIStroke", {
                Color = Theme.Primary,
                Thickness = 1,
                Parent = sectionFrame
            })
            
            local sectionTitle = Create("TextLabel", {
                Text = "┣ " .. sectionName,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Theme.Primary,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
            local contentFrame = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -30),
                Position = UDim2.new(0, 10, 0, 30),
                Parent = sectionFrame
            })
            
            local contentLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = contentFrame
            })
            
            -- Update section size
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
            end)
            
            -- Section API
            local SectionAPI = {}
            
            function SectionAPI:CreateButton(options)
                options = options or {}
                local buttonName = options.Name or "Button"
                local callback = options.Callback or function() end
                
                local button = Create("TextButton", {
                    Text = buttonName,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 0.2,
                    AutoButtonColor = false,
                    Parent = contentFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = button
                })
                
                local buttonStroke = Create("UIStroke", {
                    Color = Theme.Primary,
                    Thickness = 1,
                    Transparency = 0.5,
                    Parent = button
                })
                
                -- Hover effects
                button.MouseEnter:Connect(function()
                    Tween(button, {BackgroundColor3 = Color3.fromRGB(40, 0, 0)})
                    Tween(buttonStroke, {Transparency = 0})
                end)
                
                button.MouseLeave:Connect(function()
                    Tween(button, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                    Tween(buttonStroke, {Transparency = 0.5})
                end)
                
                -- Click
                button.MouseButton1Click:Connect(function()
                    RippleEffect(button, Mouse.X, Mouse.Y)
                    Tween(button, {Size = UDim2.new(1, -5, 0, 32)})
                    task.wait(0.1)
                    Tween(button, {Size = UDim2.new(1, 0, 0, 35)})
                    callback()
                end)
                
                local ButtonAPI = {}
                
                function ButtonAPI:SetText(text)
                    button.Text = text
                end
                
                return ButtonAPI
            end
            
            function SectionAPI:CreateToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local defaultValue = options.Default or false
                local callback = options.Callback or function() end
                
                local toggleValue = defaultValue
                
                local toggleFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = contentFrame
                })
                
                local toggleLabel = Create("TextLabel", {
                    Text = toggleName,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                local toggleButton = Create("TextButton", {
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    AutoButtonColor = false,
                    Parent = toggleFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                    Parent = toggleButton
                })
                
                Create("UIStroke", {
                    Color = Theme.Primary,
                    Thickness = 1,
                    Parent = toggleButton
                })
                
                local toggleCircle = Create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    Parent = toggleButton
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = toggleCircle
                })
                
                local function UpdateToggle()
                    if toggleValue then
                        Tween(toggleButton, {BackgroundColor3 = Theme.Primary})
                        Tween(toggleCircle, {Position = UDim2.new(0, 22, 0.5, -8)})
                        Tween(toggleLabel, {TextColor3 = Theme.Primary})
                    else
                        Tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                        Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)})
                        Tween(toggleLabel, {TextColor3 = Theme.Text})
                    end
                    callback(toggleValue)
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    toggleValue = not toggleValue
                    UpdateToggle()
                end)
                
                UpdateToggle()
                
                local ToggleAPI = {}
                
                function ToggleAPI:Set(value)
                    toggleValue = value
                    UpdateToggle()
                end
                
                function ToggleAPI:Get()
                    return toggleValue
                end
                
                return ToggleAPI
            end
            
            function SectionAPI:CreateSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local minValue = options.Min or 0
                local maxValue = options.Max or 100
                local defaultValue = options.Default or 50
                local callback = options.Callback or function() end
                
                local currentValue = defaultValue
                
                local sliderFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    Parent = contentFrame
                })
                
                local sliderLabel = Create("TextLabel", {
                    Text = sliderName .. ": " .. currentValue,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                local sliderTrack = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30),
                    Parent = sliderFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = sliderTrack
                })
                
                local sliderFill = Create("Frame", {
                    BackgroundColor3 = Theme.Primary,
                    Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0),
                    Parent = sliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = sliderFill
                })
                
                local sliderButton = Create("Frame", {
                    BackgroundColor3 = Theme.Text,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -8, 0.5, -8),
                    Parent = sliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = sliderButton
                })
                
                Create("UIStroke", {
                    Color = Theme.Primary,
                    Thickness = 2,
                    Parent = sliderButton
                })
                
                local isDragging = false
                
                local function UpdateSlider(value)
                    value = math.clamp(value, minValue, maxValue)
                    currentValue = value
                    local percent = (value - minValue) / (maxValue - minValue)
                    
                    Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)})
                    Tween(sliderButton, {Position = UDim2.new(percent, -8, 0.5, -8)})
                    sliderLabel.Text = sliderName .. ": " .. math.floor(value)
                    callback(value)
                end
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        local x = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                        UpdateSlider(minValue + (maxValue - minValue) * x)
                    end
                end)
                
                sliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local x = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                        UpdateSlider(minValue + (maxValue - minValue) * x)
                    end
                end)
                
                UpdateSlider(defaultValue)
                
                local SliderAPI = {}
                
                function SliderAPI:Set(value)
                    UpdateSlider(value)
                end
                
                function SliderAPI:Get()
                    return currentValue
                end
                
                return SliderAPI
            end
            
            function SectionAPI:CreateLabel(text, color)
                color = color or Theme.Text
                
                local label = Create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = color,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = contentFrame
                })
                
                local LabelAPI = {}
                
                function LabelAPI:SetText(newText)
                    label.Text = newText
                end
                
                return LabelAPI
            end
            
            function SectionAPI:CreateTextBox(options)
                options = options or {}
                local boxName = options.Name or "Text Box"
                local placeholder = options.Placeholder or "Type here..."
                local defaultValue = options.Default or ""
                local callback = options.Callback or function() end
                
                local textboxFrame = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = contentFrame
                })
                
                local textboxLabel = Create("TextLabel", {
                    Text = boxName,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textboxFrame
                })
                
                local inputBox = Create("TextBox", {
                    Text = defaultValue,
                    PlaceholderText = placeholder,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    ClearTextOnFocus = false,
                    Parent = textboxFrame
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = inputBox
                })
                
                Create("UIStroke", {
                    Color = Theme.Accent,
                    Thickness = 1,
                    Parent = inputBox
                })
                
                inputBox.Focused:Connect(function()
                    Tween(inputBox.UIStroke, {Color = Theme.Primary})
                end)
                
                inputBox.FocusLost:Connect(function()
                    Tween(inputBox.UIStroke, {Color = Theme.Accent})
                    callback(inputBox.Text)
                end)
                
                local TextBoxAPI = {}
                
                function TextBoxAPI:SetText(text)
                    inputBox.Text = text
                end
                
                function TextBoxAPI:GetText()
                    return inputBox.Text
                end
                
                return TextBoxAPI
            end
            
            return SectionAPI
        end
        
        return TabAPI
    end
    
    function WindowAPI:Notify(title, message, duration)
        Notify(title, message, duration)
    end
    
    function WindowAPI:Toggle()
        MainWindow.Visible = not MainWindow.Visible
    end
    
    function WindowAPI:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Add to CoreGui
    ScreenGui.Parent = CoreGui
    
    -- Initial notification
    task.spawn(function()
        task.wait(1)
        Notify("Bloodmoon UI", "Press F4 to toggle UI", 3)
    end)
    
    return WindowAPI
end

-- Export library
return Bloodmoon