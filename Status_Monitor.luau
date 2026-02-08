-- [[ FOR EDUCATIONAL PURPOSES ONLY ]]
-- Project: HCT_12072012
-- Mobile Optimized System Logger & Progress Monitor

local StatusMonitor = {}
StatusMonitor.__index = StatusMonitor

local CONFIG = {
    POSITION = UDim2.new(0.5, -160, 0.05, 0),
    SIZE = UDim2.new(0, 320, 0, 140),
    BG_COLOR = Color3.fromRGB(15, 15, 20),
    ACCENT_COLOR = Color3.fromRGB(150, 0, 0), -- Màu đỏ đặc trưng dự án
    TEXT_COLOR = Color3.fromRGB(220, 220, 220),
    LOG_BG = Color3.fromRGB(10, 10, 12),
}

local function createUI()
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "Manauz_Monitor"
    sg.IgnoreGuiInset = true

    local main = Instance.new("Frame", sg)
    main.Size = CONFIG.SIZE
    main.Position = CONFIG.POSITION
    main.BackgroundColor3 = CONFIG.BG_COLOR
    main.BorderSizePixel = 1
    main.BorderColor3 = CONFIG.ACCENT_COLOR

    -- Hiệu ứng bo góc nhẹ cho mobile
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 6)

    -- Tiêu đề
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "  SYSTEM DIAGNOSTICS [MOBILE_VER]"
    title.TextColor3 = CONFIG.ACCENT_COLOR
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Khu vực Log (Nơi hiện [NICE] và [error])
    local logFrame = Instance.new("ScrollingFrame", main)
    logFrame.Size = UDim2.new(1, -20, 0, 70)
    logFrame.Position = UDim2.new(0, 10, 0, 30)
    logFrame.BackgroundColor3 = CONFIG.LOG_BG
    logFrame.BorderSizePixel = 0
    logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logFrame.ScrollBarThickness = 2

    local layout = Instance.new("UIListLayout", logFrame)
    layout.Padding = UDim.new(0, 2)

    -- Thanh tiến trình phía dưới
    local barBG = Instance.new("Frame", main)
    barBG.Size = UDim2.new(1, -20, 0, 4)
    barBG.Position = UDim2.new(0, 10, 1, -15)
    barBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBG.BorderSizePixel = 0

    local bar = Instance.new("Frame", barBG)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = CONFIG.ACCENT_COLOR
    bar.BorderSizePixel = 0

    return {Gui = sg, Main = main, Log = logFrame, Bar = bar}
end

function StatusMonitor:Initialize()
    if self.UI then self.UI.Gui:Destroy() end
    self.UI = createUI()
end

-- Hàm quan trọng: Cập nhật dòng log và thanh tiến trình
function StatusMonitor.Update(text, percent)
    if not StatusMonitor.UI then return end
    
    local logLine = Instance.new("TextLabel", StatusMonitor.UI.Log)
    logLine.Size = UDim2.new(1, 0, 0, 16)
    logLine.BackgroundTransparency = 1
    logLine.Text = "> " .. text
    logLine.TextSize = 12
    logLine.Font = Enum.Font.Code
    logLine.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Tự động đổi màu dựa trên nội dung log
    if text:find("%[NICE%]") then
        logLine.TextColor3 = Color3.fromRGB(0, 255, 100)
    elseif text:find("%[error%]") then
        logLine.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        logLine.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    -- Cuộn xuống cuối log
    StatusMonitor.UI.Log.CanvasPosition = Vector2.new(0, 9999)
    
    -- Cập nhật thanh bar
    local p = math.clamp(percent or 0, 0, 100) / 100
    StatusMonitor.UI.Bar:TweenSize(UDim2.new(p, 0, 1, 0), "Out", "Linear", 0.2)
end

function StatusMonitor:Hide()
    if self.UI then
        game:GetService("TweenService"):Create(self.UI.Main, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        self.UI.Gui:Destroy()
        self.UI = nil
    end
end

return StatusMonitor
