-- Eclipse Hub - MM2 (Christmas, Coin Fix, Kill All, Teleport & Fling)
-- Built with Rayfield Interface Suite

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables for Logic
local ESP_Enabled = false
local Fly_Enabled = false
local CurrentWalkSpeed = 16
local WalkSpeed_Enabled = false
local AutoFarm_Enabled = false 
local KillAll_Enabled = false 

-- Fling Variables
local Fling_Enabled = false
local Fling_Target_Name = ""
local Fling_Loop = nil

-- Force Cursor Visibility
UserInputService.MouseIconEnabled = true
local function forceCursor()
    while true do
        wait(1)
        UserInputService.MouseIconEnabled = true
    end
end
task.spawn(forceCursor)

--------------------------------------------------------------------------------------
-- Window Setup
--------------------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Vant hub - MM2",
   Icon = 0, 
   LoadingTitle = "Eclipse Hub",
   LoadingSubtitle = "by Nop",
   Theme = "Amethyst",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "EclipseHubMM2",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "https://discord.gg/wFKRPQxAnF",
      RememberJoins = true
   },
   KeySystem = false,
})

--------------------------------------------------------------------------------------
-- Helper Functions (MM2 Logic)
--------------------------------------------------------------------------------------

local function getRole(player)
    if player and player.Character then
        local items = player.Backpack:GetChildren()
        if player.Character:FindFirstChildOfClass("Tool") then
            table.insert(items, player.Character:FindFirstChildOfClass("Tool"))
        end

        for _, item in pairs(items) do
            if item.Name == "Knife" or item.Name:match("Knife") then
                return "Murderer"
            elseif item.Name == "Gun" or item.Name == "Revolver" then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = player.Character:FindFirstChild("EclipseESP")
            
            if ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "EclipseESP"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                end

                local role = getRole(player)
                if role == "Murderer" then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(180, 0, 0)
                elseif role == "Sheriff" then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 180)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 180, 0)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Kill All Logic Loop
task.spawn(function()
    while true do
        task.wait(0.1) -- Check rate
        if KillAll_Enabled then
            -- Verify role again to be safe
            if getRole(LocalPlayer) == "Murderer" then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    
                    -- Find the Knife
                    local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
                    if not knife then
                        for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if t:IsA("Tool") then knife = t break end
                        end
                    end
                    
                    if knife then
                        -- Auto Equip if in backpack
                        if knife.Parent == LocalPlayer.Backpack then
                            knife.Parent = char
                            task.wait(0.2)
                        end

                        -- Attack Loop
                        local handle = knife:FindFirstChild("Handle")
                        if handle then
                            for _, target in ipairs(Players:GetPlayers()) do
                                if not KillAll_Enabled then break end
                                
                                if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                    local hum = target.Character:FindFirstChild("Humanoid")
                                    if hum and hum.Health > 0 then
                                        -- Execute Hit
                                        knife:Activate()
                                        firetouchinterest(target.Character.HumanoidRootPart, handle, 0)
                                        firetouchinterest(target.Character.HumanoidRootPart, handle, 1)
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                KillAll_Enabled = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ESP_Enabled then
        UpdateESP()
    end
    
    if WalkSpeed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         if LocalPlayer.Character.Humanoid.WalkSpeed ~= CurrentWalkSpeed then
             LocalPlayer.Character.Humanoid.WalkSpeed = CurrentWalkSpeed
         end
    end
end)

local function ToggleFly(state)
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if state and root and humanoid then
        local bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = root.CFrame
        
        local bodyVel = Instance.new("BodyVelocity", root)
        bodyVel.velocity = Vector3.new(0, 0.1, 0)
        bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        local speed = 50
        
        while Fly_Enabled and humanoid.Health > 0 do
            RunService.Heartbeat:Wait()
            local camera = Workspace.CurrentCamera
            local moveDir = humanoid.MoveDirection
            
            bodyGyro.cframe = camera.CFrame
            
            local vel = Vector3.new()
            if moveDir.Magnitude > 0 then
                vel = moveDir * speed
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, speed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vel = vel + Vector3.new(0, -speed, 0)
            end
            
            bodyVel.velocity = vel
        end
        
        bodyGyro:Destroy()
        bodyVel:Destroy()
    else
        if root then
            for _, obj in pairs(root:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                    obj:Destroy()
                end
            end
        end
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- Fling Logic (Adapted from Infinite Yield)
local function ToggleFlingPlayer(state)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if state and character and root then
        -- Find Target
        local targetPlr = nil
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name == Fling_Target_Name or v.DisplayName == Fling_Target_Name then
                targetPlr = v
                break
            end
        end
        
        if not targetPlr then
            Rayfield:Notify({Title = "Error", Content = "Player not found! Check Name.", Duration = 3})
            return
        end

        Rayfield:Notify({Title = "Flinging", Content = "Flinging " .. targetPlr.Name, Duration = 3})

        -- Setup Physics properties for fling (IY Logic)
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                child.CanCollide = false
                child.Massless = true
                child.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        local bambam = Instance.new("BodyAngularVelocity")
        bambam.Name = "EclipseFlingVelocity"
        bambam.Parent = root
        bambam.AngularVelocity = Vector3.new(0, 99999, 0)
        bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        bambam.P = math.huge

        Fling_Loop = RunService.Stepped:Connect(function()
            if Fling_Enabled and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") and character and root then
                local targetRoot = targetPlr.Character.HumanoidRootPart
                -- Teleport to target to hit them
                root.CFrame = targetRoot.CFrame
                root.Velocity = Vector3.new(0, 0, 0)
                bambam.AngularVelocity = Vector3.new(0, 99999, 0)
            else
                ToggleFlingPlayer(false)
            end
        end)
    else
        -- Cleanup
        Fling_Enabled = false
        if Fling_Loop then 
            Fling_Loop:Disconnect()
            Fling_Loop = nil
        end
        
        if character and root then
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "EclipseFlingVelocity" then
                    v:Destroy()
                end
            end
            
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    child.CanCollide = true
                    child.Massless = false
                end
            end
        end
        Rayfield:Notify({Title = "Stopped", Content = "Fling Disabled", Duration = 2})
    end
end

--------------------------------------------------------------------------------------
-- TAB 1: Main
--------------------------------------------------------------------------------------
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("Updates & Info")

MainTab:CreateParagraph({
    Title = "Latest Version 1.0",
    Content = "[NEW] Fun Tab Added\n[NEW] Fling Player Added\n[MOVED] Fake Dead to Fun Tab\n[ADDED] Settings Tab"
})

-- [ADDED] Button back below Logs
MainTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/wFKRPQxAnF")
        Rayfield:Notify({Title = "Success", Content = "Discord Link Copied!", Duration = 3})
    end,
})

-- Logic Section
MainTab:CreateSection("Main exploits")

MainTab:CreateToggle({
    Name = "ESP Players (Roles)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESP_Enabled = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("EclipseESP") then
                    p.Character.EclipseESP:Destroy()
                end
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Farm Coins (CoinContainer)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        AutoFarm_Enabled = Value
        
        if Value then
            task.spawn(function()
                while AutoFarm_Enabled do
                    task.wait() 
                    local mapFolder = Workspace:FindFirstChild("Normal")
                    local coinFound = false
                    
                    if mapFolder then
                        -- 1. Check for Standard CoinContainer
                        local coinContainer = mapFolder:FindFirstChild("CoinContainer")
                        
                        if coinContainer then
                            for _, coinModel in pairs(coinContainer:GetChildren()) do
                                if not AutoFarm_Enabled then break end
                                
                                local coinPart = coinModel:FindFirstChild("Coin")
                                if coinPart and coinPart:IsA("BasePart") and coinPart.Transparency < 1 then
                                    pcall(function()
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = coinPart.CFrame
                                        coinFound = true
                                    end)
                                    task.wait(0.2)
                                end
                            end
                        end
                        
                        -- 2. Fallback for Christmas/Other Events
                        if not coinFound then
                             for _, v in pairs(mapFolder:GetDescendants()) do
                                if not AutoFarm_Enabled then break end
                                if v.Name == "SnowToken" and v:IsA("BasePart") and v.Transparency < 1 then
                                     pcall(function()
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                                        coinFound = true
                                     end)
                                     task.wait(0.2)
                                end
                             end
                        end
                    end
                    
                    if not coinFound then
                        task.wait(1.5)
                    end
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            local bb = VirtualUser
            LocalPlayer.Idled:Connect(function()
                bb:CaptureController()
                bb:ClickButton2(Vector2.new())
                Rayfield:Notify({Title = "Anti AFK", Content = "Prevented Kick!", Duration = 2})
            end)
            Rayfield:Notify({Title = "Status", Content = "Anti AFK Active", Duration = 3})
        end
    end,
})

MainTab:CreateSection("Murderer Options")

MainTab:CreateToggle({
    Name = "Kill All (Murderer Only)",
    CurrentValue = false,
    Flag = "KillAll",
    Callback = function(Value)
        if Value then
            local role = getRole(LocalPlayer)
            if role == "Murderer" then
                KillAll_Enabled = true
                Rayfield:Notify({Title = "Enabled", Content = "Kill All Active!", Duration = 3})
            else
                KillAll_Enabled = false
                Rayfield:Notify({Title = "Error", Content = "You are NOT the Murderer!", Duration = 3})
            end
        else
            KillAll_Enabled = false
        end
    end,
})

--------------------------------------------------------------------------------------
-- TAB 2: Teleports
--------------------------------------------------------------------------------------
local TeleportTab = Window:CreateTab("Teleports", "map-pin")

TeleportTab:CreateSection("Role Teleports")

TeleportTab:CreateButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if getRole(p) == "Sheriff" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                Rayfield:Notify({Title = "Teleported", Content = "Teleported to Sheriff: " .. p.Name, Duration = 3})
                return
            end
        end
        Rayfield:Notify({Title = "Error", Content = "No Sheriff Found yet", Duration = 3})
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Murderer",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if getRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
                Rayfield:Notify({Title = "Teleported", Content = "Teleported to Murderer: " .. p.Name, Duration = 3})
                return
            end
        end
        Rayfield:Notify({Title = "Error", Content = "No Murderer Found yet", Duration = 3})
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Dropped Gun",
    Callback = function()
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop then
             LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
             Rayfield:Notify({Title = "Success", Content = "Teleported to Gun Drop!", Duration = 3})
        else
             Rayfield:Notify({Title = "Error", Content = "Gun hasn't been dropped yet.", Duration = 3})
        end
    end,
})

TeleportTab:CreateSection("World Teleports")

TeleportTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby")
        
        if lobby and lobby:FindFirstChild("Spawns") then
            -- Find a random spawn in the lobby to be safe
            local spawns = lobby.Spawns:GetChildren()
            if #spawns > 0 then
                local randomSpawn = spawns[math.random(1, #spawns)]
                LocalPlayer.Character.HumanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({Title = "Teleported", Content = "Welcome to Lobby", Duration = 3})
                return
            end
        end
        
        -- Fallback if exact spawn structure is missing but Lobby exists
        if lobby then
             LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:GetPivot() + Vector3.new(0, 5, 0)
             Rayfield:Notify({Title = "Teleported", Content = "Teleported to Lobby Center", Duration = 3})
        else
             -- Very generic fallback only if nothing is found
             LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-108, 138, 83) 
             Rayfield:Notify({Title = "Warning", Content = "Lobby not found, using fallback coords", Duration = 3})
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Map",
    Callback = function()
        -- Improved Map Search Logic
        local currentMap = Workspace:FindFirstChild("Normal")
        
        -- If "Normal" isn't found (Event maps), look for any model with "Spawns" that isn't the Lobby
        if not currentMap then
            for _, child in pairs(Workspace:GetChildren()) do
                if child:IsA("Model") and child.Name ~= "Lobby" and child:FindFirstChild("Spawns") then
                    currentMap = child
                    break
                end
            end
        end

        if currentMap then
            local spawns = currentMap:FindFirstChild("Spawns")
            if spawns and #spawns:GetChildren() > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns:GetChildren()[1].CFrame + Vector3.new(0, 2, 0)
                Rayfield:Notify({Title = "Teleported", Content = "Teleported to Map", Duration = 3})
            else
                Rayfield:Notify({Title = "Error", Content = "Map found but no Spawns detected.", Duration = 3})
            end
        else
             Rayfield:Notify({Title = "Error", Content = "Round hasn't started (No Map found).", Duration = 3})
        end
    end,
})

--------------------------------------------------------------------------------------
-- TAB 3: Player
--------------------------------------------------------------------------------------
local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Movement Modifiers")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        CurrentWalkSpeed = Value
        WalkSpeed_Enabled = true
    end,
})

PlayerTab:CreateButton({
    Name = "Enable Super Speed (50)",
    Callback = function()
        CurrentWalkSpeed = 50
        WalkSpeed_Enabled = true
        Rayfield:Notify({Title = "Speed", Content = "Speed set to 50", Duration = 2})
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        Fly_Enabled = Value
        if Value then
            task.spawn(function() ToggleFly(true) end)
        else
            ToggleFly(false)
        end
    end,
})

--------------------------------------------------------------------------------------
-- TAB 4: Fun (NEW)
--------------------------------------------------------------------------------------
local FunTab = Window:CreateTab("Fun", "gamepad-2")

FunTab:CreateSection("Character Actions")

-- [MOVED] Fake Dead Feature
FunTab:CreateToggle({
    Name = "Fake Dead (Lay Down)",
    CurrentValue = false,
    Flag = "FakeDead",
    Callback = function(Value)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        
        if Value and humanoid and root then
            -- Activation Logic
            humanoid.Sit = true
            task.wait(0.1)
            root.CFrame = root.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
            
            for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
                v:Stop()
            end
        elseif not Value and humanoid then
            -- Deactivation Logic
            humanoid.Sit = false
        end
    end,
})

FunTab:CreateSection("Fling Player (Risk)")

-- [ADDED] Disclaimer
FunTab:CreateParagraph({
    Title = "Warning",
    Content = "Fling relies on client-side physics. It might not work on all servers, executables, or against all players. Use at your own risk."
})

FunTab:CreateInput({
    Name = "Target Player Full Name",
    PlaceholderText = "UsernameHere",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        Fling_Target_Name = Text
    end,
})

FunTab:CreateToggle({
    Name = "Enable Fling",
    CurrentValue = false,
    Flag = "FlingToggle",
    Callback = function(Value)
        Fling_Enabled = Value
        if Value then
            if Fling_Target_Name ~= "" then
                ToggleFlingPlayer(true)
            else
                Rayfield:Notify({Title = "Error", Content = "Enter a name first!", Duration = 3})
                -- Reset toggle visually if possible, or just user needs to toggle off
            end
        else
            ToggleFlingPlayer(false)
        end
    end,
})

--------------------------------------------------------------------------------------
-- TAB 5: Settings (Formerly Others)
--------------------------------------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("Interface Settings")

SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = {"Amethyst", "Default", "Light", "DarkBlue", "Ocean"},
    CurrentOption = {"Amethyst"},
    MultipleOptions = false,
    Flag = "ThemeDropdown",
    Callback = function(Option)
        Window.ModifyTheme(Option[1])
    end,
})

SettingsTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
         setclipboard("https://discord.gg/wFKRPQxAnF")
         Rayfield:Notify({Title = "Discord", Content = "Link Copied", Duration = 2})
    end,
})
