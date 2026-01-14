--[[ 
   SCRIPT UPDATED V6 FOR TRNGHAI 
   Special: Hardcore Horror Edition
   New: Object ESP (Item Finder), FullBright, Speed, Stamina
   Removed: No Jumpscares (Keep the Fun!)
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Giao diện Neon Red (Blood Theme)
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "TrNgHai_V6"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(200, 0, 0)
UIStroke.Thickness = 2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TRNGHAI HORROR V6"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15

local function createModernBtn(text)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollList
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(80, 0, 0)
    return btn
end

ScrollList.Parent = MainFrame
ScrollList.Position = UDim2.new(0.05, 0, 0.12, 0)
ScrollList.Size = UDim2.new(0.9, 0, 0.85, 0)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 0

UIListLayout.Parent = ScrollList
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

-- NÚT BẤM
local ItemBtn = createModernBtn("🔍 HIỆN VẬT PHẨM: OFF")
local ESPBtn = createModernBtn("👁️ HIỆN THỰC THỂ: OFF")
local BrightBtn = createModernBtn("🔆 BẬT ĐÈN MAP: OFF")
local SpeedBtn = createModernBtn("🏃 TĂNG TỐC (X2): OFF")
local InstantBtn = createModernBtn("⚡ BỎ QUA CHỜ: OFF")
local StaminaBtn = createModernBtn("🔥 VÔ HẠN SỨC: OFF")

-----------------------------------------------------------
-- LOGIC
-----------------------------------------------------------
local player = game.Players.LocalPlayer
local itemESP, espActive, bright, speed, instant, infStamina = false, false, false, false, false, false

-- 1. HIỆN VẬT PHẨM (Key, Tool, v.v.)
ItemBtn.MouseButton1Click:Connect(function()
    itemESP = not itemESP
    ItemBtn.Text = itemESP and "🔍 HIỆN VẬT PHẨM: ON" or "🔍 HIỆN VẬT PHẨM: OFF"
end)

-- 2. HIỆN THỰC THỂ
ESPBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    ESPBtn.Text = espActive and "👁️ HIỆN THỰC THỂ: ON" or "👁️ HIỆN THỰC THỂ: OFF"
end)

-- 3. CÁC TÍNH NĂNG KHÁC
BrightBtn.MouseButton1Click:Connect(function()
    bright = not bright
    BrightBtn.Text = bright and "🔆 BẬT ĐÈN MAP: ON" or "🔆 BẬT ĐÈN MAP: OFF"
    game.Lighting.Ambient = bright and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    speed = not speed
    SpeedBtn.Text = speed and "🏃 TĂNG TỐC (X2): ON" or "🏃 TĂNG TỐC (X2): OFF"
end)

InstantBtn.MouseButton1Click:Connect(function()
    instant = not instant
    InstantBtn.Text = instant and "⚡ BỎ QUA CHỜ: ON" or "⚡ BỎ QUA CHỜ: OFF"
end)

StaminaBtn.MouseButton1Click:Connect(function()
    infStamina = not infStamina
    StaminaBtn.Text = infStamina and "🔥 VÔ HẠN SỨC: ON" or "🔥 VÔ HẠN SỨC: OFF"
end)

-- LOOP CẬP NHẬT
game:GetService("RunService").Stepped:Connect(function()
    local char = player.Character
    if not char then return end

    if speed then char.Humanoid.WalkSpeed = 35 else char.Humanoid.WalkSpeed = 16 end
    if instant then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
        end
    end
    if infStamina then
        for _, v in pairs(char:GetDescendants()) do
            if v.Name:lower():find("stamina") or v.Name:lower():find("energy") then
                if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 100 end
            end
        end
    end

    -- ESP SYSTEM
    for _, v in pairs(workspace:GetDescendants()) do
        -- Check Thực thể (Quái)
        if espActive and v:IsA("Humanoid") and v.Parent.Name ~= player.Name then
            local root = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Head")
            if root and not root:FindFirstChild("Tag") then
                local bg = Instance.new("BillboardGui", root)
                bg.Name = "Tag"
                bg.AlwaysOnTop = true
                bg.Size = UDim2.new(0, 100, 0, 50)
                local tl = Instance.new("TextLabel", bg)
                tl.BackgroundTransparency = 1
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.Text = "⚠️ " .. v.Parent.Name
                tl.TextColor3 = Color3.new(1, 0, 0)
                tl.TextScaled = true
            end
        -- Check Vật phẩm (Item)
        elseif itemESP and (v:IsA("ClickDetector") or v:IsA("ProximityPrompt")) then
            local target = v.Parent
            if target:IsA("BasePart") and not target:FindFirstChild("ItemTag") then
                local bg = Instance.new("BillboardGui", target)
                bg.Name = "ItemTag"
                bg.AlwaysOnTop = true
                bg.Size = UDim2.new(0, 80, 0, 40)
                local tl = Instance.new("TextLabel", bg)
                tl.BackgroundTransparency = 1
                tl.Size = UDim2.new(1, 0, 1, 0)
                tl.Text = "💎 ITEM"
                tl.TextColor3 = Color3.new(0, 1, 1)
                tl.TextScaled = true
            end
        end
    end
end)
