-- Untested create something under issues and I'll fix your bug
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local Player = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Chatted = LocalPlayer.Chatted
local Prefix = ";"

function SellBricks()
    local Successful, Error =
        pcall(function()
            Remotes.sellBricks:FireServer()
        end
    )
    if not Successful then
        warn("Sell bricks failed with error: " .. tostring(Error))
    end
end

function GenerateBoost()
local Coins = 4800000000
local Iterations = 100000
local successful, error =
    pcall(function()
        for i = 1, Iterations do
            Remotes.generateBoost:FireServer("Coins", Coins)
        end
    end)
end
if not successful then
    warn("Generate Coins failed with error: " .. tostring(error))
end

function SetGunsStats(CoolDown, RocketSpeed)
    local GStats = require(LocalPlayer.Backpack.Launcher.Stats)
    GStats.Cooldown = CoolDown
    GStats.RocketSpeed = RocketSpeed
end

function BombCoolDown(CoolDown)
    local BStats = require(LocalPlayer.Backpack.Bomb.Stats)
    BStats.Cooldown = CoolDown
end

Chatted:Connect(function(Message)
    local Arguments = string.split(Message, " ")
    local CommandUsed = string.sub(Arguments[1], #Prefixs + 1):lower()

    if CommandUsed == "cmds" then
        print("bombcooldown - cooldown")
        print("gunstats - cooldown, rocketspeed")
        print("gaincoins")
        print("sellbricks")
    elseif CommandUsed == "bombcooldown" then
        BombCoolDown(Arguments[2])
    elseif CommandUsed == "gunstats" then
        SetGunsStats(Arguments[2], Arguments[3])
    elseif CommandUsed == "gaincoins" then
        GenerateBoost()
    elseif CommandUsed = "sellbricks" then
        SellBricks()
    end
end)
