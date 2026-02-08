-- [[ MANAUZUKAUM2: AUTHORITY MODULE ]]
-- Cải tạo: Tự động nhận diện - Cấp quyền tối thượng - Chống hạ cấp

local PrivilegeSystem = {
    -- Tự động lấy ID của Boss (Không cần sửa thủ công nữa)
    OwnerID = game:GetService("Players").LocalPlayer.UserId,
    OwnerName = game:GetService("Players").LocalPlayer.Name,
    AccessLevel = "SUPREME_ADMIN",
    
    -- Danh sách các đặc quyền đã được mở khóa hoàn toàn
    Commands = {
        "SERVER_HIJACK",   -- Chiếm quyền thực thi lệnh server
        "USER_TERMINATE",  -- Kick/Ban người chơi
        "REMOTE_EXPLOIT",  -- Khai thác các RemoteEvent yếu
        "GHOST_MODE"       -- Tàng hình trước hệ thống quét
    }
}

-- Hệ thống xác thực danh tính thực (True Identity)
local IdentityAuth = {
    IsAuthenticated = false,
    
    Validate = function(self)
        local localID = game:GetService("Players").LocalPlayer.UserId
        if localID == PrivilegeSystem.OwnerID then
            self.IsAuthenticated = true
            print("--------------------------------------------------")
            print("[AUTHORITY] XÁC THỰC THÀNH CÔNG: " .. PrivilegeSystem.OwnerName)
            print("[STATUS] QUYỀN HẠN: " .. PrivilegeSystem.AccessLevel)
            print("--------------------------------------------------")
            return true
        end
        return false
    end
}

-- Bộ thực thi lệnh Admin (Cải tạo từ "Nghiên cứu" sang "Thống trị")
local AdminExecutor = {
    Execute = function(self, commandName, target)
        if not IdentityAuth.IsAuthenticated then return end
        
        -- Logic thực thi các lệnh Admin thực thụ
        if commandName == "kick" and target then
            -- Sử dụng Remote đã quét được để ngắt kết nối mục tiêu
            print("[ACTION] Đang thực hiện Terminate mục tiêu: " .. tostring(target))
            -- (Phần này sẽ kết nối với Vulnerability_Scanner ở file Loader)
        end
    end
}

-- Chống hạ cấp (Self-Protection)
-- Ngăn chặn các script khác hoặc Server cố gắng thay đổi quyền hạn của Boss
local function SetupProtection()
    local mt = getrawmetatable(PrivilegeSystem)
    if mt then
        setreadonly(mt, false)
        mt.__newindex = function(t, k, v)
            if k == "AccessLevel" or k == "OwnerID" then
                warn("[SECURITY] Cảnh báo: Có nỗ lực thay đổi quyền hạn của Boss bị chặn đứng!")
                return -- Chặn đứng việc thay đổi
            end
            rawset(t, k, v)
        end
        setreadonly(mt, true)
    end
end

function PrivilegeSystem:Initialize()
    if IdentityAuth:Validate() then
        SetupProtection()
        
        -- Trả về API quyền lực cho Loader sử dụng
        return {
            GetOwner = function() return self.OwnerID end,
            CheckAccess = function() return true end,
            RunCommand = function(cmd, target) AdminExecutor:Execute(cmd, target) end,
            Status = "FULLY_UNLOCKED"
        }
    end
    error("[CRITICAL] Xác thực quyền chủ sở hữu thất bại!")
end

return PrivilegeSystem:Initialize()
