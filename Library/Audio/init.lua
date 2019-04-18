-- Debug function;
local enableDebug = true; local funcPrint = print; local funcString = tostring; local debugTag = script.Name; function DebugPrint(text) if enableDebug then funcPrint(debugTag..">> "..funcString(text)) end; end;
-- Settings;

-- Variables;
local RunService = game:GetService("RunService");
local SoundService = game:GetService("SoundService");
local localPlayer = game.Players.LocalPlayer;
local remotePlayAudio = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayAudio");

local soundFiles = script:GetChildren();

local Library = {};
-- Script;
for key, data in pairs(require(game.ReplicatedStorage.Library.Weapons)) do
	for soundType, audioProperties in pairs(data.Audio) do
		local audioId = audioProperties.Id;
		local soundFile = script:FindFirstChild(audioId);
		if soundFile then
			Library[audioId] = soundFile;
		else
			if Library[audioId] == nil then
				soundFile = Instance.new("Sound", script);
				soundFile.Name = audioId;
				soundFile.SoundId = "rbxassetid://"..audioId;
				soundFile.PlaybackSpeed = audioProperties.Pitch;
				soundFile.RollOffMode = Enum.RollOffMode.Linear;
				soundFile.EmitterSize = 5;
				if soundType == "PrimaryFire" then
					soundFile.MaxDistance = 128;
				elseif soundType == "Empty" then
					soundFile.MaxDistance = 16;
				else
					soundFile.MaxDistance = 32;
				end
				soundFile.SoundGroup = game.SoundService.WeaponEffects;
				soundFile.Volume = audioProperties.Volume ~= nil and audioProperties.Volume or 0.5;
				Library[audioId] = soundFile;
			end
		end
	end
end
for a=1, #soundFiles do
	if soundFiles[a]:IsA("Sound") then
		Library[soundFiles[a].Name] = soundFiles[a];
	end
end

function Get(id)
	local audioInstance = Library[id];
	if audioInstance ~= nil then
		return audioInstance;
	end
end

function Play(id, parent, looped)
	if id == nil then return end;
	local audioInstance = Library[id];
	if audioInstance ~= nil then
		if parent == nil then
			if RunService:IsClient() then
				SoundService:PlayLocalSound(audioInstance);
			else
				--PlayReplicated(id, parent);
			end
			return audioInstance;
		else
			local newSound = audioInstance:Clone();
			newSound.Parent = parent;
			if looped ~= nil and looped then newSound.Looped = true; end
			newSound:Play();
			newSound.Ended:Connect(function() wait(); newSound:Destroy() end);
			return newSound;
		end
	else
		warn("Audio missing (",id,").");
	end
end

function PlayReplicated(id, parent, looped)
	if RunService:IsServer() then error("Audio>>  Failed to play audio from server. Use Play() instead.") return end;
	local audioInstance = Library[id];
	if audioInstance ~= nil then
		if parent == nil then
			SoundService:PlayLocalSound(audioInstance);
			remotePlayAudio:FireServer(audioInstance);
			return audioInstance;
		else
			local newSound = audioInstance:Clone();
			newSound.Parent = parent;
			if looped ~= nil and looped then newSound.Looped = true; end
			newSound:Play();
			remotePlayAudio:FireServer(audioInstance, parent);
			newSound.Ended:Connect(function() wait(); newSound:Destroy() end);
			return newSound;
		end
	end
end

script.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then 
		warn("Importing new audio file(",child,").");
		child.Parent = script;
		Library[child.Name] = child;
	end
end)

return {
	Play = Play;
	PlayReplicated = PlayReplicated;
	Get = Get;
};