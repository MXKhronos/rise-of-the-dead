return function(module)
	local DebuggerModule = require(game.ReplicatedStorage.Library.Debugger);
	local Debugger = DebuggerModule.new(script.Name);
	local Global = getfenv(0);
	local EnvMeta = {__metatable={};};
	local Env = setmetatable({}, EnvMeta);

	local library = game.ReplicatedStorage.Library;
	local serverLibrary = game.ServerScriptService.ServerLibrary;

	local function ___debugEnv()
		print("Debug ENV:");
		for k, v in pairs(getfenv()) do print(k,"=",v); end;
		print("End Debug ENV:");
	end

	--== Meta;
	EnvMeta.Debugger = Debugger;
	EnvMeta.pcall = Global.pcall;
	EnvMeta.Library = {};

	EnvMeta.error = function(err)
		error("Map>>  "..err);
	end;
	
	EnvMeta.require = function(module)
		local mod = nil;
		if type(module) == "userdata" and module.ClassName == "ModuleScript" then
			local yielded = false;
			delay(5, function() if not yielded then error("Timed-out when requiring ModuleScript ("..module.Name..")."); end end);
			local _require = require;
			local modRequireSuccess, modRequireError = pcall(function()
				mod = setfenv(_require, Env)(module);
			end)
			if modRequireSuccess then
				Debugger = DebuggerModule.new(Map.MapId);
				setmetatable(mod, Env);
			else 
				error("Error while loading ModuleScript ("..module.Name..")>>  "..modRequireError);
			end
			yielded = true;
			return mod;
		end
	end

	EnvMeta.__index = function(t, k)
		Debugger:Log("MapEnv indexing "..k);
		return EnvMeta[k];
	end

	EnvMeta.__newindex = function(t, k, v)
		Debugger:Log("MapEnv new indexing "..k.." = "..v);
		Env[k] = v;
	end

	local MapMeta = {};
	local Map = Env.require(module);
	if Map and Map.MapId then
		setmetatable(Map, MapMeta);
	end
end