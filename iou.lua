-- code written by dank
-- bug fixes by Vezise/vez/_vez0
-- hamon fix by DuongNoob (cuz me vez was too lazy)
-- modified by Grok for alt-account vampire distribution

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat task.wait() until GrabError.Text ~= "Label"
        local Reason = GrabError.Text
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        end
    end
end)

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local UserInputService = game:GetService("UserInputService")
local teleportButton = Enum.KeyCode.F3
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local part
local dontTPOnDeath = true

if LocalPlayer.PlayerStats.Level.Value == 50 then while true do print("Level 50, Auto pres disabled") task.wait(9999999) end end

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    print("I FOUND IT")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

print("I DID FOUND IT, MAYBE IT WILL WORK?")
RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end

task.spawn(function()
    if game.Lighting:WaitForChild("DepthOfField", 10) then
        game.Lighting.DepthOfField:Destroy()
    end
end)

workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_6.Size = Vector3.new(2048, 89, 2048)
workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_4.Size = Vector3.new(2048, 89, 2048)

-- Data for prestige
local Data = { }
local File = pcall(function()
    Data = game:GetService('HttpService'):JSONDecode(readfile("AutoPres3_"..LocalPlayer.Name..".txt"))
end)

if not File and LocalPlayer.PlayerStats.Level.Value ~= 50 then
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile("AutoPres3_"..LocalPlayer.Name..".txt", game:GetService('HttpService'):JSONEncode(Data))
end

-- Webhook function
local function SendWebhook(msg)
    local url = getgenv().webhook
    local data = {
        ["embeds"] = {
            {
                ["title"] = "Xenon V3 - Auto Prestige 3",
                ["description"] = msg,
                ["type"] = "rich",
                ["color"] = tonumber(0x7269ff),
            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request or http.request
    local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
    request(abcdef)
end

SendWebhook("Loading Xenon V3 - Auto Prestige 3\nCurrent level: `"..LocalPlayer.PlayerStats.Level.Value.."`\nCurrent prestige: `"..LocalPlayer.PlayerStats.Prestige.Value.."`\nTime since start: `" .. (tick() - Data["Time"])/60 .. " minutes`")

-- Hook functions
local itemHook = hookfunction(getrawmetatable(game.Players.LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
        return 0
    end
    return itemHook(p,i)
end)

local Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local args = {...}
    local namecallmethod = getnamecallmethod()
    if namecallmethod == "InvokeServer" and args[1] == "idklolbrah2de" then
        return "  ___XP DE KEY"
    end
    return Hook(self, ...)
end))

-- Teleport function
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local function TPReturner()
    local Site
    if foundAnything == "" then
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'))
    else
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
       foundAnything = Site.nextPageCursor
    end
    local num = 0
    for _,v in pairs(Site.data) do
       local Possible = true
       ID = tostring(v.id)
       if tonumber(v.maxPlayers) > tonumber(v.playing) then
          for _,Existing in pairs(AllIDs) do
             if num ~= 0 then
                if ID == tostring(Existing) then
                   Possible = false
                end
             else
                if tonumber(actualHour) ~= tonumber(Existing) then
                   local delFile = pcall(function()
                      delfile("XenonAutoPres3ServerBlocker.json")
                      AllIDs = {}
                      table.insert(AllIDs, actualHour)
                   end)
                end
             end
             num = num + 1
          end
          if Possible then
             table.insert(AllIDs, ID)
             task.wait()
             pcall(function()
                writefile("XenonAutoPres3ServerBlocker.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                task.wait()
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
             end)
             task.wait(1)
          end
       end
    end
end

local function Teleport()
    while task.wait() do
       pcall(function()
          if getgenv().lessPing then
             game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
             game:GetService("TeleportService").TeleportInitFailed:Connect(function()
                game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
             end)
             repeat task.wait() until game.JobId ~= game.JobId
          end
          TPReturner()
          if foundAnything ~= "" then
             TPReturner()
          end
       end)
    end
end

part = Instance.new("Part")
part.Parent = workspace
part.Anchored = true
part.Size = Vector3.new(25,1,25)
part.Position = Vector3.new(500, 2000, 500)

local function onTeleportKeyPressed()
    for i = 1, 5 do
        pcall(function()
            Teleport()
            print("Телепортация выполнена!")
            wait(0.4)
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == teleportButton then
        onTeleportKeyPressed()
    end
end)

-- Vampire distribution system using local storage
local function getVampireAssignments()
    local assignments = {}
    if isfile("vampire_assignments.json") then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("vampire_assignments.json"))
        end)
        if success then
            assignments = result
        end
    end
    return assignments
end

local function saveVampireAssignments(assignments)
    if writefile then
        writefile("vampire_assignments.json", game:GetService("HttpService"):JSONEncode(assignments))
    end
end

local function assignVampire()
    local assignments = getVampireAssignments()
    local vampires = {}
    for _, vampire in pairs(workspace.Living:GetChildren()) do
        if vampire.Name == "Vampire" and vampire:FindFirstChild("Humanoid") and vampire.Humanoid.Health > 0 then
            table.insert(vampires, vampire)
        end
    end
    
    -- Clean up assignments for dead vampires or old sessions
    for playerName, vampireNum in pairs(assignments) do
        if not vampires[vampireNum] or not game.Players:FindFirstChild(playerName) then
            assignments[playerName] = nil
        end
    end
    
    -- Assign a unique vampire
    for i, vampire in ipairs(vampires) do
        if not table.find(assignments, i) then
            assignments[LocalPlayer.Name] = i
            saveVampireAssignments(assignments)
            return vampire
        end
    end
    
    return nil -- No available vampires
end

-- Stand farming functions
local function findItem(itemName)
    local ItemsDict = {["Position"] = {}, ["ProximityPrompt"] = {}, ["Items"] = {}}
    for _,item in pairs(game:GetService("Workspace")["Item_Spawns"].Items:GetChildren()) do
        if item:FindFirstChild("MeshPart") and item.ProximityPrompt.ObjectText == itemName then
            if item.ProximityPrompt.MaxActivationDistance == 8 then
                table.insert(ItemsDict["Items"], item.ProximityPrompt.ObjectText)
                table.insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            end
        end
    end
    return ItemsDict
end

local function UseRoka()
    local Player = game.Players.LocalPlayer
    if not Player.Backpack:FindFirstChild("Rokakaka") or Player.PlayerStats.Stand.Value == "None" then return end
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if not Character:FindFirstChild("Rokakaka") then
        Character:FindFirstChildWhichIsA("Humanoid"):EquipTool(Player.Backpack:FindFirstChild("Rokakaka"))
    end
    task.wait(0.5)
    VirtualInputManager:SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2, 0, true, nil, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2, 0, false, nil, 1)
    repeat game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 8, 0, true, nil, 1) task.wait(0.5) until Player.PlayerGui:FindFirstChild("DialogueGui")
    if Player.PlayerGui:FindFirstChild("DialogueGui") then
        repeat game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 8, 0, true, nil, 1) task.wait(0.5) until Player.PlayerGui.DialogueGui.Frame.Options:FindFirstChild("Option1")
        local EatOption = Player.PlayerGui.DialogueGui.Frame.Options:FindFirstChild("Option1")
        repeat task.wait(0.5) until EatOption and EatOption.Visible
        firesignal(EatOption.TextButton.MouseButton1Click)
        repeat task.wait(0.5) until not Player.PlayerGui.DialogueGui.Frame.Parent
    end
end

local function countItems(itemName)
    local itemAmount = 0
    for _,item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then itemAmount = itemAmount + 1 end
    end
    return itemAmount
end

local function useItem(aItem, amount)
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)
    if not item then Teleport() end
    if amount then
        task.wait(3)
        LocalPlayer.Character.Humanoid:EquipTool(item)
        LocalPlayer.Character:WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Worthiness " .. amount, ["SkillTreeType"] = "Character"})
        repeat item:Activate() task.wait(0.5) until LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
        repeat 
            task.wait(0.25)
            if LocalPlayer.PlayerGui.DialogueGui.Frame:FindFirstChild("ClickContinue") then
                VirtualInputManager:SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2, 0, true, nil, 1)
                task.wait(0.25)
                VirtualInputManager:SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2, 0, false, nil, 1)
                break
            end
        until false
        firesignal(LocalPlayer.PlayerGui.DialogueGui.Frame.Options:WaitForChild("Option1").TextButton.MouseButton1Click)
        repeat task.wait(0.5) until LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.DialogueFrame.Frame.Line001.Container.Group001.Text == "You"
        task.wait(0.5)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
    end
end

local function attemptStandFarm()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    if LocalPlayer.PlayerStats.Stand.Value == "None" then
        useItem("Mysterious Arrow", "II")
        repeat task.wait(0.5) until LocalPlayer.PlayerStats.Stand.Value ~= "None"
        if not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            UseRoka()
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            SendWebhook("Got `".. LocalPlayer.PlayerStats.Stand.Value .. "` stand")
            dontTPOnDeath = true
            Teleport()
        end
    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        UseRoka()
    end
end

local function getitem(item, itemIndex)
    local gotItem = false
    local timeout = getgenv().waitUntilCollect + 5
    if Character:FindFirstChild("SummonedStand") and Character:FindFirstChild("SummonedStand").Value then
        RemoteFunction:InvokeServer("ToggleStand", "Toggle")
    end
    LocalPlayer.Backpack.ChildAdded:Connect(function() gotItem = true end)
    task.spawn(function()
        while not gotItem do
            task.wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item["Position"][itemIndex] - Vector3.new(0,10,0)
        end
    end)
    task.wait(getgenv().waitUntilCollect)
    task.spawn(function()
        fireproximityprompt(item["ProximityPrompt"][itemIndex])
        local screenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui",5)
        if not screenGui then return end
        local screenGuiPart = screenGui:WaitForChild("Part")
        for _, button in pairs(screenGuiPart:GetDescendants()) do
            if button:FindFirstChild("Part") and button:IsA("ImageButton") and button:WaitForChild("Part").TextColor3 == Color3.new(0, 1, 0) then
                repeat
                    firesignal(button.MouseEnter)
                    firesignal(button.MouseButton1Up)
                    firesignal(button.MouseButton1Click)
                    firesignal(button.Activated)
                    task.wait()
                until not LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            end
        end
    end)
    task.spawn(function()
        for i=timeout, 1, -1 do task.wait(1) end
        if not gotItem then gotItem = true end
    end)
    while not gotItem do task.wait() end
end

local function farmItem(itemName, amount)
    local items = findItem(itemName)
    local amountFirst = countItems(itemName) == amount
    for itemIndex, _ in pairs(items["Position"]) do
        if countItems(itemName) == amount or amountFirst then
            break
        else
            getitem(items, itemIndex)
        end
    end
    return true
end

local function endDialogue(NPC, Dialogue, Option)
    RemoteEvent:FireServer("EndDialogue", {["NPC"] = NPC, ["Dialogue"] = Dialogue, ["Option"] = Option})
end

local function storyDialogue()
    local Quest = {
        ["Storyline"] = {"#1", "#1", "#1", "#2", "#3", "#3", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#10", "#11", "#11", "#12", "#14"},
        ["Dialogue"] = {"Dialogue2", "Dialogue6", "Dialogue6", "Dialogue3", "Dialogue3", "Dialogue3", "Dialogue6", "Dialogue3", "Dialogue5", "Dialogue5", "Dialogue5", "Dialogue4", "Dialogue7", "Dialogue6", "Dialogue8", "Dialogue11", "Dialogue3", "Dialogue2"}
    }
    for counter = 1, 18, 1 do
        RemoteEvent:FireServer("EndDialogue", {["NPC"] = "Storyline".. " " .. Quest["Storyline"][counter],["Dialogue"] = Quest["Dialogue"][counter],["Option"] = "Option1"})
    end
end

local function killNPC(npcName, playerDistance, dontDestroyOnKill, extraParameters)
    local NPC = workspace.Living:WaitForChild(npcName, getgenv().NPCTimeOut)
    local beingTargeted = true
    local doneKilled = false
    local deadCheck
    if not NPC then Teleport() end

    local function setStandMorphPosition()
        pcall(function()
            if LocalPlayer.PlayerStats.Stand.Value == "None" then
                HRP.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                return
            end
            if not Character:FindFirstChild("SummonedStand").Value or not Character:FindFirstChild("StandMorph") then
                RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                return
            end
            Character.StandMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
            HRP.CFrame = Character.StandMorph.PrimaryPart.CFrame + Character.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance, 0)
            if not Character:FindFirstChild("FocusCam") then
                local FocusCam = Instance.new("ObjectValue", Character)
                FocusCam.Name = "FocusCam"
                FocusCam.Value = Character.StandMorph.PrimaryPart
            end
            if Character:FindFirstChild("FocusCam") and Character.FocusCam.Value ~= Character.StandMorph.PrimaryPart then
                Character.FocusCam.Value = Character.StandMorph.PrimaryPart
            end
        end)
    end

    local function HamonCharge()
        if not Character:FindFirstChild("Hamon") then return end
        if Character.Hamon.Value <= getgenv().HamonCharge then
            RemoteFunction:InvokeServer("AssignSkillKey", {["Type"] = "Spec",["Key"] = "Enum.KeyCode.L",["Skill"] = "Hamon Breathing"})
            Character.RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.L})
        end
    end

    local function BlockBreaker()
        if not NPC or NPC.Parent == nil then return end
        if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
            RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
        elseif NPC.Humanoid.Health <= 1 then
            task.spawn(function()
                task.wait(5)
                if NPC then RemoteFunction:InvokeServer("Attack", "m1") end
            end)
        elseif NPC.Humanoid.Health >= 1 then
            RemoteFunction:InvokeServer("Attack", "m1")
        end
    end

    deadCheck = LocalPlayer.PlayerGui.HUD.Main.DropMoney.Money.ChildAdded:Connect(function(child)
        local number = tonumber(string.match(child.Name,"%d+"))
        if number and NPC then
            doneKilled = true
            deadCheck:Disconnect()
            if not dontDestroyOnKill then NPC:Destroy() end
        end
    end)

    while beingTargeted do
        task.wait()
        if not NPC:FindFirstChild("HumanoidRootPart") then
            deadCheck:Disconnect()
            beingTargeted = false
        end
        if extraParameters then extraParameters() end
        task.spawn(setStandMorphPosition)
        task.spawn(HamonCharge)
        task.spawn(BlockBreaker)
    end
    return doneKilled
end 

local function checkPrestige(level, prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        SendWebhook("@everyone Congratulations you have prestiged!\nTook around `" ..
            (tick() - Data["Time"]) / 60 .. " minutes` or `" .. (tick() - Data["Time"]) / 3600 ..
            " hours` to go from `Prestige " .. Data["Prestige"] .. ", Level " .. Data["Level"] ..
            "`, to `Prestige " .. tostring(prestige + 1) .. ", Level 1!`")
        endDialogue("Prestige", "Dialogue2", "Option1")
        return true
    else
        return false
    end
end

local function allocateSkills()
    task.spawn(function()
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power V",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})
        if LocalPlayer.PlayerStats.Spec.Value == "Hamon (William Zeppeli)" then
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Hamon Punch IV",["SkillTreeType"] = "Spec"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Lung Capacity IV", ["SkillTreeType"] = "Spec"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Breathing Technique IV",["SkillTreeType"] = "Spec"})
        end
    end)
end

local function autoStory()
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    local lastTick = tick()
    allocateSkills()

    if LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum" or LocalPlayer.PlayerStats.Stand.Value == "Gold Experience") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        useItem("Requiem Arrow", "V")
        repeat task.wait(0.5) until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        autoStory()
    end

    if LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 then
        local function collectAndSell(toolName, amount)
            farmItem(toolName, amount)
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
            endDialogue("Merchant", "Dialogue5", "Option2")
        end
        
        if not LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            SendWebhook("Farming `Zeppeli's Hat` to purchase `Hamon`")
            task.wait(10)
            farmItem("Zeppeli's Hat", 1)
        end

        if LocalPlayer.PlayerStats.Money.Value <= 10000 then
            SendWebhook("Collecting `$10000` for `Hamon`")
            collectAndSell("Mysterious Arrow", 25)
            collectAndSell("Rokakaka", 25)
            collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end

        if LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            SendWebhook("Buying `Hamon`")
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat"))
            game.Players.LocalPlayer.Character.RemoteEvent:FireServer("PromptTriggered", game.ReplicatedStorage.NewDialogue:FindFirstChild("Lisa Lisa"))
            repeat game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1) task.wait(0.5) until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") then
                repeat game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1) task.wait(0.5) until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
                firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
                repeat firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click) task.wait(0.5) until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                    firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
                end
                repeat firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click) task.wait(0.5) until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                    firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
                end
            end
            task.wait(10)
            autoStory()
        else
            Teleport()
        end
    end
        
    while #questPanel:GetChildren() < 2 and repeatCount < 1000 do
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds` to complete a quest")
            lastTick = tick()
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        storyDialogue()
        task.wait(0.01)
        repeatCount = repeatCount + 1
    end

    if repeatCount >= 1000 then Teleport() end

    if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        SendWebhook("Killing Security Guard `" .. LocalPlayer.PlayerStats.QuestProgress.Value.."/"..LocalPlayer.PlayerStats.QuestMaxProgress.Value .."`")
        if killNPC("Security Guard", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        task.wait(5)
        farmItem("Rokakaka", 25)
        farmItem("Mysterious Arrow", 25)
        farmItem("Zeppeli's Hat", 1)
        if countItems("Mysterious Arrow") >= 25 and countItems("Rokakaka") >= 25 then
            dontTPOnDeath = false
            attemptStandFarm()
        else
            Teleport()
        end
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        SendWebhook("Killing `Leaky Eye Luca`")
        if killNPC("Leaky Eye Luca", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        SendWebhook("Killing `Bucciarati`")
        if killNPC("Bucciarati", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            SendWebhook("Collecting `$5000`")
            local function collectAndSell(toolName, amount)
                if countItems(toolName) <= amount then
                    farmItem(toolName, amount)
                    Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                    endDialogue("Merchant", "Dialogue5", "Option2")
                    storyDialogue()
                    autoStory()
                end
                if LocalPlayer.PlayerStats.Money.Value < 5000 then
                    storyDialogue()
                    autoStory()
                end
            end
            task.wait(10)
            collectAndSell("Mysterious Arrow", 25)
            collectAndSell("Rokakaka", 25)
            collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end
        autoStory()
    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        SendWebhook("Killing `Fugo`")
        if killNPC("Fugo", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif questPanel:FindFirstChild("Defeat Pesci") then
        SendWebhook("Killing `Pesci`")
        if killNPC("Pesci", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        SendWebhook("Killing `Ghiaccio`")
        if killNPC("Ghiaccio", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end
    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        SendWebhook("Killing `Diavolo`")
        killNPC("Diavolo", 15)
        endDialogue("Storyline #14", "Dialogue7", "Option1")
        if Character:WaitForChild("Requiem Arrow", 5) then
            LocalPlayer.Character.Humanoid.Health = 0
            Teleport()
        else
            autoStory()
        end
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        if Character:FindFirstChild("FocusCam") then
            Character.FocusCam:Destroy()
            SendWebhook("**Prestige 3, Level 50 reached!**\nTime: `" .. (tick() - Data["Time"])/60 .. " minutes or " .. (tick() - Data["Time"])/3600 .. " hours`\nFrom: `Prestige: ".. Data["Prestige"]  .. ", Level " .. Data["Level"] .. "`\nStand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`\nSpec: `" .. LocalPlayer.PlayerStats.Spec.Value .. "`\nAccount: `" .. LocalPlayer.Name .. "`")
            pcall(function() delfile("AutoPres3_"..LocalPlayer.Name..".txt") end)
        end
    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Spec.Value ~= "None" and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
        getgenv().HamonCharge = 10
        local assignedVampire = assignVampire()
        local function vampire()
            if assignedVampire and assignedVampire:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.PrimaryPart.CFrame = assignedVampire.HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            end
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds` to complete `Vampire Quest`")
                    lastTick = tick()
                end
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
                -- Clear assignment after quest completion
                local assignments = getVampireAssignments()
                assignments[LocalPlayer.Name] = nil
                saveVampireAssignments(assignments)
            end
        end
        if assignedVampire then
            SendWebhook("Account: `" .. LocalPlayer.Name .. "` assigned to Vampire #" .. tostring(getVampireAssignments()[LocalPlayer.Name]))
            killNPC("Vampire", 15, false, vampire)
            autoStory()
        else
            SendWebhook("No available vampires for `" .. LocalPlayer.Name .. "`, teleporting...")
            Teleport()
        end
    end
end

-- Periodic vampire assignment check
task.spawn(function()
    while task.wait(1) do
        if LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests:FindFirstChild("Take down 3 vampires") then
            local assignments = getVampireAssignments()
            if not assignments[LocalPlayer.Name] then
                assignVampire()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do wait(5)
        if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
            Teleport()
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            if not Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
                break
            end
        end
    end
end)

game.Workspace.Living.ChildAdded:Connect(function(character)
    if character.Name == LocalPlayer.Name then
        if LocalPlayer.PlayerStats.Level.Value == 50 then
            print("didnt reconnect")
        else
            if dontTPOnDeath then Teleport() else attemptStandFarm() end
        end
    end
end)

LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
    SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nNew level: `" .. LocalPlayer.PlayerStats.Level.Value .. "`\nCurrent prestige: `" .. LocalPlayer.PlayerStats.Prestige.Value .. "`")
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
    end
end)

hookfunction(workspace.Raycast, function() end) -- noclip bypass

autoStory()
