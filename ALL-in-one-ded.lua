repeat 
task.wait(1)
until
game.Players.LocalPlayer.PlayerGui.Intro_SCREEN

game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Finish_Loading"):FireServer()
