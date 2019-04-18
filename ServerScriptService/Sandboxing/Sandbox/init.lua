local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);

--== Variables;
local Sandbox = {};

--== Script;
function Sandbox:RunModule(environmentName, module)
	local environment = script:FindFirstChild(environmentName) and require(script[environmentName]) or nil;
	if environment then
		return environment(module);
	else
		error("Sandbox>>  Failed to run module "..module.Name.." in environment called "..environmentName);
	end
end

return Sandbox;