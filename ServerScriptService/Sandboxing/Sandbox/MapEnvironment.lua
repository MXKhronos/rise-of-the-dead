return function(scrString)
	local DebuggerModule = require(game.ReplicatedStorage.Library.Debugger);
	local Debugger = DebuggerModule.new(script.Name);
	local EnvMeta = {__metatable="The mapping environment metatable is locked.";};
	local Env = setmetatable({}, EnvMeta);

	local library = game.ReplicatedStorage.Library;
	local serverLibrary = game.ServerScriptService.ServerLibrary;

	--== Meta;
	--== Meta Globals;
	EnvMeta.Debugger = Debugger;
	EnvMeta.Library = {};
	EnvMeta.delay = delay;
	EnvMeta.Random = Random;

	--== Meta Functions;
	EnvMeta.error = function(err)
		error("Map>>  "..err);
	end;

	EnvMeta.require = function(module)
		
	end

	EnvMeta.__index = function(t, k)
		Debugger:Log("MapEnv indexing "..k);
		return EnvMeta[k];
	end

	EnvMeta.__newindex = function(t, k, v)
		Debugger:Log("MapEnv new indexing "..k.." = "..v);
		Env[k] = v;
	end
	

	local mapYielded = false;
	delay(5, function() if not mapYielded then error("Map script loading timed out."); end end);

	local MapMeta = {__metatable="The map metatable is locked.";};
	local Map = setfenv(loadstring(scrString), Env)();
	if Map and Map.MapId then
		setmetatable(Map, MapMeta);
		EnvMeta.Debugger = DebuggerModule.new(Map.MapId);
	end

	mapYielded = true;
	return Map;
end