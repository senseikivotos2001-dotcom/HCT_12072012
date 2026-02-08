-- [[ FOR EDUCATIONAL PURPOSES ONLY ]]
-- Project: HCT_12072012
-- Mobile Command Center: Kết nối Module Nghiên cứu

local CommandBar = {}
local state = {Commands = {}, Visible = false}

-- Cấu hình màu sắc đồng bộ với Status Monitor
local THEME = {
    BG = Color3.fromRGB(15, 15, 20),
    ACCENT = Color3.fromRGB(150, 0, 0), -- Đỏ đặc trưng
    TEXT = Color3.fromRGB(255, 255, 255),
    SUCCESS = Color3.fromRGB(0, 255, 100)
}

-- Hàm đăng ký lệnh (Dùng để kết nối với các file khác)
function CommandBar.Register(name, callback, help)
    state.Commands[name:lower()] = {Run = callback, Help = help or "No info"}
end

-- Khởi tạo giao diện Mobile
function CommandBar:Initialize()
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "Manauz_CommandBar"
    
    -- Nút kích hoạt tàng hình (>_)
    local toggle = Instance.new("TextButton", sg)
    toggle.Size = UDim2.new(0, 45, 0, 45)
    toggle.Position = UDim2.new(1, -60, 0.5, 0)
    toggle.BackgroundColor3 = THEME.ACCENT
    toggle.Text = ">_"
    toggle.TextColor3 = THEME.TEXT
    toggle.Font = Enum.Font.Code
    toggle.TextSize = 20
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    -- Khung nhập lệnh (Mặc định ẩn)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0.8, 0, 0, 50)
    main.Position = UDim2.new(0.1, 0, -0.2, 0) -- Giấu phía trên
    main.BackgroundColor3 = THEME.BG
    main.BorderSizePixel = 1
    main.BorderColor3 = THEME.ACCENT
    main.Visible = false
    Instance.new("UICorner", main)

    local input = Instance.new("TextBox", main)
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Enter Research Command..."
    input.TextColor3 = THEME.TEXT
    input.TextSize = 16
    input.Font = Enum.Font.Code
    input.Text = ""

    -- Logic Ẩn/Hiện
    toggle.MouseButton1Click:Connect(function()
        state.Visible = not state.Visible
        main.Visible = state.Visible
        if state.Visible then
            main:TweenPosition(UDim2.new(0.1, 0, 0.1, 0), "Out", "Back", 0.3)
            input:CaptureFocus()
        else
            main:TweenPosition(UDim2.new(0.1, 0, -0.2, 0), "In", "Quad", 0.2)
        end
    end)

    -- Xử lý lệnh khi Enter
    input.FocusLost:Connect(function(enter)
        if enter then
            local raw = input.Text:lower()
            local args = raw:split(" ")
            local cmdName = table.remove(args, 1)
            
            if state.Commands[cmdName] then
                local success, res = pcall(function() return state.Commands[cmdName].Run(args) end)
                print(success and "[NICE] " .. tostring(res) or "[error] Command Failed")
            else
                print("[error] Unknown Command: " .. tostring(cmdName))
            end
            input.Text = ""
            toggle:Click() -- Tự đóng sau khi nhập
        end
    end)
end

-- Hàm thực thi nhanh
function CommandBar.Run(cmdStr)
    local args = cmdStr:split(" ")
    local name = table.remove(args, 1)
    if state.Commands[name] then state.Commands[name].Run(args) end
end

return CommandBar
