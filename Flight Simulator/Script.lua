-- Money
for i = 1, 1000 do
    game:GetService("ReplicatedStorage").RE.ticket:FireServer("Economy", 100000000000000000000000000000000)

    local clothes = game:GetService("ReplicatedStorage").Passengers.Clothes:FindFirstChild("1").Economy:FindFirstChild("1")
    local hair = game:GetService("ReplicatedStorage").Passengers.Hair:FindFirstChild("1"):FindFirstChild("3")
    local economyType = "Economy"
    local region = "European"
    local color = BrickColor.new(125)
    local isPrivate = false
    local camera = workspace.Cameras:FindFirstChild("1")

    game:GetService("ReplicatedStorage").RE.addPassenger:FireServer(
        clothes,
        hair,
        economyType,
        region,
        color,
        isPrivate,
        camera
    )
end

-- XP
for i = 1, 1000 do
    game:GetService("ReplicatedStorage").RE.addXP:FireServer(999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999)
end
