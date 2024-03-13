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
local doorsTable = {}
local log = {
    statusPrefixes = {
        admin = "[Admin]: ",
        error = "[Error]: ",
        success = "[Success]: "
    },
    output = {},
    saveOutput = function(self)
        for _, output in next, self.output do
            output:save()
        end
    end,
    print = function(self, status, ...)
        -- Check status
        status = status:lower()
        local statusPrefix = self.statusPrefixes[status]
        assert(statusPrefix ~= nil, "Invalid status: " .. status)

        -- Setup args and function information
        local args = { ... }
        local info = debug.getinfo(2)

        -- Get function information and output
        local name = info.name or table.remove(args, 1)
        local log_line = info.currentline
        local message = table.concat(args, " ")
        local unix = os.time()
        local date = os.date("*t", unix)

        -- Output message
        print(string.format("%s%s (function=%s, line=%s) [%d:%d:%d %s]", statusPrefix, message, name, log_line, date.hour % 12, date.min, date.sec, date.hour > 12 and "PM" or "AM"))

        -- Set and add output to the logs
        local output = {
            name = name,
            status = status,
            args = args,
            line = log_line,
            date = date,
            unix = unix,
            save = function(this)
                local output = {}

                if isfile("jupiter_output.json") then
                    output = httpService:JSONDecode(readfile("jupiter_output.txt"))
                end

                table.insert(output, {
                    name = this.name,
                    status = this.status,
                    args = this.args,
                    line = this.line,
                    unix = this.unix
                })
                
                writefile("jupiter_output.json", httpService:JSONEncode(output))
            end
        }

        table.insert(self.output, output)

        return output
    end
}

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
        name = name:gsub(" ", "")
        
        local prefixPattern = string.format("^(%s)", name)
        local teamName = string.match(name, "^team:([%w]+)")

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
    log:print("Success", "Rejoining");
end

local function goto(player: Player | string)
    if type(player) == "string" then
        player = getPlayers(player)[1]
    end

    if not player:IsA("Player") then
        log:print("Error", "Player was either not inputted or found, please retry and check names.");
        return
    end

    localPlayer.Character.Head.CFrame = player.Character.Head.CFrame;
    log:print("Success", "Successfully went to " .. player.Name .. ".");
end

local function toggleNoclip()
    noclipSettings.noclip = not noclipSettings.noclip;
    log:print("Success", "Noclip has been toggled to " .. tostring(noclipSettings.noclip));
end

local function invokeGate()
    remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
    log:print("Success", "The Prison Gate has been opened");
end

local function viewPlayer(player: Player | string | nil)
    local camera = game:GetService("Workspace"):WaitForChild("CurrentCamera")

    if type(player) == "string" then
        player = getPlayers(player)[1]
    end

    if not player:IsA("Player") then
        camera.CameraSubject = localPlayer.Character
        log:print("Error", "Invalid player was given.")
        return
    end

    camera.CurrentCamera.CameraSubject = player.Character
    log:print("Success", "Camera is subject is now " .. player.Name .. ".")
end

local function setWalkSpeed(speed: any)
    if not type(speed) == "number" then
        log:print("Error", "Please enter a valid number");
        return
    end

    localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = speed;
    log:print("Success", "Walkspeed changed to " .. speed);
end

local function setJumpPower(power: any)
    if not type(power) == "number" then
        log:print("Error", "Please enter a valid number");
        return
    end

    localPlayer.Character:WaitForChild("Humanoid").JumpPower = power;
    log:print("Success", "JumpPower changed to " .. power);
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

function admin:setRank(player: Player, rank: string)
    rank = rank:lower()

    local adminInfo = {
        player = player,
        rank = rank
    }

    self.adminCount = self.adminCount + 1
    adminInfo.prefix = self:getPrefix(player)

    self.admins[player] = adminInfo

    log:print("admin", "Set " .. player.Name .. "'s rank to " .. rank .. ".")
end

function admin:getPrefix(player)
    local config = getConfig()
    
    return config.prefix[tostring(player.UserId)] or self:getRank(self:getAdmin(player).rank).prefix
end

function admin:setPrefix(player: Player, prefix: string)
    local config = getConfig()

    config.prefix[tostring(player.UserId)] = prefix
    self.admins[player].prefix = prefix

    setConfig(config)

    log:print("admin", "Set " .. player.Name .. "'s prefix to " .. prefix)
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

    local info = admin:getAdmin(player)
    if(info == nil) then return end

    local prefix = admin:getPrefix(player)
    for _, text in next, string.split(message.Message, "/") do
        for name, command in next, admin.commands do
            local cmd = string.format("%s%s", prefix, name)

            if(not text:match("^("..cmd..")")) then continue end
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

            log:print("admin", player.Name .. " ran " .. command .. " with " .. table.concat(args, ", ") .. " as the arguments.")
        end
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
