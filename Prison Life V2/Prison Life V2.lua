--[[ Credits
    !! // The Jupiter Staff Team // !!
      *The Team*
    // Styx Developer // 
    // Lolegic //
    // Che/Forest //
    // chonker //
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

function getConfig()
    if(not isfile("admin.jupiter")) writefile("admin.jupiter", '{"prefix": {}, "admins": {}}')
    return httpService:JSONDecode(readfile("admin.jupiter"))
end

function setConfig(config)
    return writefile("admin.jupiter", httpService:JSONEncode(config))
end

--! Global Tables !-- 
local Settings = {
  Prefixs = {
    LocalPlayerPrefix = ".",
    CommandGUIPrefix = ".",
    RankedPlayersPrefix = ":"
  },
  Noclip = false,

}

--! Checks !-- 
game.Loaded:Wait()

assert(not IsJupiterLoaded, "Jupiter is already loaded")
getgenv().IsJupiterLoaded = true

--! Functions !--

--[[
  I definetely want to add a logger for the Commands ran, a long with their success/error message. This way itll all be inputted to a table which will then be printable to console

Needed To Be made
Functions

Make firetouchinterest as some executors don't contain this


Kill player (both melee event and gun event)
Item Handler
AutoRespawn
Walk speed
Loop walkspeed
Jumppower
Loop jumppower
Arrest
Auto fire rate
Sit
Serverhop
Autogiveguns
View and unview
Teamevent
Exclude
Fps boost -- Remove bullets
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

-- Completed
Rejoin
Goto
Noclip
Opengate

GUI
Main
Command GUI
List of Ranked Players and Settings
Toggles/Antis
Skid Check -- With Options
Output

Command Handler
Main
Ranked system
Handles Chat Logger also
]]

-- Get Player
local NeededFunctions = {
  GetPlayers = {
    Function = function(PlayerName: string)
      for _, player in pairs(players:GetPlayers()) do
        if (string.sub(player.Name:lower(), 1, #PlayerName) == PlayerName:lower()) or (string.sub(player.DisplayName:lower(), 1, #PlayerName) == PlayerName:lower()) then
          return player
        end
      end
      return nil
    end
  },
  Log = {
    Function = function(Code: string, Text: string)
      print(Code .. ": " .. Text)
    end
  }
}


-- Local Players Commands
local LocalPlayersFunctions = {
  Prefix = {
    Function = function(Args)
      if (Args[2]) then
        Settings.Prefixs.LocalPlayerPrefix = Args[2];
        NeededFunctions.Log.Function("Success", "Prefix was changed to " .. Args[2]);
      else
        NeededFunctions.Log.Function("Error", "Prefix was not found");
      end
    end
  },
  Rejoin = {
    Function = function()
      teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
      NeededFunctions.Log.Function("Success", "Rejoining");
    end
  },
  ServerHop = { -- Needs To Be Completed
    Function = function()

    end
  },
  Goto = {
    Function = function(Args)
      if (Args[2] ~= nil) and (localPlayer.Character.Head) and (NeededFunctions.GetPlayers.Function(Args[2])) then
        localPlayer.Character.Head.CFrame = NeededFunctions.GetPlayers.Function(Args[2]).Character.Head.CFrame;
        NeededFunctions.Log.Function("Success", "Teleported to " .. NeededFunctions.GetPlayers(Args[2]));
      else
        NeededFunctions.Log.Function("Error", "Player was either not inputted or found, please retry and check names");
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
      Settings.Noclip = not Settings.Noclip;
      NeededFunctions.Log.Function("Success", "Noclip has been toggled to " .. tostring(Settings.Noclip));
    end
  },
  Gate = {
    Function = function(Args)
      remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
      NeededFunctions.Log.Function("Success", "The Prison Gate has been opened");
    end
  },
  View = {
    Function = function(Args)
      if (NeededFunctions.GetPlayers.Function(Args[2])) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = NeededFunctions.GetPlayers(Args[2]).Character;
        NeededFunctions.Log.Function("Success", "Currently viewing " .. NeededFunctions.GetPlayers(Args[2]));
      elseif (Args[2] == nil) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = localPlayer.Character
        NeededFunctions.Log.Function("Error", "Could be an error, however if this wasnt ignore this error message. If this was an error than check that you put a name for a player")
      else
        NeededFunctions.Log.Function("Error", "This is an error, please recheck username inputted. If not check if player is still in server.")
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
    level = math.huge,
    description = "This is just for showing you guys how to use this function.",
}, function(player, arg1, arg2)
    print("This is who chatted ", player.Name)
    print("This is the first argument ", arg1)
    print("This is second argument will be pack every other arg after it ", arg2)
end)

--! HeartBeat Connection !--
runService:Connect(function()
  if Settings.Noclip then
    for _,Part in pairs(localPlayer.Character:GetDescendants()) do
      if (Part:IsA("BasePart")) or (Part:IsA("Part")) then
          Part.CanCollide = false;
      end
    end
  end
end)
