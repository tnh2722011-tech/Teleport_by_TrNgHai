--[[ 
    TSB VORTEX MOBILE - SMOOTH UI & HITBOX
    --------------------------------------
    - Giao diện tối ưu cho Mobile (Có nút bấm +/-)
    - Hiệu ứng Tween mượt mà.
    - Kéo thả menu trơn tru.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local Config = { Enabled = false, Size = 12, Minimized = false }

-- [GIAO DIỆN CHÍNH]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", UI)
Main.Name = "VortexMobile"
Main.Size = UDim2.new(0, 220, 0, 180)
Main.Position = UDim2.new(0.5, -110, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 12)

-- Thanh tiêu đề (Dùng để kéo menu)
local TitleBar = Instance.new("TextButton", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.Text = "🌀 VORTEX MOBILE"
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 14
TitleBar.AutoButtonColor = false
Instance.new("UICorner", TitleBar)

-- Nút Bật/Tắt Hitbox
local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 180, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -90, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ToggleBtn.Text = "HITBOX: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", ToggleBtn)

-- Khu vực điều chỉnh Size cho Mobile
local MinusBtn = Instance.new("TextButton", Main)
MinusBtn.Size = UDim2.new(0, 40, 0, 40)
MinusBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
MinusBtn.Text = "-"
MinusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinusBtn.TextColor3 = Color3.new(1, 1, 1)
MinusBtn.TextSize = 25
Instance.new("UICorner", MinusBtn)

local PlusBtn = Instance.new("TextButton", Main)
PlusBtn.Size = UDim2.new(0, 40, 0, 40)
PlusBtn.Position = UDim2.new(0.7, 0, 0.6, 0)
PlusBtn.Text = "+"
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
PlusBtn.TextColor3 = Color3.new(1, 1, 1)
PlusBtn.TextSize = 25
Instance.new("UICorner", PlusBtn)

local SizeLabel = Instance.new("TextLabel", Main)
SizeLabel.Size = UDim2.new(0, 80, 0, 40)
SizeLabel.Position = UDim2.new(0.32, 0, 0.6, 0)
SizeLabel.Text = "SIZE: " .. Config.Size
SizeLabel.TextColor3 = Color3.new(1, 1, 1)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Font = Enum.Font.GothamBold

-- [CƠ CHẾ KÉO THẢ MƯỢT CHO MOBILE]
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- [HÀM THU NHỎ MƯỢT MÀ]
TitleBar.MouseButton1Click:Connect(function()
    Config.Minimized = not Config.Minimized
    local targetSize = Config.Minimized and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 180)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- [XỬ LÝ NÚT BẤM]
PlusBtn.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size + 2, 2, 40)
    SizeLabel.Text = "SIZE: " .. Config.Size
end)

MinusBtn.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size - 2, 2, 40)
    SizeLabel.Text = "SIZE: " .. Config.Size
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "HITBOX: ON" or "HITBOX: OFF"
    TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(45, 45, 55)}):Play()
end)

-- [HITBOX ENGINE]
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            end
        end
    end
end)

print("Vortex Mobile Loaded. Chạm tiêu đề để thu nhỏ!")
