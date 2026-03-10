local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Blacklisted users (script silently exits for these players)
local BLACKLIST = {
    ["Omar20145098"] = true,
}

if BLACKLIST[Player.Name] then
    return
end

local Toggled = false
local NoAnimToggled = false
local Connection = nil
local Keybind = nil

-- Load saved keybind
pcall(function()
    local saved = readfile("bwrken_keybind.txt"):gsub("%s+", "")
    if saved ~= "" then
        local ok, kc = pcall(function() return Enum.KeyCode[saved] end)
        if ok and kc then Keybind = saved end
    end
end)

-- Load saved position
local savedPosX, savedPosY = 0.5, 0.5
pcall(function()
    local data = readfile("bwrken_pos.txt"):gsub("%s+", "")
    local x, y = data:match("^([%d%.]+),([%d%.]+)$")
    if x and y then
        savedPosX = tonumber(x)
        savedPosY = tonumber(y)
    end
end)

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
    if animate then animate.Disabled = state end
    if state and humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

local function startDesync() end

local function stopDesync()
    if Connection then Connection:Disconnect(); Connection = nil end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BwrkensDesyncUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 280, 0, 165)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(savedPosX, 0, savedPosY, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Save position whenever it changes (fires on drag)
Frame:GetPropertyChangedSignal("Position"):Connect(function()
    pcall(function()
        local pos = Frame.Position
        writefile("bwrken_pos.txt", tostring(pos.X.Scale)..","..tostring(pos.Y.Scale))
    end)
end)

local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
}
FrameGradient.Rotation = 90
FrameGradient.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Thickness = 1.5
FrameStroke.Transparency = 0
FrameStroke.Parent = Frame

-- Title: leaves room on right for minimize button
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "BWRKEN'S DESYNC"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextStrokeTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new("Frame")
StatusDot.Parent = Frame
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0, 40)
StatusDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
StatusDot.BorderSizePixel = 0
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.Size = UDim2.new(0, 120, 0, 20)
StatusLabel.Position = UDim2.new(0, 22, 0, 33)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inactive"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 32)
ToggleButton.Position = UDim2.new(0.1, 0, 0, 57)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Text = "ACTIVATE"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(200, 200, 200)
ToggleStroke.Thickness = 1
ToggleStroke.Transparency = 0.5
ToggleStroke.Parent = ToggleButton

local NoAnimButton = Instance.new("TextButton")
NoAnimButton.Parent = Frame
NoAnimButton.Size = UDim2.new(0.8, 0, 0, 28)
NoAnimButton.Position = UDim2.new(0.1, 0, 0, 96)
NoAnimButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NoAnimButton.TextColor3 = Color3.fromRGB(200, 200, 200)
NoAnimButton.TextScaled = true
NoAnimButton.Text = "NO ANIM: OFF"
NoAnimButton.Font = Enum.Font.GothamBold
NoAnimButton.BorderSizePixel = 0
Instance.new("UICorner", NoAnimButton).CornerRadius = UDim.new(0, 8)
local NoAnimStroke = Instance.new("UIStroke")
NoAnimStroke.Color = Color3.fromRGB(180, 180, 180)
NoAnimStroke.Thickness = 1
NoAnimStroke.Transparency = 0.6
NoAnimStroke.Parent = NoAnimButton

local KeybindBox = Instance.new("TextBox")
KeybindBox.Parent = Frame
KeybindBox.Size = UDim2.new(0.8, 0, 0, 24)
KeybindBox.Position = UDim2.new(0.1, 0, 0, 133)
KeybindBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KeybindBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindBox.PlaceholderText = "Keybind: type key (e.g. F)"
KeybindBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
KeybindBox.Text = Keybind or ""
KeybindBox.TextScaled = true
KeybindBox.Font = Enum.Font.GothamBold
KeybindBox.BorderSizePixel = 0
KeybindBox.ClearTextOnFocus = false
Instance.new("UICorner", KeybindBox).CornerRadius = UDim.new(0, 6)
local KeybindStroke = Instance.new("UIStroke")
KeybindStroke.Color = Color3.fromRGB(255, 255, 255)
KeybindStroke.Thickness = 1
KeybindStroke.Transparency = 0.6
KeybindStroke.Parent = KeybindBox

-- Minimize button: tucked in from right edge so title text is never covered
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = Frame
MinimizeButton.Size = UDim2.new(0, 22, 0, 22)
MinimizeButton.Position = UDim2.new(1, -30, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BorderSizePixel = 0
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 5)
local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Color3.fromRGB(255, 255, 255)
MinStroke.Thickness = 1
MinStroke.Transparency = 0.5
MinStroke.Parent = MinimizeButton

KeybindBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local txt = KeybindBox.Text:gsub("%s+", "")
        if txt == "" then
            Keybind = nil
            KeybindBox.PlaceholderText = "Keybind: type key (e.g. F)"
            pcall(function() writefile("bwrken_keybind.txt", "") end)
        else
            txt = txt:sub(1,1):upper() .. txt:sub(2):lower()
            local ok, kc = pcall(function() return Enum.KeyCode[txt] end)
            if ok and kc then
                Keybind = txt
                KeybindBox.Text = txt
                pcall(function() writefile("bwrken_keybind.txt", txt) end)
            else
                Keybind = nil
                KeybindBox.Text = ""
                KeybindBox.PlaceholderText = "Invalid key! Try again"
            end
        end
    end
end)

local function updateButtonText()
    local keyStr = Keybind and " ["..Keybind.."]" or ""
    ToggleButton.Text = (Toggled and "DEACTIVATE" or "ACTIVATE") .. keyStr
end

updateButtonText()

local function doToggle()
    if Toggled then
        raknet.remove_send_hook(rakhook)
        stopDesync()
        NoAnimToggled = false
        setNoAnimation(false)
        NoAnimButton.Text = "NO ANIM: OFF"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        StatusLabel.Text = "Inactive"
        StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        ToggleButton.Text = "INITIALIZING..."
        task.wait(0.1)
        raknet.add_send_hook(rakhook)
        startDesync()
        NoAnimToggled = true
        setNoAnimation(true)
        NoAnimButton.Text = "NO ANIM: ON"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
        TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        StatusLabel.Text = "Active"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
    Toggled = not Toggled
    updateButtonText()
end

ToggleButton.MouseButton1Click:Connect(function()
    doToggle()
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Keybind and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode.Name == Keybind then
            doToggle()
        end
    end
end)

NoAnimButton.MouseButton1Click:Connect(function()
    if not Toggled then return end
    NoAnimToggled = not NoAnimToggled
    setNoAnimation(NoAnimToggled)
    if NoAnimToggled then
        NoAnimButton.Text = "NO ANIM: ON"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
    else
        NoAnimButton.Text = "NO ANIM: OFF"
        TweenService:Create(NoAnimButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 36)}):Play()
        ToggleButton.Visible = false
        NoAnimButton.Visible = false
        KeybindBox.Visible = false
        StatusDot.Visible = false
        StatusLabel.Visible = false
    else
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 165)}):Play()
        task.wait(0.25)
        ToggleButton.Visible = true
        NoAnimButton.Visible = true
        KeybindBox.Visible = true
        StatusDot.Visible = true
        StatusLabel.Visible = true
    end
end)

Player.CharacterAdded:Connect(function()
    if Toggled then
        task.wait(1)
        if NoAnimToggled then setNoAnimation(true) end
        startDesync()
    end
end)
