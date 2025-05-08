local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local myFrame

-- Ожидание появления объекта game:GetService("CoreGui"):GetChildren()[76].Frame
while not myFrame do
    local children = CoreGui:GetChildren()
    if #children >= 76 then
        local potentialContainer = children[76]
        if potentialContainer and potentialContainer:FindFirstChild("Frame") then
            myFrame = potentialContainer.Frame
        end
    end
    if not myFrame then
        task.wait(0.1)
    end
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
    moveAndClick(616, 112, 3)
    task.wait(0.1)
    moveAndClick(534, 210, 3)
    task.wait(0.1)
    moveAndClick(536, 326, 3)
end

while true do
    local initialPosition = humanoidRootPart.Position
    performActions()
    task.wait(4)

    local currentPosition = humanoidRootPart.Position
    local distance = (currentPosition - initialPosition).Magnitude

    if distance < 2 then
        continue
    else
        break
    end
end
