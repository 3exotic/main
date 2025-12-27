-- Services a
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Persistent storage across reinjections
getgenv().TwistedState = getgenv().TwistedState or {
    noclip = false,
    infJump = false,
    shiftClickTP = false,
    autoServerHop = false,
    autoFarmWins = false
}

-- Save current toggles back to persistent state
local function SaveState(toggles)
    getgenv().TwistedState.noclip = toggles.noclip
    getgenv().TwistedState.infJump = toggles.infJump
    getgenv().TwistedState.shiftClickTP = toggles.shiftClickTP
    getgenv().TwistedState.autoServerHop = toggles.autoServerHop
    getgenv().TwistedState.autoFarmWins = toggles.autoFarmWins
end

-- Script reinjection function
function getgenv().Reinject()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/tm.lua"))()
end

-- Current toggles in this execution
local toggles = {
    noclip = getgenv().TwistedState.noclip,
    infJump = getgenv().TwistedState.infJump,
    shiftClickTP = getgenv().TwistedState.shiftClickTP,
    autoServerHop = getgenv().TwistedState.autoServerHop,
    autoFarmWins = getgenv().TwistedState.autoFarmWins
}

-- Function to build GUI
local function createGUI()
    if player:FindFirstChild("PlayerGui"):FindFirstChild("TwistedMurdererUI") then
        player.PlayerGui.TwistedMurdererUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TwistedMurdererUI"
    screenGui.Parent = player.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Parent = screenGui

    local mCorner = Instance.new("UICorner", mainFrame)
    mCorner.CornerRadius = UDim.new(0,20)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, -50, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Twisted Murderer"
    title.TextColor3 = Color3.fromRGB(255,0,0)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Center

    local closeButton = Instance.new("TextButton", mainFrame)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -45, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(80,0,0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255,255,255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 24

    local cbCorner = Instance.new("UICorner", closeButton)
    cbCorner.CornerRadius = UDim.new(0,10)

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
    scrollFrame.Size = UDim2.new(1, -20, 0, 380)
    scrollFrame.Position = UDim2.new(0, 10, 0, 70)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scrollFrame)
    layout.Padding = UDim.new(0,10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createToggleButton(name, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 20
        btn.Parent = scrollFrame

        local bCorner = Instance.new("UICorner", btn)
        bCorner.CornerRadius = UDim.new(0,10)

        local function updateText()
            btn.Text = name.." ["..(toggles[key] and "ON" or "OFF").."]"
            btn.BackgroundColor3 = toggles[key] and Color3.fromRGB(70,70,70) or Color3.fromRGB(50,50,50)
        end
        updateText()

        btn.MouseButton1Click:Connect(function()
            toggles[key] = not toggles[key]
            SaveState(toggles)
            updateText()
        end)
    end

    local function createActionButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 20
        btn.Text = name
        btn.Parent = scrollFrame

        local bCorner = Instance.new("UICorner", btn)
        bCorner.CornerRadius = UDim.new(0,10)

        btn.MouseButton1Click:Connect(function()
            btn.Active = false
            btn.AutoButtonColor = false
            btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
            callback()
        end)
    end

    -- Toggle buttons
    createToggleButton("Noclip", "noclip")
    createToggleButton("Inf Jump", "infJump")
    createToggleButton("Shift + Click TP", "shiftClickTP")
    createToggleButton("Auto Server Hop", "autoServerHop")
    createToggleButton("Auto Farm Wins", "autoFarmWins")

    -- Manual Server Hop
    createActionButton("Server Hop", function()
        SaveState(toggles)
        TeleportService:Teleport(game.PlaceId, player)
    end)

    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
    end)
end

-- Build GUI
createGUI()

-- Persist GUI after death
player.CharacterAdded:Connect(function()
    task.wait(1)
    createGUI()
end)

-- Implementation loops

-- Noclip
RunService.Stepped:Connect(function()
    if toggles.noclip then
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if toggles.infJump then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(char.HumanoidRootPart.Velocity.X, 50, char.HumanoidRootPart.Velocity.Z)
        end
    end
end)

-- Shift + Click TP
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input)
    if toggles.shiftClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position)
        end
    end
end)

-- Auto Farm Wins
spawn(function()
    while task.wait(1) do
        if toggles.autoFarmWins then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local x = 247.56 + math.random(-20,20)
                local z = -755.99 + math.random(-20,20)
                char.HumanoidRootPart.CFrame = CFrame.new(x, 1400, z)
            end
        end
    end
end)

-- Auto Server Hop
spawn(function()
    while task.wait(5) do
        if toggles.autoServerHop then
            if #Players:GetPlayers() < 4 then
                SaveState(toggles)
                TeleportService:Teleport(game.PlaceId, player)
                if getgenv().Reinject then
                    getgenv().Reinject()
                end
                break
            end
        end
    end
end)
