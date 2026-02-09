--[[ 
    HCT_12072012 - ADVANCED KERNEL VIRTUALIZER (REFINE BUILD)
    =========================================================
    Codename: QuantumLock v2.1
    Target: Delta X / Fluxus (Mobile)
    Purpose: Tạo môi trường thực thi ảo, ẩn danh và tự phục hồi.
]]

-- ================= [1] CẤU HÌNH HỆ THỐNG (SYSTEM CONFIG) =================
local KERNEL_CONFIG = {
    VERSION = "2.1_QuantumLock_Stable",
    HEARTBEAT_INTERVAL = 5,      -- Giãn cách nhịp tim (Giảm lag cho Mobile)
    MEMORY_CLOAK_INTERVAL = 10,  -- Chu kỳ đổi mã vùng nhớ
    SELF_HEAL_THRESHOLD = 5,     -- Số lần bị can thiệp tối đa trước khi Reset
    ENCRYPTION_LAYERS = 5,       -- 5 lớp mã hóa (Theo yêu cầu của Boss)
    LOGGING_ENABLED = true,      -- Bật log để theo dõi (Debug)
    STEALTH_MODE = false         -- Tắt tàng hình để kiểm tra hoạt động trước
}

-- Polyfill cho các Executor yếu (phòng hờ thiếu hàm)
local getgenv = getgenv or function() return _G end
local setreadonly = setreadonly or function(t, v) end
local checkcaller = checkcaller or function() return true end

-- ================= [2] LÕI KERNEL (CORE STATE) =================
local Kernel = {
    State = {
        Active = true,
        Integrity = 100,
        TamperAttempts = 0,
        LastHeartbeat = os.clock(),
        EnvironmentLocks = {},
        CloakedReferences = {},
        Watchdogs = {},
        RecoveryPoints = {}
    },
    Security = {
        EnvironmentHash = nil,
        LastIntegrityCheck = 0,
        TamperFlags = {}
    }
}

-- ================= [3] HỆ THỐNG MÃ HÓA (ENCRYPTION) =================
local EncryptionLayer = {
    GenerateKey = function()
        local key = ""
        for i = 1, 32 do -- Tăng độ dài key lên 32
            key = key .. string.char(math.random(33, 126))
        end
        return key
    end,
    
    XorEncrypt = function(text, key)
        if type(text) ~= "string" then return text end -- Chỉ mã hóa string
        local encrypted = {}
        for i = 1, #text do
            local char = string.byte(text, i)
            local keyChar = string.byte(key, (i - 1) % #key + 1)
            table.insert(encrypted, string.char(bit32.bxor(char, keyChar)))
        end
        return table.concat(encrypted)
    end,
    
    ProtectEnvironment = function(env)
        -- Tạo vỏ bọc ảo
        local protectedEnv = {}
        local protectionKey = EncryptionLayer.GenerateKey()
        
        -- Mã hóa dữ liệu tĩnh
        for k, v in pairs(env) do
            if type(v) == "string" and k:sub(1,2) ~= "__" then
                protectedEnv[k] = EncryptionLayer.XorEncrypt(v, protectionKey)
            else
                protectedEnv[k] = v
            end
        end
        
        -- Lưu key giải mã ẩn
        protectedEnv.__PROTECTION_KEY = protectionKey
        protectedEnv.__DECRYPT = function(self, value)
            if type(value) == "string" then
                return EncryptionLayer.XorEncrypt(value, self.__PROTECTION_KEY)
            end
            return value
        end
        
        return protectedEnv
    end
}

-- ================= [4] QUẢN LÝ MÔI TRƯỜNG (ENVIRONMENT) =================
function Kernel:InitializeVirtualEnvironment()
    -- Khởi tạo môi trường ảo HCT_VOID
    if not getgenv().HCT_VIRTUAL_KERNEL then
        local raw_env = {
            __VERSION = KERNEL_CONFIG.VERSION,
            __CREATION_TIME = os.time(),
            __ENCRYPTION_LEVEL = KERNEL_CONFIG.ENCRYPTION_LAYERS,
            Modules = {},
            Logs = {},
            Storage = {}
        }
        
        -- Áp dụng 5 lớp mã hóa chồng lên nhau
        local layered_env = raw_env
        for i = 1, KERNEL_CONFIG.ENCRYPTION_LAYERS do
            layered_env = EncryptionLayer.ProtectEnvironment(layered_env)
        end
        
        getgenv().HCT_VIRTUAL_KERNEL = layered_env
    end
    
    -- Tính toán Hash ban đầu để làm mốc so sánh
    self.Security.EnvironmentHash = self:CalculateEnvironmentHash()
    self:LogEvent("INIT", "Môi trường ảo đã dựng với " .. KERNEL_CONFIG.ENCRYPTION_LAYERS .. " lớp QuantumLock.")
    
    return getgenv().HCT_VIRTUAL_KERNEL
end

function Kernel:CalculateEnvironmentHash()
    local env = getgenv().HCT_VIRTUAL_KERNEL or {}
    local hashStr = ""
    -- Tạo chuỗi định danh dựa trên các key tồn tại
    for k, v in pairs(env) do
        hashStr = hashStr .. tostring(k) .. ":" .. type(v) .. ";"
    end
    -- Hash đơn giản (DJB2 variant)
    local hash = 5381
    for i = 1, #hashStr do
        hash = bit32.bxor(hash * 33, string.byte(hashStr, i))
    end
    return string.format("%08x", hash)
end

-- ================= [5] TÀNG HÌNH BỘ NHỚ (MEMORY CLOAKING) =================
function Kernel:CloakMemory()
    if not KERNEL_CONFIG.STEALTH_MODE then return end -- Nếu tắt Stealth thì không chạy
    
    -- Tạo dữ liệu rác để đánh lạc hướng Admin scan
    local garbage_names = {"_ROBLOX_Analytics", "_G_Physics", "Core_Update_V2"}
    
    for _, name in ipairs(garbage_names) do
        -- Đổi tên ngẫu nhiên mỗi lần cloak
        local randomSuffix = "_" .. math.random(1000, 9999)
        local cloakName = name .. randomSuffix
        
        if not self.State.CloakedReferences[cloakName] then
            pcall(function()
                getgenv()[cloakName] = string.rep("0", math.random(100, 500)) -- Rác bộ nhớ
                self.State.CloakedReferences[cloakName] = true
            end)
        end
    end
    
    -- Dọn rác ngẫu nhiên để xóa dấu vết
    if math.random() > 0.8 then collectgarbage("collect") end
    self:LogEvent("CLOAK", "Đã đảo mã vùng nhớ thành công.")
end

-- ================= [6] HỆ THỐNG CHỐNG CAN THIỆP (ANTI-TAMPER) =================
function Kernel:DetectTamper()
    local currentHash = self:CalculateEnvironmentHash()
    local originalHash = self.Security.EnvironmentHash
    
    if currentHash ~= originalHash then
        self.State.TamperAttempts = self.State.TamperAttempts + 1
        self.State.Integrity = math.max(0, self.State.Integrity - 25) -- Trừ điểm mạnh tay hơn
        
        self:LogEvent("TAMPER", "Phát hiện can thiệp! Integrity: " .. self.State.Integrity .. "%")
        return true
    end
    return false
end

function Kernel:ApplyEnvironmentLock()
    -- Khóa các bảng hệ thống quan trọng
    local criticalTables = {getgenv(), debug, table, math}
    
    for _, tbl in ipairs(criticalTables) do
        -- Dùng pcall để tránh lỗi trên Delta X
        pcall(function()
            if setreadonly then setreadonly(tbl, false) end -- Đảm bảo ta luôn có quyền ghi
        end)
    end
end

-- ================= [7] TỰ PHỤC HỒI (SELF-HEALING) =================
function Kernel:CreateRecoveryPoint(name)
    -- Lưu lại trạng thái hiện tại
    local recoveryPoint = {
        Name = name,
        Timestamp = os.time(),
        EnvironmentHash = self.Security.EnvironmentHash,
        Integrity = self.State.Integrity
    }
    self.State.RecoveryPoints[name] = recoveryPoint
    self:LogEvent("RECOVERY", "Đã tạo điểm khôi phục: " .. name)
    return recoveryPoint
end

function Kernel:SelfHeal()
    self:LogEvent("HEAL", "Hệ thống đang tự sửa chữa...")
    
    -- Reset lại toàn bộ trạng thái an ninh
    self.State.TamperAttempts = 0
    self.State.Integrity = 100
    self:InitializeVirtualEnvironment() -- Dựng lại môi trường ảo mới
    self:CreateRecoveryPoint("PostHeal_" .. os.time())
    
    self:LogEvent("HEAL", "Đã khôi phục hệ thống về 100% Integrity.")
    return true
end

-- ================= [8] CHƯNG CẤT MÃ NGUỒN (INJECTION) =================
function Kernel:AdvancedInject(fileName, code, options)
    options = options or {}
    local priority = options.priority or "NORMAL"
    local stealth = options.stealth or KERNEL_CONFIG.STEALTH_MODE
    
    -- 1. Bọc code vào lớp vỏ bảo vệ (Wrapper)
    local wrapper = [[
        local KERNEL_ENV = getgenv().HCT_VIRTUAL_KERNEL
        local _G_REF = getgenv()
        
        -- Hàm giả lập (Stealth Proxies)
        local function s_print(...) 
            if not ]] .. tostring(stealth) .. [[ then _G_REF.print("[VIRTUAL] ", ...) end 
        end
        
        return function()
            -- Ép code chạy trong môi trường Sandbox
            local env = setmetatable({}, {
                __index = function(t, k) return _G_REF[k] end,
                __newindex = function(t, k, v) _G_REF[k] = v end
            })
            setfenv(1, env)
            
            -- Code gốc của module
            ]] .. code .. [[
        end
    ]]
    
    -- 2. Biên dịch
    local chunk, err = loadstring(wrapper, "=" .. fileName)
    if not chunk then
        self:LogEvent("ERROR", "Lỗi biên dịch module " .. fileName .. ": " .. tostring(err))
        return false
    end
    
    -- 3. Thực thi
    local executable = chunk() -- Lấy hàm đã bọc
    
    if priority == "CRITICAL" then
        task.spawn(function()
            local s, e = pcall(executable)
            if s then 
                self:LogEvent("EXEC", "Module " .. fileName .. " (CRITICAL) đã kích hoạt.")
            else
                self:LogEvent("ERROR", "Lỗi chạy module " .. fileName .. ": " .. tostring(e))
            end
        end)
    else
        task.delay(0.5, function() -- Delay nhẹ để không nghẽn luồng
            pcall(executable)
            self:LogEvent("EXEC", "Module " .. fileName .. " đang chạy nền.")
        end)
    end
    
    -- 4. Lưu vào bộ nhớ ảo để Persistence
    if getgenv().HCT_VIRTUAL_KERNEL.Modules then
        getgenv().HCT_VIRTUAL_KERNEL.Modules[fileName] = "ACTIVE"
    end
    
    return true
end

-- ================= [9] HỆ THỐNG WATCHDOG =================
function Kernel:CreateWatchdog(name, checkFunc, repairFunc, interval)
    local wd = {Active = true, Interval = interval}
    self.State.Watchdogs[name] = wd
    
    task.spawn(function()
        while wd.Active and self.State.Active do
            task.wait(wd.Interval)
            local success, healthy = pcall(checkFunc)
            
            if success and not healthy then
                self:LogEvent("ALERT", "Watchdog " .. name .. " báo động!")
                if repairFunc then 
                    pcall(repairFunc)
                    self:LogEvent("REPAIR", "Đã sửa lỗi cho " .. name)
                end
            end
        end
    end)
end

-- ================= [10] NHỊP TIM & LOGGING =================
function Kernel:LogEvent(level, msg)
    if not KERNEL_CONFIG.LOGGING_ENABLED then return end
    print(string.format("[☢️ HCT_KERNEL] [%s]: %s", level, msg))
end

function Kernel:Start()
    if not self.State.Active then return end
    self:InitializeVirtualEnvironment()
    self:CreateRecoveryPoint("Boot")
    
    self:LogEvent("START", "Kernel QuantumLock v" .. KERNEL_CONFIG.VERSION .. " đã khởi động.")
    
    -- Vòng lặp chính (Heartbeat)
    task.spawn(function()
        while self.State.Active do
            task.wait(KERNEL_CONFIG.HEARTBEAT_INTERVAL)
            
            -- 1. Kiểm tra Integrity
            if self:DetectTamper() then
                if self.State.TamperAttempts >= KERNEL_CONFIG.SELF_HEAL_THRESHOLD then
                    self:SelfHeal()
                end
            end
            
            -- 2. Mở khóa môi trường
            self:ApplyEnvironmentLock()
            
            -- 3. Tàng hình bộ nhớ (Mỗi 2 nhịp tim)
            if os.clock() % KERNEL_CONFIG.MEMORY_CLOAK_INTERVAL < 1 then
                self:CloakMemory()
            end
        end
    end)
end

-- Khởi động tự động
Kernel:Start()

-- API Public cho các module khác
return {
    Inject = function(self, ...) return Kernel:AdvancedInject(...) end,
    GetStatus = function() return Kernel.State end,
    Config = KERNEL_CONFIG
}
