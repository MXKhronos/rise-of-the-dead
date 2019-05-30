return function(object, instance, meta)
	--== Properties;
	meta.ClassName = "Player";

	--== Functions;
	meta.LoadCharacter = (function()
		player:LoadCharacter();
		-- unfinished
	end);
	return instance;
end