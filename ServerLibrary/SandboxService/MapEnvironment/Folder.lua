return function(object)
	return setmetatable({}, {
		-- metamethods;
		__metatable="This metatable is locked.";
		__index=(function(t, k)
			if k == "Name" then
				return object.Name;
			else
				Debugger:Warn("Denied access to "..k..".");
				return nil;
			end
		end);
		__newindex=(function(t, k, v)
			Debugger:Warn("Denied access to change "..k.."'s value.");
			return;
		end);
	});
end