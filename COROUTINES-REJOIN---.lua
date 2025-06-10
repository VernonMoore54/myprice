local TS = game:GetService("TeleportService")
local P = game:GetService("Players")
local player = P.LocalPlayer

local function waitForLoadingAndCheck()
    local loadingGui = player:WaitForChild("PlayerGui"):WaitForChild("LoadingScreenPrefab", 10) 
    if loadingGui then
        task.wait(10) 
        if loadingGui.Enabled then
            while loadingGui.Enabled do
                TS:Teleport(116495829188952, player)
                task.wait(1)
            end
        end
    end
end

coroutine.wrap(waitForLoadingAndCheck)()
