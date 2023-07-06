-- Still a broken build, please respect that this script was released for learning purposes. Also, you can finish this and use it, if you fix this and create a pull request you can add your name to the Contributors list. 
-- I likely will not be continuing development on this script so have fun with whatever you gain from it.

--[[
    Contributors

    JJSploit On Top -- Main Developer and Founder
    Lolegic -- Main Developer and Co-Founder
    Che -- UI Developer and Checking The Script
    Atari -- Checked The Script
    ChatGPT -- Better methods for different things within this script
]]

--// Wait until game is loaded
while not game.Loaded do
    task.wait()
end

--// Check if Jupiter is already running
assert(not getgenv().IsJupiterLoaded, "Jupiter is already loaded")

--// Set Jupiter as loaded
getgenv().IsJupiterLoaded = true

--// Variables
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Backpack = LocalPlayer.Backpack
local Humanoid = Character.Humanoid
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HeartBeat = RunService.Heartbeat
local CharacterAdded = LocalPlayer.CharacterAdded
local Remote = workspace.Remote
local ShootEvent = ReplicatedStorage:FindFirstChild("ShootEvent")
local StarterPlayer = game:GetService("StarterPlayer")
local ClientInputHandler = StarterPlayer.StarterCharacterScripts.ClientInputHandler
local TazePlayer = Remote.tazePlayer
local ChatSystem = ReplicatedStorage.DefaultChatSystemChatEvents
local MessageDoneFiltering = ChatSystem.OnMessageDoneFiltering
local OnClientEvent = MessageDoneFiltering.OnClientEvent

--// Tables
local Settings = {
    PrisonLifeOwnerOnlySettings = {
        UseNewName = false,
        OriginalName = LocalPlayer.Name
    },
    JumpPowerSettings = {
        Number = nil,
        Active = false
    },
    LoopWalkSpeedSettings = {
        LWalkSpeed = false,
        DefaultWalkSpeed = false
    },
    AutoGiveGunsSettings = {
        AutoGiveGuns = false
    },
    killAuraSettings = {
        killAura = false,
        studs = 20
    },
    NoclipSettings = {
        Noclip = false
    },
    DoorSettings = {
        OpenAllDoors = false,
        studs = 20
    },
    AntiCrimSettings = {
        AntiCriminal = false
    },
    AntiBringSettings = {
        AntiBring = false,
        GodDetection = false,
        MagnitudeCheck = false,
        Studs = 6
    },
    AntiVoidSettings = {
        AntiVoid = false
    },
    LoopKillSettings = {
        CoolDown = 0.03
    },
    AutoRespawnSettings = {
        AutoRespawn = false
    },
    KillSettings = {
        KillEvent = "MeleeKill"
    },
    LoopBringSettings = {
        Delay = 0.5
    },
    AntiTaseSettings = {
        AntiTaze = true
    },
    ExclusionSettings = {
        KillCommands = true,
        BringCommands = true
    },
    GodModeSettings = {
        GodModeSettings = false
    },
    ForceFieldSettings = {
        ForceField = false
    },
    LoopTaseSettings = {
        Delay = 0.03
    }
}

local Others = {
    GunOrder = {
        "ShotGun",
        "M9",
        "AK"
    },
    Teleports = {
        nex = CFrame.new(888, 100, 2388),
        yard = CFrame.new(791, 98, 2498),
        back = CFrame.new(984, 100, 2318),
        armory = CFrame.new(837, 100, 2266),
        tower = CFrame.new(823, 130, 2588),
        base = CFrame.new(-943, 94, 2056),
        cafe = CFrame.new(930, 100, 2289),
        kitchen = CFrame.new(919, 100, 2230),
        snack = CFrame.new(948, 102, 2341),
        vent = CFrame.new(934, 124, 2224),
        mountain = CFrame.new(-1535, 95, 2122),
        escape = CFrame.new(318, 75, 2220),
        secretroom = CFrame.new(697, 97.492, 2364),
        toilet = CFrame.new(959, 96, 2444),
        trash = CFrame.new(365, 10, 1100),
        roof = CFrame.new(827, 118, 2329),
        gate = CFrame.new(503, 102, 2252),
        cells = CFrame.new(917, 100, 2444),
        void = CFrame.new(200000, 200000, 200000)
    },
    CopyTeam = {
        CopyTeamOn = false,
        Player = ""
    },
    Prefixs = {
        ChatPrefix = ";"
    },
    Exclusion = {},
    LoopKillPlayers = {},
    JupitersCustomTeleports = {},
    SpawnLocationNewCFrame = {},
    LoopBringPlayers = {},
    LoopTasePlayers = {},
    Ranked = {}
}

--// Custom Teleports File
--[[
if readfile("JupitersCustomTeleports.txt") then
    Others.JupitersCustomTeleports = loadstring(readfile("JupitersCustomTeleports.txt"))()
else
    Others.JupitersCustomTeleports = {}
end
]]
--// Make sure firetouchinterest is a thing
assert(firetouchinterest, "No firetouchinterest")

--// Functions

--// View Player
function ViewPlayer(Player, Unview)
    if Player and Player:IsA("Player") then
        LocalPlayer.Camera.Subject = Player.Character
    elseif Unview and type(Unview) == "boolean" then
        LocalPlayer.Camera.Subject = Character
    else
        warn("Invalid input parameter")
    end
end

--// WalkSpeed
function WalkSpeed(Number)
    if typeof(Number) ~= "number" then
        warn("Walk speed must be a number.")
        return
    end
    if Number < 0 then
        warn("Walk speed must be above 0.")
        return
    end
    Character.WalkSpeed = Number
end

--// TeamEvent
function TeamEvent(Team)
    local TeamEventRemote = Remote.TeamEvent
    if Team == "Inmates" then
        TeamEventRemote:FireServer("Bright orange")
    elseif Team == "Criminals" then
        local localPlayerTorso = LocalPlayer.Character:WaitForChild("Torso")
        local CrimPads = Workspace["Criminals Spawn"].SpawnLocation
        firetouchinterest(localPlayerTorso, CrimPads, 0)
        firetouchinterest(localPlayerTorso, CrimPads, 1)
    elseif Team == "Bright blue" then
        while #game.Teams.Guards:GetPlayers() >= 8 do
            task.wait()
        end
        TeamEventRemote:FireServer("Bright blue")
    elseif Team == "Neutral" then
        TeamEventRemote:FireServer("Medium stone grey")
    else
        return "Invalid team: " .. tostring(Team)
    end
end

--// AddExclusion
function AddExclusion(Player)
    table.insert(Others.Exclusion, Player)
end

--// Arrest
function Arrest(Player)
    if Player.Character and Player.Character:FindFirstChild("Head") and LocalPlayer then
        local OldPos = LocalPlayer.Head.CFrame
        LocalPlayer:SetPrimaryPartCFrame(Player.Character.Head.CFrame)
        wait(0.07)
        Remote.arrest:InvokeServer(Player.Character.Head)
        LocalPlayer:SetPrimaryPartCFrame(OldPos)
    end
end

--// AutoFire
function AutoFire()
    for i, v in next, Backpack:GetChildren() do
        local GunStates = require(Backpack[tostring(v)].GunStates)
        GunStates.AutoFire = true
        GunStates.FireRate = 0.01
    end
end

--// GainOwnerPerk
function GainOwnerPerk()
    local NewName = "Aesthetical"
    Settings.PrisonLifeOwnerOnlySettings.UseNewName = not Settings.PrisonLifeOwnerOnlySettings.UseNewName
    if Settings.PrisonLifeOwnerOnlySettings.UseNewName then
        LocalPlayer.Name = NewName
    else
        LocalPlayer.Name = Settings.PrisonLifeOwnerOnlySettings.OriginalName
    end
end

--// GiveGuns
function GiveGuns()
    for _, Gun in pairs(Others.GunOrder) do
        ItemHandler(Gun)
    end
end

--// NewGunOrder
function NewGunOrder(Gun1, Gun2, Gun3, Gun4)
    if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 96651) then
        local Guns = {Gun1, Gun2, Gun3, Gun4}
        for _, v in pairs(Guns) do
            if v then
                table.insert(Others.GunOrder, v)
            end
        end
    end
end

--// ItemHandler
local Tools = {
    m4a1 = workspace.Prison_ITEMS.giver.M4A1.ITEMPICKUP,
    shotgun = workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP,
    ak = workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP,
    m9 = workspace.Prison_ITEMS.giver["M9"].ITEMPICKUP,
    hammer = workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP,
}

function ItemHandler(Tool)
    local function GetTool()
        for Name, item in pairs(Tools) do
            if Name == Tool then
                task.wait(0.2)
                Remote.ItemHandler:InvokeServer(Character.PrimaryPart.CFrame.Position, item and true)
            end
        end
    end

    if Character then
        GetTool()
        return "Got Tool"
    else
        task.wait(0.5)
        ItemHandler(Tool)
    end
end

--// JumpPower
function JumpPower(Number)
    Character.JumpPower = Number
end

--// MeleeKill
function MeleeKill(Player)
    if not Player or not Players:FindFirstChild(Player) or Player == LocalPlayer then
        return "Player not in game or check if it's spelled right"
    end
    if Player and Player.Character then
        local PrimaryPartCFrame = Character:GetPrimaryPartCFrame()
        Character:SetPrimaryPartCFrame(Player.Character:GetPrimaryPartCFrame())
        wait(0.1)
        for i = 1, 20 do
            ReplicatedStorage.meleeEvent:FireServer(Player)
        end
        Character:SetPrimaryPartCFrame(PrimaryPartCFrame)
        return "Successfully Killed Player"
    end
end

--// OpenGate
function OpenGate()
    Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"])
end

--// Rejoin
function Rejoin()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

--// ServerHop
function ServerHop()
    local Success, errorMsg = pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, math.random())
    end)
    if not Success then
        game:GetService("TeleportService"):Teleport(game.PlaceId, math.random())
    end
end

--// Sit
function Sit(Toggle)
    if type(Toggle) == "boolean" then
        Humanoid.Sit = Toggle
    else
        warn("Incorrect usage, not a boolean")
    end
end

--// BreakHum
function BreakHum()
    local clone = Humanoid:Clone()
    Humanoid:Destroy()
    clone.Parent = Character
    return true
end

--// Teleport
function Teleport(Player, Position, Time)
    if Player == LocalPlayer then
        Character:SetPrimaryPartCFrame(Position)
        return "Brought LocalPlayer"
    end
    local TeamEvent = Remote.TeamEvent
    local TeleportWaitTime
    local OldPosition
    local OldTeam = LocalPlayer.TeamColor.Name
    local Handcuffs = Character:FindFirstChild("Handcuffs")
    if Character:FindFirstChild("Head") then
        OldPosition = Character.Head.CFrame
    else
        OldPosition = Character:FindFirstChildWhichIsA("Part") or Character:FindFirstChildWhichIsA("BasePart")
    end
    if type(Time) == "number" then
        TeleportWaitTime = Time
    else
        TeleportWaitTime = 0.04
    end
    if OldTeam ~= "Bright blue" or Humanoid.Health == 0 then
        TeamEvent:FireServer("Bright blue")
        LocalPlayer.CharacterAppearanceLoaded:Wait()
    end
    Character:SetPrimaryPartCFrame(Position)
    BreakHum()
    task.wait(TeleportWaitTime)
    Character.Head.Anchored = true
    if Backpack:FindFirstChild("Handcuffs") then
        Backpack:FindFirstChild("Handcuffs").Parent = Character
        Handcuffs = Character:FindFirstChild("Handcuffs")
    elseif Character:FindFirstChild("Handcuffs") then
        Handcuffs = Character:FindFirstChild("Handcuffs")
    end
    if Handcuffs then
        firetouchinterest(Handcuffs.Handle, Player.Character.Torso, 0)
        Player.Character:SetPrimaryPartCFrame(Position)
        Handcuffs.Handle.CFrame = Position
    end
    while task.wait(TeleportWaitTime) do
        if Handcuffs then
            firetouchinterest(Handcuffs.Handle, Player.Character.Torso, 0)
            Player.Character:SetPrimaryPartCFrame(Position)
            Handcuffs.Handle.CFrame = Position
        end
        if not Handcuffs and Player.Character:FindFirstChild("Handcuffs") then
            Character:SetPrimaryPartCFrame(Position)
            Player.Character:FindFirstChild("Handcuffs").Handle.CFrame = Position
            break
        end
    end
    TeamEvent:FireServer(OldTeam)
    LocalPlayer.CharacterAppearanceLoaded:Wait()
    Character:SetPrimaryPartCFrame(OldPosition)
    return true
end

--// Criminal
function Criminal(Player)
    local OldTeam = LocalPlayer.TeamColor.Name
    local Handcuffs
    local Position = Character.PrimaryPart.CFrame

    if OldTeam ~= "Bright blue" or Humanoid.Health == 0 then
        TeamEvent:FireServer("Bright blue")
        LocalPlayer.CharacterAppearanceLoaded:Wait()
    end

    BreakHum()

    if Backpack:FindFirstChild("Handcuffs") then
        Backpack:FindFirstChild("Handcuffs").Parent = Character
        Handcuffs = Character:FindFirstChild("Handcuffs")
    elseif Character:FindFirstChild("Handcuffs") then
        Handcuffs = Character:FindFirstChild("Handcuffs")
    end

    if Handcuffs then
        firetouchinterest(Handcuffs.Handle, Player.Character.Torso, 0)
        Player.Character:SetPrimaryPartCFrame(Position)
        Handcuffs.Handle.CFrame = Position
    end

    while task.wait() do
        if Handcuffs then
            local CrimPads = Workspace["Criminals Spawn"].SpawnLocation
            firetouchinterest(Player.Character.Torso, CrimPads, 0)
            firetouchinterest(Player.Character.Torso, CrimPads, 1)
        else
            break
        end
    end
end

--// FPSBoost
function FPSBoost()
    local Textures = workspace:GetDescendants()
    for i, Texture in ipairs(Textures) do
        if Texture:IsA("Texture") then
            Texture.Transparency = Texture.Transparency ~= 1 and 1 or 0
        end
    end
end

--// AddCustomTeleport
function AddCustomTeleport(CFrame, Name)
    for _, Teleport in ipairs(Others.JupitersCustomTeleports) do
        if Teleport.Name == Name then
            return "Teleport with the same Name already exists"
        elseif Teleport.CFrame == CFrame then
            return "Teleport with the same CFrame already exists"
        end
    end

    table.insert(Others.JupitersCustomTeleports, { CFrame = CFrame, Name = Name })

    local Result = "{"
    for i, v in ipairs(Others.JupitersCustomTeleports) do
        if i == 0 then
            Result = Result .. ","
        end
        Result = Result .. "{CFrame = CFrame.new(" .. tostring(v.CFrame) .. "), Name = '" .. v.Name .. "'}"
    end
    Result = Result .. "}"
    writefile("Others.JupitersCustomTeleports.txt", "return " .. Result)

    return "Custom Teleport " .. Name .. " added successfully"
end

--// ShootEvent
function ShootEvent(Player)
    local Shoot = {
        {
            {
                RayObject = Ray.new(Vector3.new(0)),
                Distance = 1,
                Cframe = CFrame.new(0, 0, 0),
                Hit = Player.Character:FindFirstChild("Head")
            }
        },
        Character:FindFirstChild("M9")
    }

    for i = 1, 6 do
        if not Backpack:FindFirstChild("M9") or not Character:FindFirstChild("M9") then
            ItemHandler("M9")
        end

        if not Character:FindFirstChild("M9") then
            Backpack:FindFirstChild("M9").Parent = Character
        end

        ShootEvent:FireServer(unpack(Shoot))
        Character:FindFirstChild("M9"):Destroy()
    end
end

--// Tase
function Tase(Player)
    local Shoot = {
        {
            {
                RayObject = Ray.new(Vector3.new(0)),
                Distance = 1,
                Cframe = CFrame.new(0, 0, 0),
                Hit = Player.Character:FindFirstChild("Head")
            }
        },
        Character:FindFirstChild("Taser")
    }

    for i = 1, 6 do
        if not Character:FindFirstChild("Taser") or not Backpack:FindFirstChild("Taser") then
            TeamEvent("Bright blue")
        end

        if not Character:FindFirstChild("Taser") then
            Backpack:FindFirstChild("Taser").Parent = Character
        end

        ShootEvent:FireServer(unpack(Shoot))
        Character:FindFirstChild("Taser"):Destroy()
    end
end

--// Kill
function Kill(Player)
    if Settings.KillSettings.KillEvent == "MeleeEvent" then
        MeleeKill(Player)
    elseif Settings.KillSettings.KillEvent == "GunKill" then
        ShootEvent(Player)
    end
end

--// Chat
function Chat(Player, Message)
    ChatSystem.SayMessageRequest:FireServer("/w " .. Player .. " " .. Message, "All")
end

function CheckRank(Command, Player)
    if Settings.ExclusionSettings[Command .. "Commands"] then
        Chat(Player, "You are not allowed to use " .. Command .. " because " .. LocalPlayer.Name .. " has this function disabled!")
        return false
    else
        return true
    end
end

--// GetPlayer
function GetPlayer(Name)
    local InGamePlayers = Players:GetPlayers()
    for _, Player in ipairs(InGamePlayers) do
        if Player.Name:lower():sub(1, #Name) == Name:lower() or Player.DisplayName:lower():sub(1, #Name) == Name:lower() then
            return Player
        end
    end
    return nil
end

--// Connections

--// CharacterAdded:Connect
CharacterAdded:Connect(function(character)
    local Hum = character:WaitForChild("Humanoid")

    --// AutoRespawn
    Hum.Died:Connect(function()
        if Settings.AutoRespawnSettings.AutoRespawn then
            local Player = game.Players.LocalPlayer
            local OldColor = Player.TeamColor.Name
            local OldCameraCFrame = workspace.CurrentCamera.CFrame
            local LastCFrame = character:GetPrimaryPartCFrame()
            TeamEvent(OldColor)
            task.wait(0.3)
            if Hum.Health <= 0 then
                Player.character:SetPrimaryPartCFrame(LastCFrame)
                workspace.CurrentCamera.CFrame = OldCameraCFrame
            end
        end
    end)

    --// AutoGiveGuns
    Hum.Died:Connect(function()
        if Hum.Health == 100 and Settings.AutoGiveGunsSettings.AutoGiveGuns then
            GiveGuns()
        end
    end)

    --// SpawnLocation
    if typeof(Others.SpawnLocationNewCFrame.CFrame) == "CFrame" and not Settings.AutoRespawnSettings.AutoRespawn then
        character:SetPrimaryPartCFrame(Others.SpawnLocationNewCFrame.CFrame)
    end

    --// GodMode
    if Settings.GodModeSettings.GodModeSettings then
        BreakHum()
        task.wait(3)
    end
end)

--// HeartBeat:Connect

--// HeartBeat:Connect
HeartBeat:Connect(function()
    --// Loop Jump Power
    if Settings.JumpPowerSettings.Active then
        JumpPower(Settings.JumpPowerSettings.Number)
    end
    
    --// Loop Walk Speed
    if Settings.LoopWalkSpeedSettings.Active then
        WalkSpeed(Settings.LoopWalkSpeedSettings.LWalkSpeed)
    end
    
    --// NoClip
    if Settings.NoclipSettings.Noclip then
        for _, Part in ipairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") or Part:IsA("Part") then
                Part.CanCollide = false
            end
        end
    end
    
    --// Kill Aura
    if Settings.killAuraSettings.killAura then
        task.wait()
        for _, Player in pairs(Players:GetChildren()) do
            local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if Distance <= Settings.killAuraSettings.studs then
                Kill(Player.Name)
            end
        end
    end
    
    --// Door Aura
    for _, Door in pairs(workspace.Doors:GetChildren()) do
        if Door.Name == "door_v3" then
            local Block = Door:FindFirstChild("Block")
            if Block then
                local Distance = (Block.hitbox.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                if Distance <= Settings.DoorSettings.studs then
                    firetouchinterest(LocalPlayer.Character.Torso, Block.hitbox, 0)
                    firetouchinterest(LocalPlayer.Character.Torso, Block.hitbox, 1)
                end
            end
        end
    end
    
    --// AntiCrim
    if Settings.AntiCrimSettings.AntiCriminal and LocalPlayer.Team ~= "Guards" and LocalPlayer.Team ~= "Neutral" then
        if #game.Teams.Guards:GetPlayers() < 8 then
            TeamEvent("Bright blue")
        else
            TeamEvent("Medium stone grey")
        end
    end
    
    --// AntiBring
    if Settings.AntiBringSettings.AntiBring then
        for _, Player in pairs(Players:GetPlayers()) do
            if not Player.Character or not Player.Character.Humanoid then
                local possibility = Player
                if Settings.AntiBringSettings.GodDetection then
                    if Settings.AntiBringSettings.MagnitudeCheck then
                        local Character = possibility.Character
                        if Character and (Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude <= Settings.AntiBringSettings.Studs then
                            BreakHum()
                        end
                    else
                        BreakHum()
                    end
                end
            end
        end
        for _, Tool in pairs(LocalPlayer.Character:GetChildren()) do
            if Tool:IsA("Tool") and Tool.Name == "Handcuffs" then
                Tool:Destroy()
            end
        end
    end
    
    --// AntiVoid
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and Settings.AntiVoidSettings.AntiVoid then
        local Position = LocalPlayer.Character.PrimaryPart.Position
        if Position.Y < -100 then
            LocalPlayer.Character:SetPrimaryPartCFrame(Others.Teleports.nex)
        end
    end
    
    --// CopyTeam
    if Others.CopyTeam.CopyTeamOn then
        for _, Player in pairs(Players:GetPlayers()) do
            if Others.CopyTeam.Player == Player then
                if tostring(Others.CopyTeam.Player.Team.TeamColor) ~= tostring(LocalPlayer.Team.TeamColor) then
                    TeamEvent(Others.CopyTeam.Player.Team.TeamColor.Name)
                end
                break
            end
        end
    end
    
    --// LoopKill
    for i, GetPlayers in pairs(Others.LoopKillPlayers) do
        Kill(GetPlayers)
        if Settings.LoopKillSettings.CoolDown then
            task.wait(Settings.LoopKillSettings.CoolDown)
        end
    end
    
    --// LoopTaze
    for i, GetPlayers in pairs(Others.LoopTasePlayers) do
        Tase(GetPlayers)
        if Settings.LoopTaseSettings.Delay then
            task.wait(Settings.LoopTaseSettings.Delay)
        end
    end
    
    --// LoopBring
    for i, Player in ipairs(Others.LoopBringPlayers) do
        if Players:FindFirstChild(Player) then
            if Settings.LoopBringSettings.Position then
                Teleport(Player, Settings.LoopBringSettings.Position, Settings.LoopBringSettings.Delay)
            else
                Teleport(Player, Character:FindFirstChild("Head"), Settings.LoopBringSettings.Delay)
            end
        end
    end

    --// AntiTaze
    if Settings.AntiTaseSettings.AntiTaze then
        if getconnections(TazePlayer.OnClientEvent)[1]  then
            getconnections(TazePlayer.OnClientEvent)[1]:Disconnect()            
        end
    else
        getconnections(TazePlayer.OnClientEvent)[1]:Enable()
    end

    --// Force Field
    if Settings.ForceFieldSettings.ForceField then
        local OldPos = Character.Head.CFrame
        Character.Head:Destroy() --// destroys head
        local Head = Character:WaitForChild("Head")
        Head.CFrame = OldPos
        task.wait(5)
    end
end)

--// Command Handler + Commands

local Commands = {
    Test = {
        Aliases = {"t", "testing", "test"},
        Func = function()
            print("Test: Command Handler Is Working!")
        end
    },
    Kill = {
        Aliases = {"k", "kill"},
        Func = function(Player)
            local TargetPlayer = GetPlayer(Player)
            if TargetPlayer then
                Kill(TargetPlayer)
            else
                warn(Player .. " is not a valid Player. Please try again.")
            end
        end
    },
    AutoRespawn = {
        Aliases = {"ar", "autorespawn"},
        Func = function()
            Settings.AutoRespawnSettings.AutoRespawn = not Settings.AutoRespawnSettings.AutoRespawn
        end
    },
    Gun = {
        Aliases = {"gun"},
        Func = function(Tool)
            if Tool then
                ItemHandler(Tool)
            else
                warn("Tool has not been found. Please try again with a valid item.")
            end
        end
    },
    Hammer = {
        Aliases = {"hammer"},
        Func = function()
            ItemHandler("hammer")
        end
    },
    WalkSpeed = {
        Aliases = {"ws", "walkspeed"},
        Func = function(Num)
            WalkSpeed(tonumber(Num))
        end
    },
    LoopWalkSpeed = {
        Aliases = {"lws", "loopwalkspeed"},
        Func = function(Num)
            if type(tonumber(Num)) == "number" then
                Settings.LoopWalkSpeedSettings.DefaultWalkSpeed = Num
            else
                Settings.LoopWalkSpeedSettings.LWalkSpeed = not Settings.LoopWalkSpeedSettings.LWalkSpeed
            end
        end
    },
    JumpPower = {
        Aliases = {"jp", "jumppower"},
        Func = function(Num)
            if type(tonumber(Num)) == "number" then
                JumpPower(Num)
            else
                warn("Not a valid input: " .. Num)
            end
        end
    },
    LoopJumpPower = {
        Aliases = {"ljp", "loopjumppower"},
        Func = function(Num)
            if type(tonumber(Num)) == "number" then
                Settings.JumpPowerSettings.Number = Num
                Settings.JumpPowerSettings.Active = not Settings.JumpPowerSettings.Active
            else
                Settings.JumpPowerSettings.Active = not Settings.JumpPowerSettings.Active
            end
        end
    },
    Noclip = {
        Aliases = {"nc", "noclip"},
        Func = function()
            Settings.NoclipSettings.Noclip = not Settings.NoclipSettings.Noclip
        end
    },
    Arrest = {
        Aliases = {"arrest"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                Arrest(Player)
            else
                warn("Player " .. player .. " is not a valid Player. Please try again.")
            end
        end
    },
    OwnerPerk = {
        Aliases = {"ownerperk"},
        Func = function()
            Settings.PrisonLifeOwnerOnlySettings.UseNewName = not Settings.PrisonLifeOwnerOnlySettings.UseNewName
        end
    },
    Auto = {
        Aliases = {"autofirerate", "auto"},
        Func = function()
            AutoFire()
        end
    },
    Sit = {
        Aliases = {"Sit"},
        Func = function(Bool)
            if not Bool then
                Sit(true)
            elseif type(Bool) == "boolean" then
                Sit(Bool)
            end
        end
    },
    OpenGate = {
        Aliases = {"opengate"},
        Func = function()
            OpenGate()
        end
    },
    Rejoin = {
        Aliases = {"rejoin"},
        Func = function()
            Rejoin()
        end
    },
    ServerHop = {
        Aliases = {"serverhop"},
        Func = function()
            ServerHop()
        end
    },
    Guns = {
        Aliases = {"guns"},
        Func = function()
            GiveGuns()
        end
    },
    GunOrder = {
        Aliases = {"guns"},
        Func = function(ARGS)
            NewGunOrder(ARGS[3], ARGS[4], ARGS[5], ARGS[6])
        end
    },
    AutoGiveGun = {
        Aliases = {"agg", "autogivegun"},
        Func = function()
            Settings.AutoGiveGunsSettings.AutoGiveGuns = not Settings.AutoGiveGunsSettings.AutoGiveGuns
        end
    },
    View = {
        Aliases = {"view"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                ViewPlayer(Player)
            else
                warn("Player " .. player .. " is not a valid Player.")
            end
        end
    },
    Unview = {
        Aliases = {"unview"},
        Func = function()
            ViewPlayer(nil, true)
        end
    },
    ChangeTeam = {
        Aliases = {"changeteam", "changeteams", "team"},
        Func = function(TeamColor)
            if TeamColor then
                TeamEvent(TeamColor)
            else
                warn("No team was provided.")
            end
        end
    },
    Exclude = {
        Aliases = {"exclude"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                AddExclusion(Player)
            else
                warn("Player " .. player .. " has not been found. Please check spelling.")
            end
        end
    },
    FpsBoost = {
        Aliases = {"fpsboost"},
        Func = function()
            FPSBoost()
        end
    },
    DoorAura = {
        Aliases = {"da", "dooraura"},
        Func = function(num)
            if not num then
                Settings.DoorSettings.OpenAllDoors = not Settings.DoorSettings.OpenAllDoors
            elseif type(tonumber(num)) == "number" then
                Settings.DoorSettings.OpenAllDoors = not Settings.DoorSettings.OpenAllDoors
                Settings.DoorSettings.studs = num
            end
        end
    },
    killAura = {
        Aliases = {"ka", "aura", "killaura"},
        Func = function(num)
            Settings.killAuraSettings.killAura = not Settings.killAuraSettings.killAura
            if type(tonumber(num)) == "number" then
                Settings.killAuraSettings.studs = num
            end
        end
    },
    CTP = {
        Aliases = {"clickteleport", "ctp"},
        Func = function()
            print("Missing function for right now. This will be fixed later.")
        end
    },
    Bring = {
        Aliases = {"bring"},
        Func = function(ARGS)
            local Player = GetPlayer(ARGS[3])
            if Player and type(tonumber(ARGS[4])) == "number" then
                Teleport(Player, LocalPlayer.Character.Head.CFrame, ARGS[4])
            elseif Player then
                Teleport(Player, LocalPlayer.Character.Head.CFrame)
            else
                warn("Player " .. ARGS[3] .. " is not a valid Player.")
            end
        end
    },
    Crim = {
        Aliases = {"crim"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                Criminal(Player)
            else
                warn("Player " .. player .. " is not a valid Player.")
            end
        end
    },
    AntiCrim = {
        Aliases = {"ac", "anticrim"},
        Func = function()
            Settings.AntiCrimSettings.AntiCriminal = not Settings.AntiCrimSettings.AntiCriminal
        end
    },
    AntiBring = {
        Aliases = {"ab", "antibring"},
        Func = function()
            Settings.AntiBringSettings.AntiBring = not Settings.AntiBringSettings.AntiBring
        end
    },
    GodDetection = {
        Aliases = {"goddetection"},
        Func = function()
            Settings.AntiBringSettings.GodDetection = not Settings.AntiBringSettings.GodDetection
        end
    },
    MagnitudeCheck = {
        Aliases = {"magnitudecheck"},
        Func = function(num)
            if not num then
            Settings.AntiBringSettings.MagnitudeCheck = not Settings.AntiBringSettings.MagnitudeCheck
            elseif type(tonumber(num)) == "number" then
                Settings.AntiBringSettings.Studs = num
            end
        end
    },
    Teleport = {
        Aliases = {"teleport"},
        Func = function(ARGS)
            local Player = GetPlayer(ARGS[3])
            if Player and ARGS[4] then
                for _, v in pairs(Others.Teleports) do
                    if ARGS[4] == v then
                        Teleport(Player, ARGS[4])
                    else
                        warn("Not a valid place!")
                    end
                end
            elseif not Player and ARGS[3] then
                for _, v in pairs(Others.Teleports) do
                    if ARGS[3] == v then
                        Teleport(LocalPlayer, ARGS[3])
                    else
                        warn("Not a valid place!")
                    end
                end
            else
                warn("Something was inputted wrong.")
            end
        end
    },
    Void = {
        Aliases = {"void"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                Teleport(Player, Others.Teleports.void)
            else
                warn("Player is not correct.")
            end
        end
    },
    CopyTeam = {
        Aliases = {"ct", "copyteam"},
        Func = function(player)
            local Player = GetPlayer(player)
            Others.CopyTeam.CopyTeamOn = not Others.CopyTeam.CopyTeamOn
            if Player then
                if table.find(Others.CopyTeam.Player, Player) then
                    Others.CopyTeam.Player = table.remove(Others.CopyTeam.Player, Player)
                else
                    Others.CopyTeam.Player = table.insert(Others.CopyTeam.Player, Player)
                end
            else
                warn("No Player has been correctly inputted.")
            end
        end
    },
    CustomBringLocations = {
        Aliases = {"cbl", "custombringlocations"},
        Func = function(ARGS)
            if ARGS[3] and ARGS[4] then
                AddCustomTeleport(ARGS[3], ARGS[4])
            end
        end
    },
    LoopKill = {
        Aliases = {"lk"},
        Func = function(ARGS)
            local Player = GetPlayer(ARGS[3])
            if Player then
                table.insert(Others.LoopKillPlayers, Player)
                if type(tonumber(ARGS[4])) == "number" then
                    Settings.LoopKillSettings.CoolDown = ARGS[4]
                end
            end
        end
    },
    AntiTase = {
        Aliases = {"antitase"},
        Func = function()
            Settings.AntiTaseSettings.AntiTaze = not Settings.AntiTaseSettings.AntiTaze
        end
    },
    ExclusionSettings = {
        Aliases = {"exclusionsettings"},
        Func = function()
            print("Not implemented yet.")
        end
    },
    FF = {
        Aliases = {"ff"},
        Func = function()
            Settings.ForceFieldSettings.ForceField = not Settings.ForceFieldSettings.ForceField
        end
    },
    Tase = {
        Aliases = {"tase"},
        Func = function(player)
            local Player = GetPlayer(player)
            if Player then
                Tase(Player)
            else
                warn("Player " .. player .. " is not a valid Player.")
            end
        end
    }
}

OnClientEvent:Connect(function(Chatted)
    local Message = Chatted.Message
    local MessageCreator = Chatted.FromSpeaker
    local Arguments = string.split(Message, " ")

    local function GetCommandFromMessage(Message)
        return string.sub(Message, #Others.Prefixs.ChatPrefix + 1):lower()
    end

    local function IsValidCommand()
        return Message:sub(1, #Others.Prefixs.ChatPrefix) == Others.Prefixs.ChatPrefix
    end

    local function PrintCommands()
        for Command, Cmd in pairs(Commands) do
            if type(Cmd) == "table" and Cmd.Func then
                local Aliases = table.concat(Cmd.Aliases, ", ")
                print(Command .. " (" .. Aliases .. ")")
            end
        end
    end

    local function ExecuteCommand(Command, Args)
        for _, Cmd in pairs(Commands) do
            for _, Alias in ipairs(Cmd.Aliases) do
                if Alias == Command then
                    Cmd.Func(Args)
                    return true
                end
            end
        end
        return false
    end

    if MessageCreator == LocalPlayer.Name and IsValidCommand(Message) then
        local Command = GetCommandFromMessage(Arguments[1])
        if Command == "cmds" then
            PrintCommands()
        else
            if Command ~= "" and Command ~= nil then
                local Success = ExecuteCommand(Command, Arguments)
                if not Success then
                    warn("Invalid Command: " .. Command)
                end
            end
        end
    end
end)

