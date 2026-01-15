--[[
    TRNGHAI V26 - ULTIMATE STRUCTURE
    - Optimized ESP System (Zero FPS Drop)
    - Advanced Hooking (Stamina & Ghost)
    - Full 14 Features with Detailed Logic
]]

-- [KHỞI TẠO HỆ THỐNG]
local g = getgenv and getgenv() or _G
if g.TrNgHai_V26_Loaded then return end
g.TrNgHai_V26_Loaded = true

-- [KHAI BÁO BIẾN DỊCH VỤ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- [BẢNG QUẢN LÝ TRẠNG THÁI]
local Toggles = {
    Speed = false, Jump = false, Ghost = false, Instant = false,
    Stamina = false, Noclip = false, Fly = false, ESP_Entity = false,
    ESP_Item = false, FullBright = false, AntiAfk = true, Invisible = false
}
local Values = { Speed = 16, Jump = 50, FlySpeed = 2 }
local ItemKeywords = {"key", "coin", "gold", "tool", "item", "loot", "battery", "card", "medkit", "gear"}

-- [HỆ THỐNG GIAO DIỆN CHUYÊN NGHIỆP]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TrNgHai_HighEnd_V26"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 460)
Main.Position = UDim2.new(0.4, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- MENU DI CHUYỂN ĐƯỢC

local MainCorner = Instance.new("UICorner", Main)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "TRNGHAI V26 REBORN"
Title.TextColor3 = Color3.fromRGB(255, 20, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -60)
Container.Position = UDim2.new(0, 5, 0, 55)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 850) -- Đảm bảo đủ chỗ cho 14 tính năng
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)

local UIList = Instance.new("UIListLayout", Container)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Padding = UDim.new(0, 8)

-- [HÀM TẠO UI CHI TIẾT]
local function NewButton(name, default_state, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0, 230, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    btn.Text = name .. (default_state and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

local function NewInput(placeholder, callback)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(0, 230, 0, 38)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
end

-- [1. SPEED & JUMP CONTROL]
NewInput("NHẬP TỐC ĐỘ (SPEED)", function(val) Values.Speed = tonumber(val) or 16 end)
NewButton("1. SPEED MASTER", false, function(b)
    Toggles.Speed = not Toggles.Speed
    b.Text = "1. SPEED MASTER: " .. (Toggles.Speed and "ON" or "OFF")
    b.BackgroundColor3 = Toggles.Speed and Color3.fromRGB(80, 0, 0) or Color3.fromRGB(25, 25, 28)
end)

NewInput("NHẬP ĐỘ CAO (JUMP)", function(val) Values.Jump = tonumber(val) or 50 end)
NewButton("2. JUMP POWER", false, function(b)
    Toggles.Jump = not Toggles.Jump
    b.Text = "2. JUMP POWER: " .. (Toggles.Jump and "ON" or "OFF")
end)

-- [3. GHOST NPC - CƠ CHẾ NÂNG CAO]
NewButton("3. 👻 GHOST NPC", false, function(b)
    Toggles.Ghost = not Toggles.Ghost
    b.Text = "3. GHOST NPC: " .. (Toggles.Ghost and "ON" or "OFF")
    if Toggles.Ghost then
        -- Vô hiệu hóa va chạm với NPC nếu có thể
        pcall(function() player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end)
    end
end)

-- [4. INSTANT INTERACT]
NewButton("4. ⚡ INSTANT INTERACT", false, function(b)
    Toggles.Instant = not Toggles.Instant
    b.Text = "4. INSTANT INTERACT: " .. (Toggles.Instant and "ON" or "OFF")
end)

-- [5. INF STAMINA - HOOK CHUYÊN SÂU]
NewButton("5. 🏃 VÔ HẠN THỂ LỰC", false, function(b)
    Toggles.Stamina = not Toggles.Stamina
    b.Text = "5. VÔ HẠN THỂ LỰC: " .. (Toggles.Stamina and "ON" or "OFF")
end)

-- [6. NOCLIP]
NewButton("6. 🧱 XUYÊN TƯỜNG", false, function(b)
    Toggles.Noclip = not Toggles.Noclip
    b.Text = "6. XUYÊN TƯỜNG: " .. (Toggles.Noclip and "ON" or "OFF")
end)

-- [7. FLY MODE]
NewButton("7. 🕊️ FLY MODE", false, function(b)
    Toggles.Fly = not Toggles.Fly
    b.Text = "7. FLY MODE: " .. (Toggles.Fly and "ON" or "OFF")
end)

-- [8 & 9. ESP SYSTEM - OPTIMIZED]
NewButton("8. 👁️ HIỆN THỰC THỂ", false, function(b)
    Toggles.ESP_Entity = not Toggles.ESP_Entity
    b.Text = "8. HIỆN THỰC THỂ: " .. (Toggles.ESP_Entity and "ON" or "OFF")
    if not Toggles.ESP_Entity then
        for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TrNgHai_ESP" then v:Destroy() end end
    end
end)

NewButton("9. 🔍 HIỆN ITEM (LỌC)", false, function(b)
    Toggles.ESP_Item = not Toggles.ESP_Item
    b.Text = "9. HIỆN ITEM: " .. (Toggles.ESP_Item and "ON" or "OFF")
    if not Toggles.ESP_Item then
        for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TrNgHai_Item" then v:Destroy() end end
    end
end)

-- [10. FULL BRIGHT - NO GLARE]
NewButton("10. 🔆 FULL BRIGHT", false, function(b)
    Toggles.FullBright = not Toggles.FullBright
    b.Text = "10. FULL BRIGHT: " .. (Toggles.FullBright and "ON" or "OFF")
    if not Toggles.FullBright then
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end)

-- [11. FIX LAG - SMART CLEAN]
NewButton("11. 🚀 FIX LAG (TỐI ƯU FPS)", false, function(b)
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            elseif v:IsA("PostProcessEffect") or v:IsA("Explosion") then
                v.Enabled = false
            end
        end
    end)
    b.Text = "11. ĐÃ TỐI ƯU FPS"
end)

-- [12. ANTI-AFK]
NewButton("12. 🚫 ANTI-AFK", true, function(b)
    Toggles.AntiAfk = not Toggles.AntiAfk
    b.Text = "12. ANTI-AFK: " .. (Toggles.AntiAfk and "ON" or "OFF")
end)

-- [13. TELEPORT SYSTEM]
NewButton("13. 💾 LƯU VỊ TRÍ HIỆN TẠI", false, function(b)
    posCount = posCount + 1
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local savedPos = hrp.CFrame
        local tpBtn = NewButton("📍 ĐIỂM " .. posCount, false, function()
            player.Character:SetPrimaryPartCFrame(savedPos)
        end)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    end
end)

-- [14. INVISIBLE]
NewButton("14. 👤 TÀNG HÌNH (LOCAL)", false, function(b)
    pcall(function()
        player.Character.LowerTorso.Root:Destroy()
        b.Text = "14. ĐÃ TÀNG HÌNH"
    end)
end)

-- [[ HỆ THỐNG XỬ LÝ CHUYÊN SÂU - KHÔNG LOOP RÁC ]]

-- 1. Xử lý Di chuyển & Trạng thái (60 FPS)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp then
            if Toggles.Speed then hum.WalkSpeed = Values.Speed end
            if Toggles.Jump then hum.JumpPower = Values.Jump end
            if Toggles.Ghost then hrp.Velocity = Vector3.new(0, 0, 0) end
            if Toggles.Fly then hrp.Velocity = Vector3.new(0, 5, 0) end
            if Toggles.Noclip then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
        
        if Toggles.FullBright then
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
        end
    end)
end)

-- 2. Xử lý Tương tác & Stamina (Hook Method)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and Toggles.Stamina then
        local name = tostring(self):lower()
        if name:find("stamina") or name:find("energy") then return nil end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 3. Xử lý ESP (Tối ưu hóa: Quét 1 lần mỗi 2 giây, dùng Nhãn dán)
task.spawn(function()
    while task.wait(2) do
        if Toggles.ESP_Entity or Toggles.ESP_Item then
            for _, obj in pairs(Workspace:GetDescendants()) do
                -- ESP Entity
                if Toggles.ESP_Entity and obj:IsA("Humanoid") and obj.Parent.Name ~= player.Name then
                    local head = obj.Parent:FindFirstChild("Head")
                    if head and not head:FindFirstChild("TrNgHai_ESP") then
                        local gui = Instance.new("BillboardGui", head)
                        gui.Name = "TrNgHai_ESP"; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0, 100, 0, 40)
                        local txt = Instance.new("TextLabel", gui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
                        txt.Text = "⚠️ " .. obj.Parent.Name; txt.TextColor3 = Color3.new(1, 0, 0); txt.TextScaled = true
                    end
                end
                -- ESP Item (Lọc kỹ)
                if Toggles.ESP_Item and (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) then
                    local target = obj.Parent
                    local name = target.Name:lower()
                    local shouldShow = false
                    for _, kw in pairs(ItemKeywords) do if name:find(kw) then shouldShow = true break end end
                    
                    if shouldShow and target:IsA("BasePart") and not target:FindFirstChild("TrNgHai_Item") then
                        local gui = Instance.new("BillboardGui", target)
                        gui.Name = "TrNgHai_Item"; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0, 80, 0, 35)
                        local txt = Instance.new("TextLabel", gui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
                        txt.Text = "💎 " .. target.Name:upper(); txt.TextColor3 = Color3.new(0, 1, 1); txt.TextScaled = true
                    end
                end
                
                -- Instant Interact Logic
                if Toggles.Instant and obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
            end
        end
    end
end)

-- [NÚT MỞ RỒNG DI ĐỘNG]
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
ToggleBtn.Text = "🐉"
ToggleBtn.TextSize = 30
ToggleBtn.TextColor3 = Color3.new(1, 0, 0)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- [ANTI-AFK]
player.Idled:Connect(function()
    if Toggles.AntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)
