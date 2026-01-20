local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local Config = {
    Enabled = false,
    Size = 15,
    Transparency = 0.6,
    Minimized = false
}

-- [UI CONSTRUCTION - HIỆN ĐẠI & MƯỢT]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", UI)
Main.Name = "VortexUltimate"
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "🌀 VORTEX ULTIMATE"; Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.AutoButtonColor = false
Instance.new("UICorner", Title)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", Container)
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 45); ToggleBtn.Position = UDim2.new(0.075, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "HITBOX: OFF"; ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", ToggleBtn)

local Minus = Instance.new("TextButton", Container); Minus.Size = UDim2.new(0, 40, 0, 40); Minus.Position = UDim2.new(0.1, 0, 0.55, 0); Minus.Text = "-"; Minus.BackgroundColor3 = Color3.fromRGB(180, 40, 40); Minus.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Minus)
local Plus = Instance.new("TextButton", Container); Plus.Size = UDim2.new(0, 40, 0, 40); Plus.Position = UDim2.new(0.7, 0, 0.55, 0); Plus.Text = "+"; Plus.BackgroundColor3 = Color3.fromRGB(40, 180, 80); Plus.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Plus)
local Info = Instance.new("TextLabel", Container); Info.Size = UDim2.new(0, 80, 0, 40); Info.Position = UDim2.new(0.3, 0, 0.55, 0); Info.Text = Config.Size; Info.TextColor3 = Color3.new(1, 1, 1); Info.BackgroundTransparency = 1; Info.Font = Enum.Font.GothamBold; Info.TextSize = 18

-- [DRAG & MINIMIZE]
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() dragging = false end)
Title.MouseButton1Click:Connect(function() Config.Minimized = not Config.Minimized; Container.Visible = not Config.Minimized; local targetSize = Config.Minimized and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, 180); TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play() end)

-- [HITBOX ENGINE - PHƯƠNG PHÁP MỚI]
-- Sử dụng Heartbeat để đè lên hệ thống Physics của TSB
RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        local targetSize = Vector3.new(Config.Size, Config.Size, Config.Size)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character then
                -- Ép cả HRP và Head để tăng tỉ lệ trúng đòn
                local parts = {v.Character:FindFirstChild("HumanoidRootPart"), v.Character:FindFirstChild("Head")}
                for _, part in pairs(parts) do
                    if part then
                        part.Size = targetSize
                        part.Transparency = Config.Transparency
                        part.Color = Color3.fromRGB(255, 0, 0)
                        part.Material = Enum.Material.Neon
                        part.CanCollide = false
                        part.Massless = true -- Không làm đối thủ bị nặng
                    end
                end
            end
        end
    end
end)

-- [BUTTON EVENTS]
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "HITBOX: ON" or "HITBOX: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30, 30, 40)
    if not Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("HumanoidRootPart") then v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); v.Character.HumanoidRootPart.Transparency = 1 end
                if v.Character:FindFirstChild("Head") then v.Character.Head.Size = Vector3.new(1.2, 1.2, 1.2); v.Character.Head.Transparency = 0 end
            end
        end
    end
end)

Plus.MouseButton1Click:Connect(function() Config.Size = math.clamp(Config.Size + 2, 2, 50); Info.Text = Config.Size end)
Minus.MouseButton1Click:Connect(function() Config.Size = math.clamp(Config.Size - 2, 2, 50); Info.Text = Config.Size end)