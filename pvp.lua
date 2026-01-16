--[[
    TRNGHAI V29 - PVP ELITE EDITION
    --------------------------------
    [+] Hitbox Expander: Tăng kích cỡ vùng đánh của đối thủ.
    [+] God Mode: Khóa máu và trạng thái nhân vật.
    [+] Team Check: Tùy chọn đánh cả đồng đội hoặc chỉ đối thủ.
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_PVP_Loaded then return end
g.TrNgHai_PVP_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer

-- [CONFIG]
local Config = {
    HitboxSize = 20, -- Kích thước hitbox (Mặc định 20 là rất lớn)
    HitboxTransparency = 0.7,
    HitboxEnabled = false,
    GodModeEnabled = false,
    TeamCheck = false
}

-- [UI SYSTEM]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "TrNgHai_PVP_UI"

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.Position = UDim2.new(0.5, -110, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "💠 PVP ELITE V29"; Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16

-- Helper UI Function
local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = pos
    btn.Text = text; btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12
    Instance.new("UICorner", btn)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 35, 45)
        callback(enabled)
    end)
end

-- [PVP FEATURES]

-- 1. Hitbox Expander (Tăng vùng đánh)
local function UpdateHitbox()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if Config.HitboxEnabled then
                -- Kiểm tra Team
                if not Config.TeamCheck or v.Team ~= lp.Team then
                    hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    hrp.Transparency = Config.HitboxTransparency
                    hrp.Color = Color3.fromRGB(255, 0, 0)
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false -- Tránh việc bạn bị kẹt khi đứng gần họ
                end
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end

-- 2. God Mode (Bất tử)
local function ToggleGodMode(state)
    Config.GodModeEnabled = state
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "TrNgHai PVP", Text = "🛡️ Bất tử đã BẬT"})
    end
end

RunService.RenderStepped:Connect(function()
    -- Thực thi Hitbox
    if Config.HitboxEnabled then UpdateHitbox() end
    
    -- Thực thi God Mode
    if Config.GodModeEnabled and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            -- Vô hiệu hóa va chạm sát thương (Tùy game)
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanTouch = false end
            end
        end
    end
end)

-- [UI BUTTONS]
CreateButton("BẬT HITBOX (SIÊU TO)", UDim2.new(0.05, 0, 0.2, 0), function(s) Config.HitboxEnabled = s end)
CreateButton("BẤT TỬ (GOD MODE)", UDim2.new(0.05, 0, 0.4, 0), function(s) ToggleGodMode(s) end)
CreateButton("TEAM CHECK (OFF = ĐÁNH TẤT)", UDim2.new(0.05, 0, 0.6, 0), function(s) Config.TeamCheck = s end)

-- Nút thu gọn
local MiniBtn = Instance.new("TextButton", UI)
MiniBtn.Size = UDim2.new(0, 30, 0, 30); MiniBtn.Position = UDim2.new(0, 10, 0.4, 0)
MiniBtn.Text = "🛡️"; MiniBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(1, 0)
MiniBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

print("TrNgHai PVP Elite Edition Loaded!")
