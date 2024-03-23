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

--! Global Variables !-- 
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
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
        for _, output in ipairs(self.output) do
            output:save()
        end
    end,
    print = function(self, status, ...)
        status = status:lower()
        local statusPrefix = self.statusPrefixes[status]
        assert(statusPrefix, "Invalid status: " .. status)

        local args = { ... }
        local info = debug.getinfo(2)
        local name = info.name or table.remove(args, 1)
        local log_line = info.currentline
        local message = table.concat(args, " ")
        local unix = os.time()
        local date = os.date("*t", unix)

        -- Output message
        print(string.format("%s%s (function=%s, line=%s) [%d:%d:%d %s]", statusPrefix, message, name, log_line, date.hour % 12, date.min, date.sec, date.hour > 12 and "PM" or "AM"))

        local output = {
            name = name,
            status = status,
            args = args,
            line = log_line,
            date = date,
            unix = unix,
            save = function()
                local output = {}

                if isfile("jupiter_output.json") then
                    output = httpService:JSONDecode(readfile("jupiter_output.txt"))
                end

                table.insert(output, {
                    name = name,
                    status = status,
                    args = args,
                    line = log_line,
                    unix = unix
                })
                writefile("jupiter_output.json", httpService:JSONEncode(output))
            end
        }
        table.insert(self.output, output)
        return output
    end
}

for _, door in ipairs(workspace.Doors:GetChildren()) do
    table.insert(doorsTable, door);
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
    local result = {};

    local function addPlayer(player)
        if not table.find(result, player) then
            table.insert(result, player);
        end
    end

    for name in names:gmatch("%s?,?%s?([%w_:%s]+)%s?,?%s?") do
        name = name:gsub(" ", "");

        local prefixPattern = "^" .. name;
        local teamName = name:match("^team:([%w]+)");

        if teamName then
            local teamPattern = "^" .. teamName;

            for _, team in ipairs(teams:GetTeams()) do
                if team.Name:lower():match(teamPattern) then
                    for _, plr in ipairs(team:GetPlayers()) do
                        addPlayer(plr);
                    end
                end
            end
        else
            for _, plr in ipairs(players:GetPlayers()) do
                if plr.Name:lower():match(prefixPattern) or plr.DisplayName:lower():match(prefixPattern) then
                    addPlayer(plr);
                end
            end
        end
    end

    return result;
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

-- ! Ranked Commands ! --

local admin = {
    ranks = {
        owner = {
            name = "Owner",
            prefix = ";",
            level = 100
        },
        mod = {
            name = "Moderator",
            prefix = ";",
            level = 50
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

admin:createCommand("walkspeed" or "ws", {
    level = 100,
    description = "Set your walkspeed.",},
    function(Integer : IntValue)
    if not type(Integer) == "number" then
        log:print("Error", "Please enter a valid number");
        return;
    end
    localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Integer;
    log:print("Success", "Walkspeed changed to " .. Integer);
end)

admin:createCommand("jumppower" or "jp", {
    level = 100,
    description = "Set your jumppower",},
    function(Integer : IntValue)
    if not type(Integer) == "number" then
        log:print("Error", "Please enter a valid number");
        return;
    end
    localPlayer.Character:WaitForChild("Humanoid").JumpPower = Integer;
    log:print("Success", "JumpPower changed to " .. Integer);
end)

admin:createCommand("noclip" or "nc", {
    level = 100,
    description = "Noclip, walk through walls.",},
    function()
    noclipSettings.noclip = not noclipSettings.noclip;
    log:print("Success", "Noclip has been toggled to " .. tostring(noclipSettings.noclip));
end)

admin:createCommand("rejoin" or "rj", {
    level = 100,
    description = "Rejoin this server.",},
    function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId);
    log:print("Success", "Rejoining");
end)

admin:createCommand("opengate", {
    level = 25,
    description = "Opens main gate for the prison.",},
    function()
    remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
    log:print("Success", "The Prison Gate has been opened");
end)

admin:createCommand("goto" or "to", {
    level = 100,
    description = "Teleport to a player.",},
    function(player: Player | string)
    if type(player) == "string" then
        player = getPlayers(player)[1]
    end
    if not player:IsA("Player") then
        log:print("Error", "Player was either not inputted or found, please retry and check names.");
        return;
    end
    localPlayer.Character.Head.CFrame = player.Character.Head.CFrame;
    log:print("Success", "Successfully went to " .. player.Name .. ".");
end)

admin:createCommand("view", {
    level = 100,
    description = "View a player.",},
    function(player: Player | string | nil)
    if type(player) == "string" then
        player = getPlayers(player)[1];
    end
    if not player:IsA("Player") then
        game:GetService("Workspace"):WaitForChild("CurrentCamera").CameraSubject = localPlayer.Character;
        log:print("Error", "Invalid player was given.");
        return;
    end
    game:GetService("Workspace"):WaitForChild("CurrentCamera").CurrentCamera.CameraSubject = player.Character;
    log:print("Success", "Camera is subject is now " .. player.Name .. ".");
end)

--[[
admin:createCommand("", {
    level = 100,
    description = "",},
    function()
        
end)
]]

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
