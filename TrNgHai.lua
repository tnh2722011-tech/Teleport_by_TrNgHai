--[[ 
   TRNGHAI V23 - THE DRAGON EMPEROR (14 FEATURES)
   1. Speed  2. Ghost NPC  3. Instant  4. Stamina  5. Full Bright
   6. Noclip  7. ESP Entity  8. ESP Item  9. Fix Lag  10. Teleport (Save/Del)
   11. Jump Power  12. Fly (Bay)  13. Invisible (Tàng hình)  14. Anti-Afk
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_Loaded then return end
g.TrNgHai_Loaded = true

-- [HỆ THỐNG BẢO MẬT HOOK]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local name = tostring(self):lower()
        if name:find("stamina") or name:find("energy") or name:find("kick") then return nil end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- [BIẾN HỆ THỐNG]
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local vars = { speed = 16, jump = 50, noclip = false, ghost = false, instant = false, stamina = false, bright = false, esp = false, item = false, fly = false, invisible = false }
local posCount = 0
local itemKeywords = {"key", "coin", "gold", "tool", "item", "loot", "book", "battery", "medkit", "flashlight", "gear", "part", "card"}

-- [GIAO DIỆN V23]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 0, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 285, 0, 520)
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 3

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "TRNGHAI V23 🐉"; Title.TextColor3 = Color3.fromRGB(255, 50, 50); Title.TextSize = 25; Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Position = UDim2.new(0.05, 0, 0.12, 0); Scroll.Size = UDim2.new(0.9, 0, 0.85, 0); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 3.2, 0) -- Độ dài cực lớn để chứa đủ 14 nút

local UIList = Instance.new("UIListLayout", Scroll); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center; UIList.Padding = UDim.new(0, 8)

local function createBtn(text, color)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 230, 0, 40); btn.BackgroundColor3 = color or Color3.fromRGB(40, 0, 0)
    btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 16; btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn); return btn
end

-- [COMPONENTS - 14 TÍNH NĂNG]
local SpeedInp = Instance.new("TextBox", Scroll)
SpeedInp.Size = UDim2.new(0, 230, 0, 40); SpeedInp.BackgroundColor3 = Color3.fromRGB(60, 0, 0); SpeedInp.PlaceholderText = "1. TỐC ĐỘ: 16"; SpeedInp.Text = ""; SpeedInp.TextColor3 = Color3.new(1,1,1); SpeedInp.TextSize = 16; SpeedInp.Font = Enum.Font.GothamBold; Instance.new("UICorner", SpeedInp)

local JumpInp = Instance.new("TextBox", Scroll)
JumpInp.Size = UDim2.new(0, 230, 0, 40); JumpInp.BackgroundColor3 = Color3.fromRGB(60, 0, 0); JumpInp.PlaceholderText = "2. NHẢY CAO: 50"; JumpInp.Text = ""; JumpInp.TextColor3 = Color3.new(1,1,1); JumpInp.TextSize = 16; JumpInp.Font = Enum.Font.GothamBold; Instance.new("UICorner", JumpInp)

local GhostBtn = createBtn("3. 👻 GHOST NPC: OFF")
local InstantBtn = createBtn("4. ⚡ TƯƠNG TÁC NHANH: OFF")
local StaminaBtn = createBtn("5. 🏃 VÔ HẠN THỂ LỰC: OFF")
local BrightBtn = createBtn("6. 🔆 FULL BRIGHT: OFF")
local NoclipBtn = createBtn("7. 🧱 XUYÊN TƯỜNG: OFF")
local ESPBtn = createBtn("8. 👁️ HIỆN THỰC THỂ: OFF")
local ItemBtn = createBtn("9. 🔍 HIỆN ITEM: OFF")
local FlyBtn = createBtn("10. 🕊️ BAY (FLY): OFF")
local InviBtn = createBtn("11. 👤 TÀNG HÌNH: OFF")
local AfkBtn = createBtn("12. 🚫 CHỐNG TREO MÁY: ON", Color3.fromRGB(0, 80, 0))
local LagBtn = createBtn("13. 🚀 TỐI ƯU FPS", Color3.fromRGB(0, 50, 150))
local SaveBtn = createBtn("14. 💾 LƯU VỊ TRÍ", Color3.fromRGB(0, 100, 0))

local TPContainer = Instance.new("Frame", Scroll); TPContainer.Size = UDim2.new(1, 0, 0, 0); TPContainer.BackgroundTransparency = 1; TPContainer.AutomaticSize = Enum.AutomaticSize.Y; Instance.new("UIListLayout", TPContainer).Padding = UDim.new(0, 5)

-- [VẬN HÀNH LOGIC]
SpeedInp:GetPropertyChangedSignal("Text"):Connect(function() vars.speed = tonumber(SpeedInp.Text) or 16 end)
JumpInp:GetPropertyChangedSignal("Text"):Connect(function() vars.jump = tonumber(JumpInp.Text) or 50 end)

GhostBtn.MouseButton1Click:Connect(function() vars.ghost = not vars.ghost GhostBtn.Text = vars.ghost and "3. 👻 GHOST NPC: ON" or "3. 👻 GHOST NPC: OFF" end)
InstantBtn.MouseButton1Click:Connect(function() vars.instant = not vars.instant InstantBtn.Text = vars.instant and "4. ⚡ TƯƠNG TÁC NHANH: ON" or "4. ⚡ TƯƠNG TÁC NHANH: OFF" end)
StaminaBtn.MouseButton1Click:Connect(function() vars.stamina = not vars.stamina StaminaBtn.Text = vars.stamina and "5. 🏃 VÔ HẠN THỂ LỰC: ON" or "5. 🏃 VÔ HẠN THỂ LỰC: OFF" end)
BrightBtn.MouseButton1Click:Connect(function() vars.bright = not vars.bright BrightBtn.Text = vars.bright and "6. 🔆 FULL BRIGHT: ON" or "6. 🔆 FULL BRIGHT: OFF"; game.Lighting.Ambient = vars.bright and Color3.new(1,1,1) or Color3.new(0,0,0) end)
NoclipBtn.MouseButton1Click:Connect(function() vars.noclip = not vars.noclip NoclipBtn.Text = vars.noclip and "7. 🧱 XUYÊN TƯỜNG: ON" or "7. 🧱 XUYÊN TƯỜNG: OFF" end)
ESPBtn.MouseButton1Click:Connect(function() vars.esp = not vars.esp ESPBtn.Text = vars.esp and "8. 👁️ HIỆN THỰC THỂ: ON" or "8. 👁️ HIỆN THỰC THỂ: OFF"; if not vars.esp then for _, v in pairs(workspace:GetDescendants()) do if v.Name == "V23T" then v:Destroy() end end end end)
ItemBtn.MouseButton1Click:Connect(function() vars.item = not vars.item ItemBtn.Text = vars.item and "9. 🔍 HIỆN ITEM: ON" or "9. 🔍 HIỆN ITEM: OFF"; if not vars.item then for _, v in pairs(workspace:GetDescendants()) do if v.Name == "V23I" then v:Destroy() end end end end)
FlyBtn.MouseButton1Click:Connect(function() vars.fly = not vars.fly FlyBtn.Text = vars.fly and "10. 🕊️ BAY: ON" or "10. 🕊️ BAY: OFF" end)
InviBtn.MouseButton1Click:Connect(function() vars.invisible = not vars.invisible InviBtn.Text = vars.invisible and "11. 👤 TÀNG HÌNH: ON" or "11. 👤 TÀNG HÌNH: OFF"; if vars.invisible then player.Character.LowerTorso.Root:Destroy() end end)

SaveBtn.MouseButton1Click:Connect(function()
    posCount = posCount + 1
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = hrp.CFrame; local f = Instance.new("Frame", TPContainer); f.Size = UDim2.new(0, 230, 0, 40); f.BackgroundTransparency = 1
        local t = createBtn("📍 ĐIỂM " .. posCount, Color3.fromRGB(60, 0, 0)); t.Parent = f; t.Size = UDim2.new(0, 185, 1, 0)
        local d = createBtn("X", Color3.fromRGB(150, 0, 0)); d.Parent = f; d.Position = UDim2.new(0, 190, 0, 0); d.Size = UDim2.new(0, 40, 1, 0)
        t.MouseButton1Click:Connect(function() hrp.CFrame = p end); d.MouseButton1Click:Connect(function() f:Destroy() end)
    end
end)

-- VÒNG LẶP CHÍNH
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = vars.speed
            char.Humanoid.JumpPower = vars.jump
            if vars.noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
            if vars.ghost then char.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end
            if vars.fly then char.HumanoidRootPart.Velocity = Vector3.new(0,2,0) end -- Bay nhẹ
            if vars.stamina then
                for _, v in pairs(char:GetDescendants()) do if (v.Name:lower():find("stamina") or v.Name:lower():find("energy")) and (v:IsA("NumberValue") or v:IsA("IntValue")) then v.Value = 9999 end end
            end
            if vars.instant then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end end
            if vars.esp or vars.item then
                for _, v in pairs(workspace:GetDescendants()) do
                    if vars.esp and v:IsA("Humanoid") and v.Parent.Name ~= player.Name then
                        local r = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Head")
                        if r and not r:FindFirstChild("V23T") then
                            local bg = Instance.new("BillboardGui", r); bg.Name = "V23T"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 80, 0, 40)
                            local tl = Instance.new("TextLabel", bg); tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1,0,1,0); tl.Text = "⚠️ "..v.Parent.Name; tl.TextColor3 = Color3.new(1,0,0); tl.TextScaled = true
                        end
                    elseif vars.item and (v:IsA("ClickDetector") or v:IsA("ProximityPrompt")) then
                        local isI = false; for _, w in pairs(itemKeywords) do if v.Parent.Name:lower():find(w) then isI = true break end end
                        if isI and not v.Parent:FindFirstChild("V23I") then
                            local bg = Instance.new("BillboardGui", v.Parent); bg.Name = "V23I"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 80, 0, 40)
                            local tl = Instance.new("TextLabel", bg); tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1,0,1,0); tl.Text = "💎 "..v.Parent.Name:upper(); tl.TextColor3 = Color3.new(0,1,1); tl.TextScaled = true
                        end
                    end
                end
            end
        end
    end)
end)

-- Nút thu nhỏ
local Toggle = Instance.new("TextButton", ScreenGui); Toggle.Size = UDim2.new(0, 65, 0, 65); Toggle.Position = UDim2.new(0.02, 0, 0.4, 0); Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0); Toggle.Text = "🐉"; Toggle.TextSize = 40; Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
Toggle.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
-- Anti AFK
player.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
LagBtn.MouseButton1Click:Connect(function() for _, v in pairs(game:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false end end LagBtn.Text = "🚀 ĐÃ TỐI ƯU" end)
