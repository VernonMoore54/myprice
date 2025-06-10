repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until workspace:WaitForChild("PartyZones"):WaitForChild("PartyZone")
task.wait()
setfpscap(15)

--!strict
local zones = {
    workspace:WaitForChild("PartyZones"):WaitForChild("PartyZone"),
    workspace.PartyZones:WaitForChild("PartyZone1"),
    workspace.PartyZones:WaitForChild("PartyZone2"),
    workspace.PartyZones:WaitForChild("PartyZone3"),
}

local remote = game:GetService("ReplicatedStorage")
    :WaitForChild("Shared")
    :WaitForChild("Network")
    :WaitForChild("RemoteEvent")
    :WaitForChild("CreateParty")

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while true do
    local chosenZone

    -- ищем зону со свободными слотами (0/4)
    for _, zone in ipairs(zones) do
        local gui = zone:FindFirstChild("BillboardGui")
        if gui then
            local lbl = gui:FindFirstChild("PlayerCount")
            if lbl and lbl.Text == "0/4" then
                chosenZone = zone
                break
            end
        end
    end

    if chosenZone then
        -- телепорт к зоне
        local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        if chosenZone.PrimaryPart then
            root.CFrame = chosenZone.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        else
            root.CFrame = chosenZone:GetModelCFrame() + Vector3.new(0, 3, 0)
        end

        task.wait(1)  -- ждём, пока сервер обновит счётчик

        -- формируем аргументы для создания лобби
        local args = {{
            isPrivate = true,
            maxMembers = 1,
            trainId = "default",
            gameMode = "Normal",
        }}

        -- отправляем запросы через repeat...until с паузой 0.3 сек
        local lbl = chosenZone.BillboardGui:FindFirstChild("PlayerCount")
        repeat
            task.wait(0.3)
            remote:FireServer(unpack(args))
            task.wait(0.3)
        until lbl and lbl.Text == "1/4"

        -- после достижения 1/4 ждём 99 секунд
        task.wait(99)
    end

    task.wait(0.5)
end
