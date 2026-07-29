-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Remove existing GUI if re-executed
if game:GetService("CoreGui"):FindFirstChild("RaNiLuaUI") then
    game:GetService("CoreGui").RaNiLuaUI:Destroy()
end

-- ScreenGui Setup (Protected CoreGui for Executor)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaNiLuaUI"
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Colors (Minecraft Theme)
local MC_DIRT = Color3.fromRGB(45, 30, 20)
local MC_GRAY = Color3.fromRGB(60, 60, 60)
local MC_DARK_GRAY = Color3.fromRGB(30, 30, 30)
local MC_GREEN = Color3.fromRGB(85, 170, 0)
local MC_BORDER = Color3.fromRGB(0, 0, 0)

-- Main Frame (Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = MC_GRAY
MainFrame.BorderSizePixel = 3
MainFrame.BorderColor3 = MC_BORDER
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- UI Corner Pixel Effect (Minecraft Block Border)
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(200, 200, 200)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = MC_DARK_GRAY
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "RaNi Lua - Minecraft Edition"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 85) -- MC Yellow
TitleText.TextSize = 16
TitleText.Font = Enum.Font.Code
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

-- Sidebar (Tab List)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -32)
Sidebar.Position = UDim2.new(0, 0, 0, 32)
Sidebar.BackgroundColor3 = MC_DIRT
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabHolder = Instance.new("UIListLayout")
TabHolder.SortOrder = Enum.SortOrder.LayoutOrder
TabHolder.Padding = UDim.new(0, 4)
TabHolder.Parent = Sidebar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.Parent = Sidebar

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -136, 1, -38)
ContentFrame.Position = UDim2.new(0, 133, 0, 35)
ContentFrame.BackgroundColor3 = MC_DARK_GRAY
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

---------------------------------------------------------
-- TOGGLE / ANIMATION LOGIC
---------------------------------------------------------
local isOpen = true

local function ToggleUI()
    isOpen = not isOpen
    if isOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 340),
            Position = UDim2.new(0.5, -260, 0.5, -170)
        })
        tween:Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not isOpen then MainFrame.Visible = false end
        end)
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleUI)

-- Press 'Insert' or 'RightControl' to toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl) then
        ToggleUI()
    end
end)

-- Mobile Floating Toggle Button (Nút nổi bật/tắt)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 35)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -17)
OpenBtn.BackgroundColor3 = MC_GREEN
OpenBtn.Text = "RaNi"
OpenBtn.Font = Enum.Font.Code
OpenBtn.TextSize = 14
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.BorderSizePixel = 2
OpenBtn.BorderColor3 = MC_BORDER
OpenBtn.Parent = ScreenGui
OpenBtn.MouseButton1Click:Connect(ToggleUI)

-- Dragging System for UI
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

---------------------------------------------------------
-- TAB SYSTEM & UI CONTROLS
---------------------------------------------------------
local tabs = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = MC_GRAY
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.Code
    TabBtn.TextSize = 13
    TabBtn.BorderSizePixel = 1
    TabBtn.BorderColor3 = MC_BORDER
    TabBtn.Parent = Sidebar

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 6
    Page.ScrollBarImageColor3 = MC_GREEN
    Page.Parent = ContentFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 8)
    PagePadding.PaddingLeft = UDim.new(0, 8)
    PagePadding.PaddingRight = UDim.new(0, 8)
    PagePadding.Parent = Page

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = MC_GRAY
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = MC_GREEN
    end)

    table.insert(tabs, {Btn = TabBtn, Page = Page})
    if #tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = MC_GREEN
    end

    return Page
end

-- Create Toggle Component
local function AddToggle(parent, text, default, callback)
    local state = default or false
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -10, 0, 32)
    ToggleBtn.BackgroundColor3 = MC_GRAY
    ToggleBtn.BorderSizePixel = 1
    ToggleBtn.BorderColor3 = MC_BORDER
    ToggleBtn.Text = "  " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
    ToggleBtn.TextColor3 = state and MC_GREEN or Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.Code
    ToggleBtn.TextSize = 13
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.Parent = parent

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.Text = "  " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        ToggleBtn.TextColor3 = state and MC_GREEN or Color3.fromRGB(200, 200, 200)
        pcall(callback, state)
    end)
end

-- Create Slider Component
local function AddSlider(parent, text, min, max, default, callback)
    local val = default or min
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 45)
    SliderFrame.BackgroundColor3 = MC_GRAY
    SliderFrame.BorderSizePixel = 1
    SliderFrame.BorderColor3 = MC_BORDER
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 5, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(val)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Code
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Bar = Instance.new("TextButton")
    Bar.Size = UDim2.new(1, -10, 0, 14)
    Bar.Position = UDim2.new(0, 5, 0, 24)
    Bar.BackgroundColor3 = MC_DARK_GRAY
    Bar.BorderSizePixel = 0
    Bar.Text = ""
    Bar.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = MC_GREEN
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + ((max - min) * pos))
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(val)
        pcall(callback, val)
    end

    local sliding = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(input)
        end
    end)

    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

---------------------------------------------------------
-- TÍNH NĂNG (LOCAL PLAYER TAB)
---------------------------------------------------------
local LocalPage = CreateTab("Local Player")

-- WalkSpeed Slider (1 - 1000)
AddSlider(LocalPage, "WalkSpeed", 1, 1000, 16, function(value)
    if Humanoid then
        Humanoid.WalkSpeed = value
    end
end)

-- NoClip Toggle
local noclipConnection
AddToggle(LocalPage, "NoClip", false, function(enabled)
    if enabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        -- Restore collisions for current character parts when disabling NoClip
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Fly Toggle
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

AddToggle(LocalPage, "Fly", false, function(enabled)
    flying = enabled
    if flying then
        -- Ensure RootPart is valid (character may have changed)
        RootPart = Character and Character:FindFirstChild("HumanoidRootPart") or RootPart
        if not RootPart then return end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Parent = RootPart
        
        bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyGyro.CFrame = RootPart.CFrame
        bodyGyro.Parent = RootPart
        
        task.spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                local camCFrame = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()
                local moveDir = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if bodyVelocity and bodyVelocity.Parent then
                    bodyVelocity.Velocity = moveDir * flySpeed
                end
                if bodyGyro and bodyGyro.Parent then
                    bodyGyro.CFrame = camCFrame
                end
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end
end)

-- ESP Character
local espEnabled = false
local espTask
AddToggle(LocalPage, "ESP Nhân Vật", false, function(enabled)
    espEnabled = enabled
    if espEnabled then
        if espTask then return end
        espTask = task.spawn(function()
            while espEnabled do
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        if not plr.Character:FindFirstChild("RaNiHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "RaNiHighlight"
                            highlight.FillColor = Color3.fromRGB(255, 85, 85)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.Parent = plr.Character
                        end
                    end
                end
                task.wait(1)
            end
            espTask = nil
        end)
    else
        -- Remove existing highlights when disabling
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("RaNiHighlight") then
                plr.Character.RaNiHighlight:Destroy()
            end
        end
    end
end)

-- Tab Misc
local MiscPage = CreateTab("Misc")
-- Infinite Jump: use a single connection and flag to avoid duplicate connections
_G.InfJump = false
local infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

AddToggle(MiscPage, "Infinite Jump", false, function(enabled)
    _G.InfJump = enabled
end)
