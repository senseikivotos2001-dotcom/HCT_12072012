-- [[ MANAUZUKAUM2: SUPREME COMMAND CENTER ]]
-- Version: 3.0 [OPTIMIZED]
-- Repo: senseikivotos2001-dotcom/HCT_12072012

local Loader = {
    Modules = {},
    Url = "https://raw.githubusercontent.com/senseikivotos2001-dotcom/HCT_12072012/main/"
}

function Loader:Fetch(file)
    local success, content = pcall(game.HttpGet, game, self.Url .. file .. ".luau")
    if success then
        return loadstring(content)()
    else
        warn("[!] Failed to load: " .. file)
    end
end

function Loader:Initialize()
    -- 1. Nạp UI Giám sát (Dùng pcall để không bị văng nếu mất mạng)
    local Status = self:Fetch("Status_Monitor")
    if Status then 
        Status:Initialize() 
        Status.Update("Kích hoạt hệ thống Manauz...", 20)
    end

    -- 2. Đấu nối Bộ Ngũ (Nạp song song)
    task.spawn(function()
        self.Modules.Privilege = self:Fetch("Privilege_Research")
        self.Modules.Motion    = self:Fetch("Motion_Research")
        self.Modules.Scanner   = self:Fetch("Vulnerability_Scanner")
        self.Modules.Execution = self:Fetch("Execution_Hub")
        
        if Status then Status.Update("Kết nối Module hoàn tất!", 80) end
        
        -- 3. Kích hoạt Command Bar
        self.Modules.Console = self:Fetch("Command_Bar")
        if self.Modules.Console then
            self.Modules.Console:Initialize()
            if Status then Status.Update("Hệ thống SẴN SÀNG!", 100) end
        end
    end)
end

-- Khởi hỏa
task.spawn(function() Loader:Initialize() end)

return Loader
