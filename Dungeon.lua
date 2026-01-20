--[[
    LOOTVORTEX: UI RE-DESIGN FOR TrNgHai
    -------------------------------------------
    Giữ nguyên 100% logic: Heartbeat, CollectLoot, Firetouchinterest.
    Chỉ thay đổi: Hệ thống UI và sự kiện nút bấm.
]]

local g = getgenv and getgenv() or _G
if g.LootVortex_Loaded then return end
g.LootVortex_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- [CONFIG]
local Config = {
    Enabled = false,
    Range = 100,       
    Method = "Hybrid", 
}

-- [UI SYSTEM - MODERN RED]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "LootVortex_UI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 180, 0, 110)
Main.Position = UDim2.new(0.5, -90, 0.8, 0) -- Đẩy lên một chút để không vướng thanh điều hướng mobile
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Viền UI cho ngầu
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(200, 50, 50)
Stroke.Transparency = 0.5

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Text = "LOOTVORTEX: OFF"
Status.TextColor3 = Color3.fromRGB(200, 50, 50)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.GothamBold
Status.TextSize = 13

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleBtn.Text = "BẬT HÚT ĐỒ"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.AutoButtonColor = false -- Để tự tạo hiệu ứng tween
local BtnCorner = Instance.new("UICorner", ToggleBtn)
BtnCorner.CornerRadius = UDim.new(0, 8)

-- [HÀM XỬ LÝ CHÍNH - GIỮ NGUYÊN GỐC]
local function CollectLoot()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchInterest") and v.Parent and v.Parent:IsA("BasePart") then
            local item = v.Parent
            local dist = (root.Position - item.Position).Magnitude

            if dist <= Config.Range then
                if firetouchinterest then
                    firetouchinterest(root, item, 0)
                    firetouchinterest(root, item, 1)
                end
                item.CFrame = root.CFrame
                item.CanCollide = false
            end
        end
    end
end

-- Vòng lặp quét (Heartbeat giữ nguyên)
RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        CollectLoot()
    end
end)

-- [SỰ KIỆN NÚT BẤM + HIỆU ỨNG UI]
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        -- Hiệu ứng bật
            
