-- =========================
-- TWISTED MURDERER
-- =========================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- ===== GLOBAL STATE =====
getgenv().TwistedState = getgenv().TwistedState or {
    noclip = false,
    infJump = false,
    shiftTP = false,
    autoHop = false,
    autoFarm = false
}
local toggles = getgenv().TwistedState

-- ===== GUI PARENT (XENO SAFE) =====
local guiParent
pcall(function()
    guiParent = gethui()
end)
if not guiParent then
    guiParent = game:GetService("CoreGui")
end

-- ===== CLEAR OLD =====
for _,v in ipairs(guiParent:GetChildren()) do
    if v.Name == "TwistedMurdererUI" then
        v:Destroy()
    end
end

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "TwistedMurdererUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(420,480)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)

-- ===== DRAG =====
do
    local dragging, startPos, dragStart
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ===== TITLE =====
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

-- ===== CLOSE =====
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

-- ===== SCROLL =====
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-20,1,-80)
Scroll.Position = UDim2.fromOffset(10,70)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,10)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
end)

-- ===== TOGGLE BUTTON =====
local function ToggleButton(text,key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1,-10,0,42)
    b.Font = Enum.Font.Gotham
    b.TextSize = 18
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local function refresh()
        b.Text = text .. " : " .. (toggles[key] and "ON" or "OFF")
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

-- ===== BUTTONS =====
ToggleButton("Noclip", "noclip")
ToggleButton("Infinite Jump", "infJump")
ToggleButton("Shift + Click TP", "shiftTP")
ToggleButton("Auto Server Hop", "autoHop")
ToggleButton("Auto Farm Wins", "autoFarm")

-- =========================
-- FEATURES
-- =========================

-- Noclip
RunService.Stepped:Connect(function()
    if toggles.noclip and player.Character then
        for _,v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if toggles.infJump and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 60, hrp.Velocity.Z)
        end
    end
end)

-- Shift + Click TP
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(i)
    if toggles.shiftTP
        and i.UserInputType == Enum.UserInputType.MouseButton1
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        and player.Character
    then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(mouse.Hit.Position)
        end
    end
end)

-- ===== AUTO FARM WINS (EVERY FRAME, OFFSET CHANGES EVERY 0.5s) =====
local farmOffset = Vector3.zero
local lastOffsetUpdate = 0

RunService.Heartbeat:Connect(function(dt)
    if toggles.autoFarm and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            lastOffsetUpdate += dt
            if lastOffsetUpdate >= 0.5 then
                lastOffsetUpdate = 0
                farmOffset = Vector3.new(
                    math.random(-20,20),
                    0,
                    math.random(-20,20)
                )
            end

            hrp.CFrame = CFrame.new(
                247.56,
                1400,
                -755.99
            ) + farmOffset
        end
    end
end)

-- Auto Server Hop
task.spawn(function()
    while task.wait(5) do
        if toggles.autoHop and #Players:GetPlayers() < 4 then
            TeleportService:Teleport(game.PlaceId, player)
            break
        end
    end
end)
