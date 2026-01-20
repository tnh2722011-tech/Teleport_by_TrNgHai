--[[
    TSB HITBOX - REBORN UI
    -----------------------
    Giữ nguyên Logic gốc của TrNgHai.
    Cập nhật giao diện mượt mà, hỗ trợ Mobile.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- [GIỮ NGUYÊN CONFIG GỐC]
local Config = {
    Enabled = false,
    Size = 12,
    Transparency = 0.6,
    Color = Color3.fromRGB(255, 0, 0),
    Minimized = false
}

-- [KHỞI TẠO UI MỚI]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
UI.Name = "TrNgHai_Modern_UI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Thanh tiêu đề (Click để thu nhỏ, Hold để kéo)
local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "🌀 TSB HITBOX"; Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 13
Title.AutoButtonColor = false
Instance.new("UICorner", Title)

-- Khung chứa nội dung (Để ẩn đi khi thu nhỏ)
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

-- Nút Bật/Tắt (Toggle)
local ToggleBtn = Instance.new("TextButton", Container)
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 45); ToggleBtn.Position = UDim2.new(0.075, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ToggleBtn.Text = "TRẠNG THÁI: OFF"; ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", ToggleBtn)

-- Khu vực điều chỉnh Size (Cho cả PC và Mobile)
local Minus = Instance.new("TextButton", Container)
Minus.Size = UDim2.new(0, 40, 0, 40); Minus.Position = UDim2.new(0.1, 0, 0.55, 0)
Minus.Text = "-"; Minus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Minus.TextColor3 = Color3.new(1, 1, 1); Minus.TextSize = 20; Instance.new("UICorner", Minus)

local Plus = Instance.new("TextButton", Container)
Plus.Size = UDim2.new(0, 40, 0, 40); Plus.Position = UDim2.new(0.7, 0, 0.55, 0)
Plus.Text = "+"; Plus.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
Plus.TextColor3 = Color3.new(1, 1, 1); Plus.TextSize = 20; Instance.new("UICorner", Plus)

local Info = Instance.new("TextLabel", Container)
Info.Size = UDim2.new(0, 80, 0, 40); Info.Position = UDim2.new(0.3, 0, 0.55, 0)
Info.Text = "SIZE: " .. Config.Size; Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.BackgroundTransparency = 1; Info.Font = Enum.Font.GothamBold

-- [LÔ-GIC KÉO THẢ MƯỢT MÀ]
local dragging, dragStart, startPos
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
UserInputService.InputEnded:Connect(function() dragging = false end)

-- [LÔ-GIC THU NHỎ (MINIMIZE)]
Title.MouseButton1Click:Connect(function()
    Config.Minimized = not Config.Minimized
    Container.Visible = not Config.Minimized
    local targetSize = Config.Minimized and UDim2.new(0, 200, 0, 40) or UDim2.new(0, 200, 0, 180)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

-- [HÀM RESET (TỪ CODE GỐC)]
local function ResetHitbox()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            v.Character.HumanoidRootPart.Transparency = 1
        end
    end
end

-- [CORE HITBOX ENGINE - ĐÚNG LOGIC BẠN YÊU CẦU]
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        local targetSize = Vector3.new(Config.Size, Config.Size, Config.Size)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                
                -- Optimization: Chỉ ghi đè nếu có thay đổi (Hết ping đỏ)
                if hrp.Size ~= targetSize then
                    hrp.Size = targetSize
                    hrp.Transparency = Config.Transparency
                    hrp.Color = Config.Color
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- [SỰ KIỆN NÚT BẤM]
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "TRẠNG THÁI: ON" or "TRẠNG THÁI: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(40, 40, 50)
    if not Config.Enabled then ResetHitbox() end
end)

Plus.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size + 2, 2, 50)
    Info.Text = "SIZE: " .. Config.Size
end)

Minus.MouseButton1Click:Connect(function()
    Config.Size = math.clamp(Config.Size - 2, 2, 50)
    Info.Text = "SIZE: " .. Config.Size
end)

-- PC: Phím mũi tên vẫn hoạt động
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Up then
        Config.Size = math.clamp(Config.Size + 2, 2, 50); Info.Text = "SIZE: " .. Config.Size
    elseif input.KeyCode == Enum.KeyCode.Down then
        Config.Size = math.clamp(Config.Size - 2, 2, 50); Info.Text = "SIZE: " .. Config.Size
    end
end)

print("TSB Modern Hitbox Loaded! Chạm tiêu đề để thu nhỏ.")
