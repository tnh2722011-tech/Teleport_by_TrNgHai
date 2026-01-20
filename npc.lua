--[[ 
    SHADOWCLOAK: Vô hiệu hóa nhận diện của NPC
    -----------------------------------------
    Cơ chế xử lý:
    1. Spoof Position: Đánh lừa lệnh kiểm tra Khoảng cách (Magnitude) và Góc nhìn (FOV).
    2. Raycast Filter: Làm tia laser của NPC xuyên qua người (Raycasting).
    3. Touch Disable: Vô hiệu hóa các vùng cảm biến va chạm (Spatial Queries).
]]

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

-- Cấu hình tọa độ giả (Gửi cho NPC một vị trí cực xa để chúng không thấy bạn)
local FAKE_POSITION = Vector3.new(0, 9999, 0) 

-- [1 & 3] VÔ HIỆU HÓA KHOẢNG CÁCH, GÓC NHÌN & CẢM BIẾN VA CHẠM
-- Chúng ta sẽ khóa thuộc tính CanTouch và đánh lừa lệnh lấy vị trí .Position
for _, part in pairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanTouch = false -- NPC không thể phát hiện bạn qua va chạm (Spatial Queries)
    end
end

local mt = getrawmetatable(game)
local old_index = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(t, k)
    -- Nếu một Script (của NPC) hỏi vị trí của bạn, hãy đưa cho nó tọa độ giả
    if not checkcaller() and t:IsA("Part") and (k == "Position" or k == "CFrame") then
        if t:IsDescendantOf(char) then
            return (k == "Position" and FAKE_POSITION or CFrame.new(FAKE_POSITION))
        end
    end
    return old_index(t, k)
end)

-- [2] VÔ HIỆU HÓA TẦM NHÌN THẲNG (RAYCASTING)
-- Ép các tia laser của NPC không bao giờ chạm được vào bạn
local old_namecall
old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        -- Nếu tia laser bắn trúng bạn, xóa kết quả đó để NPC tưởng là bắn trúng không khí
        local result = old_namecall(self, unpack(args))
        if result and typeof(result) == "Instance" and result:IsDescendantOf(char) then
            return nil
        elseif typeof(result) == "RaycastResult" and result.Instance:IsDescendantOf(char) then
            return nil
        end
    end
    return old_namecall(self, ...)
end))

setreadonly(mt, true)

-- [4] TỰ ĐỘNG CẬP NHẬT KHI NHÂN VẬT HỒI SINH
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = false end
    end
end)

print("ShadowCloak đã kích hoạt: Bạn đã tàng hình trước mọi NPC.")
