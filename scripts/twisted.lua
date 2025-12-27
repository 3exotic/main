-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- CONFIG
local SCRIPT_URL = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/twisted.lua"
local PLACE_ID = game.PlaceId

-- STATE (PERSISTENT)
getgenv().TwistedState = getgenv().TwistedState or {
    Noclip = false,
    InfJump = false,
    ShiftTP = false,
    AutoFarm = false,
    AutoHop = false
}
local State = getgenv().TwistedState

-- CLEANUP
pcall(function()
    if game.CoreGui:FindFirstChild("TwistedMurderer") then
        game.CoreGui.TwistedMurderer:Destroy()
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TwistedMurderer"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 360)
main.Position = UDim2.new(0.5, -210, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Twisted Murderer"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(200, 40, 40)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = main

-- CLOSE
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.TextColor3 = Color3.fromRGB(220,60,60)
close.BackgroundColor3 = Color3.fromRGB(28,28,28)
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0.4
scroll.BackgroundTransparency = 1
scroll.Parent = main

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
end)

-- BUTTONS
local function makeToggleButton(label, stateKey)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 38)
    b.Font = Enum.Font.Gotham
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.BackgroundColor3 = Color3.fromRGB(32,32,32)
    b.BorderSizePixel = 0
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local function refresh()
        b.Text = label .. " : " .. (State[stateKey] and "ON" or "OFF")
    end
    refresh()

    b.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        refresh()
    end)

    return b
end

local function makeButton(label, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 38)
    b.Text = label
    b.Font = Enum.Font.Gotham
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.BackgroundColor3 = Color3.fromRGB(32,32,32)
    b.BorderSizePixel = 0
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- TOGGLES
makeToggleButton("Noclip","Noclip")
makeToggleButton("Infinite Jump","InfJump")
makeToggleButton("Shift + Click TP","ShiftTP")
makeToggleButton("Auto Farm Wins","AutoFarm")
makeToggleButton("Auto Server Hop","AutoHop")

-- SERVER HOP BUTTON
makeButton("Server Hop", function()
    local function serialize(t)
        local s = "{"
        for k,v in pairs(t) do
            s ..= string.format("[%q]=%s,", k, tostring(v))
        end
        return s .. "}"
    end

    if queue_on_teleport then
        queue_on_teleport([[
            getgenv().TwistedState = ]] .. serialize(State) .. [[
            loadstring(game:HttpGet("]] .. SCRIPT_URL .. [[", true))()
        ]])
    end

    local function getServers()
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?limit=100&sortOrder=Desc")
        local data = HttpService:JSONDecode(req)
        table.sort(data.data,function(a,b) return a.playing>b.playing end)
        return data.data
    end

    for _,srv in ipairs(getServers()) do
        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PLACE_ID, srv.id, player)
            break
        end
    end
end)

-- FEATURES LOGIC
RunService.Stepped:Connect(function()
    if State.Noclip and player.Character then
        for _,v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if State.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

mouse.Button1Down:Connect(function()
    if State.ShiftTP and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0)) end
    end
end)

-- AUTO FARM WINS
local farmTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if State.AutoFarm and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(247.56,1400,-755.99)
        farmTimer += dt
        if farmTimer >= 0.5 then
            farmTimer = 0
            local ox = math.random(10,25)*(math.random(0,1)==0 and -1 or 1)
            local oz = math.random(10,25)*(math.random(0,1)==0 and -1 or 1)
            hrp.CFrame = hrp.CFrame * CFrame.new(ox,0,oz)
        end
    end
end)

-- AUTO SERVER HOP
task.spawn(function()
    while task.wait(5) do
        if State.AutoHop and #Players:GetPlayers() < 4 then
            for _,srv in ipairs(HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?limit=100&sortOrder=Desc")).data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    if queue_on_teleport then
                        queue_on_teleport([[
                            getgenv().TwistedState = ]] .. "{Noclip="..tostring(State.Noclip)..",InfJump="..tostring(State.InfJump)..",ShiftTP="..tostring(State.ShiftTP)..",AutoFarm="..tostring(State.AutoFarm)..",AutoHop=true}" .. [[
                            loadstring(game:HttpGet("]] .. SCRIPT_URL .. [[", true))()
                        ]])
                    end
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, srv.id, player)
                    break
                end
            end
        end
    end
end)

-- CTRL TO TOGGLE UI
UIS.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
