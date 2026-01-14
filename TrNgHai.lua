--[[ 
   SCRIPT UPDATED V12 FULL - TRNGHAI
   Fix: Universal Infinite Stamina (Stamina V2)
   Added: Speed Slider, ESP, Teleport, NPC Invisible, Anti-Ban
]]

-- KHỞI TẠO BẢO MẬT (ANTI-BAN)
local g = getgenv and getgenv() or _G
if g.TrNgHai_Loaded then return end
g.TrNgHai_Loaded = true

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if not checkcaller() and t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
        return 16
    end
    return oldIndex(t, k)
end)
setreadonly(mt, true)

-- BIẾN HỆ THỐNG
local player = game.Players.LocalPlayer
local noclip, espActive, itemESP, invisible, infStamina = false, false, false, false, false
local walkSpeedValue = 16
local posCount = 0
local tpButtons = {}

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)

-----------------------------------------------------------
-- GIAO DIỆN (UI)
-----------------------------------------------------------
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 480) -- Tăng kích thước một chút
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Text = "🛡️"; ToggleBtn.TextColor3 = Color3.new(1, 0, 0); ToggleBtn.TextSize = 25
ToggleBtn.Draggable = true; Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "TRNGHAI STEALTH V12"; Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold

local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Position = UDim2.new(0.05, 0, 0.1, 0); ScrollList.Size = UDim2.new(0.9, 0, 0.88, 0)
ScrollList.BackgroundTransparency = 1; ScrollList.ScrollBarThickness = 0; ScrollList.CanvasSize = UDim2.new(0,0,2.5,0)
local UIListLayout = Instance.new("UIListLayout", ScrollList)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; UIListLayout.Padding = UDim.new(0, 8)

local function createBtn(text, color, parent)
    local btn = Instance.new("TextButton", parent or ScrollList)
    btn.Size = UDim2.new(0, 210, 0, 35); btn.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn); return btn
end

-- UI COMPONENTS
local SpeedLabel = Instance.new("TextLabel", ScrollList)
SpeedLabel.Size = UDim2.new(0, 210, 0, 20); SpeedLabel.Text = "TỐC ĐỘ: 16"; SpeedLabel.TextColor3 = Color3.new(1, 1, 1); SpeedLabel.BackgroundTransparency = 1

local SpeedSlider = Instance.new("TextBox", ScrollList)
SpeedSlider.Size = UDim2.new(0, 210, 0, 30); SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SpeedSlider.Text = "16"; SpeedSlider.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", SpeedSlider)

local StaminaBtn = createBtn("⚡ VÔ HẠN STAMINA: OFF")
local NoclipBtn = createBtn("🧱 NOCLIP: OFF")
local InvBtn = createBtn("👻 NPC GHOST: OFF")
local ESPBtn = createBtn("👁️ ENTITY ESP: OFF")
local ItemBtn = createBtn("🔍 ITEM FINDER: OFF")
local SaveBtn = createBtn("💾 LƯU VỊ TRÍ", Color3.fromRGB(0, 100, 0))
local ClearBtn = createBtn("🗑️ XÓA TẤT CẢ ĐIỂM", Color3.fromRGB(100, 0, 0))
local LagBtn = createBtn("🚀 TỐI ƯU FPS", Color3.fromRGB(0, 50, 150))

-----------------------------------------------------------
-- LOGIC FUNCTIONS
-----------------------------------------------------------

local function clearAllTags(tagName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == tagName then v:Destroy() end
    end
end

SpeedSlider.FocusLost:Connect(function()
    walkSpeedValue = tonumber(SpeedSlider.Text) or 16
    SpeedLabel.Text = "TỐC ĐỘ: " .. walkSpeedValue
end)

StaminaBtn.MouseButton1Click:Connect(function()
    infStamina = not infStamina
    StaminaBtn.Text = infStamina and "⚡ VÔ HẠN STAMINA: ON" or "⚡ VÔ HẠN STAMINA: OFF"
    StaminaBtn.BackgroundColor3 = infStamina and Color3.fromRGB(0, 80, 80) or Color3.fromRGB(25, 25, 25)
end)

ESPBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    ESPBtn.Text = espActive and "👁️ ENTITY ESP: ON" or "👁️ ENTITY ESP: OFF"
    if not espActive then clearAllTags("TH_EntityTag") end
end)

ItemBtn.MouseButton1Click:Connect(function()
    itemESP = not itemESP
    ItemBtn.Text = itemESP and "🔍 ITEM FINDER: ON" or "🔍 ITEM FINDER: OFF"
    if not itemESP then clearAllTags("TH_ItemTag") end
end)

SaveBtn.MouseButton1Click:Connect(function()
    posCount = posCount + 1
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.CFrame
        local tpBtn = createBtn("📍 ĐIỂM " .. posCount, Color3.fromRGB(50, 50, 50))
        table.insert(tpButtons, tpBtn)
        tpBtn.MouseButton1Click:Connect(function() 
            if player.Character then player.Character.HumanoidRootPart.CFrame = pos end
        end)
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, b in pairs(tpButtons) do b:Destroy() end
    tpButtons = {}; posCount = 0
end)

LagBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
    LagBtn.Text = "🚀 ĐÃ TỐI ƯU"
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoclipBtn.Text = noclip and "🧱 NOCLIP: ON" or "🧱 NOCLIP: OFF"
end)

InvBtn.MouseButton1Click:Connect(function()
    invisible = not invisible
    InvBtn.Text = invisible and "👻 NPC GHOST: ON" or "👻 NPC GHOST: OFF"
end)

-----------------------------------------------------------
-- MAIN LOOP (Xử lý liên tục)
-----------------------------------------------------------
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeedValue
            
            -- FIX STAMINA V2 (Quét mọi khả năng)
            if infStamina then
                -- 1. Quét trong nhân vật
                for _, v in pairs(char:GetDescendants()) do
                    if v.Name:lower():find("stamina") or v.Name:lower():find("energy") or v.Name:lower():find("sprint") then
                        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 100 end
                    end
                end
                -- 2. Quét trong PlayerScripts (Cho một số game lưu stamina ở ngoài)
                for _, v in pairs(player:FindFirstChild("PlayerVars") or player:GetDescendants()) do
                    if v.Name:lower():find("stamina") and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = 100
                    end
                end
            end

            if noclip then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
            
            if invisible and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            end
            
            -- ESP Logic
            if espActive or itemESP then
                for _, v in pairs(workspace:GetDescendants()) do
                    if espActive and v:IsA("Humanoid") and v.Parent.Name ~= player.Name then
                        local r = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Head")
                        if r and not r:FindFirstChild("TH_EntityTag") then
                            local bg = Instance.new("BillboardGui", r)
                            bg.Name = "TH_EntityTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 100, 0, 50)
                            local tl = Instance.new("TextLabel", bg)
                            tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0)
                            tl.Text = "⚠️ " .. v.Parent.Name; tl.TextColor3 = Color3.new(1, 0, 0); tl.TextScaled = true
                        end
                    elseif itemESP and (v:IsA("ClickDetector") or v:IsA("ProximityPrompt")) then
                        local t = v.Parent
                        if t:IsA("BasePart") and not t:FindFirstChild("TH_ItemTag") then
                            local bg = Instance.new("BillboardGui", t)
                            bg.Name = "TH_ItemTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 80, 0, 40)
                            local tl = Instance.new("TextLabel", bg)
                            tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0)
                            tl.Text = "💎 ITEM"; tl.TextColor3 = Color3.new(0, 1, 1); tl.TextScaled = true
                        end
                    end
                end
            end
        end
    end)
end)
