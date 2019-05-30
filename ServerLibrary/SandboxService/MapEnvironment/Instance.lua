local Instance = {};

local global = {};
local index = 0;

function Instance.new(className, object)
	index = index +1;
	local instance = newproxy(true);
	local instanceMeta = getmetatable(instance);
	instanceMeta.Instance = instance;
	instanceMeta.Name = object.Name;
	instanceMeta.ClassName = "Instance";
	instanceMeta.Indentifier = tostring(index);
	instanceMeta.__index=(function(t, k)
		if instanceMeta[k] then return instanceMeta[k]; end
		warn(instance.ClassName.." denied access to "..k..".");
	end);
	instanceMeta.__metatable = "This metatable is locked.";
	global[instance.Indentifier] = object;

	if script.Parent:FindFirstChild(className) then
		return require(script.Parent[className])(object, instance, instanceMeta);
	else
		warn("Instance>>  ClassName ("..className..") does not exist.");
	end
end

function Instance:Get(instance)
	if instance.Indentifier == nil then Debugger:Warn(instance.Name.." is missing indentifier."); return end;
	return global[instance.Indentifier];
end

return Instance;