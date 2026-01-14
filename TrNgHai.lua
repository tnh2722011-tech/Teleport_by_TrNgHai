--[[ 
   SCRIPT UPDATED V8 FOR TRNGHAI 
   Fix: ESP & Item Tag removal when OFF
   Features: Teleport, Noclip, ESP, FixLag, Stamina, Mini Toggle
]]

local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrNgHai_V8"
ScreenGui.Parent = game.CoreGui

local noclip, espActive, itemESP, bright, speed, instant, infStamina = false, false, false, false, false, false, false
local posCount = 0

-- 1. NÚT THU NHỎ (TOGGLE BUTTON)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Text = "💀"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 25
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- 2. GIAO DIỆN CHÍNH
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 420)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(200, 0, 0)
UIStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TRNGHAI ULTIMATE V8"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15

local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Position = UDim2.new(0.05, 0, 0.1, 0)
ScrollList.Size = UDim2.new(0.9, 0, 0.88, 0)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 0

local UIListLayout = Instance.new("UIListLayout", ScrollList)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

local function createBtn(text, color)
    local btn = Instance.new("TextButton", ScrollList)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- TẠO CÁC NÚT
local SaveBtn = createBtn("💾 LƯU VỊ TRÍ", Color3.fromRGB(0, 80, 0))
local NoclipBtn = createBtn("👻 XUYÊN TƯỜNG: OFF")
local ESPBtn = createBtn("👁️ HIỆN THỰC THỂ: OFF")
local ItemBtn = createBtn("🔍 HIỆN VẬT PHẨM: OFF")
local BrightBtn = createBtn("🔆 BẬT ĐÈN MAP: OFF")
local SpeedBtn = createBtn("🏃 TĂNG TỐC (X2): OFF")
local StaminaBtn = createBtn("🔥 VÔ HẠN SỨC: OFF")
local InstantBtn = createBtn("⚡ BỎ QUA CHỜ: OFF")
local LagBtn = createBtn("🚀 FIX LAG (FPS BOOST)", Color3.fromRGB(0, 50, 150))

-----------------------------------------------------------
-- LOGIC FIX ESP (Hàm xóa Tag)
-----------------------------------------------------------
local function clearTags(tagName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == tagName then v:Destroy() end
    end
end

ESPBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    ESPBtn.Text = espActive and "👁️ HIỆN THỰC THỂ: ON" or "👁️ HIỆN THỰC THỂ: OFF"
    ESPBtn.BackgroundColor3 = espActive and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(30, 0, 0)
    if not espActive then clearTags("EntityTagV8") end
end)

ItemBtn.MouseButton1Click:Connect(function()
    itemESP = not itemESP
    ItemBtn.Text = itemESP and "🔍 HIỆN VẬT PHẨM: ON" or "🔍 HIỆN VẬT PHẨM: OFF"
    ItemBtn.BackgroundColor3 = itemESP and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(30, 0, 0)
    if not itemESP then clearTags("ItemTagV8") end
end)

-- Các logic khác (Teleport, Noclip, Speed...)
SaveBtn.MouseButton1Click:Connect(function()
    posCount = posCount + 1
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local currentPos = char.HumanoidRootPart.CFrame
        local tpBtn = createBtn("📍 ĐẾN ĐIỂM " .. posCount, Color3.fromRGB(60, 60, 60))
        tpBtn.MouseButton1Click:Connect(function() player.Character.HumanoidRootPart.CFrame = currentPos end)
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoclipBtn.Text = noclip and "👻 XUYÊN TƯỜNG: ON" or "👻 XUYÊN TƯỜNG: OFF"
end)

BrightBtn.MouseButton1Click:Connect(function()
    bright = not bright
    BrightBtn.Text = bright and "🔆 BẬT ĐÈN MAP: ON" or "🔆 BẬT ĐÈN MAP: OFF"
    game.Lighting.Ambient = bright and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    speed = not speed
    SpeedBtn.Text = speed and "🏃 TĂNG TỐC (X2): ON" or "🏃 TĂNG TỐC (X2): OFF"
end)

StaminaBtn.MouseButton1Click:Connect(function()
    infStamina = not infStamina
    StaminaBtn.Text = infStamina and "🔥 VÔ HẠN SỨC: ON" or "🔥 VÔ HẠN SỨC: OFF"
end)

InstantBtn.MouseButton1Click:Connect(function()
    instant = not instant
    InstantBtn.Text = instant and "⚡ BỎ QUA CHỜ: ON" or "⚡ BỎ QUA CHỜ: OFF"
end)

LagBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false
        elseif v:IsA("Decal") then v:Destroy() end
    end
    LagBtn.Text = "🚀 ĐÃ TỐI ƯU FPS"
end)

-- VÒNG LẶP HỆ THỐNG
game:GetService("RunService").Stepped:Connect(function()
    local char = player.Character
    if not char then return end

    if noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if speed then char.Humanoid.WalkSpeed = 35 else char.Humanoid.WalkSpeed = 16 end

    if infStamina then
        for _, v in pairs(char:GetDescendants()) do
            if v.Name:lower():find("stamina") or v.Name:lower():find("energy") then
                if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 100 end
            end
        end
    end

    if instant then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end

    -- ESP SYSTEM CẢI TIẾN
    if espActive or itemESP then
        for _, v in pairs(workspace:GetDescendants()) do
            if espActive and v:IsA("Humanoid") and v.Parent.Name ~= player.Name then
                local root = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Head")
                if root and not root:FindFirstChild("EntityTagV8") then
                    local bg = Instance.new("BillboardGui", root)
                    bg.Name = "EntityTagV8"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 50)
                    local tl = Instance.new("TextLabel", bg)
                    tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.Text = "⚠️ " .. v.Parent.Name; tl.TextColor3 = Color3.new(1, 0, 0); tl.TextScaled = true
                end
            elseif itemESP and (v:IsA("ClickDetector") or v:IsA("ProximityPrompt")) then
                local target = v.Parent
                if target:IsA("BasePart") and not target:FindFirstChild("ItemTagV8") then
                    local bg = Instance.new("BillboardGui", target)
                    bg.Name = "ItemTagV8"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 80, 0, 40)
                    local tl = Instance.new("TextLabel", bg)
                    tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.Text = "💎 ITEM"; tl.TextColor3 = Color3.new(0, 1, 1); tl.TextScaled = true
                end
            end
        end
    end
end)
