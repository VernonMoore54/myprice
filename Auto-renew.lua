repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

-- Функция ожидания смерти персонажа
local function waitForDeath()
	while true do
		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")

		-- Ждём, пока здоровье станет 0
		repeat
			task.wait()
		until humanoid.Health <= 0

		-- Когда умер — запускаем task.spawn с циклом
		task.spawn(function()
			while true do
				local args = {
					false
				}
				ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EndDecision"):FireServer(unpack(args))
				task.wait(1)
			end
		end)

		-- Ждём нового персонажа, если возродится
		localPlayer.CharacterAdded:Wait()
	end
end

-- Запускаем отслеживание смерти
waitForDeath()
