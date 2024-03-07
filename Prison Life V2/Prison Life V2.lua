--[[
    Project: Jupiter
    Status: In Progress, V2
    Developer: Styx
    Contributors:
    - Lolegic
    - Chonker
]]

--! Global Variables !-- 
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")

local localPlayer = players.LocalPlayer
local remote = workspace:WaitForChild("Remote")
local messageDoneFiltering = replicatedStorage:WaitForChild("OnMessageDoneFiltering")

--! Global Tables !--
local noclipSettings = {Noclip = false}
local commandLogs = {}
local doorsTable = {}

--! Checks !-- 
game.Loaded:Wait()

assert(not IsJupiterLoaded, "Jupiter is already loaded")
getgenv().IsJupiterLoaded = true

for _, Door in next, workspace.Doors:GetChildren() do
  table.insert(doorsTable, Door)
end

--! Functions !--

local function getConfig()
  if(not isfile("admin.jupiter")) then
  writefile("admin.jupiter", '{"prefix": {}, "admins": {}}')
  return httpService:JSONDecode(readfile("admin.jupiter"))
end

local function setConfig(config)
  return writefile("admin.jupiter", httpService:JSONEncode(config))
end

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

-- Converting shit to Camal Casing

-- Get Player
local neededFunctions = {
  getPlayers = {
    Function = function(PlayerName: string)
      for _, player in pairs(players:GetPlayers()) do
        if (string.sub(player.Name:lower(), 1, #PlayerName) == PlayerName:lower()) or (string.sub(player.DisplayName:lower(), 1, #PlayerName) == PlayerName:lower()) then
          return player;
        end
      end
      return nil;
    end
  },
  log = {
    Function = function(Code: string, Text: string, FuncName: string, Player: string)
      print(Code .. ": " .. Text);
      table.insert(commandLogs, Code .. " " .. Text .. " " .. FuncName .. " ", Player);
    end
  },
  illegalRegionDetection = { -- WILL BE USED IN ARREST
    Function = function(Player : string)
      if (Player.Character) and (replicatedStorage.Modules_client.RegionModule_client.findRegion(Player.Character)["Name"]) then
        for _, RegionValue in pairs(replicatedStorage.PermittedRegions:GetChildren()) do
          if (replicatedStorage.Modules_client.RegionModule_client.findRegion(Player.Character)["Name"] == RegionValue.Value) then
            return false;
          end
        end
      end
      return true;
    end
  }

}

-- Local Players Commands
local LocalPlayersFunctions = {
  Prefix = {
    --[[
    Function = function(Args)
      if (Args[2]) then
        Settings.Prefixs.LocalPlayerPrefix = Args[2];
        neededFunctions.log.Function("Success", "Prefix was changed to " .. Args[2], "prefix");
      else
        neededFunctions.log.Function("Error", "Prefix was not found", "prefix", "LocalPlayer");
      end
    end
  },
    ]]
  Rejoin = {
    Function = function()
      teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
      neededFunctions.log.Function("Success", "Rejoining", "rejoin", "LocalPlayer");
    end
  },
  ServerHop = { -- Needs To Be Completed
    Function = function()

    end
  },
  Goto = {
    Function = function(Args)
      if (Args[2] ~= nil) and (localPlayer.Character.Head) and (neededFunctions.GetPlayer.Function(Args[2])) then
        localPlayer.Character.Head.CFrame = neededFunctions.GetPlayer.Function(Args[2]).Character.Head.CFrame;
        neededFunctions.log.Function("Success", "Teleported to " .. neededFunctions.GetPlayers(Args[2]), "goto", "LocalPlayer");
      else
        neededFunctions.log.Function("Error", "Player was either not inputted or found, please retry and check names", "goto", "LocalPlayer");
      end
    end
  },
  Bring = {
    Function = function(Args) -- Needs To Be Completed
      local CFrame = Args[2]

    end
  },
  Noclip = {
    Function = function()
      noclipSettings.noclip = not noclipSettings.noclip;
      neededFunctions.log.Function("Success", "Noclip has been toggled to " .. tostring(noclipSettings.noclip), "noclip", "LocalPlayer");
    end
  },
  Gate = {
    Function = function(Args)
      remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
      neededFunctions.log.Function("Success", "The Prison Gate has been opened", "gate", "LocalPlayer");
    end
  },
  View = {
    Function = function(Args)
      if (neededFunctions.GetPlayer.Function(Args[2])) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = neededFunctions.GetPlayers(Args[2]).Character;
        neededFunctions.log.Function("Success", "Currently viewing " .. neededFunctions.GetPlayers(Args[2]), "view", "LocalPlayer");
      elseif (Args[2] == nil) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = localPlayer.Character;
        neededFunctions.log.Function("Error", "Could be an error, however if this wasnt ignore this error message. If this was an error than check that you put a name for a player", "view", "LocalPlayer");
      else
        neededFunctions.log.Function("Error", "This is an error, please recheck username inputted. If not check if player is still in server.", "view", "LocalPlayer");
      end
    end
  },
  WalkSpeed = {
    Function = function(Args)
      if (typeof(Args[2]) ~= "number") and (Args[2] < 0) and not (nil) then
        neededFunctions.log.Function("Error", "Please enter a valid number", "walkspeed", "LocalPlayer");
      else
        localPlayer.Character.Humanoid.WalkSpeed = Args[2];
        neededFunctions.log.Function("Success", "Walkspeed changed to " .. Args[2], "Walkspeed", "LocalPlayer");
      end
    end
  },
  Jumppower = {
    Function = function(Args)
      if (typeof(Args[2]) ~= "number") and (Args[2] < 0) and not (nil) then
        neededFunctions.log.Function("Error", "Please enter a valid number", "Jumppower", "LocalPlayer");
      else
        localPlayer.Character.Humanoid.JumpPower = Args[2];
        neededFunctions.log.Function("Success", "Jumppower changed to " .. Args[2], "Jumppower", "LocalPlayer");
      end
    end
  },
  
}



--[[

Command Handler
 = {
  Aliases = {""},
  Function = function(Args)

  end
},


Functions
 = {
  Function = function(Args)

  end
},


]]

-- Ranked Commands

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
    rank = rank or "player"
    return config.prefix[tostring(player.UserId)] or self:getRank(self:getAdmin(player).rank).prefix
end

function admin:getAdmin(player)
    return self.admins[player]
end

function admin:getCommand(command)
    return self.commands[command]
end

function admin:getRank(rank)
    return admin.ranks[rank]
end

function admin:createCommand(name, commandInfo, callback)
    commandInfo.name = name
    commandInfo.description = commandInfo.description or "No description was given."
    commandInfo.callback = callback
    commandInfo.whitelist = {}
    commandInfo.blacklist = {}

    admin.commands[name] = commandInfo
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




end

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