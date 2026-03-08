local _k = false
local g = game:GetService("HttpService")
local h = game:GetService("CoreGui")
local s = Instance.new

-- Try to load saved key
local savedKey = ""
pcall(function()
    savedKey = readfile("bwrken_key.txt")
end)

local sg = s("ScreenGui"); sg.Parent = h; sg.ResetOnSpawn = false
local f = s("Frame"); f.Parent = sg; f.Size = UDim2.new(0,340,0,200); f.Position = UDim2.new(0.5,-170,0.5,-100); f.BackgroundColor3 = Color3.fromRGB(10,10,20); f.BorderColor3 = Color3.fromRGB(0,200,255); f.BorderSizePixel = 2
local t = s("TextLabel"); t.Parent = f; t.Size = UDim2.new(1,0,0,40); t.BackgroundColor3 = Color3.fromRGB(0,20,40); t.BorderSizePixel = 0; t.Text = "Bwrken Desync | Key System"; t.TextColor3 = Color3.fromRGB(0,220,255); t.TextSize = 14; t.Font = Enum.Font.GothamBold
local i = s("TextBox"); i.Parent = f; i.Size = UDim2.new(0.85,0,0,36); i.Position = UDim2.new(0.075,0,0,60); i.BackgroundColor3 = Color3.fromRGB(5,15,30); i.BorderColor3 = Color3.fromRGB(0,100,150); i.TextColor3 = Color3.fromRGB(200,230,255); i.PlaceholderText = "Enter your key..."; i.Text = savedKey; i.TextSize = 13; i.Font = Enum.Font.Code; i.ClearTextOnFocus = false
local b = s("TextButton"); b.Parent = f; b.Size = UDim2.new(0.85,0,0,34); b.Position = UDim2.new(0.075,0,0,106); b.BackgroundColor3 = Color3.fromRGB(0,80,140); b.BorderSizePixel = 0; b.Text = "VERIFY KEY"; b.TextColor3 = Color3.fromRGB(255,255,255); b.TextSize = 13; b.Font = Enum.Font.GothamBold
local l = s("TextLabel"); l.Parent = f; l.Size = UDim2.new(1,0,0,30); l.Position = UDim2.new(0,0,0,150); l.BackgroundTransparency = 1; l.Text = "Enter your key above"; l.TextColor3 = Color3.fromRGB(150,150,180); l.TextSize = 11; l.Font = Enum.Font.Gotham

-- Auto verify if saved key exists
if savedKey ~= "" then
    l.Text = "Saved key found, verifying..."; l.TextColor3 = Color3.fromRGB(255,200,0)
    task.spawn(function()
        task.wait(0.5)
        b:GetPropertyChangedSignal("Text"):Wait()
    end)
end

b.MouseButton1Click:Connect(function()
    local k = i.Text:gsub("%s+","")
    if k == "" then l.Text = "Please enter a key"; return end
    l.Text = "Verifying..."; l.TextColor3 = Color3.fromRGB(255,200,0)
    local ok,r = pcall(function()
        return g:JSONDecode(game:HttpGet("https://gist.githubusercontent.com/sus893/0746492d540c669dac3cfde3b05f7b60/raw/8341afc4c7ef5c7bd46d752d17451a745faf8155/keys.json"))
    end)
    if not ok then l.Text = "[ERROR] Could not reach key server"; l.TextColor3 = Color3.fromRGB(255,80,80); return end
    local d = r[k]
    if not d then l.Text = "[DENIED] Invalid key"; l.TextColor3 = Color3.fromRGB(255,60,60); return end
    if d.expires ~= "never" and os.time() > d.expires then l.Text = "[DENIED] Key expired"; l.TextColor3 = Color3.fromRGB(255,60,60); return end
    l.Text = "[AUTHORIZED] Welcome!"; l.TextColor3 = Color3.fromRGB(0,255,136)
    -- Save key for next time
    pcall(function() writefile("bwrken_key.txt", k) end)
    task.wait(1.5)
    sg:Destroy()
    _k = true
end)

-- Auto verify saved key
if savedKey ~= "" then
    task.spawn(function()
        task.wait(0.3)
        b:GetPropertyChangedSignal("Text"):Wait()
    end)
    local ok,r = pcall(function()
        return g:JSONDecode(game:HttpGet("https://gist.githubusercontent.com/sus893/0746492d540c669dac3cfde3b05f7b60/raw/8341afc4c7ef5c7bd46d752d17451a745faf8155/keys.json"))
    end)
    if ok then
        local d = r[savedKey]
        if d and (d.expires == "never" or os.time() <= d.expires) then
            l.Text = "[AUTHORIZED] Welcome!"; l.TextColor3 = Color3.fromRGB(0,255,136)
            task.wait(1.5)
            sg:Destroy()
            _k = true
        else
            l.Text = "Saved key invalid, enter manually"; l.TextColor3 = Color3.fromRGB(255,80,80)
            pcall(function() writefile("bwrken_key.txt", "") end)
        end
    end
end

repeat task.wait() until _k

loadstring(game:HttpGet("https://raw.githubusercontent.com/sus893/bwrken-desync/refs/heads/main/bwrken_desync.lua?nocache="..tostring(tick())))()
