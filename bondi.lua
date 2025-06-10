repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

task.wait()

setfpscap(15)

loadstring(game:HttpGet("https://rifton.top/loader.lua"))()
