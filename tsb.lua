local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local Config = { Enabled = false, Size = 15, Minimized = false }

-- [UI SYSTEM]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", UI)
Main.Name = "VortexPro"
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Thanh tiêu đề
local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "🌀 VORTEX V2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.AutoButtonColor = false
Instance.new("UICorner", Title)

-- Container chứa các nút (Để ẩn khi thu nhỏ)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", Container)
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ToggleBtn.Text = "HITBOX: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn)

-- Chỉnh Size
local Minus = Instance.new("TextButton", Container)
Minus.Size = UDim2.new(0, 45, 0, 45); Minus.Position = UDim2.new(0.075, 0, 0.5, 0)
Minus.Text = "-"; Minus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Minus.TextColor3 = Color3.new(1,1,1); Minus.Font = Enum.Font.GothamBold; Instance.new("UICorner", Minus)

local Plus = Instance.new("TextButton", Container)
Plus.Size = UDim2.new(0, 45, 0, 45); Plus.Position = UDim2.new(0.68, 0, 0.5, 0)
Plus.Text = "+"; Plus.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
Plus.TextColor3 = Color3.new(1,1,1); Plus.Font = Enum.Font.GothamBold; Instance.new("UICorner", Plus)

local SizeDisplay = Instance.new("TextLabel", Container)
SizeDisplay.Size = UDim2.new(0, 70, 0, 45); SizeDisplay.Position = UDim2.new(0.32, 0, 0.5, 0)
SizeDisplay.Text = Config.Size; SizeDisplay.TextColor3 = Color3.new(1,1,1)
SizeDisplay.BackgroundTransparency = 1; SizeDisplay.Font = Enum.Font.GothamBold; SizeDisplay.TextSize = 18

-- [DRAG LOGIC]
local dragStart, startPos, dragging
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) dragging = false end)

-- [MINIMIZE LOGIC]
Title.MouseButton1Click:Connect(function()
    Config.Minimized = not Config.Minimized
    Container.Visible = not Config.Minimized -- Ẩn nút ngay lập tức để không bị lỗi đè
    local targetSize = Config.Minimized and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, 180)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

-- [HITBOX ENGINE - FIXED FOR TSB]
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                -- CƠ CHẾ QUAN TRỌNG: Massless giúp không bị đẩy lùi khi va chạm
                hrp.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
                hrp.Transparency = 0.7
                hrp.Color = Color3.fromRGB(255, 0, 0)
                hrp.CanCollide = false
                hrp.Massless = true 
            end
        end
    end
end)

-- [BUTTONS EVENTS]
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "HITBOX: ON" or "HITBOX: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(35, 35, 45)
end)

Plus.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size + 2, 2, 50)
    SizeDisplay.Text = Config.Size
end)

Minus.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size - 2, 2, 50)
    SizeDisplay.Text = Config.Size
end)
