--[[
    LOOTVORTEX: Chuyên dụng cho Dungeon & Looting
    -------------------------------------------
    Cơ chế: Quét các vật thể có TouchInterest và ép game ghi nhận việc nhặt đồ.
]]

local g = getgenv and getgenv() or _G
if g.LootVortex_Loaded then return end
g.LootVortex_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()

-- [CONFIG]
local Config = {
    Enabled = false,
    Range = 100,       -- Tầm xa (studs)
    Method = "Hybrid", -- Cả dịch chuyển vật phẩm và ép lệnh chạm
}

-- [UI TỐI GIẢN]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "LootVortex_UI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 180, 0, 110)
Main.Position = UDim2.new(0.5, -90, 0.85, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 30); Status.Text = "LOOTVORTEX: OFF"; Status.TextColor3 = Color3.fromRGB(200, 50, 50)
Status.BackgroundTransparency = 1; Status.Font = Enum.Font.GothamBold; Status.TextSize = 13

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40); ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleBtn.Text = "BẬT HÚT ĐỒ"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1); ToggleBtn.Font = Enum.Font.GothamSemibold; ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn)

-- [HÀM XỬ LÝ CHÍNH]
local function CollectLoot()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Tìm tất cả các vật phẩm có thể nhặt được
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchInterest") and v.Parent and v.Parent:IsA("BasePart") then
            local item = v.Parent
            local dist = (root.Position - item.Position).Magnitude

            if dist <= Config.Range then
                -- Cách 1: Ép lệnh chạm (Hiệu quả nhất nếu máy hỗ trợ)
                if firetouchinterest then
                    firetouchinterest(root, item, 0)
                    firetouchinterest(root, item, 1)
                end
                
                -- Cách 2: Dịch chuyển vật phẩm về chân (Dành cho game check khoảng cách)
                item.CFrame = root.CFrame
                item.CanCollide = false
            end
        end
    end
end

-- Vòng lặp quét vật phẩm
RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        CollectLoot()
    end
end)

-- Sự kiện nút bấm
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        Status.Text = "LOOTVORTEX: RUNNING"
        Status.TextColor3 = Color3.fromRGB(50, 200, 100)
        ToggleBtn.Text = "TẮT HÚT ĐỒ"
    else
        Status.Text = "LOOTVORTEX: OFF"
        Status.TextColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "BẬT HÚT ĐỒ"
    end
end)

print("LootVortex loaded. Tập trung vào việc nhặt đồ.")
