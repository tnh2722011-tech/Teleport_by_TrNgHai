--[[
    TRNGHAI V29 - FLY PRO EDITION
    --------------------------------
    [+] Chuyên biệt: Chỉ tập trung vào tính năng Bay.
    [+] Physics: Kết hợp BodyMover + TranslateBy.
    [+] Compatibility: Hỗ trợ hoàn hảo R6 và R15.
    [+] Optimization: Code sạch, cực kỳ nhẹ.
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_FlyPro_Loaded then return end
g.TrNgHai_FlyPro_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- [CONFIG]
local Config = {
    FlySpeed = 1, -- Mức mặc định
    Enabled = false
}

-- [CLEANUP OLD UI]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "TrNgHai_FlyUI" then v:Destroy() end
end

-- [UI SYSTEM - MINIMALIST DESIGN]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "TrNgHai_FlyUI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 200, 0, 150)
Main.Position = UDim2.new(0.5, -100, 0.8, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.Text = "💠 FLY PRO V29"; Header.TextColor3 = Color3.fromRGB(80, 150, 255)
Header.BackgroundTransparency = 1; Header.Font = Enum.Font.GothamBold; Header.TextSize = 14

-- Speed Display
local SpeedLabel = Instance.new("TextLabel", Main)
SpeedLabel.Size = UDim2.new(1, 0, 0, 30); SpeedLabel.Position = UDim2.new(0, 0, 0.2, 0)
SpeedLabel.Text = "SPEED: 1"; SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Font = Enum.Font.GothamSemibold; SpeedLabel.TextSize = 20

-- Buttons Style Helper
local function StyleButton(btn, color)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
end

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 30); ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleBtn.Text = "OFF"
StyleButton(ToggleBtn, Color3.fromRGB(150, 50, 50))

-- Control Buttons (+ / -)
local PlusBtn = Instance.new("TextButton", Main)
PlusBtn.Size = UDim2.new(0.42, 0, 0, 30); PlusBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
PlusBtn.Text = "+"
StyleButton(PlusBtn, Color3.fromRGB(50, 50, 60))

local MinusBtn = Instance.new("TextButton", Main)
MinusBtn.Size = UDim2.new(0.42, 0, 0, 30); MinusBtn.Position = UDim2.new(0.53, 0, 0.72, 0)
MinusBtn.Text = "-"
StyleButton(MinusBtn, Color3.fromRGB(50, 50, 60))

-- [FLY LOGIC CORE]
local ctrl = {f = 0, b = 0, l = 0, r = 0, q = 0, e = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0, q = 0, e = 0}

local function UpdateFlyState(state)
    Config.Enabled = state
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    
    if state then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
        
        -- Lock States
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Swimming) -- Trick lơ lửng từ bản V3

        -- Create Movers
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyPro_Gyro"; bg.P = 9e4; bg.maxTorque = Vector3.one * 9e9; bg.cframe = root.CFrame
        
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyPro_Vel"; bv.velocity = Vector3.zero; bv.maxForce = Vector3.one * 9e9
        
        -- Notification
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Fly Pro", Text = "Kích hoạt thành công!", Duration = 2})
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        
        if root:FindFirstChild("FlyPro_Gyro") then root.FlyPro_Gyro:Destroy() end
        if root:FindFirstChild("FlyPro_Vel") then root.FlyPro_Vel:Destroy() end
    end
end

-- Inputs
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
    elseif input.KeyCode == Enum.KeyCode.E then ctrl.q = 1 -- Up
    elseif input.KeyCode == Enum.KeyCode.Q then ctrl.e = -1 -- Down
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
    elseif input.KeyCode == Enum.KeyCode.E then ctrl.q = 0
    elseif input.KeyCode == Enum.KeyCode.Q then ctrl.e = 0
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Config.Enabled and player.Character then
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if root and root:FindFirstChild("FlyPro_Vel") then
            local bv = root.FlyPro_Vel
            local bg = root.FlyPro_Gyro
            
            -- Tính toán vận tốc dựa trên Camera
            if ctrl.f + ctrl.b ~= 0 or ctrl.l + ctrl.r ~= 0 or ctrl.q + ctrl.e ~= 0 then
                bv.velocity = ((camera.CFrame.lookVector * (ctrl.f + ctrl.b)) + 
                    ((camera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b + ctrl.q + ctrl.e) * 0.2, 0).p) - camera.CFrame.p)) * (Config.FlySpeed * 50)
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r, q = ctrl.q, e = ctrl.e}
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            
            -- Xoay nhân vật theo Camera
            bg.cframe = camera.CFrame
            
            -- Hỗ trợ TranslateBy để tăng tốc (Logic từ V3 bạn gửi)
            if hum.MoveDirection.Magnitude > 0 then
                char:TranslateBy(hum.MoveDirection * (Config.FlySpeed / 5))
            end
        end
    end
end)

-- UI Interactions
ToggleBtn.MouseButton1Click:Connect(function()
    UpdateFlyState(not Config.Enabled)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.FlySpeed = Config.FlySpeed + 1
    SpeedLabel.Text = "SPEED: " .. Config.FlySpeed
end)

MinusBtn.MouseButton1Click:Connect(function()
    if Config.FlySpeed > 1 then
        Config.FlySpeed = Config.FlySpeed - 1
        SpeedLabel.Text = "SPEED: " .. Config.FlySpeed
    end
end)

-- Mini Toggle Button (💠)
local MiniBtn = Instance.new("TextButton", UI)
MiniBtn.Size = UDim2.new(0, 35, 0, 35); MiniBtn.Position = UDim2.new(0, 10, 0.5, 0)
MiniBtn.Text = "💠"; MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(1, 0)
MiniBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

print("TrNgHai Fly Pro Loaded!")
