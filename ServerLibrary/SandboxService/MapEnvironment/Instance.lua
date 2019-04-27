local Instance = {};

local global = {};
local index = 0;

function Instance.new(className, object)
	index = index +1;
	local instance;
	instance = setmetatable({
		Name = object.Name;
		ClassName = "Instance";
		Indentifier = tostring(index);
	}, {
		-- metamethods;
		__metatable = "This metatable is locked.";
		__index=(function(t, k)
			warn(instance.ClassName.." denied access to "..k..".");
		end);
	});
	global[instance.Indentifier] = object;

	if script.Parent:FindFirstChild(className) then
		return require(script.Parent[className])(object, instance);
	else
		warn("Instance>>  ClassName ("..className..") does not exist.");
	end
end

function Instance:Get(instance)
	if instance.Indentifier == nil then Debugger:Warn(instance.Name.." is missing indentifier."); return end;
	return global[instance.Indentifier];
end

return Instance;