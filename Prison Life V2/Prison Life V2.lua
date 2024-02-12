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
  LocalPlayer = game:GetService("Players").LocalPlayer
}

--! Global Tables !-- 
local Settings = {
  Prefixs = {
    LocalPlayerPrefix = ".",
    CommandGUIPrefix = ".",
    RankedPlayersPrefix = ":"
  }
}

--! Checks !-- 
game.Loaded:Wait()

assert(not IsJupiterLoaded, "Jupiter is already loaded")
getgenv().IsJupiterLoaded = true

--! Functions !--

-- Get Player
local NeededFunctions = {
  GetPlayers = {
    Function = function(PlayerName)
      for _, player in pairs(Variables.Players:GetChildren()) do
        if string.sub(player.Name:lower(), 1, #PlayerName) == PlayerName:lower() or
           string.sub(player.DisplayName:lower(), 1, #PlayerName) == PlayerName:lower() then
          return player
        end
      end
      return nil
    end
  }


}


-- Local Players Commands
local LocalPlayersFunctions = {
  Prefix = {
    Aliases = {"prefix"},
    Function = function(Args)
      Settings.Prefixs.LocalPlayerPrefix = Args[2];
    end
  },
  Rejoin = {
    Aliases = {"rejoin", "rj"},
    Function = function()
      Variables.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId);
    end
  },
  ServerHop = {
    Aliases = {"shop", "serverhop"},
    Function = function()
    
    end
  },
  Goto = {
    Aliases = {"goto", "to"},
    Function = function(Args)
      if (Args[2] ~= nil) and (Variables.LocalPlayer.Character.Head) then
        Variables.LocalPlayer.Character.Head.CFrame = 
      end
    end
  },
  Bring = {
    Aliases = {"bring", "teleport"},
    Function = function(Args)

    end
  },



  
}



--[[


 = {
  Aliases = {""},
  Function = function(Args)
    
  end)
},


]]

-- Ranked Commands