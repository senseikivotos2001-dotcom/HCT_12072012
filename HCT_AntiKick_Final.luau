-- [[ PROJECT: HCT_12072012 - SECURITY LAYER ]]
-- PURPOSE: ENSURING SESSION CONTINUITY

local NetworkProtector = { Enabled = true }
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Danh sách "Đen" (Chặn đứng mọi lệnh trục xuất)
local BLACKLIST = {
    "Kick", "kick", "Disconnect", "Close", "Destroy", "Remove",
    "Teleport", "TeleportToPlaceInstance"
}

-- Hệ thống Hook Metatable (Giữ lại phần lõi mạnh nhất)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

-- ### 1. CHẶN LỆNH GỌI (Namecall) ###
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not NetworkProtector.Enabled then return oldNamecall(self, ...) end

    -- Kiểm tra nếu lệnh nằm trong danh sách đen và tác động lên Boss
    for _, blocked in ipairs(BLACKLIST) do
        if method == blocked and (self == LP or self == game:GetService("NetworkClient")) then
            -- Chỉ in cảnh báo nhẹ để Boss biết Admin vừa "hụt"
            warn("[HCT_SECURITY]: Đã chặn nỗ lực " .. method .. " từ hệ thống.")
            return nil -- Vô hiệu hóa lệnh
        end
    end

    return oldNamecall(self, ...)
end)

-- ### 2. BẢO VỆ THỰC THỂ (Index) ###
mt.__index = newcclosure(function(self, key)
    if not NetworkProtector.Enabled then return oldIndex(self, key) end

    -- Ngăn chặn việc xóa nhân vật hoặc thay đổi Parent để làm văng game
    if self == LP and (key == "Parent" or key == "Character") then
        return Players
    end
    
    -- Chặn các hàm xóa trực tiếp khi bị gọi qua Index
    if key == "Destroy" or key == "Remove" then
        return function() return nil end
    end

    return oldIndex(self, key)
end)

setreadonly(mt, true)
print("[HCT]: Giao thức Anti-Kick đã được nạp thành công.")

return NetworkProtector
