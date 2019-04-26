return function(scrString, scrContainer)
	local DebuggerModule = require(game.ReplicatedStorage.Library.Debugger);
	local SandboxModule = require(script.Parent.Sandbox);
	local Debugger = DebuggerModule.new(script.Name);
	local EnvMeta = {__metatable="The mapping environment is locked.";};
	local MapMeta = {__metatable="The map metatable is locked.";};
	local Env = setmetatable({}, EnvMeta);

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
	
	--== Map Headers;
	MapMeta.GetFolder = nil;
	MapMeta.Configurations = require(library.Configurations);
	MapMeta.Library = {};
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

	end

	MapMeta.LoadAudio = function(self, container)
		for _, c in pairs(container) do c.Parent = library.Audio; end;
	end

	--== Sandbox;
	local mapYielded = false;
	delay(5, function() if not mapYielded then error("Map script loading timed out."); end end);
	local Map = nil;
	local success, err = pcall(function()
		Map = setfenv(loadstring(scrString), Env)()
	end);
	if Map and Map.MapId then
		setmetatable(Map, MapMeta);
	end
	if not success then
		error("MapEnvironment>>  Failed to run source.");
	end
	mapYielded = true;
	return Map;
end