--[[
	This Sandboxing script is still work in progress. This is a test script which will sandbox every community scripts.
]]--
local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);

--== Modules;
local SandboxService = require(script.SandboxService);

--== Variables;
local MapTemplateSource = game.ServerStorage.Community.Template_Script;

--== Script;
Debugger:Log("Initializing SandboxService");
SandboxService:RunString("MapEnvironment", MapTemplateSource.Value);