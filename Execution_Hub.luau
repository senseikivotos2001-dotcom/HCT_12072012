-- [[ MANAUZUKAUM2: SYSTEM INTERVENTION HUB ]]
-- Cải tạo: Ép lệnh Server - Trừng phạt mục tiêu - Phá vỡ giới hạn game

local InterventionHub = {
    CurrentTarget = nil,
    InterventionActive = true
}

-- 1. HÀM ÉP LỆNH (FORCE EXECUTION)
-- Dùng để "nhồi" dữ liệu vào các RemoteEvent đã quét được để ép Server thực thi theo ý Boss
function InterventionHub:ForceExecute(remoteName, ...)
    local Scanner = require(script.Parent.Vulnerability_Scanner)
    local targets = Scanner:GetTargets()
    
    if targets[remoteName] then
        local remote = targets[remoteName].Object
        print("[FORCE] Đang ép lệnh qua cổng: " .. remoteName)
        
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    else
        warn("[FAILED] Cổng này quá bảo mật hoặc không tồn tại!")
    end
end

-- 2. CHẾ ĐỘ TRỪNG PHẠT (PUNISHMENT MODE)
-- Biến mục tiêu thành "bao cát" để Boss thử nghiệm các lỗ hổng
function InterventionHub:Punish(targetName)
    local player = game.Players:FindFirstChild(targetName)
    if player and player.Character then
        print("[DOMINANCE] Đang áp đặt quyền năng lên: " .. targetName)
        
        -- Chỗ này Boss có thể tự thêm các lệnh trừng phạt cụ thể dựa trên game
        -- Ví dụ: Ép chết, đóng băng, hoặc văng khỏi map nếu có Remote hỗ trợ
    else
        print("[SYSTEM] Không tìm thấy đối tượng để trừng phạt.")
    end
end

-- 3. PHÁ VỠ GIỚI HẠN (LIMIT BREAKER)
-- Gỡ bỏ các rào cản di chuyển hoặc tương tác mà game đặt ra
function InterventionHub:BreakLimits()
    print("[BREAKER] Đang bẻ gãy các giới hạn hệ thống...")
    
    -- Gỡ bỏ giới hạn tốc độ rơi, nhảy, và trọng lực cục bộ
    game:GetService("Workspace").Gravity = 196.2 -- Reset về chuẩn nếu bị game làm khó
    local LP = game:GetService("Players").LocalPlayer
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid").MaxSlopeAngle = 90
    end
end

function InterventionHub:Initialize()
    print("[HUB] Hệ thống Can thiệp đã sẵn sàng. Mục tiêu: Thống trị.")
    return {
        Force = function(name, ...) self:ForceExecute(name, ...) end,
        Punish = function(target) self:Punish(target) end,
        Break = function() self:BreakLimits() end,
        Status = "DOMINANCE_READY"
    }
end

return InterventionHub:Initialize()
