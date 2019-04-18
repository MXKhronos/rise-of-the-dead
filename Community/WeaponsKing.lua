local Map = {};
local random = Random.new();
local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local modProfile = require(game.ServerScriptService:WaitForChild("ServerLibrary"):WaitForChild("Profile"));
local modCommunityProfile = require(game.ServerScriptService:WaitForChild("ServerLibrary"):WaitForChild("CommunityProfile")); modCommunityProfile.Map = Map;
local modStorage = require(game.ServerScriptService:WaitForChild("ServerLibrary"):WaitForChild("Storage"));
local modTagging = require(game.ServerScriptService.ServerLibrary.Tagging);
local modConfigurations = require(game.ReplicatedStorage.Library.Configurations);
local modAudio = require(game.ReplicatedStorage.Library.Audio);

local remotes = game.ReplicatedStorage:WaitForChild("Remotes");
local bindNotifyPlayer = remotes.Chat.NotifyPlayer;
local bindServerEquipPlayer = remotes.Inventory.ServerEquipPlayer;
local bindServerUnequipPlayer = remotes.Inventory.ServerUnequipPlayer;

local remoteUpdateScoreboard = Instance.new("RemoteEvent");
remoteUpdateScoreboard.Name = "UpdateCustomScoreboard";
remoteUpdateScoreboard.Parent = remotes;

local remoteEndRound = Instance.new("RemoteEvent");
remoteEndRound.Name = "ToggleEndRound";
remoteEndRound.Parent = remotes;

local remoteNewDeathnotice = Instance.new("RemoteEvent");
remoteNewDeathnotice.Name = "NewDeathnotice";
remoteNewDeathnotice.Parent = remotes;

local timerTickTag = Instance.new("IntValue");
timerTickTag.Name = "TimerTick";
timerTickTag.Parent = game.ReplicatedStorage;

local mapGui = script:WaitForChild("MapGui");

local roundLength = 600;
local roundEndLength = 15;
local RoundEndEnum = {TimesUp=1; Winner=2;};
local roundInProgress = false;

local weaponsList = {"AK-47"; "M4A4"; "MP7"; "MP5"; "Sawed-Off"; "XM1014"; "Desert Eagle"; "Tec-9"; "Dual P250"; "CZ75-Auto"; "P250"; "AWP"; "Minigun"; "Grenade Launcher"; "Revolver 454"};
local killPerWeapon = 2;

local MapServerStorage, maps, currentMap;
local ambientPart;
local roundThread;
--==
Map.MapId = "WeaponsKing";
modConfigurations.Set("DisableExperienceGain", true);
modConfigurations.Set("AutoSpawning", false);
modConfigurations.Set("RemoveForceFieldOnWeaponFire", true);

game.ServerScriptService.ServerScripts.ServerReplicatorScript.UpdateTargetableEntities:Fire({["Humanoid"]=1; ["Zombie"]=1.5;});
for _, child in pairs(script.Audio:GetChildren()) do child.Parent = game.ReplicatedStorage.Library.Audio; end;

local MatchReady = false;
local PlayerData = {};
local ActiveSpawns = {};

function compressData()
	local compressedData = {};
	for name, values in pairs(PlayerData) do
		local winsCount = values.SaveData and values.SaveData.Save and values.SaveData.Save.Wins;
		table.insert(compressedData, {Player=values.Player; Wins=winsCount; K=values.Round.Kills; D=values.Round.Deaths; W=values.Round.Weapon; L=values.Round.ArmsList; EG=values.Round.KillsRequired});
	end
	table.sort(compressedData, function(A, B) return (A.K or 0)> (B.K or 0); end);
	return compressedData;
end

function updateLeaderboard()
	remoteUpdateScoreboard:FireAllClients(compressData());
end

function pickMap()
	MapServerStorage = game.ServerStorage:WaitForChild("MapServerStorage");
	maps = MapServerStorage:GetChildren();
	local chosenMap;
	repeat
		chosenMap = maps[math.random(1, #maps)].Name;
	until chosenMap ~= currentMap or not wait();
	currentMap = chosenMap;
	return currentMap;
end

local function newRound()
	local tempList = {};
	local armsList = {};
	for a=1, #weaponsList do table.insert(tempList, weaponsList[a]); end;
	for a=1, #tempList do table.insert(tempList, 1, table.remove(tempList, math.random(a, #tempList))) end;
	for a=1, 15 do table.insert(armsList, tempList[a]) end;
	return {Kills=0; Deaths=0; WeaponIndex=1; Weapon=armsList[1]; ArmsList=armsList; KillsRequired=killPerWeapon; Streak=0;};
end

function Map.OnPlayerConnect(player)
	local saveData = {};
	local playerName = player.Name;
	PlayerData[playerName] = {Player=player; SaveData=saveData; Round=newRound();};
	
	--== Load Save
	local Saved = modCommunityProfile:GetPlayerData(player);
	if Saved then
		saveData.Save = Saved;
	end
	
	saveData.Inventory = modStorage.new("Inventory", 1, player);
	modCommunityProfile:SetSaveData(player, saveData);
	mapGui:Clone().Parent = player.PlayerGui;
	
	if roundInProgress then
		saveData.Inventory:Add(PlayerData[playerName].Round.Weapon);
	end
	
	if player.Name == "MXKhronos" or player.UserId < 0 then
		player.Chatted:connect(function(msg)
			if msg:lower() == "/endround" then
				coroutine.resume(roundThread);
			elseif msg:lower() == "/nextweapon" then
				if PlayerData[playerName].Round and PlayerData[playerName].Round.Kills then
					local playerData = PlayerData[playerName];
					playerData.Round.KillsRequired = playerData.Round.KillsRequired -killPerWeapon;
					
					if playerData.Round.KillsRequired <= 0 then
						playerData.Round.KillsRequired = killPerWeapon;
						playerData.Round.WeaponIndex = playerData.Round.WeaponIndex +1;
						if playerData.Round.WeaponIndex ~= #playerData.Round.ArmsList then
							PlayerData[playerName].Round.Weapon = playerData.Round.ArmsList[playerData.Round.WeaponIndex];
							bindServerUnequipPlayer:Invoke(PlayerData[playerName].Player);
							PlayerData[playerName].SaveData.Inventory:Wipe();
							PlayerData[playerName].SaveData.Inventory:Add(PlayerData[playerName].Round.Weapon, nil, function(event, item)
								if event == "Success" then
									PlayerData[playerName].SaveData.Inventory:Sync();
									bindServerEquipPlayer:Invoke(PlayerData[playerName].Player, item.ID);
								end
							end);
						else
							coroutine.resume(roundThread);
						end
					end
				end
			end
		end)
	end
	
	local function spawnCharacter()
		if not roundInProgress then repeat until roundInProgress or not wait(0.1); end
		player:LoadCharacter();
	end
	
	player.CharacterAdded:Connect(function(character)
		modCommunityProfile:SetSaveData(player, saveData);
		updateLeaderboard();
		local humanoid = character:WaitForChild("Humanoid");
		coroutine.wrap(function()
			if #ActiveSpawns > 0 then
				humanoid.RootPart.CFrame = ActiveSpawns[random:NextInteger(1, #ActiveSpawns)];
			end
		end)();
		runConnection = humanoid.Running:Connect(function(s)
			local ff = character:FindFirstChildWhichIsA("ForceField");
			if s > 0 and ff then
				ff:Destroy();
				runConnection:Disconnect();
			elseif ff == nil then
				runConnection:Disconnect();
			end
		end);
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff;
		humanoid.Died:Connect(function()
			delay(2.5, function() spawnCharacter(); end);
			local tagsList = modTagging.Tagged[character];
			if tagsList and #tagsList > 0 then
				local tagData = tagsList[#tagsList];
				if tagData ~= nil and tagData.Tagger.Parent ~= nil and game.Players:GetPlayerFromCharacter(tagData.Tagger) then
					local killerPlayer = game.Players:GetPlayerFromCharacter(tagData.Tagger);
					local killerName = killerPlayer.Name;
					local killerData = PlayerData[killerName];
					if PlayerData[playerName].Round.Streak >= 5 then
						bindNotifyPlayer:Fire(game.Players, killerName.." terminated "..playerName.."'s "..PlayerData[playerName].Round.Streak.." streak!", "Inform");
					end
					if killerData.Round and killerData.Round.Kills then
						killerData.Round.Kills = killerData.Round.Kills +1;
						killerData.Round.KillsRequired = killerData.Round.KillsRequired -1;
						killerData.Round.Streak = killerData.Round.Streak +1;
						if killerData.Round.Streak == 2 then
							bindNotifyPlayer:Fire(game.Players, killerName.." got a double kill!", "Tier2");
						elseif killerData.Round.Streak == 3 then
							bindNotifyPlayer:Fire(game.Players, killerName.." got a triple kill!", "Tier3");
						elseif killerData.Round.Streak == 4 then
							bindNotifyPlayer:Fire(game.Players, killerName.." got a quad kill!", "Tier4");
						elseif killerData.Round.Streak >= 5 and killerData.Round.Streak <= 9 then
							bindNotifyPlayer:Fire(game.Players, killerName.." killed "..killerData.Round.Streak.." in a row!", "Tier5");
						elseif killerData.Round.Streak >= 10 then
							bindNotifyPlayer:Fire(game.Players, killerName.." is dominating with "..killerData.Round.Streak.." kills in a row!", "Tier6");
						end
						
						remoteNewDeathnotice:FireAllClients(playerName, killerName, killerData.Round.Weapon, tagData.Headshot);
						
						if killerData.Round.KillsRequired <= 0 then
							killerData.Round.KillsRequired = killPerWeapon;
							killerData.Round.WeaponIndex = killerData.Round.WeaponIndex +1;
							if killerData.Round.WeaponIndex ~= #killerData.Round.ArmsList then
								PlayerData[killerName].Round.Weapon = killerData.Round.ArmsList[killerData.Round.WeaponIndex];
								--bindServerUnequipPlayer:Invoke(PlayerData[killerName].Player);
								PlayerData[killerName].SaveData.Inventory:Wipe();
								PlayerData[killerName].SaveData.Inventory:Add(PlayerData[killerName].Round.Weapon, nil, function(event, item)
									if event == "Success" then
										PlayerData[killerName].SaveData.Inventory:Sync();
										bindServerEquipPlayer:Invoke(PlayerData[killerName].Player, item.ID);
									end
								end);
							else
								-- End Round;
								coroutine.resume(roundThread);
							end
						end
					end
				end
			end
			if PlayerData[playerName].Round and PlayerData[playerName].Round.Deaths then
				PlayerData[playerName].Round.Deaths = PlayerData[playerName].Round.Deaths +1;
				PlayerData[playerName].Round.Streak = 0;
			end
			local weaponId = saveData.Inventory:FindByName(PlayerData[playerName].Round.Weapon);
			if weaponId then
				saveData.Inventory:DeleteValues(weaponId.ID, {"A"; "MA"});
				saveData.Inventory:Sync();
			end
			updateLeaderboard();
		end);
		local weaponId = saveData.Inventory:FindByName(PlayerData[playerName].Round.Weapon);
		if weaponId then
			workspace:WaitForChild(playerName):WaitForChild("EquipmentScript");
			wait();
			bindServerEquipPlayer:Invoke(player, weaponId.ID);
		else
			warn("Map>> weapon(",PlayerData[playerName].Round.Weapon,") does not exist in inventory.");
		end
	end)
	
	if roundInProgress then spawnCharacter(); end
end

function Map.OnPlayerDisconnect(player)
	local playerName = player.Name;
	if PlayerData[playerName] then
		wait(2);
		PlayerData[playerName] = nil;
	end
	updateLeaderboard();
end

local function switchMap(name)
	local map = MapServerStorage:FindFirstChild(name);
	if workspace:FindFirstChild("Environment") then workspace.Environment:ClearAllChildren() end;
	if workspace:FindFirstChild("PlayerClips") then workspace.PlayerClips:ClearAllChildren() end;
	if workspace:FindFirstChild("Spawners") then workspace.Spawners:ClearAllChildren(); end;
	if workspace:FindFirstChild("Entity") then workspace.Entity:ClearAllChildren(); end;
	if workspace:FindFirstChild("Characters") then workspace.Characters:ClearAllChildren() end;
	
	for p, player in pairs(game.Players:GetPlayers()) do
		if player.Character then
			player.Character:Destroy();
		end
	end
	
	local mapFolders = map:GetChildren();
	for a=1, #mapFolders do
		local dir = workspace:FindFirstChild(mapFolders[a].Name);
		if dir then
			local new = mapFolders[a]:Clone();
			coroutine.wrap(function()
				local skip = new.Name ~= "Environment";
				coroutine.wrap(function()
					wait(4)
					skip = true;
				end)()
				for _, child in pairs(new:GetChildren()) do
					child.Parent = dir;
					if not skip then wait(); end;
				end
			end)()
		end
	end
	
	ambientPart = workspace.Environment:WaitForChild("AmbientPart");
	
	modAudio.Play("WindAmbient1", ambientPart, true);
	
	local playerClips = workspace:FindFirstChild("PlayerClips");
	if playerClips then
		ActiveSpawns = {};
		local spawnLocations = playerClips:GetChildren();
		for _, part in pairs(spawnLocations) do
			if part:IsA("SpawnLocation") then
				table.insert(ActiveSpawns, part.CFrame*CFrame.new(0, 3.5, 0));
			end
		end
	end
end

function Map.Initialize()
	spawn(function()
		while wait(random:NextNumber(6, 14)) do
			if ambientPart then
				modAudio.Play("FarThunder"..random:NextInteger(1, 2), ambientPart);
			end
			spawn(function()
				wait(random:NextNumber(0.2, 0.4));
				game.Lighting.OutdoorAmbient = Color3.fromRGB(61, 68, 91);
				wait(0.05);
				game.Lighting.OutdoorAmbient = Color3.fromRGB(7, 9, 12);
				wait(random:NextNumber(0.05, 0.1));
				game.Lighting.OutdoorAmbient = Color3.fromRGB(61, 68, 91);
				wait(0.05);
				game.Lighting.OutdoorAmbient = Color3.fromRGB(7, 9, 12);
				if random:NextInteger(1, 2) == 1 then
					wait(random:NextNumber(0.05, 0.1));
					game.Lighting.OutdoorAmbient = Color3.fromRGB(61, 68, 91);
					wait(0.05);
					game.Lighting.OutdoorAmbient = Color3.fromRGB(7, 9, 12);
				end
			end)
		end
	end)

	pickMap();
	switchMap(currentMap);
	wait(5);
 	while true do
		roundThread = coroutine.running();
		roundInProgress = true;
		for playerName, playerData in pairs(PlayerData) do
			PlayerData[playerName].Round = newRound();
			if playerData.Player:IsDescendantOf(game.Players) and playerData.SaveData and playerData.SaveData.Inventory then
				playerData.SaveData.Inventory:Add(PlayerData[playerName].Round.Weapon, nil, function(event, item)
					if event == "Success" then
						playerData.SaveData.Inventory:Sync();
					end
				end);
			end
		end
		wait(1);
		remoteEndRound:FireAllClients(false);
		for playerName, playerData in pairs(PlayerData) do
			playerData.Player:LoadCharacter();
		end
		updateLeaderboard();
		timerTickTag.Value = os.time()+roundLength;
		local delayCancelled = false;
		delay(roundLength, function() if not delayCancelled then coroutine.resume(roundThread, RoundEndEnum.TimesUp); end end);
		coroutine.yield();
		delayCancelled = true;
		roundInProgress = false;
		local leaderboard = compressData();
		remoteEndRound:FireAllClients(true, leaderboard);
		if #leaderboard > 1 then
			local kingData = leaderboard[1];
			local kingPlayer = kingData.Player;
			if kingPlayer and PlayerData[kingPlayer.Name].SaveData then
				if PlayerData[kingPlayer.Name].SaveData.Save == nil then 
					PlayerData[kingPlayer.Name].SaveData.Save = {Wins=0;}
				end;
				local Save = PlayerData[kingPlayer.Name].SaveData.Save;
				Save.Wins = (Save.Wins or 0)+1;
				local profile = modProfile:Get(kingPlayer);
				if profile and profile.Cosmetics and profile.Cosmetics.AddAccessory then
					profile.Cosmetics.AddAccessory("HeadGroup", "Weapons King");
				end
			end
		end
		timerTickTag.Value = os.time()+roundEndLength;
		for playerName,_ in pairs(PlayerData) do
			if PlayerData[playerName].Player ~= nil then
				bindServerUnequipPlayer:Invoke(PlayerData[playerName].Player);
				if PlayerData[playerName].SaveData and PlayerData[playerName].SaveData.Inventory then
					PlayerData[playerName].SaveData.Inventory:Wipe();
					PlayerData[playerName].SaveData.Inventory:Sync();
				end
			end
		end
		wait(roundEndLength-6);
		pickMap();
		switchMap(currentMap);
		wait(5);
	end
end

return Map;