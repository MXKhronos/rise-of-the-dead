local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);

--== Variables;
local Sandbox = {};

--== Script;
function Sandbox:RunString(environmentName, str, source)
	local environment = script:FindFirstChild(environmentName) and require(script[environmentName]) or nil;
	if environment then
		return environment(str, source);
	else
		error("Sandbox>>  Failed to run string in environment called "..environmentName);
	end
end

return Sandbox;