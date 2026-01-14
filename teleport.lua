--[[ 
   SCRIPT CREATED FOR TRNGHAI 
   Features: Save Pos, Teleport List, Noclip, Fly
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SaveBtn = Instance.new("TextButton")
local NoclipBtn = Instance.new("TextButton")
local FlyBtn = Instance.new("TextButton")
local ScrollList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Cấu hình Giao diện (GUI)
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển trên màn hình

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "HACK MENU - TRNGHAI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

-- Nút Lưu vị trí
SaveBtn.Parent = MainFrame
SaveBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
SaveBtn.Size = UDim2.new(0.9, 0, 0, 30)
SaveBtn.Text = "Lưu Vị Trí Hiện Tại"
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

-- Nút Xuyên tường (Noclip)
NoclipBtn.Parent = MainFrame
NoclipBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 30)
NoclipBtn.Text = "Xuyên Tường: OFF"
NoclipBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Nút Bay (Fly)
FlyBtn.Parent = MainFrame
FlyBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
FlyBtn.Size = UDim2.new(0.9, 0, 0, 30)
FlyBtn.Text = "Bay: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Danh sách điểm Teleport
ScrollList.Parent = MainFrame
ScrollList.Position = UDim2.new(0.05, 0, 0.42, 0)
ScrollList.Size = UDim2.new(0.9, 0, 0.55, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-----------------------------------------------------------
-- LOGIC XỬ LÝ
-----------------------------------------------------------

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local noclip = false
local flying = false
local posCount = 0

-- 1. Hàm Lưu vị trí và tạo nút Teleport
SaveBtn.MouseButton1Click:Connect(function()
    posCount = posCount + 1
    local currentPos = char.HumanoidRootPart.CFrame
    local posName = "Điểm " .. posCount
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Parent = ScrollList
    tpBtn.Size = UDim2.new(1, 0, 0, 25)
    tpBtn.Text = "Đến: " .. posName
    tpBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    tpBtn.MouseButton1Click:Connect(function()
        char.HumanoidRootPart.CFrame = currentPos
    end)
end)

-- 2. Hàm Xuyên tường (Noclip)
NoclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    NoclipBtn.Text = noclip and "Xuyên Tường: ON" or "Xuyên Tường: OFF"
    NoclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 3. Hàm Bay (Fly) - Đơn giản hóa
FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    FlyBtn.Text = flying and "Bay: ON" or "Bay: OFF"
    FlyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    
    if flying then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Name = "FlyVelocity"
        char.Humanoid.PlatformStand = true
    else
        if char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
            char.HumanoidRootPart.FlyVelocity:Destroy()
        end
        char.Humanoid.PlatformStand = false
    end
end)

-- Điều khiển bay bằng phím (Cơ bản)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if flying and char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
        local bv = char.HumanoidRootPart.FlyVelocity
        if input.KeyCode == Enum.KeyCode.W then bv.Velocity = char.HumanoidRootPart.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.S then bv.Velocity = char.HumanoidRootPart.CFrame.LookVector * -50
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if flying and char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
        char.HumanoidRootPart.FlyVelocity.Velocity = Vector3.new(0,0.1,0)
    end
end)
