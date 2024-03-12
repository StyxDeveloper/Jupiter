--[[
    Project: Jupiter
    Status: In Progress, V2
    Developer: Styx
    Contributors:
    - Lolegic
    - Chonker
]]

--! Checks !--
game.Loaded:Wait()

assert(not IsJupiterLoaded, "Jupiter is already loaded")
getgenv().IsJupiterLoaded = true

--! Global Variables !-- 
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")
local teams = game:GetService("Teams")

local localPlayer = players.LocalPlayer
local remote = workspace:WaitForChild("Remote")
local messageDoneFiltering = replicatedStorage:WaitForChild("OnMessageDoneFiltering")
local regions = require(replicatedStorage:WaitForChild("Modules_client"):WaitForChild("RegionModule_client"))

--! Global Tables !--
local noclipSettings = {Noclip = false}
local commandLogs = {}
local doorsTable = {}

for _, Door in next, workspace.Doors:GetChildren() do
    table.insert(doorsTable, Door)
end

--! Functions !--

local function getConfig()
    if not isfile("admin.jupiter") then
        writefile("admin.jupiter", '{"prefix": {}, "admins": {}}')
    end
    
    return httpService:JSONDecode(readfile("admin.jupiter"))
end

local function setConfig(config: table)
    writefile("admin.jupiter", httpService:JSONEncode(config))
end

local function getPlayers(names: string)
    local result: { Player } = {}

    local function addPlayer(player)
        if table.find(result, player) then return end
        return table.insert(result, player)
    end

    local _players = players:GetPlayers()
    local _teams = teams:GetTeams()

    for name in string.gmatch(names:lower(), "%s?,?%s?([%w_:%s]+)%s?,?%s?") do
        local prefixPattern = string.format("^(%s)", name)
        local teamName = string.match(name, "^team:%s?([%w]+)")

        if teamName then
            local teamPattern = string.format("^(%s)", teamName)

            for _, team in next, _teams do
                if not string.match(team.Name:lower(), teamPattern) then
                    continue
                end

                for _, plr in next,  team:GetPlayers() do
                    addPlayer(plr)
                end
            end

            continue
        end

        for _, plr in next, _players do
            if not (string.match(plr.Name:lower(), prefixPattern) or string.match(plr.DisplayName:lower(), prefixPattern)) then
                continue
            end

            addPlayer(plr)
        end
    end

    return result
end

local function log(Code, Text, FuncName, Player)
    print(Code .. ": " .. Text);
    table.insert(commandLogs, Code .. " " .. Text .. " " .. FuncName .. " ", Player);
end

local function isInIllegialRegion(player: Player)
    if player.Character and regions.findRegion(player.Character)["Name"] then
        for _, RegionValue in pairs(replicatedStorage.PermittedRegions:GetChildren()) do
            if regions.findRegion(player.Character)["Name"] == RegionValue.Value then
                return false;
            end
        end
    end

    return true;
end

local function rejoin()
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
    log("Success", "Rejoining", "rejoin", "LocalPlayer");
end

local function goto(player: Player | string)
    if type(player) == "string" then
        player = getPlayers(player)[1]
    end

    if not player:IsA("Player") then
        log("Error", "Player was either not inputted or found, please retry and check names.", "goto", "LocalPlayer");
        return
    end

    localPlayer.Character.Head.CFrame = player.Character.Head.CFrame;
    log("Success", "Successfully went to " .. player.Name .. ".", "goto", "LocalPlayer");
end

local function toggleNoclip()
    noclipSettings.noclip = not noclipSettings.noclip;
    log("Success", "Noclip has been toggled to " .. tostring(noclipSettings.noclip), "toggleNoclip", "LocalPlayer");
end

local function invokeGate()
    remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
    log("Success", "The Prison Gate has been opened", "invokeGate", "LocalPlayer");
end

local function viewPlayer(player: Player | string | nil)
    local camera = game:GetService("Workspace"):WaitForChild("CurrentCamera")

    if type(player) == "string" then
        player = getPlayers(player)[1]
    end

    if not player:IsA("Player") then
        camera.CameraSubject = localPlayer.Character
        log("Error", "Invalid player was given.", "viewPlayer", "LocalPlayer")
        return
    end

    camera.CurrentCamera.CameraSubject = player.Character
    log("Success", "Camera is subject is now " .. player.Name .. ".", "viewPlayer", "LocalPlayer")
end

local function setWalkSpeed(speed: any)
    if not type(speed) == "number" then
        log("Error", "Please enter a valid number", "setWalkspeed", "LocalPlayer");
        return
    end

    localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speed;
    log("Success", "Walkspeed changed to " .. speed, "setWalkSpeed", "LocalPlayer");
end

local function setJumpPower(power: any)
    if not type(power) == "number" then
        log("Error", "Please enter a valid number", "setJumpPower", "LocalPlayer");
        return
    end

    localPlayer.Character:WaitForChild("Humanoid").JumpPower = power;
    log("Success", "JumpPower changed to " .. power, "setJumpPower", "LocalPlayer");
end

-- ! Ranked Commands ! --

local admin = {
    ranks = {
        owner = {
            name = "Owner",
            prefix = ";",
            level = math.huge
        },
        mod = {
            name = "Moderator",
            prefix = ";",
            level = 100
        },
        friend = {
            name = "Friend",
            prefix = ";",
            level = 25
        },
        player = {
            name = "Non-Admin",
            prefix = ";",
            level = 0
        }
    },
    admins = {},
    commands = {},
    adminCount = 0
}

function admin:setRank(player, rank)
    rank = rank:lower()

    local adminInfo = {
        player = player,
        rank = rank
    }

    self.adminCount = self.adminCount + 1

    self.admins[self.adminCount] = adminInfo
    adminInfo.prefix = self:getPrefix(player)
    self.admins[self.adminCount] = adminInfo
end

function admin:getPrefix(player)
    local config = getConfig()
    
    return config.prefix[tostring(player.UserId)] or self:getRank(self:getAdmin(player).rank).prefix
end

function admin:getAdmin(player)
    return self.admins[player]
end

function admin:getCommand(command)
    return self.commands[command]
end

function admin:getRank(rank)
    return self.ranks[rank]
end

function admin:createCommand(name, commandInfo, callback)
    commandInfo.name = name
    commandInfo.description = commandInfo.description or "No description was given."
    commandInfo.callback = callback
    commandInfo.whitelist = {}
    commandInfo.blacklist = {}

    self.commands[name] = commandInfo
end

function admin.handler(message)
    local player = players:FindFirstChild(message.FromSpeaker)
    local text = message.Message

    local info = admin:getAdmin(player)
    if(info == nil) then return end

    local prefix = admin:getPrefix(player)
    for name, command in next, admin.commands do
        local cmd = string.format("%s%s", prefix, name)

        if(not text:match("^"..cmd)) then continue end
        if(command.rank > admin:getRank(info.rank).level) then continue end

        local funcInfo = debug.getinfo(command.callback)
        local args = {}
        local words = string.split(text, cmd)[1].split(" ")
        local nparams = funcInfo.nparams - 1

        for count, word in next, words do
            if(count >= nparams) then
                args[nparams] = (args[nparams] or "") .. word .. " "
                continue
            end
            args[count] = word
        end

        local lastArg = args[nparams]

        args[nparams] = string.sub(lastArg, 1, #lastArg - 1)

        command.callback(player, table.unpack(args))
    end
end

messageDoneFiltering.OnClientEvent:Connect(admin.handler)

admin:createCommand("test", {
    level = math.huge, -- Owner rank
    description = "This is just for showing you guys how to use this function.",
}, function(player, arg1, arg2)
    print("This is who chatted ", player.Name)
    print("This is the first argument ", arg1)
    print("This is second argument will be pack every other arg after it ", arg2)
end)


--! Character Appearance Loaded Connection !--
localPlayer.CharacterAppearanceLoaded:Connect(function(Character)
  if (noclipSettings.noclip) then
    for _,Parts : Instance in ipairs(Character:GetDescendants()) do
      if (Parts:IsA("BasePart")) or (Parts:IsA("Part")) or (Parts:IsA("Accessory")) then
        Parts.CanCollide = false;
      end
    end
  end
end)

--! HeartBeat Connection !--
runService:Connect(function()

end)

--! TODO !--

--[[
Needed To Be made
Functions

Make firetouchinterest as some executors don't contain this

Kill player (both melee event and gun event)
Item Handler
AutoRespawn
Arrest
Auto fire rate
Serverhop
Autogiveguns
Teamevent
Exclude
Fps boost -- Remove bullets also
Open doors
No doors
Kill aura
Door aura
Antibring
Anticrim
Copyteam
Loopkill
AntiTase
FF
Tase
Respawn
Chatlogger
Command logger
Admin player command handler
Bring
Criminal Player
LoopBring/LoopCrim
LoopKill
Commands
Bring Car
Command Logger -- Ill look into making the ranked one also have this, which will be added to a file

-- Completed
Rejoin
Goto
Noclip
Opengate
View (This also does unview)
Walk Speed
Jump Power
Local Players Functions Logger

GUI
Main
Command GUI
List of Ranked Players and Settings
Toggles/Antis
Skid Check -- With Options
Output
chatlogs
Sections (Antis, Abusive, Misc).

Command Handler
Main
Ranked system
Handles Chat Logger also
]]
