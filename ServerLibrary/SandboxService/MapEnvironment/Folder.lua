return function(object, meta)
	meta.__index = meta;
	meta.__metatable = "This metatable is locked.";
	return setmetatable({
		ClassName = "Folder";
	}, meta);
end