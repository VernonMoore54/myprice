local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local targetText = "Kiciahook V2 | Dead Rails"

local function findTextLabel(parent, text)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("TextLabel") and child.Text == text then
            return child
        elseif #child:GetChildren() > 0 then
            local found = findTextLabel(child, text)
            if found then
                return found
            end
        end
    end
    return nil
end

while not findTextLabel(CoreGui, targetText) do
    wait(0.2)
end

local function moveAndClick(x, y, clicks)
    VirtualInputManager:SendMouseMoveEvent(x, y, game)
    task.wait(0.1)
    for i = 1, clicks do
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        task.wait(0.1)
    end
end

local function performActions()
    moveAndClick(721, 224, 5)
    task.wait(0.1)
    moveAndClick(643, 320, 5)
    task.wait(0.1)
    moveAndClick(643, 436, 3)
end

while true do
    local initialPosition = humanoidRootPart.Position
    performActions()
    task.wait(8)

    local currentPosition = humanoidRootPart.Position
    local distance = (currentPosition - initialPosition).Magnitude

    if distance < 2 then
        continue
    else
        break
    end
end
