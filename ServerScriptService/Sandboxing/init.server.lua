--[[
	This Sandboxing script is still work in progress. This is a test script which will sandbox every community scripts.
]]--
local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);

--== Modules;
local Sandbox = require(script.Sandbox);

--== Variables;
local MapTemplateModule = game.ServerStorage.Community.Template;

--== Script;
Debugger:Log("Initializing Sandbox for Template");
Sandbox:RunModule("MapEnvironment", MapTemplateModule);