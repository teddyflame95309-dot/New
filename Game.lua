-- CONFIGURATION
local debugX = true -- Debug mode enabled

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Debug function
local function Debug(msg)
    if debugX then
        print("[DEBUG] " .. tostring(msg))
    end
end

-- Settings
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.15,
        TargetPart = "Head",
        TeamCheck = false, -- You said you turned this off
        VisibleCheck = false,
        WallCheck = false
    },
    Speed = {
        Enabled = false,
        Velocity = 60, -- Velocity-based (undetected)
        Keybind = Enum.KeyCode.LeftShift
    },
    ESP = {
        Enabled = false,
        ShowBoxes = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        MaxDistance = 1000,
        TeamCheck = false
    },
    Misc = {
        InfiniteJump = false,
        NoClip = false
    }
}

-- Storage
local ESPObjects = {}
local Highlights = {}
local SpeedConnection = nil

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Rivals Script Fixed",
    Icon = 0,
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Fixed Version",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RivalsScript",
        FileName = "Settings"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

-- TABS
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- AIMBOT SECTION
AimbotTab:CreateSection("Aimbot Settings")

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        Settings.Aimbot.Enabled = Value
        Debug("Aimbot: " .. tostring(Value))
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 400},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "AimbotFOV",
    Callback = function(Value)
        Settings.Aimbot.FOV = Value
        Debug("FOV set to: " .. Value)
    end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 15,
    Flag = "AimbotSmooth",
    Callback = function(Value)
        Settings.Aimbot.Smoothness = Value / 100
        Debug("Smoothness: " .. Settings.Aimbot.Smoothness)
    end
})

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    CurrentOption = "Head",
    Flag = "TargetPart",
    Callback = function(Option)
        Settings.Aimbot.TargetPart = Option
        Debug("Target part: " .. Option)
    end
})

-- VISUALS SECTION
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        Settings.ESP.Enabled = Value
        Debug("ESP: " .. tostring(Value))
    end
})

VisualsTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Flag = "ESPBoxes",
    Callback = function(Value)
        Settings.ESP.ShowBoxes = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ESPNames",
    Callback = function(Value)
        Settings.ESP.ShowNames = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(Value)
        Settings.ESP.ShowHealth = Value
    end
})

VisualsTab:CreateSlider({
    Name = "Max ESP Distance",
    Range = {100, 5000},
    Increment = 100,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "ESPDistance",
    Callback = function(Value)
        Settings.ESP.MaxDistance = Value
    end
})

-- MOVEMENT SECTION
MovementTab:CreateSection("Speed Settings")

MovementTab:CreateToggle({
    Name = "Enable Velocity Speed",
    CurrentValue = false,
    Flag = "SpeedEnabled",
    Callback = function(Value)
        Settings.Speed.Enabled = Value
        Debug("Speed toggle: " .. tostring(Value))
    end
})

MovementTab:CreateSlider({
    Name = "Speed Velocity",
    Range = {20, 200},
    Increment = 5,
    Suffix = " velocity",
    CurrentValue = 60,
    Flag = "SpeedValue",
    Callback = function(Value)
        Settings.Speed.Velocity = Value
        Debug("Speed velocity: " .. Value)
    end
})

MovementTab:CreateKeybind({
    Name = "Speed Keybind",
    CurrentKeybind = "LeftShift",
    HoldToInteract = true,
    Flag = "SpeedKeybind",
    Callback = function(Keybind)
        Settings.Speed.Keybind = Keybind
    end
})

-- MISC SECTION
MiscTab:CreateSection("Other Features")

MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        Settings.Misc.InfiniteJump = Value
    end
})

-- UTILITY FUNCTIONS

local function IsTeammate(player)
    if player == LocalPlayer then return true end
    if not Settings.Aimbot.TeamCheck and not Settings.ESP.TeamCheck then return false end
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not Settings.Aimbot.VisibleCheck then return true end
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction.Unit * 1000, raycastParams)
    return result == nil
end

-- VELOCITY SPEED (UNDEtected method)
local function SetupSpeed()
    if SpeedConnection then SpeedConnection:Disconnect() end
    
    SpeedConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Speed.Enabled then return end
        if not LocalPlayer.Character then return end
        if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if not Humanoid then return end
        
        -- Check if moving
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        
        -- Apply velocity when moving
        if moveDirection.Magnitude > 0 then
            moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
            
            -- Use velocity instead of WalkSpeed (undetected)
            local targetVelocity = moveDirection * Settings.Speed.Velocity
            
            -- Apply to HumanoidRootPart
            HRP.Velocity = Vector3.new(targetVelocity.X, HRP.Velocity.Y, targetVelocity.Z)
            
            -- Alternative: Use CFrame for more control
            -- HRP.CFrame = HRP.CFrame + (moveDirection * Settings.Speed.Velocity * 0.016)
        end
    end)
end

SetupSpeed()

-- AIMBOT FUNCTIONS
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot.FOV
    
    Debug("Searching for targets...")
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            Debug("Checking player: " .. player.Name)
            
            -- Check team
            if IsTeammate(player) then
                Debug("Skipping teammate: " .. player.Name)
                continue
            end
            
            -- Check character
            if not player.Character then
                Debug("No character for: " .. player.Name)
                continue
            end
            
            -- Check target part
            local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if not targetPart or not humanoid or not hrp then
                Debug("Missing parts for: " .. player.Name)
                continue
            end
            
            -- Check if alive
            if humanoid.Health <= 0 then
                Debug("Player dead: " .. player.Name)
                continue
            end
            
            -- Get screen position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if not onScreen then
                Debug("Player off screen: " .. player.Name)
                continue
            end
            
            -- Calculate distance from center
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            
            Debug("Distance from center: " .. distanceFromCenter .. " (FOV: " .. Settings.Aimbot.FOV .. ")")
            
            if distanceFromCenter < shortestDistance then
                -- Visibility check
                if Settings.Aimbot.VisibleCheck and not IsVisible(targetPart) then
                    Debug("Player not visible: " .. player.Name)
                    continue
                end
                
                closestPlayer = {
                    Player = player,
                    Character = player.Character,
                    Part = targetPart,
                    ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
                    Distance = distanceFromCenter
                }
                shortestDistance = distanceFromCenter
                Debug("New target: " .. player.Name)
            end
        end
    end
    
    return closestPlayer
end

local function AimAt(target)
    if not target then return end
    if not target.Part then return end
    
    local targetPos = target.ScreenPosition
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Calculate delta
    local delta = (targetPos - screenCenter) * Settings.Aimbot.Smoothness
    
    Debug("Aiming: delta X=" .. delta.X .. " Y=" .. delta.Y)
    
    -- Move mouse (try multiple methods)
    local success = false
    
    -- Method 1: mousemoverel
    if mousemoverel then
        pcall(function()
            mousemoverel(delta.X, delta.Y)
            success = true
            Debug("Used mousemoverel")
        end)
    end
    
    -- Method 2: mousemoveabs (some executors)
    if not success and mousemoveabs then
        pcall(function()
            local newPos = Vector2.new(screenCenter.X + delta.X, screenCenter.Y + delta.Y)
            mousemoveabs(newPos.X, newPos.Y)
            success = true
            Debug("Used mousemoveabs")
        end)
    end
    
    -- Method 3: CFrame manipulation (silent aim style)
    if not success then
        pcall(function()
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.Aimbot.Smoothness)
            Debug("Used CFrame lerp")
        end)
    end
end

-- ESP FUNCTIONS
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square")
    }
    
    local drawings = ESPObjects[player]
    
    -- Box
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Color = Color3.fromRGB(255, 0, 0)
    drawings.Box.Visible = false
    
    drawings.BoxOutline.Thickness = 3
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.BoxOutline.Visible = false
    
    -- Name
    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    drawings.Name.Visible = false
    
    -- Distance
    drawings.Distance.Size = 11
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Color = Color3.fromRGB(200, 200, 200)
    drawings.Distance.Visible = false
    
    -- Health bar
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Visible = false
    
    drawings.HealthBarBg.Thickness = 1
    drawings.HealthBarBg.Filled = true
    drawings.HealthBarBg.Color = Color3.fromRGB(40, 40, 40)
    drawings.HealthBarBg.Visible = false
    
    Debug("Created ESP for: " .. player.Name)
end

local function UpdateESP(player)
    if not ESPObjects[player] then CreateESP(player) end
    
    local drawings = ESPObjects[player]
    
    -- Check if should show
    if not Settings.ESP.Enabled then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    if not player.Character then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    -- Check team
    if Settings.ESP.TeamCheck and IsTeammate(player) then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local head = player.Character:FindFirstChild("Head")
    
    if not humanoid or not hrp or not head then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    if humanoid.Health <= 0 then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    -- Distance check
    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
    if distance > Settings.ESP.MaxDistance then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    -- Get positions
    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)
    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
    
    if not rootOnScreen then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    -- Calculate box
    local boxHeight = math.abs(headPos.Y - rootPos.Y) + 10
    local boxWidth = boxHeight * 0.6
    local boxPosition = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y - 5)
    
    -- Update Box
    if Settings.ESP.ShowBoxes then
        drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
        drawings.BoxOutline.Position = boxPosition
        drawings.BoxOutline.Visible = true
        
        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        drawings.Box.Position = boxPosition
        drawings.Box.Visible = true
    else
        drawings.Box.Visible = false
        drawings.BoxOutline.Visible = false
    end
    
    -- Update Name
    if Settings.ESP.ShowNames then
        drawings.Name.Text = player.Name
        drawings.Name.Position = Vector2.new(rootPos.X, boxPosition.Y - 15)
        drawings.Name.Visible = true
    else
        drawings.Name.Visible = false
    end
    
    -- Update Distance
    if Settings.ESP.ShowDistance then
        drawings.Distance.Text = math.floor(distance) .. "m"
        drawings.Distance.Position = Vector2.new(rootPos.X, boxPosition.Y + boxHeight + 2)
        drawings.Distance.Visible = true
    else
        drawings.Distance.Visible = false
    end
    
    -- Update Health Bar
    if Settings.ESP.ShowHealth then
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barWidth = 4
        local barHeight = boxHeight * healthPercent
        
        drawings.HealthBarBg.Size = Vector2.new(barWidth, boxHeight)
        drawings.HealthBarBg.Position = Vector2.new(boxPosition.X + boxWidth + 3, boxPosition.Y)
        drawings.HealthBarBg.Visible = true
        
        drawings.HealthBar.Size = Vector2.new(barWidth, barHeight)
        drawings.HealthBar.Position = Vector2.new(boxPosition.X + boxWidth + 3, boxPosition.Y + boxHeight - barHeight)
        
        -- Color based on health
        if healthPercent > 0.6 then
            drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        elseif healthPercent > 0.3 then
            drawings.HealthBar.Color = Color3.fromRGB(255, 255, 0)
        else
            drawings.HealthBar.Color = Color3.fromRGB(255, 0, 0)
        end
        
        drawings.HealthBar.Visible = true
    else
        drawings.HealthBar.Visible = false
        drawings.HealthBarBg.Visible = false
    end
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
        Debug("Removed ESP for: " .. player.Name)
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if Settings.Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target then
            AimAt(target)
        end
    end
    
    -- ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            UpdateESP(player)
        end
    end
    
    -- Cleanup ESP
    for player, _ in pairs(ESPObjects) do
        if not player.Parent then
            RemoveESP(player)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.Misc.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Player added/removed
Players.PlayerAdded:Connect(function(player)
    Debug("Player joined: " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Character added
LocalPlayer.CharacterAdded:Connect(function(char)
    Debug("Character spawned")
    SetupSpeed() -- Re-setup speed on respawn
end)

-- Load configuration
Rayfield:LoadConfiguration()

Debug("Script loaded successfully!")
print("=== RIVALS SCRIPT LOADED ===")
print("Features: Velocity Speed (Undetected), Aimbot, ESP")
print("Debug Mode: ON - Check console for info")
