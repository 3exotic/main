local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = tostring(game.PlaceId)
local userId = tostring(player.UserId)

local gameList = {
    ["1234567890"] = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/game1.lua",
    ["9876543210"] = "https://raw.githubusercontent.com/3exotic/main/refs/heads/main/game2.lua"
}

local blacklist = {
    ["111111111"] = true,
    ["222222222"] = true
}

local blacklistReason = "You are permanently blacklisted for abusing the script."

local function kick(msg)
    player:Kick(msg)
end

if blacklist[userId] then
    kick(blacklistReason ~= "" and blacklistReason or "Blacklisted User")
    return
end

local scriptUrl = gameList[placeId]

if type(scriptUrl) ~= "string" then
    kick("Unsupported Game")
    return
end

local ok, source = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if not ok or type(source) ~= "string" or #source == 0 then
    kick("Loader error: gamescript fetch (E01)")
end

local fn, compileErr = loadstring(source)
if not fn then
    kick("Loader error: gamescript compile (E03C) | " .. tostring(compileErr))
end

local success, runtimeErr = pcall(fn)
if not success then
    kick("Loader error: gamescript runtime (E03R) | " .. tostring(runtimeErr))
end
