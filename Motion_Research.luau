local MotionModule = {
    Enabled = true,
    FlySpeed = 60,
    NoClip = false,
    GhostPosition = nil
}

local RunService = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer

RunService.Stepped:Connect(function()
    if not MotionModule.Enabled or not LP.Character then return end
    local Root = LP.Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    if MotionModule.GhostPosition then
        Root.CFrame = MotionModule.GhostPosition
        Root.Velocity = Vector3.new(0, 0, 0)
    end
    
    if MotionModule.NoClip then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

function MotionModule:SetState(mode, val)
    if mode == "fly" then
        self.GhostPosition = val and LP.Character.HumanoidRootPart.CFrame or nil
    elseif mode == "noclip" then
        self.NoClip = val
    end
end

return MotionModule
