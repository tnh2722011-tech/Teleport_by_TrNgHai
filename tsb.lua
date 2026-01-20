--[[
    TSB HITBOX CONTROLLER
    ---------------------
    Thiết kế dành riêng cho The Strongest Battlegrounds.
    Tính năng: Tăng vùng nhận diện va chạm của đối thủ.
]]

local g = getgenv and getgenv() or _G
if g.TSB_Hitbox_Loaded then return end
g.TSB_Hitbox_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer

-- [CONFIG]
local Config = {
    Enabled = false,
    Size = 12, -- Mức an toàn cho TSB là 10-15
    Transparency = 0.6,
    Color = Color3.fromRGB(255, 0, 0)
}

-- [UI TỐI GIẢN]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "TSB_Hitbox_UI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 200, 0, 150)
Main.Position = UDim2.new(0.5, -100, 0.8, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "TSB HITBOX"; Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40); ToggleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
ToggleBtn.Text = "TRẠNG THÁI: OFF"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1); ToggleBtn.Font = Enum.Font.GothamSemibold; ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn)

-- Hiển thị thông số hiện tại
local Info = Instance.new("TextLabel", Main)
Info.Size = UDim2.new(1, 0, 0, 30); Info.Position = UDim2.new(0, 0, 0.7, 0)
Info.Text = "Kích thước: " .. Config.Size; Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.BackgroundTransparency = 1; Info.Font = Enum.Font.Gotham; Info.TextSize = 11

-- [LOGIC XỬ LÝ]
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                
                -- Thay đổi thuộc tính Part
                hrp.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
                hrp.Transparency = Config.Transparency
                hrp.Color = Config.Color
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false -- Quan trọng: Tránh việc bạn bị đẩy ra khi đấm
            end
        end
    end
end)

-- Nút bấm
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ToggleBtn.Text = "TRẠNG THÁI: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        ToggleBtn.Text = "TRẠNG THÁI: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        -- Trả lại kích thước cũ (Reset trực quan)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                v.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)

-- Cho phép điều chỉnh kích thước nhanh bằng phím mũi tên Lên/Xuống
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Up then
        Config.Size = math.clamp(Config.Size + 1, 2, 30)
        Info.Text = "Kích thước: " .. Config.Size
    elseif input.KeyCode == Enum.KeyCode.Down then
        Config.Size = math.clamp(Config.Size - 1, 2, 30)
        Info.Text = "Kích thước: " .. Config.Size
    end
end)

print("TSB Hitbox Loaded! Dùng mũi tên Lên/Xuống để chỉnh độ to.")
