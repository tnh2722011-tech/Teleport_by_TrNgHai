--[[
    TRNGHAI V29 - ETERNAL LEGACY
    --------------------------------
    [+] UI: Aero Glass Design (Sang trọng, Hiện đại).
    [+] Teleport: Multi-Point System (Lưu/Xóa/TP nhiều điểm).
    [+] ESP: Player, Item, NPC (Separated).
    [+] Core: Fix Jump Logic, God Mode (NoTouch), Optimize.
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_V29_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "TrNgHai V29", Text = "Script đang chạy!", Duration = 3})
    return 
end
g.TrNgHai_V29_Loaded = true

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

-- [CONFIG]
local Config = {
    Speed = 16, Jump = 50, FlySpeed = 60,
    Waypoints = {}, -- Lưu danh sách vị trí {Name = "...", CFrame = ...}
    States = {
        Speed = false, Jump = false, Ghost = false, Instant = false,
        Stamina = false, Noclip = false, Fly = false, 
        EspPlayer = false, EspItem = false, EspNPC = false,
        Bright = false, AntiAfk = true, GodMode = false
    }
}

-- [CLEANUP]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("TrNgHai") then v:Destroy() end
end

-- [UI SYSTEM - AERO GLASS]
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "TrNgHai_Eternal"
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 450, 0, 320) -- Form chữ nhật ngang
Main.Position = UDim2.new(0.5, -225, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Blur Effect Background
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(80, 120, 255) -- Màu xanh Neon
MainStroke.Transparency = 0.5

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "💠 TRNGHAI V29 ETERNAL"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(150, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- [TAB SYSTEM]
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(0, 110, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0

local PageContainer = Instance.new("Frame", Main)
PageContainer.Size = UDim2.new(1, -120, 1, -50)
PageContainer.Position = UDim2.new(0, 115, 0, 45)
PageContainer.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = {} -- Lưu các trang

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton", TabContainer)
    tabBtn.Size = UDim2.new(0, 100, 0, 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = icon .. "  " .. name
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local padding = Instance.new("UIPadding", tabBtn); padding.PaddingLeft = UDim.new(0, 10)
    
    -- Tạo trang tương ứng
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0) -- Auto resize sau
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    table.insert(Pages, {Btn = tabBtn, Page = page})
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(80, 120, 255)
    end)
    
    return page
end

local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.8, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.new(0.9,0.9,0.9)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 10, 0, 10); status.Position = UDim2.new(1, -20, 0.5, -5)
    status.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Instance.new("UICorner", status).CornerRadius = UDim.new(1,0)
    
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(60, 60, 60)}):Play()
        callback(on)
    end)
end

local function CreateInput(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- [TAB 1: MOVEMENT & PLAYER]
local TabMove = CreateTab("Movement", "⚡")

CreateInput(TabMove, "Nhập Tốc Độ (Mặc định 16)", function(v) Config.Speed = tonumber(v) or 16 end)
CreateToggle(TabMove, "Bật Speed (Render Override)", function(s) Config.States.Speed = s end)

CreateInput(TabMove, "Nhập Độ Cao (Mặc định 50)", function(v) Config.Jump = tonumber(v) or 50 end)
CreateToggle(TabMove, "Bật Jump (Force Logic)", function(s) 
    Config.States.Jump = s 
    if s and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true -- BẮT BUỘC DÙNG JUMPPOWER
    end
end)

CreateToggle(TabMove, "Fly V2 (WASD + Mouse)", function(s)
    Config.States.Fly = s
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if s and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "V29_Fly"; bv.MaxForce = Vector3.one * math.huge
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "V29_Gyro"; bg.MaxTorque = Vector3.one * math.huge; bg.P = 10000
        char.Humanoid.PlatformStand = true
    elseif hrp then
        for _,v in pairs(hrp:GetChildren()) do if v.Name:find("V29_") then v:Destroy() end end
        char.Humanoid.PlatformStand = false
    end
end)

CreateToggle(TabMove, "Noclip (Xuyên Tường)", function(s) Config.States.Noclip = s end)
CreateToggle(TabMove, "Ghost NPC (Đứng yên)", function(s) Config.States.Ghost = s end)

-- [TAB 2: COMBAT & GOD]
local TabCombat = CreateTab("Combat", "⚔️")

CreateToggle(TabCombat, "🛡️ GOD MODE (Hitbox Null)", function(s)
    Config.States.GodMode = s
    if s and player.Character then
        -- Xóa TouchInterest ở Handle của tool hoặc bộ phận cơ thể để tránh dính dame chạm
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("TouchTransmitter") then v:Destroy() end
        end
    end
end)

CreateToggle(TabCombat, "Instant Interact (E)", function(s) Config.States.Instant = s end)

-- [TAB 3: ESP MASTER]
local TabEsp = CreateTab("Visuals", "👁️")

CreateToggle(TabEsp, "ESP Player (Người chơi)", function(s) Config.States.EspPlayer = s end)
CreateToggle(TabEsp, "ESP NPC (Quái/Bot)", function(s) Config.States.EspNPC = s end)
CreateToggle(TabEsp, "ESP Item (Vật phẩm)", function(s) Config.States.EspItem = s end)
CreateToggle(TabEsp, "Full Bright (Sáng)", function(s) Config.States.Bright = s; Lighting.Brightness = s and 2 or 1 end)

-- [TAB 4: TELEPORT PRO]
local TabTp = CreateTab("Teleport", "📍")

local TpNameInput = "Point 1"
CreateInput(TabTp, "Tên vị trí (VD: Bai Farm 1)", function(v) TpNameInput = v end)

CreateButton(TabTp, "💾 LƯU VỊ TRÍ HIỆN TẠI", Color3.fromRGB(0, 150, 100), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.CFrame
        table.insert(Config.Waypoints, {Name = TpNameInput, CFrame = pos})
        
        -- Tạo nút TP mới ngay lập tức
        local idx = #Config.Waypoints
        local data = Config.Waypoints[idx]
        
        local container = Instance.new("Frame", TabTp)
        container.Size = UDim2.new(1, -10, 0, 30)
        container.BackgroundTransparency = 1
        
        local btnTP = Instance.new("TextButton", container)
        btnTP.Size = UDim2.new(0.7, 0, 1, 0); btnTP.BackgroundColor3 = Color3.fromRGB(60,60,70); btnTP.Text = "Go: " .. data.Name
        btnTP.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnTP).CornerRadius = UDim.new(0,6)
        
        local btnDel = Instance.new("TextButton", container)
        btnDel.Size = UDim2.new(0.25, 0, 1, 0); btnDel.Position = UDim2.new(0.75, 0, 0, 0); btnDel.BackgroundColor3 = Color3.fromRGB(150,50,50)
        btnDel.Text = "X"; btnDel.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0,6)
        
        btnTP.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = data.CFrame
            end
        end)
        
        btnDel.MouseButton1Click:Connect(function()
            container:Destroy()
            table.remove(Config.Waypoints, idx)
        end)
    end
end)

-- [TAB 5: SETTINGS]
local TabSet = CreateTab("Settings", "⚙️")
CreateButton(TabSet, "Fix Lag (Tối ưu)", Color3.fromRGB(0, 100, 200), function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false end
    end
end)
CreateToggle(TabSet, "Anti-AFK", function(s) Config.States.AntiAfk = s end)
CreateButton(TabSet, "Tắt GUI", Color3.fromRGB(200, 50, 50), function() UI:Destroy() end)

-- ================= LOGIC LOOPS =================

-- >> SPEED & JUMP FIX
RunService.RenderStepped:Connect(function()
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            if Config.States.Speed then hum.WalkSpeed = Config.Speed end
            if Config.States.Jump then 
                hum.UseJumpPower = true -- FIX JUMP
                hum.JumpPower = Config.Jump 
            end
        end
    end
end)

-- >> MOVEMENT LOGIC
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Ghost NPC
    if Config.States.Ghost then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero end
    end
    
    -- Noclip
    if Config.States.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    -- God Mode (Null Hitbox Loop)
    if Config.States.GodMode then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanTouch = false end -- Không nhận sự kiện chạm
        end
    end
end)

-- >> FLY LOGIC (SMOOTH)
RunService.RenderStepped:Connect(function()
    if Config.States.Fly and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("V29_Fly") then
            local cf = camera.CFrame
            local vel = Vector3.zero
            hrp.V29_Gyro.CFrame = cf
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
            
            hrp.V29_Fly.Velocity = vel * Config.FlySpeed
        end
    end
end)

-- >> ESP SYSTEM (LOOP TỐI ƯU 1s/lần)
local function CreateESP(target, name, color)
    if not target:FindFirstChild("V29_ESP") then
        local bg = Instance.new("BillboardGui", target)
        bg.Name = "V29_ESP"; bg.Size = UDim2.new(0,100,0,50); bg.AlwaysOnTop = true
        local t = Instance.new("TextLabel", bg); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1
        t.Text = name; t.TextColor3 = color; t.Font = Enum.Font.GothamBold; t.TextStrokeTransparency = 0
    end
end

task.spawn(function()
    while task.wait(1) do
        -- Clear Old ESP if turned off
        if not Config.States.EspPlayer and not Config.States.EspNPC and not Config.States.EspItem then
            for _,v in pairs(Workspace:GetDescendants()) do if v.Name == "V29_ESP" then v:Destroy() end end
        end

        -- ESP PLAYER
        if Config.States.EspPlayer then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    CreateESP(p.Character.Head, "👤 " .. p.Name, Color3.fromRGB(255, 50, 50))
                end
            end
        end
        
        -- SCAN WORKSPACE
        if Config.States.EspNPC or Config.States.EspItem or Config.States.Instant then
            for _, v in pairs(Workspace:GetDescendants()) do
                -- ESP NPC
                if Config.States.EspNPC and v:IsA("Humanoid") and v.Parent.Name ~= player.Name and not Players:GetPlayerFromCharacter(v.Parent) then
                    local head = v.Parent:FindFirstChild("Head")
                    if head then CreateESP(head, "👾 " .. v.Parent.Name, Color3.fromRGB(255, 170, 0)) end
                end
                
                -- ESP ITEM & INSTANT
                if (v:IsA("ProximityPrompt") or v:IsA("ClickDetector")) then
                    if Config.States.Instant and v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
                    if Config.States.EspItem and v.Parent then
                         CreateESP(v.Parent, "💎 " .. v.Parent.Name, Color3.fromRGB(0, 255, 255))
                    end
                end
            end
        end
    end
end)

-- >> ANTI AFK
player.Idled:Connect(function()
    if Config.States.AntiAfk then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.zero)
    end
end)

-- >> TOGGLE BUTTON
local OpenBtn = Instance.new("TextButton", UI)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0.02, 0, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); OpenBtn.Text = "💠"
OpenBtn.TextColor3 = Color3.fromRGB(80, 120, 255); OpenBtn.TextSize = 25
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local s = Instance.new("UIStroke", OpenBtn); s.Color = Color3.fromRGB(80, 120, 255); s.Thickness = 2
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
