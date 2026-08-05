--[[
    ╔═══════════════════════════════════════╗
    ║    Ra Ni Hub - Forsaken v2.1          ║
    ║        Auto Block M1 + Dodge          ║
    ║           Created by Ra Ni            ║
    ║         UI Library: Rayfield          ║
    ╚═══════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Connections = {}
local OriginalValues = {}

-- Helper Functions
local function GetHumanoidRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

-- Check if killer is attacking
local function IsKillerAttacking(killer)
    local animator = killer:FindFirstChildOfClass("Animator")
    if animator then
        local activeTracks = animator:GetPlayingAnimationTracks()
        for _, track in ipairs(activeTracks) do
            if track.Name:lower():find("attack") or track.Name:lower():find("hit") then
                return true
            end
        end
    end
    
    local tool = killer:FindFirstChildOfClass("Tool")
    if tool then
        return true
    end
    
    return false
end

-- Get distance between 2 parts
local function GetDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

-- Perfect block timing
local function PerfectBlock()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- Dodge (space + direction)
local function Dodge(direction)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    if direction then
        VirtualInputManager:SendKeyEvent(true, direction, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, direction, false, game)
    end
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Ra Ni Hub",
    Icon = "Zombie",
    ConfigurationSaving = {
        FileName = "RaNiHub_Forsaken",
        FolderName = "RaNiHub",
        CreateConfiguration = true
    }
})

Rayfield:LoadConfiguration()

-- TAB 1: STAMINA
local StaminaTab = Window:CreateTab("Stamina", "Zap")
StaminaTab:CreateSection("Stamina Settings")

StaminaTab:CreateToggle({
    Name = "Infinity Stamina",
    CurrentValue = false,
    Flag = "InfinityStamina",
    Callback = function(Value)
        if Value then
            Connections["InfinityStamina"] = true
            task.spawn(function()
                while Connections["InfinityStamina"] do
                    pcall(function()
                        local module = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
                        module.Stamina = module.MaxStamina
                    end)
                    task.wait(0.005)
                end
            end)
        else
            Connections["InfinityStamina"] = false
        end
    end,
})

StaminaTab:CreateSlider({
    Name = "Max Stamina",
    Range = {1, 500},
    Increment = 1,
    CurrentValue = 100,
    Flag = "MaxStamina",
    Callback = function(Value)
        pcall(function()
            local module = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
            module.MaxStamina = Value
        end)
    end,
})

StaminaTab:CreateSlider({
    Name = "Sprint Speed",
    Range = {1, 40},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SprintSpeed",
    Callback = function(Value)
        pcall(function()
            local module = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
            module.SprintSpeed = Value
        end)
    end,
})

-- TAB 2: ESP
local ESPTab = Window:CreateTab("ESP", "Eye")
ESPTab:CreateSection("Visual ESP")

ESPTab:CreateToggle({
    Name = "Killers ESP",
    CurrentValue = false,
    Flag = "KillersESP",
    Callback = function(Value)
        if Value then
            Connections["KillersESP"] = true
            task.spawn(function()
                while Connections["KillersESP"] do
                    local killersFolder = Workspace.Players:FindFirstChild("Killers")
                    if killersFolder then
                        for _, model in ipairs(killersFolder:GetChildren()) do
                            pcall(function()
                                if not model:FindFirstChild("ESPHighlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESPHighlight"
                                    highlight.Adornee = model
                                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                    highlight.FillTransparency = 0.7
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = model
                                end
                            end)
                        end
                    end
                    task.wait(5)
                end
            end)
        else
            Connections["KillersESP"] = false
            local killersFolder = Workspace.Players:FindFirstChild("Killers")
            if killersFolder then
                for _, model in ipairs(killersFolder:GetChildren()) do
                    local highlight = model:FindFirstChild("ESPHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Survivors ESP",
    CurrentValue = false,
    Flag = "SurvivorsESP",
    Callback = function(Value)
        if Value then
            Connections["SurvivorsESP"] = true
            task.spawn(function()
                while Connections["SurvivorsESP"] do
                    local survivorsFolder = Workspace.Players:FindFirstChild("Survivors")
                    if survivorsFolder then
                        for _, model in ipairs(survivorsFolder:GetChildren()) do
                            pcall(function()
                                if not model:FindFirstChild("ESPHighlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESPHighlight"
                                    highlight.Adornee = model
                                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                    highlight.FillTransparency = 0.7
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = model
                                end
                            end)
                        end
                    end
                    task.wait(5)
                end
            end)
        else
            Connections["SurvivorsESP"] = false
            local survivorsFolder = Workspace.Players:FindFirstChild("Survivors")
            if survivorsFolder then
                for _, model in ipairs(survivorsFolder:GetChildren()) do
                    local highlight = model:FindFirstChild("ESPHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end,
})

ESPTab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.7,
    Flag = "ESPTransparency",
    Callback = function(Value)
        for _, folder in ipairs({Workspace.Players:FindFirstChild("Killers"), Workspace.Players:FindFirstChild("Survivors")}) do
            if folder then
                for _, model in ipairs(folder:GetChildren()) do
                    local highlight = model:FindFirstChild("ESPHighlight")
                    if highlight then
                        highlight.FillTransparency = Value
                    end
                end
            end
        end
    end,
})

-- TAB 3: AUTO BLOCK
local AutoBlockTab = Window:CreateTab("Auto Block", "Shield")
AutoBlockTab:CreateSection("Auto Defense")

AutoBlockTab:CreateToggle({
    Name = "Auto Block M1",
    CurrentValue = false,
    Flag = "AutoBlockM1",
    Callback = function(Value)
        if Value then
            Connections["AutoBlockM1"] = true
            task.spawn(function()
                while Connections["AutoBlockM1"] do
                    pcall(function()
                        local hrp = GetHumanoidRootPart()
                        if not hrp then return end
                        
                        local killersFolder = Workspace.Players:FindFirstChild("Killers")
                        if not killersFolder then return end
                        
                        for _, killer in ipairs(killersFolder:GetChildren()) do
                            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local distance = GetDistance(killerHRP, hrp)
                                
                                if distance <= 15 and IsKillerAttacking(killer) then
                                    PerfectBlock()
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        else
            Connections["AutoBlockM1"] = false
        end
    end,
})

AutoBlockTab:CreateToggle({
    Name = "Auto Block (Distance)",
    CurrentValue = false,
    Flag = "AutoBlockDistance",
    Callback = function(Value)
        if Value then
            Connections["AutoBlockDistance"] = true
            task.spawn(function()
                while Connections["AutoBlockDistance"] do
                    pcall(function()
                        local hrp = GetHumanoidRootPart()
                        if not hrp then return end
                        
                        local killersFolder = Workspace.Players:FindFirstChild("Killers")
                        if not killersFolder then return end
                        
                        for _, killer in ipairs(killersFolder:GetChildren()) do
                            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local distance = GetDistance(killerHRP, hrp)
                                
                                if distance <= 15 then
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                    task.wait(0.1)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            Connections["AutoBlockDistance"] = false
        end
    end,
})

AutoBlockTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(Value)
        if Value then
            Connections["AutoDodge"] = true
            task.spawn(function()
                while Connections["AutoDodge"] do
                    pcall(function()
                        local hrp = GetHumanoidRootPart()
                        if not hrp then return end
                        
                        local killersFolder = Workspace.Players:FindFirstChild("Killers")
                        if not killersFolder then return end
                        
                        for _, killer in ipairs(killersFolder:GetChildren()) do
                            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local distance = GetDistance(killerHRP, hrp)
                                
                                if distance <= 10 then
                                    local direction = (hrp.Position - killerHRP.Position).Unit
                                    local dodgeDirection = direction.X > 0 and Enum.KeyCode.D or Enum.KeyCode.A
                                    Dodge(dodgeDirection)
                                end
                            end
                        end
                    end)
                    task.wait(0.15)
                end
            end)
        else
            Connections["AutoDodge"] = false
        end
    end,
})

AutoBlockTab:CreateToggle({
    Name = "Auto Sprint",
    CurrentValue = false,
    Flag = "AutoSprint",
    Callback = function(Value)
        if Value then
            Connections["AutoSprint"] = true
            task.spawn(function()
                while Connections["AutoSprint"] do
                    pcall(function()
                        local hrp = GetHumanoidRootPart()
                        if not hrp then return end
                        
                        local killersFolder = Workspace.Players:FindFirstChild("Killers")
                        if not killersFolder then
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                            return
                        end
                        
                        local killerNear = false
                        for _, killer in ipairs(killersFolder:GetChildren()) do
                            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local distance = GetDistance(killerHRP, hrp)
                                if distance <= 30 then
                                    killerNear = true
                                    break
                                end
                            end
                        end
                        
                        if killerNear then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                        else
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            Connections["AutoSprint"] = false
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        end
    end,
})

AutoBlockTab:CreateSlider({
    Name = "Block Distance",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "BlockDistance",
    Callback = function(Value)
        -- Distance used in block functions
    end,
})

-- TAB 4: AUTO STUN
local AutoStunTab = Window:CreateTab("Auto Stun", "Zap")
AutoStunTab:CreateSection("Stun Settings")

AutoStunTab:CreateToggle({
    Name = "Auto Stun Killer",
    CurrentValue = false,
    Flag = "AutoStun",
    Callback = function(Value)
        if Value then
            Connections["AutoStun"] = true
            task.spawn(function()
                while Connections["AutoStun"] do
                    pcall(function()
                        local hrp = GetHumanoidRootPart()
                        if not hrp then return end
                        
                        local killersFolder = Workspace.Players:FindFirstChild("Killers")
                        if not killersFolder then return end
                        
                        for _, killer in ipairs(killersFolder:GetChildren()) do
                            local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local distance = GetDistance(killerHRP, hrp)
                                if distance <= 10 then
                                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                                    if remotes then
                                        local stunEvent = remotes:FindFirstChild("Stun")
                                        if stunEvent then
                                            stunEvent:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        else
            Connections["AutoStun"] = false
        end
    end,
})

AutoStunTab:CreateToggle({
    Name = "Auto Spam Stun",
    CurrentValue = false,
    Flag = "AutoSpamStun",
    Callback = function(Value)
        if Value then
            Connections["AutoSpamStun"] = true
            task.spawn(function()
                while Connections["AutoSpamStun"] do
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes then
                            local stunEvent = remotes:FindFirstChild("Stun")
                            if stunEvent then
                                stunEvent:FireServer()
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            Connections["AutoSpamStun"] = false
        end
    end,
})

-- TAB 5: GENERATOR
local GeneratorTab = Window:CreateTab("Generator", "BatteryCharging")
GeneratorTab:CreateSection("Auto Generator")

GeneratorTab:CreateToggle({
    Name = "Auto Fix Generator",
    CurrentValue = false,
    Flag = "AutoFixGen",
    Callback = function(Value)
        if Value then
            Connections["AutoFixGen"] = true
            task.spawn(function()
                while Connections["AutoFixGen"] do
                    pcall(function()
                        local map = Workspace:FindFirstChild("Map")
                        if not map then task.wait(1) return end
                        
                        local ingame = map:FindFirstChild("Ingame")
                        if not ingame then task.wait(1) return end
                        
                        local mapFolder = ingame:FindFirstChild("Map")
                        if not mapFolder then task.wait(1) return end
                        
                        local hrp = GetHumanoidRootPart()
                        if not hrp then task.wait(1) return end
                        
                        for _, obj in pairs(mapFolder:GetChildren()) do
                            if obj.Name:find("Generator") then
                                local originalPos = hrp.CFrame
                                hrp.CFrame = obj.CFrame
                                task.wait(0.5)
                                
                                local prox = obj:FindFirstChildOfClass("ProximityPrompt")
                                if prox then fireproximityprompt(prox) end
                                
                                task.wait(7.5)
                                hrp.CFrame = originalPos
                                break
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            Connections["AutoFixGen"] = false
        end
    end,
})

GeneratorTab:CreateButton({
    Name = "Fix All Generators",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                
                local ingame = map:FindFirstChild("Ingame")
                if not ingame then return end
                
                local mapFolder = ingame:FindFirstChild("Map")
                if not mapFolder then return end
                
                local hrp = GetHumanoidRootPart()
                if not hrp then return end
                
                for _, obj in pairs(mapFolder:GetChildren()) do
                    if obj.Name:find("Generator") then
                        local originalPos = hrp.CFrame
                        hrp.CFrame = obj.CFrame
                        task.wait(0.5)
                        
                        local prox = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prox then fireproximityprompt(prox) end
                        
                        task.wait(7.5)
                        hrp.CFrame = originalPos
                    end
                end
            end)
        end)
    end,
})

-- TAB 6: TELEPORT
local TeleportTab = Window:CreateTab("Teleport", "Navigation")
TeleportTab:CreateSection("Teleport Options")

TeleportTab:CreateButton({
    Name = "TP To Nearest Generator",
    Callback = function()
        pcall(function()
            local map = Workspace:FindFirstChild("Map")
            if not map then return end
            
            local ingame = map:FindFirstChild("Ingame")
            if not ingame then return end
            
            local mapFolder = ingame:FindFirstChild("Map")
            if not mapFolder then return end
            
            local hrp = GetHumanoidRootPart()
            if not hrp then return end
            
            local nearestGen = nil
            local nearestDist = math.huge
            
            for _, obj in pairs(mapFolder:GetChildren()) do
                if obj.Name:find("Generator") and obj:FindFirstChild("Part") then
                    local dist = (obj.Part.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestGen = obj
                    end
                end
            end
            
            if nearestGen then
                hrp.CFrame = nearestGen.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "TP To Exit/Gate",
    Callback = function()
        pcall(function()
            local map = Workspace:FindFirstChild("Map")
            if not map then return end
            
            local ingame = map:FindFirstChild("Ingame")
            if not ingame then return end
            
            local mapFolder = ingame:FindFirstChild("Map")
            if not mapFolder then return end
            
            local hrp = GetHumanoidRootPart()
            if not hrp then return end
            
            for _, obj in pairs(mapFolder:GetChildren()) do
                if obj.Name:find("Exit") or obj.Name:find("Gate") then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    break
                end
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "TP To Safe Room",
    Callback = function()
        pcall(function()
            local map = Workspace:FindFirstChild("Map")
            if not map then return end
            
            local ingame = map:FindFirstChild("Ingame")
            if not ingame then return end
            
            local mapFolder = ingame:FindFirstChild("Map")
            if not mapFolder then return end
            
            local hrp = GetHumanoidRootPart()
            if not hrp then return end
            
            for _, obj in pairs(mapFolder:GetChildren()) do
                if obj.Name:find("Safe") or obj.Name:find("Room") then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    break
                end
            end
        end)
    end,
})

-- TAB 7: MISC
local MiscTab = Window:CreateTab("Misc", "Package")
MiscTab:CreateSection("Visual Settings")

MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        if Value then
            OriginalValues.Brightness = Lighting.Brightness
            OriginalValues.ClockTime = Lighting.ClockTime
            OriginalValues.FogStart = Lighting.FogStart
            OriginalValues.FogEnd = Lighting.FogEnd
            OriginalValues.GlobalShadows = Lighting.GlobalShadows
            
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = OriginalValues.Brightness or 2
            Lighting.ClockTime = OriginalValues.ClockTime or 12
            Lighting.FogStart = OriginalValues.FogStart or 0
            Lighting.FogEnd = OriginalValues.FogEnd or 100000
            Lighting.GlobalShadows = OriginalValues.GlobalShadows or true
        end
    end,
})

MiscTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        else
            Lighting.FogStart = OriginalValues.FogStart or 0
            Lighting.FogEnd = OriginalValues.FogEnd or 100000
        end
    end,
})

MiscTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end,
})

MiscTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 100},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.JumpPower = Value
        end
    end,
})

MiscTab:CreateSlider({
    Name = "FOV",
    Range = {60, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(Value)
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = Value
        end
    end,
})

MiscTab:CreateSection("Utility")

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            Connections["AntiAFK"] = true
            task.spawn(function()
                local VirtualUser = game:GetService("VirtualUser")
                while Connections["AntiAFK"] do
                    task.wait(120)
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0), game:GetService("CoreGui"))
                end
            end)
        else
            Connections["AntiAFK"] = false
        end
    end,
})

-- TAB 8: COMBAT
local CombatTab = Window:CreateTab("Combat", "Sword")
CombatTab:CreateSection("Attack Options")

CombatTab:CreateButton({
    Name = "Kill Aura",
    Callback = function()
        pcall(function()
            local hrp = GetHumanoidRootPart()
            if not hrp then return end
            
            local killersFolder = Workspace.Players:FindFirstChild("Killers")
            if not killersFolder then return end
            
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then return end
            
            local stunEvent = remotes:FindFirstChild("Stun")
            if not stunEvent then return end
            
            for _, killer in ipairs(killersFolder:GetChildren()) do
                local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                if killerHRP then
                    local distance = GetDistance(killerHRP, hrp)
                    if distance <= 10 then
                        stunEvent:FireServer()
                        task.wait(0.1)
                    end
                end
            end
        end)
    end,
})

CombatTab:CreateButton({
    Name = "Speed Boost (20s)",
    Callback = function()
        pcall(function()
            local humanoid = GetHumanoid()
            if not humanoid then return end
            
            local originalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 100
            
            task.delay(20, function()
                if humanoid and humanoid.Parent then
                    humanoid.WalkSpeed = originalSpeed
                end
            end)
        end)
    end,
})

-- NOTIFICATIONS
Rayfield:CreateNotification({
    Title = "Ra Ni Hub v2.1",
    Content = "Loaded Successfully!",
    Duration = 5
})

-- Cleanup on character reset
LocalPlayer.CharacterAdded:Connect(function()
    if Connections["Fullbright"] then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
    end
end)

-- Final cleanup
LocalPlayer.AncestryChanged:Connect(function()
    for name, connection in pairs(Connections) do
        Connections[name] = false
    end
end)

print("Ra Ni Hub v2.1 Loaded!")
