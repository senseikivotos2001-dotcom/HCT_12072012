-- [[ HCT_12072012 - SYSTEM BOOTLOADER V7.0 ]]
-- Tích hợp: Kernel Virtualizer (QuantumLock v2.1)
-- Target: Delta X / Fluxus (Mobile Optimization)

local CONFIG = {
    REPO_URL = "https://raw.githubusercontent.com/senseikivotos2001-dotcom/HCT_12072012/main/",
    KERNEL_FILE = "Kernel_Virtualizer.luau",
    -- Danh sách Module và độ ưu tiên
    MODULES = {
        {Name = "Privilege_Research.luau",    Priority = "CRITICAL", Stealth = true}, -- Anti-Kick (Cần chạy ngay)
        {Name = "Vulnerability_Scanner.luau", Priority = "HIGH",     Stealth = true}, -- Quét lỗ hổng
        {Name = "Motion_Research.luau",       Priority = "NORMAL",   Stealth = false}, -- Bay/Tốc độ
        {Name = "Execution_Hub.luau",         Priority = "NORMAL",   Stealth = false}, -- UI/Menu
        {Name = "Status_Monitor.luau",        Priority = "LOW",      Stealth = true}   -- Monitor
    }
}

-- Hàm tiện ích: Gửi thông báo hệ thống
local function Notify(title, msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title; Text = msg; Duration = 5;
        })
    end)
    print(string.format("[>> SYSTEM]: %s | %s", title, msg))
end

-- ================= [ GIAI ĐOẠN 1: KHỞI ĐỘNG KERNEL ] =================
Notify("HCT BOOT", "Đang khởi tạo môi trường ảo QuantumLock...")

local success_k, kernel_code = pcall(game.HttpGet, game, CONFIG.REPO_URL .. CONFIG.KERNEL_FILE)

if not success_k or not kernel_code then
    return Notify("FATAL ERROR", "Không thể tải Kernel! Hệ thống dừng hoạt động.")
end

-- Nạp Kernel vào bộ nhớ
local load_k, err_k = loadstring(kernel_code)
if not load_k then
    return Notify("KERNEL PANIC", "Lỗi cú pháp Kernel: " .. tostring(err_k))
end

-- Kích hoạt Kernel và lấy API điều khiển
local HCT_API = load_k() 
getgenv().HCT_API = HCT_API -- Lưu API ra global để dùng sau này nếu cần

-- Kiểm tra sức khỏe Kernel
local status = HCT_API.GetStatus()
if not status.Active then
    return Notify("KERNEL FAIL", "Kernel không khởi động được!")
end

Notify("KERNEL ONLINE", string.format("Integrity: %d%% | Active Threads: %d", status.Integrity, 0))

-- ================= [ GIAI ĐOẠN 2: CHƯNG CẤT MODULE ] =================
local loaded_count = 0

for _, module in ipairs(CONFIG.MODULES) do
    -- Tải code thô từ GitHub
    local url = CONFIG.REPO_URL .. module.Name
    local s, code = pcall(game.HttpGet, game, url)
    
    if s and code then
        -- Dùng Kernel để "Inject" (Chưng cất) code vào môi trường ảo
        -- Thay vì dùng loadstring() thường, ta dùng HCT_API:Inject()
        local injected = HCT_API:Inject(module.Name, code, {
            priority = module.Priority,
            stealth = module.Stealth,
            persistence = true
        })
        
        if injected then
            print(string.format("[>> INJECT]: %-25s [OK] -> Priority: %s", module.Name, module.Priority))
            loaded_count = loaded_count + 1
        else
            warn(string.format("[>> ERROR]: %-25s [FAIL] -> Kernel từ chối nạp.", module.Name))
        end
    else
        warn(string.format("[>> MISSING]: %-25s [404] -> Không tìm thấy file.", module.Name))
    end
    
    task.wait(0.2) -- Nghỉ nhẹ để tránh nghẽn mạng Delta X
end

-- ================= [ GIAI ĐOẠN 3: HOÀN TẤT ] =================
Notify("SYSTEM READY", string.format("Đã nạp thành công %d/%d module vào Vùng Ảo.", loaded_count, #CONFIG.MODULES))
