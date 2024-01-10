--// No longer receiving any updates, this script is fully out of support. 

--// Contributors
local ContributorsList = {
    {Username = "JJSploit On Top", Importance = "Main Developer and Founder"},
    {Username = "Lolegic", Importance = "Main Developer and Co-Founder"},
    {Username = "Che", Importance = "Gave Recommendations"},
    {Username = "Atari", Importance = "Gave Recommendations"},
    {Username = "ChatGPT", Importance = "Better Method For ChatHandler"},
    {Username = "MemoryEditor", Importance = "My Mexican Cartel Worker"}
}

--// Wait until game is loaded
repeat
    task.wait()
until game.Loaded

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
local Remote = Workspace.Remote
local ShootEvent = ReplicatedStorage:FindFirstChild("ShootEvent")
local StarterPlayer = game:GetService("StarterPlayer")
local ClientInputHandler = StarterPlayer.StarterCharacterScripts.ClientInputHandler
local TazePlayer = Remote.tazePlayer
local ChatSystem = ReplicatedStorage.DefaultChatSystemChatEvents
local MessageDoneFiltering = ChatSystem.OnMessageDoneFiltering
local OnClientEvent = MessageDoneFiltering.OnClientEvent
local StartTime = os.clock()
local StarterGui = game:GetService("StarterGui")

--// Tables
local Settings = {
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
    KillAuraSettings = {
        KillAura = false,
        Studs = 20
    },
    NoclipSettings = {
        Noclip = false
    },
    DoorSettings = {
        OpenAllDoors = false,
        Studs = 20
    },
    AntiBringSettings = {
        AntiBring = false,
        MagnitudeCheck = false,
        Studs = 6
    },
    AntiCrimSettings = {
        AntiCrim = false
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
    ForceFieldSettings = {
        ForceField = false
    },
    LoopTaseSettings = {
        Delay = 0.03
    },
    ChatLoggerSettings = {
        ChatLogger = false
    }
}

local Others = {
    GunOrder = {
        "shotgunun",
        "m9",
        "ak"
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
    LoopBringPlayers = {},
    LoopTasePlayers = {},
    Ranked = {}
}

--// ItemHandler
local Tools = {
    m4a1 = Workspace.Prison_ITEMS.giver.M4A1,
    shotgun = Workspace.Prison_ITEMS.giver["Remington 870"],
    ak = Workspace.Prison_ITEMS.giver["AK-47"],
    m9 = Workspace.Prison_ITEMS.giver["M9"],
    hammer = Workspace.Prison_ITEMS.single.Hammer
}

--// Check For FireTouchInterest
if not firetouchinterest then
    print("No firetouchinterest some functions will not work correctly")
    getgenv().firetouchinterest = function()
        task.wait()
    end
end

--// Functions

--// WalkSpeed
local function WalkSpeed(Number)
    if typeof(Number) ~= "number" then
        warn("Walk speed must be a number.")
        return
    end
    if Number < 0 then
        warn("Walk speed must be above 0.")
        return
    end
    Humanoid.WalkSpeed = Number
end

--// TeamEvent
local function TeamEvent(Team)
    local TeamEventRemote = Remote.TeamEvent
    local OriginalCFrame = nil
    if Character:FindFirstChild("Head") then
        OriginalCFrame = Character.Head.CFrame
    else
        OriginalCFrame = Character:FindFirstChildWhichIsA("Part") or Character:FindFirstChildWhichIsA("BasePart")
    end
    if Team == "inmates" then
        TeamEventRemote:FireServer("Bright orange")
        wait(1)
        Character:SetPrimaryPartCFrame(OriginalCFrame)
    elseif Team == "criminals" or Team == "crim" then
        local CrimPads = Workspace["Criminals Spawn"]:FindFirstChild("SpawnLocation")
        Character:SetPrimaryPartCFrame(CrimPads.CFrame)
        task.wait(0.2)
        Character:SetPrimaryPartCFrame(OriginalCFrame)
    elseif Team == "guards" then
        while #game.Teams.Guards:GetPlayers() == 8 do
            wait(1)
        end
        TeamEventRemote:FireServer("Bright blue")
        wait(1)
        Character:SetPrimaryPartCFrame(OriginalCFrame)
    elseif Team == "neutral" then
        TeamEventRemote:FireServer("Medium stone grey")
        wait(1)
        Character:SetPrimaryPartCFrame(OriginalCFrame)
    else
        return "Invalid team: " .. tostring(Team)
    end
end

--// AddExclusion
local function AddExclusion(Player)
    table.insert(Others.Exclusion, Player)
end

--// Arrest
local function Arrest(Player)
    if Player.Character and Player.Character:FindFirstChild("Head") and LocalPlayer then
        local OldPos = LocalPlayer.Head.CFrame
        LocalPlayer:SetPrimaryPartCFrame(Player.Character.Head.CFrame)
        wait(0.07)
        Remote.arrest:InvokeServer(Player.Character.Head)
        LocalPlayer:SetPrimaryPartCFrame(OldPos)
    end
end

--// AutoFire
local function AutoFire()
    for i, v in next, Backpack:GetChildren() do
        local GunStates = require(Backpack[tostring(v)].GunStates)
        GunStates.AutoFire = true
        GunStates.FireRate = 0.01
    end
end

--// NewGunOrder
local function NewGunOrder(Gun1, Gun2, Gun3, Gun4)
    if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, 96651) then
        local Guns = {Gun1, Gun2, Gun3, Gun4}
        for _, v in pairs(Guns) do
            if v then
                table.insert(Others.GunOrder, v)
            end
        end
    end
end

local function ItemHandler(Tool)
    local function GetTool()
        for Name, item in pairs(Tools) do
            if Name == Tool then
                task.wait(0.2)
                Remote.ItemHandler:InvokeServer({Position = Character.PrimaryPart.CFrame.Position, Parent = item})
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
local function JumpPower(Number)
    Humanoid.JumpPower = Number
end

--// MeleeKill
local function MeleeKill(Player)
    if Player and Player.Character then
        local PrimaryPartCFrame = Character:GetPrimaryPartCFrame()
        Character:SetPrimaryPartCFrame(Player.Character:GetPrimaryPartCFrame())
        task.wait(.4)
        for i = 1, 20 do
            ReplicatedStorage.meleeEvent:FireServer(Players:FindFirstChild(Player))
        end
        Character:SetPrimaryPartCFrame(PrimaryPartCFrame)
        return "Successfully Killed Player"
    end
end

--// BreakHum
local function BreakHum()
    local clone = Humanoid:Clone()
    Humanoid:Destroy()
    clone.Parent = Character
    return true
end

--// Teleport
local function Teleport(Player, Position, Time)
    -- Will return later down the line
end

--// Criminal
local function Criminal(Player)
    -- Will return later
end

--// ShootEvent
local function ShootEvent(Player)
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
local function Tase(Player)
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
local function Kill(Player)
    if Settings.KillSettings.KillEvent == "MeleeKill" then
        print(MeleeKill(Player))
    elseif Settings.KillSettings.KillEvent == "GunKill" then
        ShootEvent(Player)
    end
end

--// Chat
local function Chat(Player, Message)
    ChatSystem.SayMessageRequest:FireServer("/w " .. Player .. " " .. Message, "All")
end

local function CheckRank(Command, Player)
    if Settings.ExclusionSettings[Command .. "Commands"] then
        Chat(
            Player,
            "You are not allowed to use " ..
                Command .. " because " .. LocalPlayer.Name .. " has this local function disabled!"
        )
        return false
    else
        return true
    end
end

--// GetPlayer
local function GetPlayer(Name)
    local InGamePlayers = Players:GetPlayers()
    for _, Player in ipairs(InGamePlayers) do
        if Player.Name:lower():sub(1, #Name) == Name:lower() or Player.DisplayName:lower():sub(1, #Name) == Name:lower() then -- Needs to be fixed?
            return Player
        end
    end
    return nil
end

--// Connections

--// CharacterAdded:Connect
CharacterAdded:Connect(
    function(character)
        local Hum = character:WaitForChild("Humanoid")

        --// AutoRespawn
        Hum.Died:Connect(
            function()
                if Settings.AutoRespawnSettings.AutoRespawn then
                    local OldColor = LocalPlayer.TeamColor.Name
                    local OldCameraCFrame = Workspace.CurrentCamera.CFrame
                    local LastCFrame = character:GetPrimaryPartCFrame()
                    TeamEvent(OldColor)
                    while task.wait() do
                        if Hum.Health > 0 then
                            LocalPlayer.character:SetPrimaryPartCFrame(LastCFrame)
                            Workspace.CurrentCamera.CFrame = OldCameraCFrame
                            break
                        end
                    end
                end
            end
        )

        --// AutoGiveGuns
        Hum.Died:Connect(
            function()
                if Hum.Health == 100 and Settings.AutoGiveGunsSettings.AutoGiveGuns then
                    for _, Gun in pairs(Others.GunOrder) do
                        ItemHandler(Gun)
                    end
                end
            end
        )
    end
)

--// HeartBeat:Connect
HeartBeat:Connect(
    function()
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
        if Settings.KillAuraSettings.KillAura then
            task.wait()
            for _, Player in pairs(Players:GetChildren()) do
                local Distance =
                    (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if Distance <= Settings.KillAuraSettings.Studs then
                    Kill(Player.Name)
                end
            end
        end

        --// Door Aura
        for _, Door in pairs(Workspace.Doors:GetChildren()) do
            if Door.Name == "door_v3" then
                local Block = Door:FindFirstChild("Block")
                if Block then
                    local Distance = (Block.hitbox.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                    if Distance <= Settings.DoorSettings.Studs then
                        firetouchinterest(LocalPlayer.Character.Torso, Block.hitbox, 0)
                        firetouchinterest(LocalPlayer.Character.Torso, Block.hitbox, 1)
                    end
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

        --// AntiCrim
        if Settings.AntiCrimSettings.AntiCrim and LocalPlayer.Team ~= "Guards" and LocalPlayer.Team ~= "Neutral" then
            if #game.Teams.Guards:GetPlayers() < 8 then
                TeamEvent("Bright blue")
            else
                TeamEvent("Medium stone grey")
            end
        end

        --// AntiBring
        if Settings.AntiBringSettings.AntiBring then
            if Humanoid.Sit and Humanoid.SeatPart == "VehicleSeat" then
                Humanoid.Sit = false
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
            if getconnections(TazePlayer.OnClientEvent)[1] then
                getconnections(TazePlayer.OnClientEvent)[1]:Disconnect()
            end
        else
            getconnections(TazePlayer.OnClientEvent)[1]:Enable()
        end

        --// Force Field
        if Settings.ForceFieldSettings.ForceField then
            local OldPos = Character.PrimaryPart.CFrame
            Character.Head:Destroy() --// destroys head
            local Head = Character:WaitForChild("Head")
            Head.CFrame = OldPos
            task.wait(5)
        end
    end
)

--// Command Handler + Commands

local Commands = {
    Prefix = {
        Aliases = {"prefix", "customprefix"},
        Func = function(Input)
            Settings.Prefixs.ChatPrefix = Input
        end
    },
    Kill = {
        Aliases = {"k", "kill"},
        Func = function(Player)
            local TargetPlayer = GetPlayer(Player[2])
            Kill(TargetPlayer)
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
            ItemHandler(Tool[2])
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
            WalkSpeed(tonumber(Num[2]))
        end
    },
    LoopWalkSpeed = {
        Aliases = {"lws", "loopwalkspeed"},
        Func = function(Num)
            Settings.LoopWalkSpeedSettings.DefaultWalkSpeed = Num[2]
            Settings.LoopWalkSpeedSettings.LWalkSpeed = not Settings.LoopWalkSpeedSettings.LWalkSpeed
        end
    },
    JumpPower = {
        Aliases = {"jp", "jumppower"},
        Func = function(Num)
            JumpPower(Num[2])
        end
    },
    LoopJumpPower = {
        Aliases = {"ljp", "loopjumppower"},
        Func = function(Num)
            if type(tonumber(Num[2])) == "number" then
                Settings.JumpPowerSettings.Number = Num[2]
                Settings.JumpPowerSettings.Active = true
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
            local Player = GetPlayer(player[2])
            if Player then
                Arrest(Player)
            else
                warn("Player " .. player[2] .. " is not a valid Player. Please try again.")
            end
        end
    },
    Auto = {
        Aliases = {"autofirerate", "auto"},
        Func = function()
            AutoFire()
        end
    },
    Sit = {
        Aliases = {"sit"},
        Func = function()
            Humanoid.Sit = true
        end
    },
    OpenGate = {
        Aliases = {"opengate"},
        Func = function()
            Remote.ItemHandler:InvokeServer(Workspace.Prison_ITEMS.buttons["Prison Gate"]["Prison Gate"])
        end
    },
    Rejoin = {
        Aliases = {"rejoin", "rj"},
        Func = function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end
    },
    ServerHop = {
        Aliases = {"serverhop"},
        Func = function()
            local Success, errorMsg =
                pcall(
                function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, math.random())
                end
            )
            if not Success then
                game:GetService("TeleportService"):Teleport(game.PlaceId, math.random())
            end
        end
    },
    Guns = {
        Aliases = {"guns"},
        Func = function()
            for _, Gun in pairs(Others.GunOrder) do
                ItemHandler(Gun)
            end
        end
    },
    GunOrder = {
        Aliases = {"gunorder"},
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
            local Player = GetPlayer(player[2])
            if Players:FindFirstChild(Player) then
                workspace.CurrentCamera.CameraSubject = Player.Character
            end
        end
    },
    Unview = {
        Aliases = {"unview"},
        Func = function()
            workspace.CurrentCamera.CameraSubject = Character
        end
    },
    ChangeTeam = {
        Aliases = {"changeteam", "changeteams", "team"},
        Func = function(TeamColor)
            TeamEvent(TeamColor[2])
        end
    },
    Exclude = {
        Aliases = {"exclude"},
        Func = function(player)
            local Player = GetPlayer(player[2])
            if Player then
                AddExclusion(Player)
            else
                warn("Player " .. player[2] .. " has not been found. Please check spelling.")
            end
        end
    },
    FpsBoost = {
        Aliases = {"fpsboost"},
        Func = function()
            local Textures = Workspace:GetDescendants()
            for i, Texture in ipairs(Textures) do
                if Texture:IsA("Texture") then
                    Texture.Transparency = Texture.Transparency ~= 1 and 1 or 0
                end
            end
        end
    },
    DoorAura = {
        Aliases = {"da", "dooraura"},
        Func = function(num)
            if not num[2] then
                Settings.DoorSettings.OpenAllDoors = not Settings.DoorSettings.OpenAllDoors
            elseif type(tonumber(num[2])) == "number" then
                Settings.DoorSettings.OpenAllDoors = true
                Settings.DoorSettings.Studs = num[2]
            end
        end
    },
    KillAura = {
        Aliases = {"ka", "aura", "killaura"},
        Func = function(num)
            if type(tonumber(num[2])) == "number" then
                Settings.KillAuraSettings.Studs = num
                Settings.KillAuraSettings.KillAura = true
            else
                Settings.KillAuraSettings.KillAura = not Settings.KillAuraSettings.KillAura
            end
        end
    },
    CTP = {
        Aliases = {"clickteleport", "ctp"},
        Func = function()
            print("Missing function for right now. This will be fixed later.")
        end
    },
    --[[ Not working anymore
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
    ]]
    AntiBring = {
        Aliases = {"ab", "antibring"},
        Func = function()
            Settings.AntiBringSettings.AntiBring = not Settings.AntiBringSettings.AntiBring
        end
    },
    AntiCrim = {
        Aliases = {"ac", "anticriminal"},
        Func = function()
            Settings.AntiCrimSettings.AntiCrim = not Settings.AntiCrimSettings.AntiCrim
        end
    },
    --[[
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
    ]]
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
        Func = function(Args)
            local Player = GetPlayer(Args[2])
            if Player then
                Tase(Player)
            else
                warn("Player " .. Args[2] .. " is not a valid Player.")
            end
        end
    },
    Goto = {
        Aliases = {"goto", "to"},
        Func = function(Arg)
            if Character.Head then
                Character.Head = Players:FindFirstChild(GetPlayer(Arg[2])).PrimaryPart.CFrame
            else
                warn("No Head on character please wait until fully respawned")
            end
        end
    },
    Respawn = {
        Aliases = {"re", "respawn"},
        Func = function()
            local OriginalCFrame = Character.PrimaryPart.CFrame
            TeamEvent(LocalPlayer.Team.Name)
            task.wait(1)
            Character:SetPrimaryPartCFrame(OriginalCFrame)
        end
    },
    ChatLogger = {
        Aliases = {"chatlogger", "logchat"},
        Func = function()
            Settings.ChatLoggerSettings.ChatLogger = not Settings.ChatLoggerSettings.ChatLogger
        end
    },
    CommandLogger = {
        Aliases = {"cmdlogger", "logcmds"},
        Func = function()
            Settings.ChatLoggerSettings.CommandLogger = not Settings.ChatLoggerSettings.CommandLogger
        end
    }
}

OnClientEvent:Connect(
    function(Chatted)
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

        if Settings.ChatLoggerSettings.ChatLogger == true then
            print("ChatLogs:\n User: " .. MessageCreator .. "\n Message: " .. table.concat(Messages))
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
    end
)

StarterGui:SetCore(
    "SendNotification",
    {
        Title = "Successfully Loaded",
        Text = "Time Taken: " .. (os.clock() - StartTime) * 1000 .. " ms",
        Duration = 3
    }
)

print("Prefix: " .. Settings.Prefixs.ChatPrefix .. "\nContributors:")
for _, Contributor in pairs(ContributorsList) do
    print("- " .. Contributor.Username .. " | " .. Contributor.Importance)
end
