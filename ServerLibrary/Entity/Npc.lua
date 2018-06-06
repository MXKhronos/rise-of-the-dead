local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local module = {};

local modNpcModules = {}; for _, npcMod in pairs(game.ServerScriptService.ServerLibrary.Entity.Npc:GetChildren()) do if npcMod:IsA("ModuleScript") then modNpcModules[npcMod.Name] = require(npcMod) end end;
local modNpcAnimator = require(game.ServerScriptService.ServerLibrary.Entity.NpcAnimator);
local modPrefabManager = require(game.ServerScriptService.ServerLibrary.PrefabManager);

local remotes = game.ReplicatedStorage.Remotes;
local remoteLoadAppearance = remotes.NonPlayerCharacter.LoadNpcAppearance;

local replicatedPrefabs = game.ReplicatedStorage.Prefabs;
local npcPrefabs = game.ServerStorage.PrefabStorage.Npc;
local animationLibrary = game.ServerStorage.PrefabStorage.Animations;

local skeletonCache = {};
function GetNpcSkeleton(name)
	if skeletonCache[name] then return skeletonCache[name] end;
	
	if npcPrefabs:FindFirstChild(name) == nil then error("Npc prefab: "..name.." does not exist."); end;
	local newSkeleton = npcPrefabs[name]:Clone();
	local skeletonObjects = newSkeleton:GetChildren();
	local skeletonPartNames = {HumanoidRootPart=true; Head=true; UpperTorso=true; LowerTorso=true;};
	local objectChildrenToKeep = {Neck=true; Waist=true; Root=true;};
	
	for a=1, #skeletonObjects do
		if skeletonPartNames[skeletonObjects[a].Name] then
			local objectChildrens = skeletonObjects[a]:GetChildren();
			for b=1, #objectChildrens do
				if not objectChildrens[b]:IsA("Motor6D") then
					objectChildrens[b]:Destroy();
				end
			end
		elseif skeletonObjects[a]:IsA("Humanoid") then
			skeletonObjects[a]:ClearAllChildren();
		else
			skeletonObjects[a]:Destroy();
		end
	end
	
	skeletonCache[name] = newSkeleton;
	return newSkeleton;
end

function Spawn(name, cframe, preloadCallback)
	if npcPrefabs:FindFirstChild(name) == nil then error("Npc prefab: "..name.." does not exist."); end;
	local npc = GetNpcSkeleton(name):Clone();
	local rootPart = npc:WaitForChild("HumanoidRootPart");
	if cframe then rootPart.CFrame = cframe end;
	
	local npcModule = modNpcModules[name](npc, cframe);
	if preloadCallback then preloadCallback(npc, npcModule) end;
	npc.Parent = workspace.Entity;
	if rootPart:CanSetNetworkOwnership() then rootPart:SetNetworkOwner(nil); end

	if animationLibrary:FindFirstChild(name) then
		if npcModule then modNpcAnimator(npcModule, name); end;
	else
		error("Animation library: "..name.." does not exist.");
	end;
	
	local npcPrefab = replicatedPrefabs.Npc:FindFirstChild(name) or modPrefabManager:LoadPrefab(npcPrefabs[name], replicatedPrefabs.Npc);
	if #game.Players:GetPlayers() > 0 then
		remoteLoadAppearance:FireAllClients(npc, npcPrefab);
	end
	return npc;
end

module.GetNpcSkeleton = GetNpcSkeleton;
module.Spawn = Spawn;
return module;

--	if animationLibrary:FindFirstChild(name) == nil then error("Animation library: "..name.." does not exist."); end;
--	local findLoadedAnimation = game.ReplicatedStorage.AnimationLibrary:FindFirstChild(name);
--	local AnimationPrefab = findLoadedAnimation or modPrefabManager:LoadPrefab(animationLibrary[name], game.ReplicatedStorage.AnimationLibrary);