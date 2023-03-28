local succ, err =
    pcall(
    function()
        game:GetService("ReplicatedStorage").Remotes.sellBricks:FireServer()
    end
)

if not succ then
    warn("Sell bricks failed with error: " .. tostring(err))
end

local coins = 4800000000
local iterCount = 100000

local gsucc, gerr =
    pcall(
    function()
        for i = 1, iterCount do
            game:GetService("ReplicatedStorage").Remotes.generateBoost:FireServer("Coins", coins)
        end
    end
)

if not gsucc then
    warn("Generate coins failed with error: " .. tostring(gerr))
end

function SetGunsStats(CoolDown, RocketSpeed)
    local GStats = require(game:GetService("Players").LocalPlayer.Backpack.Launcher.Stats)
    GStats.Cooldown = CoolDown
    GStats.RocketSpeed = RocketSpeed
end

function BombCoolDown(CoolDown)
    local BStats = require(game:GetService("Players").LocalPlayer.Backpack.Bomb.Stats)
    BStats.Cooldown = CoolDown
end
