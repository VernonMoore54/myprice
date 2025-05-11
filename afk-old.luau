local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local fileName = "IdleTimeData.json"
local idleData = {}
local idleTime = 0

local function safeReadFile()
    local success, data = pcall(function()
        return readfile(fileName)
    end)
    if success then
        return HttpService:JSONDecode(data)
    else
        return nil
    end
end

local function safeWriteFile(data)
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    return success, err
end

idleData = safeReadFile()
if not idleData then
    idleData = {
        lastIdleTime = 0,
        lastConnectionTime = os.time(),
    }
    safeWriteFile(idleData)
end

local function getEmptiestServer()
    local bestServer = nil
    local minPlayers = math.huge
    local cursor = ""
    local pagesChecked = 0

    repeat
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100&sortOrder=Asc"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local response = request({
            Url = url,
            Method = "GET"
        })

        if response.Success then
            local data = HttpService:JSONDecode(response.Body)
            for _, server in ipairs(data.data) do
                if server.playing < minPlayers and server.playing > 0 then
                    minPlayers = server.playing
                    bestServer = server.id
                end
            end
            cursor = data.nextPageCursor or ""
        else
            break
        end

        pagesChecked += 1
        task.wait(0.3)
    until cursor == "" or pagesChecked >= 5

    return bestServer
end

local function teleportToEmptiestServer()
    local serverId = getEmptiestServer()
    if serverId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, player)
    else
        warn("Не удалось найти пустой сервер.")
    end
end

local function createTeleportAndAnchorButtons()
    local screenGui = Instance.new("ScreenGui")
    local teleportButton = Instance.new("TextButton")
    local anchorButton = Instance.new("TextButton")

    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.Name = "TeleportUI"
    screenGui.ResetOnSpawn = false

    teleportButton.Name = "TeleportButton"
    teleportButton.Parent = screenGui
    teleportButton.Text = "Teleport"
    teleportButton.Size = UDim2.new(0, 120, 0, 40)
    teleportButton.Position = UDim2.new(0, 10, 1, -50)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    teleportButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    teleportButton.TextScaled = true
    teleportButton.BorderSizePixel = 0

    teleportButton.MouseButton1Click:Connect(function()
        idleTime = 31
        teleportToEmptiestServer()
    end)

    anchorButton.Name = "AnchorButton"
    anchorButton.Parent = screenGui
    anchorButton.Text = "Anchor Parts"
    anchorButton.Size = UDim2.new(0, 120, 0, 40)
    anchorButton.Position = UDim2.new(0, 10, 1, -100)
    anchorButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    anchorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    anchorButton.TextScaled = true
    anchorButton.BorderSizePixel = 0

    anchorButton.MouseButton1Click:Connect(function()
        local character = player.Character or player.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        teleportButton.Position = UDim2.new(0, 10, 1, -50)
        anchorButton.Position = UDim2.new(0, 10, 1, -100)
    end)
end

createTeleportAndAnchorButtons()

function monitorIdleTime()
    task.wait(5)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local threshold = 15
    local lastPosition = humanoidRootPart.Position

    while true do
        wait(1)
        local currentPosition = humanoidRootPart.Position

        if (currentPosition - lastPosition).Magnitude < 0.1 then
            idleTime = idleTime + 1
        else
            idleTime = 0
            lastPosition = currentPosition
        end

        if idleTime >= threshold then
            idleData.lastIdleTime = os.time()
            local success, err
            repeat
                success, err = safeWriteFile(idleData)
                if not success then wait(1) end
            until success
            teleportToEmptiestServer()
            break
        end

        if not character or not humanoidRootPart:IsDescendantOf(workspace) then
            break
        end
    end
end

player.CharacterAdded:Connect(monitorIdleTime)
monitorIdleTime()
