local InstanceFolder = require(script.Folder);
local InstancePlayer = require(script.Player);

return function(scrString, scrContainer)
	local DebuggerModule = require(game.ReplicatedStorage.Library.Debugger);
	local Debugger = DebuggerModule.new(script.Name);
	local EnvMeta = {__metatable="The mapping environment is locked.";};
	local MapMeta = {__metatable="The map metatable is locked.";};
	local Env = setmetatable({}, EnvMeta);
	local Map = setmetatable({}, MapMeta);

	local library = game.ReplicatedStorage.Library;
	local serverLibrary = game.ServerScriptService.ServerLibrary;

	--== Modules;
	
	--== Global Headers;
	EnvMeta.delay = delay;
	EnvMeta.Random = Random;
	EnvMeta.print = print;
	EnvMeta.error = error;
	EnvMeta.__index = EnvMeta;
	EnvMeta.__newindex = EnvMeta;
	EnvMeta.Debugger = Debugger;
	EnvMeta.Map = Map;
	
	--== Map Headers;
	MapMeta.__index = MapMeta;
	MapMeta.Players = {};
	MapMeta.GetFolder = nil;
	MapMeta.Configurations = require(library.Configurations);
	MapMeta.Library = {};
	MapMeta.OnPlayerConnect = (function() end);
	MapMeta.LoadAudio = nil;

	--== Global Sources;
	EnvMeta.print = function(...)
		print("Map>>  "..(...));
	end

	EnvMeta.error = function(s)
		error("Map>>  "..s);
	end

	EnvMeta.__index = function(t, k)
		Debugger:Log("MapEnv indexing "..k);
		return EnvMeta[k];
	end

	EnvMeta.__newindex = function(t, k, v)
		Debugger:Log("MapEnv new indexing "..k.." = "..v);
		Env[k] = v;
	end

	--== Map Sources;
	MapMeta.GetFolder = function(self, folderName)
		if scrContainer == nil then Debugger:Warn("Source Container does not exist.") end;
		local folder = scrContainer:FindFirstChild(folderName);
		if folder then
			return InstanceFolder(folder);
		end
	end

	MapMeta.LoadAudio = function(self, container)
		for _, c in pairs(container) do c.Parent = library.Audio; end;
	end

	--== Sandbox;
	local mapYielded = false;
	delay(5, function() if not mapYielded then error("Map script loading timed out."); end end);
	local success, err = pcall(setfenv(loadstring(scrString), Env));
	if success then
		local function OnPlayerAdded(player)
			MapMeta.Players[player.Name] = InstancePlayer(player);
			return MapMeta.Players[player.Name];
		end
		--== Connections;
		for _, player in pairs(game.Players:GetPlayers()) do OnPlayerAdded(player) end;
		game.Players.PlayerAdded:Connect(OnPlayerAdded);
	else
		warn("MapEnvironment>>  Failed Error: "..err);
	end
	mapYielded = true;
	return Map;
end