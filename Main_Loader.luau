--[[ 
    HCT_12072012 - ELITE EXECUTION HUB (V4.0 MODDED)
    Mục tiêu: Tối ưu hóa tốc độ nạp Anti-Kick và bảo vệ hệ thống.
]]
if not loadstring then
    getgenv().loadstring = function(...) return error("Executor không hỗ trợ loadstring") end
end

local CONFIG = {
    BASE_URL = "https://raw.githubusercontent.com/senseikivotos2001-dotcom/HCT_12072012/main/",
    PARALLEL_LOAD = true, -- Giữ lại nạp song song để đạt tốc độ tối đa
    LOAD_TIMEOUT = 7,     -- Giảm timeout để xử lý nhanh
}

local SystemState = {
    Modules = {
        {Name = "Privilege_Research.luau", Priority = 1, Desc = "Anti-Kick Core"}, -- Luôn ưu tiên số 1
        {Name = "Motion_Research.luau", Priority = 2, Desc = "Movement"},
        {Name = "Vulnerability_Scanner.luau", Priority = 3, Desc = "Scanner"},
        {Name = "Execution_Hub.luau", Priority = 4, Desc = "Core Engine"},
        {Name = "Status_Monitor.luau", Priority = 5, Desc = "Monitor"}
    }
}

-- ### HÀM THỰC THI (TINH GỌN) ###
local function ExecuteElite(moduleName)
    local success, content = pcall(function()
        return game:HttpGet(CONFIG.BASE_URL .. moduleName, true)
    end)
    
    if success and content then
        -- Sử dụng newcclosure để ẩn danh hàm nạp
        local func, err = loadstring(content, moduleName)
        if func then
            task.spawn(function()
                -- Chạy với môi trường bảo vệ
                local ok, runErr = pcall(func)
                if not ok then warn("[HCT_ERR]: " .. moduleName .. " -> " .. runErr) end
            end)
            print("[HCT_ACTIVE]: " .. moduleName)
            return true
        end
    end
    warn("[HCT_FAIL]: " .. moduleName)
    return false
end

-- ### HỆ THỐNG NẠP SONG SONG (GIỮ LẠI TỪ BẢN GỐC) ###
local function BootSystem()
    print("------------------------------------------------------")
    print("[HCT_V4_ELITE]: Khởi chạy giao thức bất tử...")

    -- 1. Nạp cưỡng bức Anti-Kick trước (Sequential Load cho P1)
    ExecuteElite(SystemState.Modules[1].Name)
    task.wait(0.2) -- Nhịp nghỉ cực ngắn để MetaMethod kịp ăn vào hệ thống

    -- 2. Nạp song song các module còn lại (Parallel Load cho P2-P5)
    if CONFIG.PARALLEL_LOAD then
        for i = 2, #SystemState.Modules do
            task.spawn(function()
                ExecuteElite(SystemState.Modules[i].Name)
            end)
        end
    else
        for i = 2, #SystemState.Modules do
            ExecuteElite(SystemState.Modules[i].Name)
        end
    end

    print("[HCT_V4_ELITE]: Toàn bộ hệ thống đã trực chiến.")
    print("------------------------------------------------------")
end

-- Tự động dọn dẹp bộ nhớ định kỳ (Giữ lại từ bản cũ)
task.spawn(function()
    while task.wait(60) do
        collectgarbage("collect")
    end
end)

return BootSystem()
