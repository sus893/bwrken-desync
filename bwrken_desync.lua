local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Toggled = false
local NoAnimToggled = false
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

local function startDesync()
    Connection = RunService.Heartbeat:Connect(function()
        -- position lock removed, desync only
    end)
end

local function stopDesync()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BwrkensDesyncUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 220, 0, 140)
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

-- Main toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 32)
ToggleButton.Position = UDim2.new(0.1, 0, 0, 52)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Text = "ACTIVATE"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- No animation toggle button
local NoAnimButton = Instance.new("TextButton")
NoAnimButton.Parent = Frame
NoAnimButton.Size = UDim2.new(0.8, 0, 0, 28)
NoAnimButton.Position = UDim2.new(0.1, 0, 0, 95)
NoAnimButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
NoAnimButton.TextColor3 = Color3.fromRGB(200, 200, 255)
NoAnimButton.TextScaled = true
NoAnimButton.Text = "NO ANIM: OFF"
NoAnimButton.Font = Enum.Font.GothamBold
NoAnimButton.BorderSizePixel = 0

local NoAnimCorner = Instance.new("UICorner")
NoAnimCorner.CornerRadius = UDim.new(0, 8)
NoAnimCorner.Parent = NoAnimButton

-- Minimize button
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

-- Main toggle logic
ToggleButton.MouseButton1Click:Connect(function()
    if Toggled then
        raknet.remove_send_hook(rakhook)
        stopDesync()
        -- turn off no anim when deactivating
        NoAnimToggled = false
        setNoAnimation(false)
        NoAnimButton.Text = "NO ANIM: OFF"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 100)}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
        ToggleButton.Text = "ACTIVATE"
        StatusLabel.Text = "Inactive"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        ToggleButton.Text = "INITIALIZING..."
        wait(0.1)
        raknet.add_send_hook(rakhook)
        startDesync()
        -- auto enable no anim on activate
        NoAnimToggled = true
        setNoAnimation(true)
        NoAnimButton.Text = "NO ANIM: ON"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 80, 200)}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 200, 100)}):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 255, 100)}):Play()
        ToggleButton.Text = "DEACTIVATE"
        StatusLabel.Text = "Active"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
    end
    Toggled = not Toggled
end)

-- No anim toggle logic (only works while desync is active)
NoAnimButton.MouseButton1Click:Connect(function()
    if not Toggled then return end
    NoAnimToggled = not NoAnimToggled
    setNoAnimation(NoAnimToggled)
    if NoAnimToggled then
        NoAnimButton.Text = "NO ANIM: ON"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 80, 200)}):Play()
    else
        NoAnimButton.Text = "NO ANIM: OFF"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 100)}):Play()
    end
end)

-- Minimize logic
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 35)}):Play()
        ToggleButton.Visible = false
        NoAnimButton.Visible = false
        StatusDot.Visible = false
        StatusLabel.Visible = false
    else
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 140)}):Play()
        wait(0.2)
        ToggleButton.Visible = true
        NoAnimButton.Visible = true
        StatusDot.Visible = true
        StatusLabel.Visible = true
    end
end)

Player.CharacterAdded:Connect(function()
    if Toggled then
        wait(1)
        if NoAnimToggled then
            setNoAnimation(true)
        end
        startDesync()
    end
end)
