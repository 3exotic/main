-- =========================
-- TWISTED MURDERER
-- WITH REINJECTION + STATE
-- =========================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local SCRIPT_URL = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/twisted.lua"

-- =========================
-- STATE HANDLING
-- =========================

getgenv().TwistedState = getgenv().TwistedState or {
    noclip = false,
    infJump = false,
    shiftTP = false,
    autoHop = false,
    autoFarm = false
}

-- restore from teleport queue if exists
if getgenv().QueuedTwistedState then
    for k,v in pairs(getgenv().QueuedTwistedState) do
        getgenv().TwistedState[k] = v
    end
    getgenv().QueuedTwistedState = nil
end

local toggles = getgenv().TwistedState

-- =========================
-- REINJECT FUNCTION
-- =========================

local function reinjectWithState()
    -- save state into teleport-safe global
    getgenv().QueuedTwistedState = table.clone(toggles)

    -- queue script on teleport
    if queue_on_teleport then
        queue_on_teleport(
            "getgenv().QueuedTwistedState = " ..
            HttpService:JSONEncode(getgenv().QueuedTwistedState) ..
            "\nloadstring(game:HttpGet('"..SCRIPT_URL.."'))()"
        )
    end

    TeleportService:Teleport(game.PlaceId, player)
end

-- =========================
-- GUI PARENT (XENO SAFE)
-- =========================

local guiParent
pcall(function()
    guiParent = gethui()
end)
if not guiParent then
    guiParent = game:GetService("CoreGui")
end

for _,v in ipairs(guiParent:GetChildren()) do
    if v.Name == "TwistedMurdererUI" then
        v:Destroy()
    end
end

-- =========================
-- GUI
-- =========================

local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "TwistedMurdererUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(420,480)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

-- drag
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-60,0,50)
Title.Position = UDim2.fromOffset(20,10)
Title.BackgroundTransparency = 1
Title.Text = "Twisted Murderer"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(255,40,40)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center

-- close
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.fromOffset(36,36)
Close.Position = UDim2.new(1,-46,0,12)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 22
Close.BackgroundColor3 = Color3.fromRGB(90,0,0)
Close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,10)
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- scroll
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-20,1,-80)
Scroll.Position = UDim2.fromOffset(10,70)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,10)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
end)

-- toggle button
local function ToggleButton(text,key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1,-10,0,42)
    b.Font = Enum.Font.Gotham
    b.TextSize = 18
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local function refresh()
        b.Text = text.." : "..(toggles[key] and "ON" or "OFF")
        b.BackgroundColor3 = toggles[key]
            and Color3.fromRGB(70,70,70)
            or Color3.fromRGB(45,45,45)
    end

    refresh()
    b.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        refresh()
    end)
end

-- buttons
ToggleButton("Noclip","noclip")
ToggleButton("Infinite Jump","infJump")
ToggleButton("Shift + Click TP","shiftTP")
ToggleButton("Auto Server Hop","autoHop")
ToggleButton("Auto Farm Wins","autoFarm")

-- =========================
-- FEATURES
-- =========================

RunService.Stepped:Connect(function()
    if toggles.noclip and player.Character then
        for _,v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if toggles.infJump and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X,60,hrp.Velocity.Z) end
    end
end)

local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(i)
    if toggles.shiftTP
        and i.UserInputType == Enum.UserInputType.MouseButton1
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        and player.Character
    then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position) end
    end
end)

-- auto farm (every frame)
local offset = Vector3.zero
local t = 0
local function rand()
    local m = math.random(10,25)
    return (math.random(0,1)==0 and -m or m)
end

RunService.Heartbeat:Connect(function(dt)
    if toggles.autoFarm and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            t += dt
            if t >= 0.5 then
                t = 0
                offset = Vector3.new(rand(),0,rand())
            end
            hrp.CFrame = CFrame.new(247.56,1400,-755.99) + offset
        end
    end
end)

-- auto server hop
task.spawn(function()
    while task.wait(5) do
        if toggles.autoHop and #Players:GetPlayers() < 4 then
            reinjectWithState()
            break
        end
    end
end)
