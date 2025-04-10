-- Admin Detector by Ice
local GroupID = 3194064

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId

local function getNewServer()
    local serversListUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversListUrl))
    end)
    
    if success and result then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                return server.id
            end
        end
    end
    
    return nil
end

local function executeScript()
    local newServerId = getNewServer()
    if newServerId then
        TeleportService:TeleportToPlaceInstance(PlaceId, newServerId)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(GroupID) then
        executeScript()
    end
end)
