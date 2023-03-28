while task.wait(0.6) do
    for i = 1, 1000 do
        local rEvents = game:GetService("ReplicatedStorage").rEvents
        rEvents.orbEvent:FireServer("collectOrb", "Blue Orb", "City")
        rEvents.orbEvent:FireServer("collectOrb", "Gem", "City")
    end
    game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
end
