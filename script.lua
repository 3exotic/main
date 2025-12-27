local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local placeId = tostring(game.PlaceId)
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

local gameList = {
    ["286090429"] = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/arsenal.lua",
    ["1215581239"] = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/doomspire.lua"
    ["841005469"] = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/doomspire.lua"
}

local universalUrl = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/scripts/universal.lua"
local discordLink = "https://discord.gg/vUFXDnHQXN"

local supported = gameList[placeId] ~= nil

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Scale = math.clamp(math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y) / 900, 0.85, 1)
scale.Parent = gui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.4, 0.45)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0.06, 0)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0.03, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0.05, 0)
padding.PaddingBottom = UDim.new(0.05, 0)
padding.PaddingLeft = UDim.new(0.05, 0)
padding.PaddingRight = UDim.new(0.05, 0)
padding.Parent = frame

local function label(text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 0.12)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamSemibold
    l.TextScaled = true
    l.TextWrapped = true
    l.TextColor3 = color or Color3.fromRGB(230,230,230)
    l.Parent = frame
end

label("User: " .. player.Name)
label("Game: " .. gameName)
label("Supported? " .. (supported and "Yes" or "No"), supported and Color3.fromRGB(80,200,120) or Color3.fromRGB(220,80,80))

local function button(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromScale(1, 0.14)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0.5, 0)
    b.Parent = frame

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
    end)

    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play()
    end)

    return b
end

local function close()
    TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    task.wait(0.25)
    gui:Destroy()
end

local function run(url)
    close()
    loadstring(game:HttpGet(url))()
end

if supported then
    button("Load Script").MouseButton1Click:Connect(function()
        run(gameList[placeId])
    end)
end

button("Load Universal Script").MouseButton1Click:Connect(function()
    run(universalUrl)
end)

button("Join Discord").MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(discordLink)
    end
    close()
end)

if not supported then
    button("Close").MouseButton1Click:Connect(close)
end

frame.Active = true
frame.Draggable = true
