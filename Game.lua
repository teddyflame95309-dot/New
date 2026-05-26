-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration
local Config = {
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.15,
        TargetPart = "Head",
        TeamCheck = true,
        VisibleCheck = true
    },
    SpeedHack = {
        Enabled = false,
        Speed = 50,
        DefaultSpeed = 16
    },
    InfiniteJump = {
        Enabled = false
    },
    ESP = {
        Enabled = false,
        ShowBoxes = true,
        ShowHealth = true,
        Show3D = true,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        MaxDistance = 2000
    }
}

-- Storage
local ESPObjects = {}
local Highlights3D = {}

-- FOV Circle - CENTERED ON SCREEN
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.NumSides = 64
-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RIVALS SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame
-- DRAGGING (Fixed)
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- MINIMIZE
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    MinimizeBtn.Text = minimized and "+" or "-"
    
    local targetSize = minimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 450)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
end)

-- CLOSE
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    for _, obj in pairs(ESPObjects) do
        for _, drawing in pairs(obj) do
            drawing:Remove()
        end
    end
    for _, highlight in pairs(Highlights3D) do
        if highlight then highlight:Destroy() end
    end
end)
-- Helper: Create Section Header
local function CreateSection(text)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 25)
    Section.BackgroundTransparency = 1
    Section.Parent = ScrollingFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(0, 170, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Section
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 2)
    Line.Position = UDim2.new(0, 0, 1, -2)
    Line.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

-- Helper: Create Toggle
local function CreateToggle(name, configTable, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = ScrollingFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 50, 0, 24)
    ToggleBg.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = Frame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleBg
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(0, 2, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleBg
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0.5, 0)
    BtnCorner.Parent = ToggleBtn
    
    local function UpdateToggle()
        local enabled = configTable[configKey]
        ToggleBg.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        ToggleBtn.Position = enabled and UDim2.new(0, 28, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        if callback then callback(enabled) end
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        UpdateToggle()
    end)
    
    UpdateToggle()
    return Frame
end
-- Helper: Create Slider (FIXED)
local function CreateSlider(name, configTable, configKey, min, max, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 55)
    Frame.BackgroundTransparency = 1
    Frame.Parent = ScrollingFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. configTable[configKey]
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -40, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(configTable[configKey])
    ValueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Frame
    
    -- Slider Background (TextButton for click detection)
    local SliderBg = Instance.new("TextButton")
    SliderBg.Name = "SliderBg"
    SliderBg.Size = UDim2.new(1, 0, 0, 12)
    SliderBg.Position = UDim2.new(0, 0, 0, 28)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBg.BorderSizePixel = 0
    SliderBg.Text = ""
    SliderBg.AutoButtonColor = false
    SliderBg.Parent = Frame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 6)
    BgCorner.Parent = SliderBg
    
    -- Fill
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    local initialPercent = (configTable[configKey] - min) / (max - min)
    Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBg
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 6)
    FillCorner.Parent = Fill
    
    -- Slider Logic
    local isDragging = false
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * (max - min)))
        
        configTable[configKey] = value
        Label.Text = name .. ": " .. value
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        
        if callback then callback(value) end
    end
    
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            UpdateSlider(input)
        end
    end)
    
    SliderBg.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end
-- Create UI
CreateSection("AIMBOT")
CreateToggle("Enable Aimbot", Config.Aimbot, "Enabled")
CreateToggle("Team Check", Config.Aimbot, "TeamCheck")
CreateToggle("Visible Check", Config.Aimbot, "VisibleCheck")
CreateSlider("FOV Size", Config.Aimbot, "FOV", 50, 400)
CreateSlider("Smoothness", Config.Aimbot, "Smoothness", 1, 50, function(val)
    Config.Aimbot.Smoothness = val / 100
end)

CreateSection("SPEED HACK")
CreateToggle("Enable Speed", Config.SpeedHack, "Enabled", function(state)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = state and Config.SpeedHack.Speed or Config.SpeedHack.DefaultSpeed
    end
end)
CreateSlider("Speed Value", Config.SpeedHack, "Speed", 16, 70, function(val)
    if Config.SpeedHack.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

CreateSection("INFINITE JUMP")
CreateToggle("Enable Inf Jump", Config.InfiniteJump, "Enabled")

CreateSection("ESP")
CreateToggle("Enable ESP", Config.ESP, "Enabled")
CreateToggle("Show 2D Boxes", Config.ESP, "ShowBoxes")
CreateToggle("Show 3D Highlight", Config.ESP, "Show3D")
CreateToggle("Show Health Bar", Config.ESP, "ShowHealth")
CreateToggle("ESP Team Check", Config.ESP, "TeamCheck")
-- UTILITY FUNCTIONS

local function IsTeammate(player)
    if player == LocalPlayer then return true end
    if not Config.Aimbot.TeamCheck and not Config.ESP.TeamCheck then return false end
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not Config.Aimbot.VisibleCheck then return true end
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local distance = direction.Magnitude
    direction = direction.Unit * distance
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetCharacterBounds(character)
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return nil end
    
    return {
        Root = hrp.Position,
        Head = head.Position,
        Height = (head.Position - hrp.Position).Magnitude + 4,
        Width = 4
    }
end

-- 3D ESP
local function Create3DHighlight(player)
    if Highlights3D[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Config.ESP.BoxColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlights3D[player] = highlight
end

local function Update3DHighlight(player, character)
    if not Config.ESP.Show3D or not Config.ESP.Enabled then
        if Highlights3D[player] then Highlights3D[player].Parent = nil end
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        if Highlights3D[player] then Highlights3D[player].Parent = nil end
        return
    end
    
    Create3DHighlight(player)
    local highlight = Highlights3D[player]
    highlight.Parent = character
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    if healthPercent > 0.6 then
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
    elseif healthPercent > 0.3 then
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
    else
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
    end
end
-- 2D ESP
local function CreateESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    
    local obj = ESPObjects[player]
    obj.Box.Thickness = 1
    obj.Box.Filled = false
    obj.BoxOutline.Thickness = 3
    obj.BoxOutline.Filled = false
    obj.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    obj.HealthBar.Thickness = 1
    obj.HealthBar.Filled = true
    obj.HealthBarBg.Thickness = 1
    obj.HealthBarBg.Filled = true
    obj.HealthBarBg.Color = Color3.fromRGB(40, 40, 40)
    obj.Name.Size = 13
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    obj.Distance.Size = 11
    obj.Distance.Center = true
    obj.Distance.Outline = true
    obj.Distance.Color = Color3.fromRGB(200, 200, 200)
end

local function UpdateESP(player, character)
    local obj = ESPObjects[player]
    if not obj then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp or humanoid.Health <= 0 then
        for _, drawing in pairs(obj) do drawing.Visible = false end
        return
    end
    
    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
    if distance > Config.ESP.MaxDistance then
        for _, drawing in pairs(obj) do drawing.Visible = false end
        return
    end
    
    local bounds = GetCharacterBounds(character)
    if not bounds then
        for _, drawing in pairs(obj) do drawing.Visible = false end
        return
    end
    
    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(bounds.Root)
    local headPos, headOnScreen = Camera:WorldToViewportPoint(bounds.Head + Vector3.new(0, 1, 0))
    
    if not rootOnScreen then
        for _, drawing in pairs(obj) do drawing.Visible = false end
        return
    end
    
    local boxHeight = math.abs(headPos.Y - rootPos.Y) + 15
    local boxWidth = boxHeight * 0.6
    local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y - 5)
    
    if Config.ESP.ShowBoxes then
        obj.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
        obj.BoxOutline.Position = boxPos
        obj.BoxOutline.Visible = true
        obj.Box.Size = Vector2.new(boxWidth, boxHeight)
        obj.Box.Position = boxPos
        obj.Box.Color = Config.ESP.BoxColor
        obj.Box.Visible = true
    else
        obj.Box.Visible = false
        obj.BoxOutline.Visible = false
    end
    
    if Config.ESP.ShowHealth then
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barWidth = 4
        local barHeight = boxHeight * healthPercent
        local barX = boxPos.X + boxWidth + 3
        local barY = boxPos.Y
        
        obj.HealthBarBg.Size = Vector2.new(barWidth, boxHeight)
        obj.HealthBarBg.Position = Vector2.new(barX, barY)
        obj.HealthBarBg.Visible = true
        
        obj.HealthBar.Size = Vector2.new(barWidth, barHeight)
        obj.HealthBar.Position = Vector2.new(barX, barY + boxHeight - barHeight)
        
        if healthPercent > 0.6 then obj.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        elseif healthPercent > 0.3 then obj.HealthBar.Color = Color3.fromRGB(255, 255, 0)
        else obj.HealthBar.Color = Color3.fromRGB(255, 0, 0) end
        
        obj.HealthBar.Visible = true
    else
        obj.HealthBar.Visible = false
        obj.HealthBarBg.Visible = false
    end
    
    obj.Name.Text = player.Name
    obj.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 15)
    obj.Name.Visible = true
    
    obj.Distance.Text = math.floor(distance) .. "m"
    obj.Distance.Position = Vector2.new(rootPos.X, boxPos.Y + boxHeight + 2)
    obj.Distance.Visible = true
end
-- AIMBOT
local function GetTarget()
    local closest = nil
    local shortestDist = Config.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not IsTeammate(player) then
            local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - 
                        Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    
                    if distFromCenter < shortestDist and IsVisible(targetPart) then
                        shortestDist = distFromCenter
                        closest = {
                            Player = player,
                            Part = targetPart,
                            ScreenPos = screenPos
                        }
                    end
                end
            end
        end
    end
    
    return closest
end

local function SmoothAim(targetPos)
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetVector = Vector2.new(targetPos.X, targetPos.Y)
    local delta = (targetVector - mousePos) * Config.Aimbot.Smoothness
    
    -- Try mousemoverel
    if mousemoverel then
        mousemoverel(delta.X, delta.Y)
    end
end
-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FOV Circle CENTERED ON SCREEN (FIXED)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    -- ESP Updates
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character then
            CreateESP(player)
            Create3DHighlight(player)
            
            if Config.ESP.Enabled then
                UpdateESP(player, player.Character)
                Update3DHighlight(player, player.Character)
            else
                if ESPObjects[player] then
                    for _, drawing in pairs(ESPObjects[player]) do drawing.Visible = false end
                end
                if Highlights3D[player] then Highlights3D[player].Parent = nil end
            end
        end
    end
    
    -- Cleanup
    for player, obj in pairs(ESPObjects) do
        if not player.Parent then
            for _, drawing in pairs(obj) do drawing:Remove() end
            ESPObjects[player] = nil
        end
    end
    
    for player, highlight in pairs(Highlights3D) do
        if not player.Parent then
            highlight:Destroy()
            Highlights3D[player] = nil
        end
    end
    
    -- Aimbot
    if Config.Aimbot.Enabled then
        local target = GetTarget()
        if target then
            SmoothAim(target.ScreenPos)
            FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump.Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Character spawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if Config.SpeedHack.Enabled then
        char.Humanoid.WalkSpeed = Config.SpeedHack.Speed
    end
end)

-- Initial setup
if LocalPlayer.Character then
    if Config.SpeedHack.Enabled then
        LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Config.SpeedHack.Speed
    end
end

print("=== RIVALS SCRIPT LOADED ===")
