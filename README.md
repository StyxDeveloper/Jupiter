# Jupiter
Jupiter is dedicated to delivering reliable and top-notch scripts, which is why we prioritize quality and refuse to compromise on development by rushing or cutting corners. Although Jupiter is not yet complete, we are working diligently to ensure that it becomes one of the best scripts available. To stay informed about our progress and receive timely updates on Jupiter's completion, please join our server at https://discord.gg/XVAsJPz6T2.

# What Does Jupiter Do?
Initially, Jupiter began as a small Roblox executor. However, we eventually decided that maintaining an executor was tedious and presented various challenges. As a result, we changed direction and are now dedicated to providing some of the best non-skidded Roblox Scripts available.

# Am I Allowed To Make A Pull Request?
Jupiter allows everyone to make a Pull Request! This provides an opportunity for users to contribute to the development of the software and make it even better.


# How Do I Use The Script
Use The Loader 
```lua
local Games = { -- Game | PlaceId | Link
    {"Flight Simulator", 3376584594, ""},
    {"Gods Of Glory", 5665787539, ""},
    {"Destruction Simulator", 2248408710, ""},
    {"Tapping Simulator", 9498006165, ""},
    {"Legends Of Speed", 3101667897, ""}
}

function InitializeScript(PlaceID)
    for i, game in ipairs(Games) do
        if game[2] == PlaceID then
            local scriptLink = game[3]
            local success, errorMessage = pcall(function()
                loadstring(game:HttpGet(scriptLink))()
            end)
            if not success then
                warn("Failed to load script for " .. game[1] .. " : " .. errorMessage)
            end
        else
            warn("Game is not found in the Script-Hub if you want this game supported leave us suggestions")
        end
    end
end

InitializeScript(game.PlaceId)
```

# What Games Are Supported

Flight Simulator
Gods Of Glory
Destruction Simulator
Tapping Simulator
Legends Of Speed
