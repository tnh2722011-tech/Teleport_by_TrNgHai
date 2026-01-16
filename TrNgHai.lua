--[[
    TRNGHAI V28 - CYBER DRAGON EDITION
    [+] UI: Modern Dark Theme, Gradients, Shadows, Animations.
    [+] System: Notification Library included.
    [+] Core: Optimized V27 Logic.
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_V28_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "TrNgHai V28", Text = "Script đã chạy rồi!", Duration = 3})
    return 
end
g.TrNgHai_V28_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- [CONFIG & STATE]
local Config = {
    Speed = 16, Jump = 50, FlySpeed = 50,
    States = {
        Speed = false, Jump = false, Ghost = false, Instant = false,
        Stamina = false, Noclip = false, Fly = false, Esp = false,
        EspItem = false, Bright = false, AntiAfk = true
    }
}
local SavedCFrame = nil

-- [CLEANUP OLD UI]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("TrNgHai") then v:Destroy() end
end

-- [UI LIBRARY - HỆ THỐNG GIAO DIỆN]
local Library = {}
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "TrNgHai_CyberDragon"
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- >> Hàm tạo thông báo (Notification)
function Library:Notify(text, type)
    local notif = Instance.new("Frame", UI)
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.Position = UDim2.new(1, 20, 0.85, 0) -- Bắt đầu từ ngoài màn hình phải
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BorderSizePixel = 0
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = type == "Success" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1.5
    
    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1, -20, 1, 0); label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animation In
    notif:TweenPosition(UDim2.new(1, -270, 0.85, 0), "Out", "Quad", 0.5)
    
    task.delay(3, function()
        notif:TweenPosition(UDim2.new(1, 20, 0.85, 0), "In", "Quad", 0.5, true, function() notif:Destroy() end)
    end)
end

-- >> Main Frame
local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 320, 0, 500)
Main.Position = UDim2.new(0.5, -160, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- >> Dragging Logic
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then if dragging then update(input) end end end)

-- >> Decor: Gradient Stroke
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2
local Gradient = Instance.new("UIGradient", MainStroke)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}
Gradient.Rotation = 45
task.spawn(function()
    while task.wait() do Gradient.Rotation = Gradient.Rotation + 1 end -- Xoay viền màu
end)

-- >> Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Header.BorderSizePixel = 0
local Title = Instance.new("TextLabel", Header)
Title.Text = "TRNGHAI V28 🐉"; Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 50); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 22

-- >> Scroll Container
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -60); Scroll.Position = UDim2.new(0, 5, 0, 55); Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
local UIList = Instance.new("UIListLayout", Scroll); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- >> Component Functions
function Library:CreateButton(text, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 280, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 10, 0, 10); status.Position = UDim2.new(1, -25, 0.5, -5)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        -- Animation Effect
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}):Play()
        callback(toggled, lbl)
    end)
    return btn
end

function Library:CreateAction(text, color, callback) -- Nút bấm thực hiện ngay (không toggle)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 280, 0, 42)
    btn.BackgroundColor3 = color
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
end

function Library:CreateInput(placeholder, callback)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(0, 280, 0, 40); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 1, 0); box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1; box.Text = ""; box.PlaceholderText = placeholder
    box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Gotham; box.TextSize = 14
    
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- ================= [FEATURE IMPLEMENTATION] =================

-- 1. SPEED
Library:CreateInput("Nhập Tốc Độ (Mặc định 16)...", function(v) Config.Speed = tonumber(v) or 16 end)
Library:CreateButton("1. Speed Master", function(state)
    Config.States.Speed = state
    Library:Notify(state and "Đã bật Speed!" or "Đã tắt Speed!", state and "Success" or "Fail")
end)
RunService.RenderStepped:Connect(function()
    if Config.States.Speed and player.Character then
        local h = player.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = Config.Speed end
    end
end)

-- 2. JUMP
Library:CreateInput("Nhập Nhảy Cao (Mặc định 50)...", function(v) Config.Jump = tonumber(v) or 50 end)
Library:CreateButton("2. Jump Power", function(state)
    Config.States.Jump = state
    Library:Notify(state and "Đã bật Jump!" or "Đã tắt Jump!", state and "Success" or "Fail")
end)
RunService.RenderStepped:Connect(function()
    if Config.States.Jump and player.Character then
        local h = player.Character:FindFirstChild("Humanoid")
        if h then h.JumpPower = Config.Jump end
    end
end)

-- 3. GHOST NPC
Library:CreateButton("3. Ghost NPC (Đứng yên)", function(state)
    Config.States.Ghost = state
end)
RunService.Stepped:Connect(function()
    if Config.States.Ghost and player.Character then
        local r = player.Character:FindFirstChild("HumanoidRootPart")
        if r then r.Velocity = Vector3.zero end
    end
end)

-- 4. INSTANT INTERACT
Library:CreateButton("4. Instant Interact", function(state)
    Config.States.Instant = state
    if state then
        for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end
        Library:Notify("Đã bỏ thời gian chờ!", "Success")
    end
end)
Workspace.DescendantAdded:Connect(function(v)
    if Config.States.Instant and v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
end)

-- 5. STAMINA (HOOK)
Library:CreateButton("5. Vô hạn Thể Lực", function(state)
    Config.States.Stamina = state
end)
local mt = getrawmetatable(game); setreadonly(mt, false)
local old = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if Config.States.Stamina and not checkcaller() and (m == "FireServer" or m == "InvokeServer") then
        local n = tostring(self):lower()
        if n:find("stamina") or n:find("run") or n:find("energy") or n:find("exhaust") then return nil end
    end
    return old(self, ...)
end); setreadonly(mt, true)

-- 6. NOCLIP
Library:CreateButton("6. Xuyên Tường (Noclip)", function(state)
    Config.States.Noclip = state
    Library:Notify(state and "Bật Noclip" or "Tắt Noclip", state and "Success" or "Fail")
end)
RunService.Stepped:Connect(function()
    if Config.States.Noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- 7. FLY V2 (WASD)
Library:CreateButton("7. Fly Mode V2 (PC only)", function(state)
    Config.States.Fly = state
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if state and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "V28_Fly"; bv.MaxForce = Vector3.one * math.huge
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "V28_Gyro"; bg.MaxTorque = Vector3.one * math.huge; bg.P = 10000
        char.Humanoid.PlatformStand = true
        Library:Notify("Bay bằng WASD + Chuột", "Success")
    elseif hrp then
        for _,v in pairs(hrp:GetChildren()) do if v.Name:find("V28_") then v:Destroy() end end
        char.Humanoid.PlatformStand = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.States.Fly and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("V28_Fly") then
            local cf = camera.CFrame
            local vel = Vector3.zero
            hrp.V28_Gyro.CFrame = cf
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
            
            hrp.V28_Fly.Velocity = vel * Config.FlySpeed
        end
    end
end)

-- 8 & 9. ESP SYSTEM (OPTIMIZED)
Library:CreateButton("8. ESP Player (Box)", function(state)
    Config.States.Esp = state
    if not state then for _,v in pairs(Workspace:GetDescendants()) do if v.Name == "V28_ESP" then v:Destroy() end end end
end)
Library:CreateButton("9. ESP Item", function(state)
    Config.States.EspItem = state
    if not state then for _,v in pairs(Workspace:GetDescendants()) do if v.Name == "V28_Item" then v:Destroy() end end end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.States.Esp then
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") and not p.Character.Head:FindFirstChild("V28_ESP") then
                    local bg = Instance.new("BillboardGui", p.Character.Head); bg.Name = "V28_ESP"; bg.Size = UDim2.new(0,100,0,50); bg.AlwaysOnTop = true
                    local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1
                    t.Text = "⚠️ " .. p.Name; t.TextColor3 = Color3.fromRGB(255, 50, 50); t.TextStrokeTransparency = 0; t.Font = Enum.Font.GothamBlack
                end
            end
        end
        if Config.States.EspItem then
            for _,v in pairs(Workspace:GetDescendants()) do
                if (v:IsA("ProximityPrompt") or v:IsA("ClickDetector")) and v.Parent and not v.Parent:FindFirstChild("V28_Item") then
                     local bg = Instance.new("BillboardGui", v.Parent); bg.Name = "V28_Item"; bg.Size = UDim2.new(0,80,0,40); bg.AlwaysOnTop = true
                     local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1
                     t.Text = "💎 " .. v.Parent.Name; t.TextColor3 = Color3.fromRGB(0, 255, 255); t.TextStrokeTransparency = 0; t.Font = Enum.Font.GothamBold
                end
            end
        end
    end
end)

-- 10. BRIGHT
Library:CreateButton("10. Full Bright", function(state)
    Config.States.Bright = state
    Lighting.Brightness = state and 2 or 1
    Lighting.ClockTime = state and 14 or Lighting.ClockTime
end)

-- 11. FIX LAG
Library:CreateAction("11. Fix Lag (Tối ưu FPS)", Color3.fromRGB(0, 100, 200), function()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false end
        if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    end
    Library:Notify("Đã tối ưu đồ hoạ!", "Success")
end)

-- 12. ANTI AFK
Library:CreateButton("12. Anti-AFK", function(state)
    Config.States.AntiAfk = state
end)
player.Idled:Connect(function()
    if Config.States.AntiAfk then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.zero)
    end
end)

-- 13. TELEPORT
Library:CreateAction("13. [LƯU] Vị trí hiện tại", Color3.fromRGB(200, 150, 0), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        SavedCFrame = player.Character.HumanoidRootPart.CFrame
        Library:Notify("Đã lưu vị trí!", "Success")
    end
end)
Library:CreateAction("📍 [DỊCH] Đến vị trí lưu", Color3.fromRGB(50, 50, 50), function()
    if SavedCFrame and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = SavedCFrame
        Library:Notify("Đã dịch chuyển!", "Success")
    else
        Library:Notify("Chưa lưu vị trí!", "Fail")
    end
end)

-- 14. INVISIBLE
Library:CreateAction("14. Tàng hình (Xóa chân)", Color3.fromRGB(100, 0, 0), function()
    if player.Character and player.Character:FindFirstChild("LowerTorso") then
        player.Character.LowerTorso.Root:Destroy()
        Library:Notify("Đã kích hoạt tàng hình!", "Success")
    else
        Library:Notify("Không tìm thấy nhân vật!", "Fail")
    end
end)

-- >> TOGGLE OPEN BUTTON (DRAGON ICON)
local OpenBtn = Instance.new("TextButton", UI)
OpenBtn.Size = UDim2.new(0, 60, 0, 60); OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "🐉"; OpenBtn.TextSize = 35; OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local StrokeBtn = Instance.new("UIStroke", OpenBtn); StrokeBtn.Color = Color3.fromRGB(255, 0, 0); StrokeBtn.Thickness = 2
OpenBtn.Draggable = true

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

Library:Notify("TrNgHai V28 Loaded!", "Success")
