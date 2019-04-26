Debugger:Log("WeaponsKing Script Loaded");
--== Map;
local Map = {
	MapId="WeaponsKing";
};

--== Game Configurations;
Map.Configurations.Set("DisableExperienceGain", true);
Map.Configurations.Set("AutoSpawning", false);
Map.Configurations.Set("RemoveForceFieldOnWeaponFire", true);
Map.Configurations.Set("UpdateTargetableEntities", {Humanoid=1; Zombie=1.5;});

--== Load assets;
--Audio
Map:LoadAudio(Map:GetFolder("Audio"));

function Map:OnPlayerConnect(player)
	
end

return Map;