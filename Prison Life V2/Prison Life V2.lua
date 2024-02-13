--[[ Credits
    !! // The Jupiter Staff Team // !!
      *The Team*
    // Styx Developer // 
    // Lolegic //
    // Che/Forest //
]]

--! Global Variables !-- 
local Variables = {
  TeleportService = game:GetService("TeleportService"),
  Players = game:GetService("Players"),
  LocalPlayer = game:GetService("Players").LocalPlayer,
  HeartBeat = game:GetService("RunService").Heartbeat,
  Remote = game:GetService("Workspace").Remote
}

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
      for _, player in pairs(Variables.Players:GetChildren()) do
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
      Variables.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
      NeededFunctions.Log.Function("Success", "Rejoining");
    end
  },
  ServerHop = { -- Needs To Be Completed
    Function = function()

    end
  },
  Goto = {
    Function = function(Args)
      if (Args[2] ~= nil) and (Variables.LocalPlayer.Character.Head) and (NeededFunctions.GetPlayers.Function(Args[2])) then
        Variables.LocalPlayer.Character.Head.CFrame = NeededFunctions.GetPlayers.Function(Args[2]).Character.Head.CFrame;
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
      Variables.Remote.ItemHandler:InvokeServer(game:GetService("Workspace").Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"]);
      NeededFunctions.Log.Function("Success", "The Prison Gate has been opened");
    end
  },
  View = {
    Function = function(Args)
      if (NeededFunctions.GetPlayers.Function(Args[2])) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = NeededFunctions.GetPlayers(Args[2]).Character;
        NeededFunctions.Log.Function("Success", "Currently viewing " .. NeededFunctions.GetPlayers(Args[2]));
      elseif (Args[2] == nil) then
        game:GetService("Workspace").CurrentCamera.CameraSubject = Variables.LocalPlayer.Character
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


--! HeartBeat Connection !--
Variables.HeartBeat:Connect(function()
  if Settings.Noclip then
    for _,Part in pairs(Variables.LocalPlayer.Character:GetDescendants()) do
      if (Part:IsA("BasePart")) or (Part:IsA("Part")) then
          Part.CanCollide = false;
      end
    end
  end
end)
