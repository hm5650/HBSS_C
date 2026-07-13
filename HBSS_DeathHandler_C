local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local lol = true
local function handle(player)
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            if lol then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                    elseif part:IsA("Accessory") or part:IsA("Tool") then
                        part:Destroy()
                    end
                end
                task.wait(0.1)
                character:Destroy()
            end
        end)
    end
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end
for _, player in ipairs(Players:GetPlayers()) do
    handle(player)
end
Players.PlayerAdded:Connect(handle)
