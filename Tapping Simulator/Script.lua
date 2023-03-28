_G.Egg = "" --// Name

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage.Events

local function fireServer(eventName, param)
    Events[eventName]:FireServer(param)
end

local function HatchEgg(Egg)
    Events.HatchEgg:InvokeServer({}, Egg, 1)
end

local function AutoTap()
    fireServer("Tap", "Main")
end

local function AutoRebirth()
    fireServer("Rebirth", 1)
end

local function MainLoop()
    if _G.Egg then
        HatchEgg(_G.Egg)
    end
end

RunService.Heartbeat:Connect(AutoTap)
RunService.Heartbeat:Connect(AutoRebirth)
RunService.Heartbeat:Connect(MainLoop)
