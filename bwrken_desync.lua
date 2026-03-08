local _k=false;local g,h,s=game:GetService("HttpService"),game:GetService("CoreGui"),Instance.new;local sg=s("ScreenGui");sg.Parent=h;sg.ResetOnSpawn=false;local f=s("Frame");f.Parent=sg;f.Size=UDim2.new(0,340,0,200);f.Position=UDim2.new(0.5,-170,0.5,-100);f.BackgroundColor3=Color3.fromRGB(10,10,20);f.BorderColor3=Color3.fromRGB(0,200,255);f.BorderSizePixel=2;local t=s("TextLabel");t.Parent=f;t.Size=UDim2.new(1,0,0,40);t.BackgroundColor3=Color3.fromRGB(0,20,40);t.BorderSizePixel=0;t.Text="Bwrken Desync | Key System";t.TextColor3=Color3.fromRGB(0,220,255);t.TextSize=14;t.Font=Enum.Font.GothamBold;local i=s("TextBox");i.Parent=f;i.Size=UDim2.new(0.85,0,0,36);i.Position=UDim2.new(0.075,0,0,60);i.BackgroundColor3=Color3.fromRGB(5,15,30);i.BorderColor3=Color3.fromRGB(0,100,150);i.TextColor3=Color3.fromRGB(200,230,255);i.PlaceholderText="Enter your key...";i.Text="";i.TextSize=13;i.Font=Enum.Font.Code;i.ClearTextOnFocus=false;local b=s("TextButton");b.Parent=f;b.Size=UDim2.new(0.85,0,0,34);b.Position=UDim2.new(0.075,0,0,106);b.BackgroundColor3=Color3.fromRGB(0,80,140);b.BorderSizePixel=0;b.Text="VERIFY KEY";b.TextColor3=Color3.fromRGB(255,255,255);b.TextSize=13;b.Font=Enum.Font.GothamBold;local l=s("TextLabel");l.Parent=f;l.Size=UDim2.new(1,0,0,30);l.Position=UDim2.new(0,0,0,150);l.BackgroundTransparency=1;l.Text="Enter your key above";l.TextColor
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Toggled = false
local LastPosition = nil
local Connection = nil

-- Improved hook function with less aggressive packet manipulation
local function rakhook(packet)
    if packet.PacketId == 0x1B then
        -- Instead of completely overwriting, we'll selectively modify
        local data = packet.AsBuffer
        local currentValue = buffer.readu32(data, 1)
        
        -- Only modify if needed, reducing server rejection
        if currentValue ~= 0 then
            buffer.writeu32(data, 1, 0)
            packet:SetData(data)
        end
        
        -- Return false occasionally to prevent complete blocking
        if math.random() > 0.7 then
            return false
        end
    end
end

-- Improved animation control with fallback
local function setNoAnimation(state)
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 5)
    local animate = character:FindFirstChild("Animate")
    
    if animate then
        animate.Disabled = state
    end
    
    -- Additional animation control
    if state and humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

-- Position interpolation to prevent lagback
local function startPositionTracking()
    Connection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = Player.Character.HumanoidRootPart
            
            if LastPosition then
                local distance = (rootPart.Position - LastPosition).Magnitude
                -- Prevent extreme position changes
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

-- Beautiful UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BwrkensDesyncUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Frame with gradient background
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Add rounded corners to main frame
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame

-- Add gradient background
local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
}
FrameGradient.Rotation = 90
FrameGradient.Parent = Frame

-- Add subtle border
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(80, 80, 90)
FrameStroke.Thickness = 1
FrameStroke.Transparency = 0.5
FrameStroke.Parent = Frame

-- Title with better styling
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

-- Status indicator
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

-- Beautiful toggle button
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

-- Rounded corners for button
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Button gradient
local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
}
ButtonGradient.Rotation = 90
ButtonGradient.Parent = ToggleButton

-- Button hover effect
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

-- Smooth toggle animation
ToggleButton.MouseButton1Click:Connect(function()
    if Toggled then
        -- Deactivate
        raknet.remove_send_hook(rakhook)
        setNoAnimation(false)
        stopPositionTracking()
        
        -- Animate UI
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
        -- Activate with delay to prevent instant freeze
        ToggleButton.Text = "INITIALIZING..."
        wait(0.1)
        
        raknet.add_send_hook(rakhook)
        setNoAnimation(true)
        startPositionTracking()
        
        -- Animate UI
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

-- Add minimize button
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

-- Cleanup on character respawn
Player.CharacterAdded:Connect(function()
    if Toggled then
        wait(1)
        setNoAnimation(true)
        startPositionTracking()
    end
end)
