local ctween = {}
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local activeTweens = {}
local tweenIdCounter = 0

function ctween:go(endPosition, duration)
    local player = players.LocalPlayer
    if not player or not player.Character then return end
    local humanoidRootPart = player.Character.HumanoidRootPart
    if not humanoidRootPart then return end
    local startPosition = humanoidRootPart.CFrame
    local startTime = os.clock()
    local tweenId = tweenIdCounter + 1
    tweenIdCounter = tweenIdCounter + 1
    local isRunning = true
    local connection
    local endCFrame = endPosition
    local function updatePosition()
        if not isRunning then return end
        local elapsedTime = os.clock() - startTime
        if elapsedTime >= duration then
            humanoidRootPart.CFrame = endCFrame
            connection:Disconnect()
            activeTweens[tweenId] = nil
            isRunning = false
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        else
            local t = elapsedTime / duration
            humanoidRootPart.CFrame = startPosition:Lerp(endCFrame, t)
        end
    end
    connection = RunService.Heartbeat:Connect(updatePosition)
    activeTweens[tweenId] = {
        connection = connection,
        isRunning = true,
        cancel = function()
            if activeTweens[tweenId] then
                connection:Disconnect()
                activeTweens[tweenId] = nil
                isRunning = false
            end
        end
    }
    return function()
        if activeTweens[tweenId] then
            activeTweens[tweenId].cancel()
        end
    end
end
function ctween:clearAll()
    for id, tween in pairs(activeTweens) do
        if tween.connection then
            tween.connection:Disconnect()
        end
        tween.isRunning = false
    end
    activeTweens = {}
end

return ctween
