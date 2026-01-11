-- ==============================================
-- Aurora UI Library v1.0
-- Clean, Modular UI Library for Roblox Games
-- ==============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local references
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- Configuration
local CONFIG = {
    PrimaryColor = Color3.fromRGB(0, 170, 255),
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(50, 50, 50),
    
    WindowSize = UDim2.new(0, 500, 0, 400),
    MinWindowSize = UDim2.new(0, 300, 0, 200),
    MaxWindowSize = UDim2.new(0, 800, 0, 600),
    
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    
    AnimationSpeed = 0.2,
    BorderRadius = 6,
    
    SafeMobileScale = 0.7 -- Scale down on mobile
}

-- Utility Functions
local Utilities = {}

function Utilities.Create(instanceType, properties)
    local obj = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

function Utilities.Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or CONFIG.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utilities.CreateShadow(parent, sizeOffset)
    local shadow = Utilities.Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, sizeOffset or 20, 1, sizeOffset or 20),
        Position = UDim2.new(0.5, -((sizeOffset or 20)/2), 0.5, -((sizeOffset or 20)/2)),
        ZIndex = -1
    })
    shadow.Parent = parent
    return shadow
end

function Utilities.CreateRoundedFrame(parent, properties)
    local frame = Utilities.Create("Frame", properties)
    local corner = Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    })
    corner.Parent = frame
    if parent then frame.Parent = parent end
    return frame
end

function Utilities.CreateStroke(parent, color, thickness)
    local stroke = Utilities.Create("UIStroke", {
        Color = color or CONFIG.PrimaryColor,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    stroke.Parent = parent
    return stroke
end

-- Main Library
local Aurora = {}

function Aurora:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Aurora UI"
    local windowIcon = options.Icon or ""
    
    -- Create Main Container
    local ScreenGui = Utilities.Create("ScreenGui", {
        Name = "AuroraUI_" .. windowTitle,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local MainContainer = Utilities.Create("Frame", {
        Name = "MainContainer",
        BackgroundColor3 = CONFIG.BackgroundColor,
        Size = CONFIG.WindowSize,
        Position = UDim2.new(0.5, -CONFIG.WindowSize.X.Offset/2, 0.5, -CONFIG.WindowSize.Y.Offset/2),
        ClipsDescendants = true
    })
    MainContainer.Parent = ScreenGui
    
    Utilities.CreateRoundedFrame(MainContainer, {})
    Utilities.CreateStroke(MainContainer, CONFIG.PrimaryColor, 2)
    Utilities.CreateShadow(MainContainer)
    
    -- Title Bar
    local TitleBar = Utilities.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2
    })
    TitleBar.Parent = MainContainer
    
    local TitleCorner = Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, CONFIG.BorderRadius)
    })
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Utilities.Create("TextLabel", {
        Name = "TitleLabel",
        Text = windowTitle,
        Font = CONFIG.FontBold,
        TextSize = 16,
        TextColor3 = CONFIG.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    TitleLabel.Parent = TitleBar
    
    -- Window Controls
    local CloseButton = Utilities.Create("TextButton", {
        Name = "CloseButton",
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = CONFIG.TextColor,
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundTransparency = 0.2
    })
    CloseButton.Parent = TitleBar
    Utilities.CreateRoundedFrame(CloseButton, {})
    
    local MinimizeButton = Utilities.Create("TextButton", {
        Name = "MinimizeButton",
        Text = "─",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = CONFIG.TextColor,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundTransparency = 0.2
    })
    MinimizeButton.Parent = TitleBar
    Utilities.CreateRoundedFrame(MinimizeButton, {})
    
    -- Content Area
    local ContentArea = Utilities.Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -45),
        Position = UDim2.new(0, 0, 0, 45)
    })
    ContentArea.Parent = MainContainer
    
    -- Tab System
    local TabContainer = Utilities.Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    TabContainer.Parent = ContentArea
    Utilities.CreateRoundedFrame(TabContainer, {})
    
    local TabScroller = Utilities.Create("ScrollingFrame", {
        Name = "TabScroller",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    TabScroller.Parent = TabContainer
    
    local TabListLayout = Utilities.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    TabListLayout.Parent = TabScroller
    
    -- Page Container
    local PageContainer = Utilities.Create("Frame", {
        Name = "PageContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -155, 1, 0),
        Position = UDim2.new(0, 155, 0, 0)
    })
    PageContainer.Parent = ContentArea
    
    local PageFolder = Utilities.Create("Folder", {
        Name = "Pages"
    })
    PageFolder.Parent = PageContainer
    
    -- Draggable Window
    local isDragging = false
    local dragStart, startPos
    
    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateDrag(input)
        end
    end)
    
    -- Window Controls
    local isMinimized = false
    local originalSize = MainContainer.Size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Utilities.Tween(ContentArea, {Size = UDim2.new(1, 0, 0, 0)})
            Utilities.Tween(MainContainer, {Size = UDim2.new(MainContainer.Size.X.Scale, MainContainer.Size.X.Offset, 0, 40)})
        else
            Utilities.Tween(ContentArea, {Size = UDim2.new(1, 0, 1, -45)})
            Utilities.Tween(MainContainer, {Size = originalSize})
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Utilities.Tween(MainContainer, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(CONFIG.AnimationSpeed)
        ScreenGui:Destroy()
    end)
    
    -- Toggle Hotkey
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainContainer.Visible = not MainContainer.Visible
        end
    end)
    
    -- Public Methods
    local WindowAPI = {}
    local tabs = {}
    local currentTab = nil
    
    function WindowAPI:CreateTab(tabName, tabIcon)
        local tabButton = Utilities.Create("TextButton", {
            Name = "Tab_" .. tabName,
            Text = "  " .. tabName,
            Font = CONFIG.Font,
            TextSize = 14,
            TextColor3 = CONFIG.TextColor,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundTransparency = 0.8,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        tabButton.Parent = TabScroller
        Utilities.CreateRoundedFrame(tabButton, {})
        
        -- Create Page
        local pageFrame = Utilities.Create("Frame", {
            Name = "Page_" .. tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })
        pageFrame.Parent = PageFolder
        
        local pageScroller = Utilities.Create("ScrollingFrame", {
            Name = "PageScroller",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CONFIG.PrimaryColor,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        pageScroller.Parent = pageFrame
        
        local pageLayout = Utilities.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        pageLayout.Parent = pageScroller
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroller.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab Selection
        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                currentTab.Page.Visible = false
            end
            
            Utilities.Tween(tabButton, {BackgroundColor3 = CONFIG.PrimaryColor})
            pageFrame.Visible = true
            currentTab = {Button = tabButton, Page = pageFrame}
        end)
        
        -- Select first tab
        if not currentTab then
            tabButton.BackgroundColor3 = CONFIG.PrimaryColor
            pageFrame.Visible = true
            currentTab = {Button = tabButton, Page = pageFrame}
        end
        
        -- Update scroller size
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroller.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab API
        local TabAPI = {}
        
        function TabAPI:CreateSection(sectionName)
            local sectionFrame = Utilities.Create("Frame", {
                Name = "Section_" .. sectionName,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #pageScroller:GetChildren()
            })
            sectionFrame.Parent = pageScroller
            Utilities.CreateRoundedFrame(sectionFrame, {})
            Utilities.CreateStroke(sectionFrame, CONFIG.AccentColor)
            
            local sectionTitle = Utilities.Create("TextLabel", {
                Name = "SectionTitle",
                Text = sectionName,
                Font = CONFIG.FontBold,
                TextSize = 14,
                TextColor3 = CONFIG.PrimaryColor,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            sectionTitle.Parent = sectionFrame
            
            local contentContainer = Utilities.Create("Frame", {
                Name = "ContentContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -30),
                Position = UDim2.new(0, 10, 0, 30)
            })
            contentContainer.Parent = sectionFrame
            
            local contentLayout = Utilities.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            contentLayout.Parent = contentContainer
            
            -- Section API
            local SectionAPI = {}
            
            function SectionAPI:CreateButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                local buttonName = buttonConfig.Name or "Button"
                local callback = buttonConfig.Callback or function() end
                
                local button = Utilities.Create("TextButton", {
                    Name = "Button_" .. buttonName,
                    Text = buttonName,
                    Font = CONFIG.Font,
                    TextSize = 13,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundColor3 = CONFIG.AccentColor,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 0.2,
                    AutoButtonColor = false
                })
                button.Parent = contentContainer
                Utilities.CreateRoundedFrame(button, {})
                
                local buttonStroke = Utilities.CreateStroke(button, CONFIG.PrimaryColor, 1)
                buttonStroke.Transparency = 0.8
                
                -- Hover effects
                button.MouseEnter:Connect(function()
                    Utilities.Tween(button, {BackgroundTransparency = 0})
                    Utilities.Tween(buttonStroke, {Transparency = 0})
                end)
                
                button.MouseLeave:Connect(function()
                    Utilities.Tween(button, {BackgroundTransparency = 0.2})
                    Utilities.Tween(buttonStroke, {Transparency = 0.8})
                end)
                
                -- Click
                button.MouseButton1Click:Connect(function()
                    Utilities.Tween(button, {Size = UDim2.new(1, -5, 0, 32)})
                    task.wait(0.1)
                    Utilities.Tween(button, {Size = UDim2.new(1, 0, 0, 35)})
                    callback()
                end)
                
                -- Update section size
                contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sectionFrame.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
                end)
                
                local ButtonAPI = {}
                
                function ButtonAPI:SetText(newText)
                    button.Text = newText
                end
                
                function ButtonAPI:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return ButtonAPI
            end
            
            function SectionAPI:CreateToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local toggleName = toggleConfig.Name or "Toggle"
                local defaultValue = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end
                
                local toggleValue = defaultValue
                
                local toggleFrame = Utilities.Create("Frame", {
                    Name = "Toggle_" .. toggleName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                toggleFrame.Parent = contentContainer
                
                local toggleLabel = Utilities.Create("TextLabel", {
                    Name = "ToggleLabel",
                    Text = toggleName,
                    Font = CONFIG.Font,
                    TextSize = 13,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                toggleLabel.Parent = toggleFrame
                
                local toggleButton = Utilities.Create("TextButton", {
                    Name = "ToggleButton",
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0.5, -10),
                    BackgroundTransparency = 0.2
                })
                toggleButton.Parent = toggleFrame
                Utilities.CreateRoundedFrame(toggleButton, {})
                Utilities.CreateStroke(toggleButton, CONFIG.PrimaryColor, 1)
                
                local toggleCircle = Utilities.Create("Frame", {
                    Name = "ToggleCircle",
                    BackgroundColor3 = CONFIG.TextColor,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundTransparency = 0
                })
                toggleCircle.Parent = toggleButton
                Utilities.CreateRoundedFrame(toggleCircle, {})
                
                local function UpdateToggle()
                    if toggleValue then
                        Utilities.Tween(toggleButton, {BackgroundColor3 = CONFIG.PrimaryColor})
                        Utilities.Tween(toggleCircle, {Position = UDim2.new(0, 22, 0.5, -8)})
                    else
                        Utilities.Tween(toggleButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                        Utilities.Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)})
                    end
                    callback(toggleValue)
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    toggleValue = not toggleValue
                    UpdateToggle()
                end)
                
                UpdateToggle()
                
                local ToggleAPI = {}
                
                function ToggleAPI:GetValue()
                    return toggleValue
                end
                
                function ToggleAPI:SetValue(value)
                    toggleValue = value
                    UpdateToggle()
                end
                
                function ToggleAPI:Toggle()
                    toggleValue = not toggleValue
                    UpdateToggle()
                end
                
                return ToggleAPI
            end
            
            function SectionAPI:CreateSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local sliderName = sliderConfig.Name or "Slider"
                local minValue = sliderConfig.Min or 0
                local maxValue = sliderConfig.Max or 100
                local defaultValue = sliderConfig.Default or 50
                local callback = sliderConfig.Callback or function() end
                local step = sliderConfig.Step or 1
                
                local currentValue = defaultValue
                
                local sliderFrame = Utilities.Create("Frame", {
                    Name = "Slider_" .. sliderName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60)
                })
                sliderFrame.Parent = contentContainer
                
                local sliderLabel = Utilities.Create("TextLabel", {
                    Name = "SliderLabel",
                    Text = sliderName .. ": " .. currentValue,
                    Font = CONFIG.Font,
                    TextSize = 13,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                sliderLabel.Parent = sliderFrame
                
                local sliderTrack = Utilities.Create("Frame", {
                    Name = "SliderTrack",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundTransparency = 0.2
                })
                sliderTrack.Parent = sliderFrame
                Utilities.CreateRoundedFrame(sliderTrack, {})
                
                local sliderFill = Utilities.Create("Frame", {
                    Name = "SliderFill",
                    BackgroundColor3 = CONFIG.PrimaryColor,
                    Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0),
                    BackgroundTransparency = 0
                })
                sliderFill.Parent = sliderTrack
                Utilities.CreateRoundedFrame(sliderFill, {})
                
                local sliderButton = Utilities.Create("TextButton", {
                    Name = "SliderButton",
                    Text = "",
                    BackgroundColor3 = CONFIG.TextColor,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -8, 0.5, -8),
                    BackgroundTransparency = 0
                })
                sliderButton.Parent = sliderTrack
                Utilities.CreateRoundedFrame(sliderButton, {})
                Utilities.CreateStroke(sliderButton, CONFIG.PrimaryColor)
                
                local isSliding = false
                
                local function UpdateSlider(value)
                    value = math.clamp(value, minValue, maxValue)
                    if step > 1 then
                        value = math.floor(value / step + 0.5) * step
                    end
                    
                    currentValue = value
                    local percentage = (value - minValue) / (maxValue - minValue)
                    
                    Utilities.Tween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)})
                    Utilities.Tween(sliderButton, {Position = UDim2.new(percentage, -8, 0.5, -8)})
                    sliderLabel.Text = sliderName .. ": " .. math.floor(value)
                    
                    callback(value)
                end
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSliding = true
                    end
                end)
                
                sliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSliding = false
                    end
                end)
                
                sliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local x = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                        UpdateSlider(minValue + (maxValue - minValue) * x)
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local x = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                        UpdateSlider(minValue + (maxValue - minValue) * x)
                    end
                end)
                
                UpdateSlider(defaultValue)
                
                local SliderAPI = {}
                
                function SliderAPI:GetValue()
                    return currentValue
                end
                
                function SliderAPI:SetValue(value)
                    UpdateSlider(value)
                end
                
                return SliderAPI
            end
            
            function SectionAPI:CreateTextBox(textboxConfig)
                textboxConfig = textboxConfig or {}
                local textboxName = textboxConfig.Name or "Text Box"
                local placeholder = textboxConfig.Placeholder or "Type here..."
                local defaultValue = textboxConfig.Default or ""
                local callback = textboxConfig.Callback or function() end
                
                local textboxFrame = Utilities.Create("Frame", {
                    Name = "TextBox_" .. textboxName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                textboxFrame.Parent = contentContainer
                
                local textboxLabel = Utilities.Create("TextLabel", {
                    Name = "TextBoxLabel",
                    Text = textboxName,
                    Font = CONFIG.Font,
                    TextSize = 13,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                textboxLabel.Parent = textboxFrame
                
                local inputBox = Utilities.Create("TextBox", {
                    Name = "InputBox",
                    Text = defaultValue,
                    PlaceholderText = placeholder,
                    Font = CONFIG.Font,
                    TextSize = 12,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    BackgroundTransparency = 0.2,
                    ClearTextOnFocus = false
                })
                inputBox.Parent = textboxFrame
                Utilities.CreateRoundedFrame(inputBox, {})
                Utilities.CreateStroke(inputBox, CONFIG.AccentColor, 1)
                
                inputBox.Focused:Connect(function()
                    Utilities.Tween(inputBox.UIStroke, {Color = CONFIG.PrimaryColor})
                end)
                
                inputBox.FocusLost:Connect(function()
                    Utilities.Tween(inputBox.UIStroke, {Color = CONFIG.AccentColor})
                    callback(inputBox.Text)
                end)
                
                local TextBoxAPI = {}
                
                function TextBoxAPI:GetText()
                    return inputBox.Text
                end
                
                function TextBoxAPI:SetText(text)
                    inputBox.Text = text
                end
                
                return TextBoxAPI
            end
            
            function SectionAPI:CreateLabel(labelConfig)
                labelConfig = labelConfig or {}
                local labelText = labelConfig.Text or "Label"
                local textSize = labelConfig.TextSize or 13
                local textColor = labelConfig.Color or CONFIG.TextColor
                
                local labelFrame = Utilities.Create("TextLabel", {
                    Name = "Label",
                    Text = labelText,
                    Font = CONFIG.Font,
                    TextSize = textSize,
                    TextColor3 = textColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                labelFrame.Parent = contentContainer
                
                local LabelAPI = {}
                
                function LabelAPI:SetText(text)
                    labelFrame.Text = text
                end
                
                function LabelAPI:SetColor(color)
                    labelFrame.TextColor3 = color
                end
                
                return LabelAPI
            end
            
            function SectionAPI:CreateDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local dropdownName = dropdownConfig.Name or "Dropdown"
                local options = dropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                local defaultValue = dropdownConfig.Default or options[1]
                local callback = dropdownConfig.Callback or function() end
                
                local currentValue = defaultValue
                local isOpen = false
                
                local dropdownFrame = Utilities.Create("Frame", {
                    Name = "Dropdown_" .. dropdownName,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                dropdownFrame.Parent = contentContainer
                
                local dropdownLabel = Utilities.Create("TextLabel", {
                    Name = "DropdownLabel",
                    Text = dropdownName,
                    Font = CONFIG.Font,
                    TextSize = 13,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                dropdownLabel.Parent = dropdownFrame
                
                local dropdownButton = Utilities.Create("TextButton", {
                    Name = "DropdownButton",
                    Text = currentValue,
                    Font = CONFIG.Font,
                    TextSize = 12,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    BackgroundTransparency = 0.2
                })
                dropdownButton.Parent = dropdownFrame
                Utilities.CreateRoundedFrame(dropdownButton, {})
                Utilities.CreateStroke(dropdownButton, CONFIG.AccentColor, 1)
                
                local dropdownIcon = Utilities.Create("TextLabel", {
                    Name = "DropdownIcon",
                    Text = "▼",
                    Font = CONFIG.Font,
                    TextSize = 10,
                    TextColor3 = CONFIG.TextColor,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Center
                })
                dropdownIcon.Parent = dropdownButton
                
                local dropdownList = Utilities.Create("ScrollingFrame", {
                    Name = "DropdownList",
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = CONFIG.PrimaryColor,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Visible = false
                })
                dropdownList.Parent = dropdownButton
                Utilities.CreateRoundedFrame(dropdownList, {})
                Utilities.CreateStroke(dropdownList, CONFIG.AccentColor, 1)
                
                local listLayout = Utilities.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                listLayout.Parent = dropdownList
                
                local function UpdateDropdown()
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            if child.Text == currentValue then
                                child.BackgroundColor3 = CONFIG.PrimaryColor
                            else
                                child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            end
                        end
                    end
                    callback(currentValue)
                end
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        dropdownList.Visible = true
                        Utilities.Tween(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))})
                        Utilities.Tween(dropdownIcon, {Rotation = 180})
                    else
                        Utilities.Tween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)})
                        Utilities.Tween(dropdownIcon, {Rotation = 0})
                        task.wait(0.2)
                        dropdownList.Visible = false
                    end
                end
                
                -- Populate options
                for _, option in ipairs(options) do
                    local optionButton = Utilities.Create("TextButton", {
                        Name = "Option_" .. option,
                        Text = option,
                        Font = CONFIG.Font,
                        TextSize = 12,
                        TextColor3 = CONFIG.TextColor,
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        Size = UDim2.new(1, -10, 0, 28),
                        BackgroundTransparency = 0.2,
                        AutoButtonColor = false
                    })
                    optionButton.Parent = dropdownList
                    Utilities.CreateRoundedFrame(optionButton, {})
                    
                    optionButton.MouseButton1Click:Connect(function()
                        currentValue = option
                        dropdownButton.Text = option
                        ToggleDropdown()
                        UpdateDropdown()
                    end)
                end
                
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                end)
                
                dropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                UpdateDropdown()
                
                local DropdownAPI = {}
                
                function DropdownAPI:GetValue()
                    return currentValue
                end
                
                function DropdownAPI:SetValue(value)
                    if table.find(options, value) then
                        currentValue = value
                        dropdownButton.Text = value
                        UpdateDropdown()
                    end
                end
                
                function DropdownAPI:SetOptions(newOptions)
                    options = newOptions
                    for _, child in pairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, option in ipairs(newOptions) do
                        local optionButton = Utilities.Create("TextButton", {
                            Name = "Option_" .. option,
                            Text = option,
                            Font = CONFIG.Font,
                            TextSize = 12,
                            TextColor3 = CONFIG.TextColor,
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                            Size = UDim2.new(1, -10, 0, 28),
                            BackgroundTransparency = 0.2,
                            AutoButtonColor = false
                        })
                        optionButton.Parent = dropdownList
                        Utilities.CreateRoundedFrame(optionButton, {})
                        
                        optionButton.MouseButton1Click:Connect(function()
                            currentValue = option
                            dropdownButton.Text = option
                            ToggleDropdown()
                            UpdateDropdown()
                        end)
                    end
                end
                
                return DropdownAPI
            end
            
            return SectionAPI
        end
        
        return TabAPI
    end
    
    function WindowAPI:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end
    
    function WindowAPI:SetVisible(visible)
        MainContainer.Visible = visible
    end
    
    function WindowAPI:ToggleVisibility()
        MainContainer.Visible = not MainContainer.Visible
    end
    
    function WindowAPI:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Parent to CoreGui
    ScreenGui.Parent = CoreGui
    
    return WindowAPI
end

-- Export the library
return Aurora