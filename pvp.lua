--[[
    TRNGHAI V29 - PVP ELITE EDITION (UPGRADED)
    ------------------------------------------
    Hướng dẫn: Dán toàn bộ nội dung này vào file pvp.lua để thay thế nội dung cũ.
    Tính năng chính:
    - Lưu & phục hồi trạng thái gốc của HumanoidRootPart (kích thước, transparency, color, material, canCollide, canTouch).
    - Áp dụng thay đổi khi CharacterAdded / PlayerAdded; khôi phục khi tắt tính năng hoặc PlayerRemoving.
    - Cập nhật theo interval để giảm tải (không dùng RenderStepped liên tục).
    - UI: bật/tắt Hitbox, God Mode, TeamCheck, tăng/giảm Hitbox size & transparency, Unload script.
    - Phím tắt RightShift để ẩn/hiện UI.
    - Unload an toàn: phục hồi mọi thay đổi, ngắt kết nối, xoá GUI, xoá cờ global.
]]

local g = getgenv and getgenv() or _G
if g.TrNgHai_PVP_Loaded then
    warn("TrNgHai_PVP already loaded")
    return
end
g.TrNgHai_PVP_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

-- [CONFIG]
local Config = {
    HitboxSize = 20, -- mặc định (rất lớn)
    HitboxTransparency = 0.7,
    HitboxEnabled = false,
    GodModeEnabled = false,
    TeamCheck = false,
    UIVisible = true,
    UpdateInterval = 0.12 -- giây giữa mỗi lần cập nhật hitbox để giảm load
}

-- [STATE] lưu trạng thái gốc để có thể phục hồi
local OriginalState = {} -- OriginalState[player] = {saved = true, props = {...}, part = hrp}

-- Utility: lưu thuộc tính gốc của HRP
local function saveOriginal(hrp, player)
    if not hrp or not player then return end
    if OriginalState[player] and OriginalState[player].saved then return end
    OriginalState[player] = {
        saved = true,
        part = hrp,
        props = {
            Size = hrp.Size,
            Transparency = hrp.Transparency,
            Color = hrp.Color,
            Material = hrp.Material,
            CanCollide = hrp.CanCollide,
            CanTouch = hrp.CanTouch
        }
    }
end

local function restoreOriginal(player)
    local data = OriginalState[player]
    if not data or not data.part then return end
    local hrp = data.part
    -- nếu hrp bị mất hay không hợp lệ thì bỏ qua
    if not hrp or not hrp.Parent then
        OriginalState[player] = nil
        return
    end
    local props = data.props
    pcall(function()
        hrp.Size = props.Size or Vector3.new(2,2,1)
        hrp.Transparency = props.Transparency or 1
        hrp.Color = props.Color or Color3.new(1,1,1)
        hrp.Material = props.Material or Enum.Material.Plastic
        hrp.CanCollide = (props.CanCollide == nil) and true or props.CanCollide
        hrp.CanTouch = (props.CanTouch == nil) and true or props.CanTouch
    end)
    OriginalState[player] = nil
end

-- Áp dụng hitbox lên hrp
local function applyHitboxTo(hrp, player)
    if not hrp or not hrp:IsA("BasePart") then return end
    saveOriginal(hrp, player)
    pcall(function()
        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
        hrp.Transparency = Config.HitboxTransparency
        hrp.Color = Color3.fromRGB(255, 0, 0)
        hrp.Material = Enum.Material.Neon
        hrp.CanCollide = false
        hrp.CanTouch = false
    end)
end

-- Kết nối & dọn dẹp
local connections = {
    playerAdded = nil,
    playerRemoving = nil,
    charAdded = {}, -- charAdded[player] = conn
    updateLoop = nil,
    inputConn = nil,
    unloadConn = nil,
    lpCharConn = nil
}

local function applyToPlayer(player)
    if not player or player == lp then return end
    local function onChar(char)
        if not char then return end
        local ok, hrp = pcall(function() return char:FindFirstChild("HumanoidRootPart") end)
        if not ok or not hrp then
            -- thử chờ 2s nếu cần
            hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 2) or hrp
        end
        if hrp and Config.HitboxEnabled then
            if (not Config.TeamCheck) or (player.Team ~= lp.Team) then
                applyHitboxTo(hrp, player)
            end
        end
    end

    -- áp dụng ngay nếu character có sẵn
    if player.Character then
        onChar(player.Character)
    end

    -- đảm bảo chỉ có 1 kết nối CharacterAdded cho mỗi player
    if connections.charAdded[player] then
        pcall(function() connections.charAdded[player]:Disconnect() end)
        connections.charAdded[player] = nil
    end
    connections.charAdded[player] = player.CharacterAdded:Connect(onChar)
end

local function removePlayerConnections(player)
    if connections.charAdded[player] then
        pcall(function() connections.charAdded[player]:Disconnect() end)
        connections.charAdded[player] = nil
    end
    restoreOriginal(player)
end

-- Player events
connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
    removePlayerConnections(player)
end)

connections.playerAdded = Players.PlayerAdded:Connect(function(player)
    if player ~= lp then
        applyToPlayer(player)
    end
end)

-- Khởi tạo cho các player hiện tại
for _, p in pairs(Players:GetPlayers()) do
    if p ~= lp then applyToPlayer(p) end
end

-- Hàm cập nhật hitbox cho tất cả player (gọi theo interval)
local function updateAllHitboxes()
    if not Config.HitboxEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then
                if (not Config.TeamCheck) or (player.Team ~= lp.Team) then
                    applyHitboxTo(hrp, player)
                else
                    -- nếu team check on và cùng team, phục hồi nếu trước đó thay đổi
                    if OriginalState[player] then restoreOriginal(player) end
                end
            end
        end
    end
end

-- Update loop theo interval
local lastUpdate = 0
connections.updateLoop = RunService.Heartbeat:Connect(function(dt)
    if not g.TrNgHai_PVP_Loaded then return end
    lastUpdate = lastUpdate + dt
    if lastUpdate < Config.UpdateInterval then return end
    lastUpdate = 0
    updateAllHitboxes()
end)

-- God Mode Implementation (local player)
local godConns = {} -- lưu kết nối Humanoid cho lp

local function enableGodMode()
    Config.GodModeEnabled = true
    StarterGui:SetCore("SendNotification", {Title = "TrNgHai PVP", Text = "🛡️ God Mode: BẬT", Duration = 3})
    -- function để attach lên humanoid
    local function onHum(hum)
        if not hum then return end
        -- tắt trạng thái chết
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        -- giữ máu bằng MaxHealth
        pcall(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
            hum.HealthChanged:Connect(function()
                pcall(function() if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end end)
            end)
            hum.Died:Connect(function()
                -- ngay cả khi die try revive by setting health
                pcall(function() hum.Health = hum.MaxHealth end)
            end)
        end)
    end

    -- nếu character tồn tại, attach
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then onHum(hum) end
    end
    -- kết nối CharacterAdded để attach tiếp
    if connections.lpCharConn then
        pcall(function() connections.lpCharConn:Disconnect() end)
        connections.lpCharConn = nil
    end
    connections.lpCharConn = lp.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then onHum(hum) end
    end)
end

local function disableGodMode()
    Config.GodModeEnabled = false
    StarterGui:SetCore("SendNotification", {Title = "TrNgHai PVP", Text = "🛡️ God Mode: TẮT", Duration = 3})
    -- ngắt kết nối CharacterAdded (nếu có)
    if connections.lpCharConn then
        pcall(function() connections.lpCharConn:Disconnect() end)
        connections.lpCharConn = nil
    end
    -- không cần restore humanoid health properties vì chúng là thuộc tính động; cố gắng để hum max bình thường
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
            end)
        end
    end
end

-- UI
local UI = Instance.new("ScreenGui")
UI.Name = "TrNgHai_PVP_UI"
-- CoreGui gắn trực tiếp (chú ý một số executor có hạn chế)
UI.Parent = CoreGui

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 260, 0, 340)
Main.Position = UDim2.new(0.5, -130, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local corner = Instance.new("UICorner", Main)
corner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 44)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "💠 PVP ELITE V29 (UPGRADED)"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local function makeButton(text, posY)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    local uc = Instance.new("UICorner", btn)
    uc.CornerRadius = UDim.new(0,6)
    return btn
end

local toggleHitboxBtn = makeButton("BẬT HITBOX (SIÊU TO)", 50)
local godBtn = makeButton("BẤT TỬ (GOD MODE)", 96)
local teamBtn = makeButton("TEAM CHECK (OFF = ĐÁNH TẤT)", 142)
local incBtn = makeButton("TĂNG HITBOX (+)", 188)
local decBtn = makeButton("GIẢM HITBOX (-)", 232)
local transDecBtn = makeButton("GIẢM TRANSPARENCY", 276)
local transIncBtn = makeButton("TĂNG TRANSPARENCY", 320)
local unloadBtn = makeButton("UNLOAD & RESTORE", 364)
Main.Size = UDim2.new(0, 260, 0, 420)

-- Helper to update button color on state
local function setBtnState(btn, enabled)
    btn.BackgroundColor3 = enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 35, 45)
end

-- Button callbacks
toggleHitboxBtn.MouseButton1Click:Connect(function()
    Config.HitboxEnabled = not Config.HitboxEnabled
    setBtnState(toggleHitboxBtn, Config.HitboxEnabled)
    if not Config.HitboxEnabled then
        -- restore all
        for player, _ in pairs(OriginalState) do
            restoreOriginal(player)
        end
        OriginalState = {}
    else
        -- apply immediately
        updateAllHitboxes()
    end
end)

godBtn.MouseButton1Click:Connect(function()
    Config.GodModeEnabled = not Config.GodModeEnabled
    setBtnState(godBtn, Config.GodModeEnabled)
    if Config.GodModeEnabled then enableGodMode() else disableGodMode() end
end)

teamBtn.MouseButton1Click:Connect(function()
    Config.TeamCheck = not Config.TeamCheck
    setBtnState(teamBtn, Config.TeamCheck)
    -- nếu bật teamcheck thì restore cùng team
    if Config.HitboxEnabled then updateAllHitboxes() end
end)

incBtn.MouseButton1Click:Connect(function()
    Config.HitboxSize = math.clamp(Config.HitboxSize + 2, 1, 200)
    StarterGui:SetCore("SendNotification", {Title="TrNgHai PVP", Text="Hitbox Size: "..tostring(Config.HitboxSize), Duration=1})
    if Config.HitboxEnabled then updateAllHitboxes() end
end)

decBtn.MouseButton1Click:Connect(function()
    Config.HitboxSize = math.clamp(Config.HitboxSize - 2, 1, 200)
    StarterGui:SetCore("SendNotification", {Title="TrNgHai PVP", Text="Hitbox Size: "..tostring(Config.HitboxSize), Duration=1})
    if Config.HitboxEnabled then updateAllHitboxes() end
end)

transDecBtn.MouseButton1Click:Connect(function()
    Config.HitboxTransparency = math.clamp(Config.HitboxTransparency - 0.05, 0, 1)
    StarterGui:SetCore("SendNotification", {Title="TrNgHai PVP", Text="Transparency: "..string.format("%.2f",Config.HitboxTransparency), Duration=1})
    if Config.HitboxEnabled then updateAllHitboxes() end
end)

transIncBtn.MouseButton1Click:Connect(function()
    Config.HitboxTransparency = math.clamp(Config.HitboxTransparency + 0.05, 0, 1)
    StarterGui:SetCore("SendNotification", {Title="TrNgHai PVP", Text="Transparency: "..string.format("%.2f",Config.HitboxTransparency), Duration=1})
    if Config.HitboxEnabled then updateAllHitboxes() end
end)

-- Unload: restore and disconnect everything
local function Unload()
    if not g.TrNgHai_PVP_Loaded then return end
    g.TrNgHai_PVP_Loaded = nil

    -- restore hitboxes
    for player, _ in pairs(OriginalState) do
        pcall(function() restoreOriginal(player) end)
    end
    OriginalState = {}

    -- restore local humanoid settings
    if lp and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
            pcall(function() if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end end)
        end
    end

    -- disconnect connections
    for k, v in pairs(connections) do
        if v and typeof(v) == "RBXScriptConnection" then
            pcall(function() v:Disconnect() end)
        elseif type(v) == "table" then
            for a,b in pairs(v) do
                if typeof(b) == "RBXScriptConnection" then pcall(function() b:Disconnect() end) end
            end
        end
    end

    -- destroy UI
    pcall(function() UI:Destroy() end)

    StarterGui:SetCore("SendNotification", {Title="TrNgHai PVP", Text="Script đã gỡ — mọi thay đổi đã được phục hồi", Duration=4})
    print("TrNgHai PVP Unloaded & Restored")
end

unloadBtn.MouseButton1Click:Connect(Unload)

-- Keybind: RightShift to hide/show UI
connections.inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.UIVisible = not Config.UIVisible
        Main.Visible = Config.UIVisible
    end
end)

-- Ensure UI initial button states
setBtnState(toggleHitboxBtn, Config.HitboxEnabled)
setBtnState(godBtn, Config.GodModeEnabled)
setBtnState(teamBtn, Config.TeamCheck)

StarterGui:SetCore("SendNotification", {Title = "TrNgHai PVP", Text = "TrNgHai PVP Elite Edition Loaded!", Duration = 3})
print("TrNgHai PVP Elite Edition Loaded!")

-- Safety: nếu script bị unload bằng cách khác, cố gắng cleanup thông thường (lắng nghe niling global)
connections.unloadConn = nil
-- Nothing else needed; Unload() là entrypoint để gỡ.
