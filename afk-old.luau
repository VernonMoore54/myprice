--[[
Enhanced Idle Serverhop GUI Script
- Buttons always on top using DisplayOrder
- Live countdown timer displayed above buttons
]]


if game.PlaceId == 116495829188952 then
print("idi")
else 
repeat
task.wait(1)
until game.PlaceId == 116495829188953
end



local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local fileName = "IdleTimeData.json"
local idleData = {}
local idleTime = 0
local threshold = 25 -- seconds until auto-serverhop

-- Safe file read/write
local function safeReadFile()
    local ok, data = pcall(readfile, fileName)
    if ok then return HttpService:JSONDecode(data) end
    return nil
end

local function safeWriteFile(tbl)
    local ok, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(tbl))
    end)
    return ok, err
end

-- Initialize or load idle data
idleData = safeReadFile() or { lastIdleTime = 0, lastConnectionTime = os.time() }
safeWriteFile(idleData)

-- Find emptiest server
local function getEmptiestServer()
    local best, minPlayers = nil, math.huge
    local cursor = ""
    local pages = 0
    repeat
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?limit=100&sortOrder=Asc%s",
            game.PlaceId,
            cursor ~= "" and "&cursor="..cursor or ""
        )
        local res = request({ Url = url, Method = "GET" })
        if not res.Success then break end
        local data = HttpService:JSONDecode(res.Body)
        for _, server in ipairs(data.data) do
            if server.playing > 0 and server.playing < minPlayers then
                minPlayers, best = server.playing, server.id
            end
        end
        cursor = data.nextPageCursor or ""
        pages = pages + 1
        task.wait(0.3)
    until cursor == "" or pages >= 5
    return best
end

local function teleportToEmptiestServer()
    local sid = getEmptiestServer()
    if sid then
        TeleportService:TeleportToPlaceInstance(116495829188952, sid, player)
    else
        warn("Failed to find empty server.")
    end
end

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999 -- ensure on top
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Countdown timer label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "IdleTimer"
timerLabel.Parent = screenGui
timerLabel.Size = UDim2.new(0, 150, 0, 30)
timerLabel.Position = UDim2.new(0, 10, 1, -145)
timerLabel.BackgroundTransparency = 0.5
timerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextScaled = true
timerLabel.BorderSizePixel = 0
timerLabel.Text = "Hop in: " .. threshold .. "s"

-- Teleport button
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Parent = screenGui
teleportButton.Size = UDim2.new(0, 120, 0, 40)
teleportButton.Position = UDim2.new(0, 10, 1, -100)
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
teleportButton.TextColor3 = Color3.fromRGB(0, 255, 255)
teleportButton.TextScaled = true
teleportButton.BorderSizePixel = 0
teleportButton.Text = "Teleport"

teleportButton.MouseButton1Click:Connect(function()
    idleTime = threshold + 1
    teleportToEmptiestServer()
end)

-- Anchor button
local anchorButton = Instance.new("TextButton")
anchorButton.Name = "AnchorButton"
anchorButton.Parent = screenGui
anchorButton.Size = UDim2.new(0, 120, 0, 40)
anchorButton.Position = UDim2.new(0, 10, 1, -50)
anchorButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
anchorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
anchorButton.TextScaled = true
anchorButton.BorderSizePixel = 0
anchorButton.Text = "Anchor Parts"

anchorButton.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true end
    end
end)

-- Reposition UI each frame
RunService.RenderStepped:Connect(function()
    timerLabel.Position = UDim2.new(0, 10, 1, -145)
    teleportButton.Position = UDim2.new(0, 10, 1, -100)
    anchorButton.Position = UDim2.new(0, 10, 1, -50)
end)

-- Monitor idle and update timer
local function monitorIdleTime()
    task.wait(5)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position

    while char and hrp:IsDescendantOf(workspace) do
        task.wait(1)
        local currPos = hrp.Position
        if (currPos - lastPos).Magnitude < 0.1 then
            idleTime = idleTime + 1
        else
            idleTime = 0
            lastPos = currPos
        end
        -- update timer display
        local timeLeft = math.max(threshold - idleTime, 0)
        timerLabel.Text = string.format("Hop in: %ds", timeLeft)
        if idleTime >= threshold then
            idleData.lastIdleTime = os.time()
            while not safeWriteFile(idleData) do task.wait(1) end
            while true do
            task.wait(0.3)
            teleportToEmptiestServer()
            end
            break
        end
    end
end

player.CharacterAdded:Connect(monitorIdleTime)
monitorIdleTime()
