local raknet = require("raknet")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Toggled = false
local LastPosition = nil
local Connection = nil

local function rakhook(packet)
    if packet.PacketId == 0x1B then
        local data = packet.AsBuffer
        local currentValue = buffer.readu32(data, 1)
        if currentValue ~= 0 then
            buffer.writeu32(data, 1, 0)
            packet:SetData(data)
        end
        if math.random() > 0.7 then
            return false
        end
    end
end

local function setNoAnimation(state)
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 5)
    local animate = character:FindFirstChild("Animate")
    if animate then
        animate.Disabled = state
    end
    if state and humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

local function startPositionTracking()
    Connection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = Player.Character.HumanoidRootPart
            if LastPosition then
                local distance = (rootPart.Position - LastPosition).Magnitude
                if distance > 50 then
                    rootPart.CFrame = CFrame.new(LastPosition) * rootPart.CFrame.Rotation
                end
            end
            LastPosition = rootPart.Position
        end
    end)
end

local function stopPositionTracking()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    LastPosition = nil
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BwrkensDesyncUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame

local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
}
FrameGradient.Rotation = 90
FrameGradient.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(80, 80, 90)
FrameStroke.Thickness = 1
FrameStroke.Transparency = 0.5
FrameStroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "BWRKEN'S DESYNC"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.Gotham
Title.TextStrokeTransparency = 0.8
Title.TextStrokeColor3 = Color3.fromRGB(100, 100, 255)

local StatusDot = Instance.new("Frame")
StatusDot.Parent = Frame
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0, 35)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
StatusDot.BorderSizePixel = 0

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.Size = UDim2.new(0, 100, 0, 20)
StatusLabel.Position = UDim2.new(0, 22, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inactive"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.55, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Text = "ACTIVATE"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
}
ButtonGradient.Rotation = 90
ButtonGradient.Parent = ToggleButton

local hovering = false
ToggleButton.MouseEnter:Connect(function()
    hovering = true
    if not Toggled then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(85, 85, 95)
        }):Play()
    end
end)

ToggleButton.MouseLeave:Connect(function()
    hovering = false
    if not Toggled then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        }):Play()
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    if Toggled then
        raknet.remove_send_hook(rakhook)
        setNoAnimation(false)
        stopPositionTracking()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        }):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        }):Play()
        ToggleButton.Text = "ACTIVATE"
        StatusLabel.Text = "Inactive"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        ToggleButton.Text = "INITIALIZING..."
        wait(0.1)
        raknet.add_send_hook(rakhook)
        setNoAnimation(true)
        startPositionTracking()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        }):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        }):Play()
        ToggleButton.Text = "DEACTIVATE"
        StatusLabel.Text = "Active"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
    end
    Toggled = not Toggled
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -25, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BorderSizePixel = 0

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 220, 0, 35)
        }):Play()
        ToggleButton.Visible = false
        StatusDot.Visible = false
        StatusLabel.Visible = false
    else
        TweenService:Create(Frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 220, 0, 100)
        }):Play()
        wait(0.2)
        ToggleButton.Visible = true
        StatusDot.Visible = true
        StatusLabel.Visible = true
    end
end)

Player.CharacterAdded:Connect(function()
    if Toggled then
        wait(1)
        setNoAnimation(true)
        startPositionTracking()
    end
end)
