-- [[ MANAUZUKAUM2: SUPREME COMMAND CENTER ]]
-- Cải tạo: Kết nối Bộ Ngũ - Quản lý Phím tắt - Điều phối Tác chiến

local Loader = {
    Version = "3.0 - War Machine",
    Modules = {}
}

function Loader:Initialize()
    print("--------------------------------------------------")
    print("[SYSTEM] ĐANG KÍCH HOẠT HỆ THỐNG MANAUZUKAUM2...")
    
    -- 1. KẾT NỐI BỘ NGŨ QUYỀN NĂNG (Đấu dây các Module)
    local success, err = pcall(function()
        -- Load các thành phần cốt lõi
        self.Modules.Privilege = require(script.Parent.Privilege_Research)
        self.Modules.Motion    = require(script.Parent.Motion_Research)
        self.Modules.Scanner   = require(script.Parent.Vulnerability_Scanner)
        
        -- Load "Thanh kiếm" thực thi (File số 5 mới thêm vào)
        self.Modules.Execution = require(script.Parent.Execution_Hub)
    end)
    
    if not success then
        warn("[ERROR] Đấu dây thất bại! Kiểm tra lại tên 5 file trên GitHub: " .. tostring(err))
        return
    end

    -- 2. TỰ ĐỘNG CẬU NHẬT HỆ THỐNG (Sync dữ liệu)
    print("[SYSTEM] Đang đồng bộ hóa Mắt Thần và Thanh Kiếm...")
    self.Modules.Scanner:UpdateSecurityShield()
    
    -- 3. THIẾT LẬP TRÌNH ĐIỀU KHIỂN (Hotkeys)
    local UIS = game:GetService("UserInputService")
    
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        
        -- PHÍM F: KHÔNG TRỌNG LỰC (FLY)
        if input.KeyCode == Enum.KeyCode.F then
            local isFlying = not self.Modules.Motion.GhostPosition
            self.Modules.Motion:SetState("fly", isFlying)
            print("[MOTION] Trạng thái Bay: " .. (isFlying and "BẬT" or "TẮT"))
            
        -- PHÍM N: XUYÊN THỰC TẠI (NOCLIP)
        elseif input.KeyCode == Enum.KeyCode.N then
            local isNoClip = not self.Modules.Motion.NoClip
            self.Modules.Motion:SetState("noclip", isNoClip)
            print("[MOTION] Trạng thái Xuyên tường: " .. (isNoClip and "BẬT" or "TẮT"))
            
        -- PHÍM P: QUÉT TỬ HUYỆT (RADAR SCAN)
        elseif input.KeyCode == Enum.KeyCode.P then
            print("[RADAR] Đang tìm kiếm mục tiêu cho Thanh Kiếm...")
            self.Modules.Scanner:Refresh()
            
        -- PHÍM K: THỰC THI "TRỪNG PHẠT" (Dùng file số 5)
        elseif input.KeyCode == Enum.KeyCode.K then
            print("[HUB] Đang chuẩn bị lệnh trừng phạt...")
            -- Gọi hàm Punish từ file số 5 cho đối tượng gần nhất hoặc chỉ định
            -- self.Modules.Execution:Punish(game.Players.LocalPlayer) -- Ví dụ test
        end
    end)

    print("--------------------------------------------------")
    print("[READY] BỘ NGŨ MANAUZUKAUM2 ĐÃ SẴN SÀNG THỐNG TRỊ!")
    print("[HOTKEYS] F: Bay | N: Xuyên | P: Quét | K: Trừng phạt")
    print("--------------------------------------------------")
end

-- Kích nổ hệ thống
task.spawn(function()
    Loader:Initialize()
end)

return Loader
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "MANAUZUKAUM2 ACTIVE";
    Text = "Hệ thống đã bị chiếm quyền. Chào mừng Boss trở lại!";
    Icon = "rbxassetid://12345678"; -- Boss có thể thay ID ảnh ngầu vào đây
    Duration = 10;
})
