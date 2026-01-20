--[[ 
    TSB VORTEX CUSTOM
    -----------------
    - FIX: Hitbox thực tế (Sử dụng RenderStepped để ép Size liên tục).
    - FIX: UI có thể kéo (Hold tiêu đề để di chuyển).
    - ADD: Nút thu nhỏ (Minimize).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- [CONFIG]
local Config = { Enabled = false, Size = 12, Visible = true }

-- [UI CONSTRUCTION]
local UI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 200, 0, 160)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true -- Bật tính năng di chuyển

local Corner = Instance.new("UICorner", Main)

local Title = Instance.new("TextButton", Main) -- Dùng nút để làm thanh tiêu đề có thể click thu nhỏ
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = " 🌀 TSB VORTEX (Kéo để di chuyển)"; Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 12
Instance.new("UICorner", Title)

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40); ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.Text = "HITBOX: OFF"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", ToggleBtn)

local RangeLabel = Instance.new("TextLabel", Main)
RangeLabel.Size = UDim2.new(1, 0, 0, 30); RangeLabel.Position = UDim2.new(0, 0, 0.65, 0)
RangeLabel.Text = "Size: " .. Config.Size .. " (Mũi tên ↑ ↓)"; RangeLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
RangeLabel.BackgroundTransparency = 1; RangeLabel.TextSize = 11

-- [LOGIC THU NHỎ]
Title.MouseButton1Click:Connect(function()
    Config.Visible = not Config.Visible
    ToggleBtn.Visible = Config.Visible
    RangeLabel.Visible = Config.Visible
    Main:TweenSize(Config.Visible and UDim2.new(0, 200, 0, 160) or UDim2.new(0, 200, 0, 35), "Out", "Quad", 0.3)
end)

-- [LOGIC HITBOX THỰC TẾ]
-- Sử dụng RenderStepped để ép Size mỗi khi khung hình render, ngăn server reset
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                -- Ép Size liên tục
                hrp.Size = Vector3.new(Config.Size, Config.Size, Config.Size)
                hrp.Transparency = 0.7
                hrp.Color = Color3.new(1, 0, 0)
                hrp.CanCollide = false
            end
        end
    end
end)

-- [CONTROLS]
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "HITBOX: ON" or "HITBOX: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(40, 40, 45)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Up then
        Config.Size = math.clamp(Config.Size + 1, 2, 30)
        RangeLabel.Text = "Size: " .. Config.Size .. " (Mũi tên ↑ ↓)"
    elseif input.KeyCode == Enum.KeyCode.Down then
        Config.Size = math.clamp(Config.Size - 1, 2, 30)
        RangeLabel.Text = "Size: " .. Config.Size .. " (Mũi tên ↑ ↓)"
    elseif input.KeyCode == Enum.KeyCode.RightShift then -- Phím ẩn/hiện toàn bộ menu
        UI.Enabled = not UI.Enabled
    end
end)
