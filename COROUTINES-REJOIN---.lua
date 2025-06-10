repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

task.wait()

setfpscap(15)

local TS = game:GetService("TeleportService")
local P  = game:GetService("Players")
local RS = game:GetService("RunService")
local NC = game:GetService("NetworkClient")
local CG = game:GetService("CoreGui")
local CP = game:GetService("ContentProvider")
local LS = game:GetService("LogService")

local placeId = 116495829188952
local player  = P.LocalPlayer

local function doTeleport()
    pcall(function()
        TS:Teleport(placeId, player)
    end)
end

local function doTeleportToInstance()
    local success = pcall(function()
        TS:TeleportToPlaceInstance(placeId, game.JobId, player)
    end)
    if not success then
        doTeleport()
    end
end

-- BindToClose
coroutine.wrap(function()
    game:BindToClose(doTeleport)
end)()

-- AncestryChanged
coroutine.wrap(function()
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then doTeleport() end
    end)
end)()

-- Heartbeat timeout
coroutine.wrap(function()
    local last = tick()
    RS.Heartbeat:Connect(function()
        if tick() - last > 10 then doTeleport() end
        last = tick()
    end)
end)()

-- IsLoaded timeout
coroutine.wrap(function()
    local startTime = tick()
    while not game:IsLoaded() do
        if tick() - startTime > 30 then
            doTeleport()
            return
        end
        task.wait(1)
    end
end)()

-- ConnectionStatusChanged
coroutine.wrap(function()
    NC.ConnectionStatusChanged:Connect(function(_, newStatus)
        if newStatus == Enum.ConnectionStatus.Disconnected then
            doTeleport()
        end
    end)
end)()

-- PlayerRemoving
coroutine.wrap(function()
    P.PlayerRemoving:Connect(function(plr)
        if plr == player then doTeleport() end
    end)
end)()

-- ErrorPrompt
coroutine.wrap(function()
    CG.DescendantAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            local err = child:FindFirstChild("ErrorMessage", true)
            repeat task.wait(0.1) until err and err.Text ~= "Label"
            doTeleport()
        end
    end)
end)()

-- TeleportInitFailed
coroutine.wrap(function()
    TS.TeleportInitFailed:Connect(function(plr, _)
        if plr == player then
            doTeleportToInstance()
        end
    end)
end)()

-- LocalPlayerArrivedFromTeleport
coroutine.wrap(function()
    TS.LocalPlayerArrivedFromTeleport:Connect(function()
        -- Optional state reset
    end)
end)()

-- New: Monitor game load with timeout using coroutine.status
coroutine.wrap(function()
    local waitCo = coroutine.create(function()
        game.IsLoaded:Wait()
    end)
    coroutine.resume(waitCo)
    local start = tick()
    while true do
        task.wait(1)
        if coroutine.status(waitCo) == "dead" then break end
        if tick() - start > 30 then
            doTeleport()
            break
        end
    end
end)()

-- New: Monitor ContentProvider load queue
coroutine.wrap(function()
    local initialQueue = CP.RequestQueueSize
    local startTime = tick()
    while true do
        task.wait(1)
        local current = CP.RequestQueueSize
        if current == 0 then break end
        if tick() - startTime > 30 and current >= initialQueue then
            doTeleport()
            break
        end
        initialQueue = current
    end
end)()

-- New: LogService error message watch
coroutine.wrap(function()
    local connection
    connection = LS.MessageOut:Connect(function(msg, type)
        if type == Enum.MessageType.MessageError then
            local m = msg:lower()
            if m:find("connect") or m:find("load") then
                doTeleport()
                if connection then connection:Disconnect() end
            end
        end
    end)
    game.IsLoaded:Wait()
    if connection then connection:Disconnect() end
end)()
