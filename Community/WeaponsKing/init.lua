print("WeaponsKing Script Loaded");
--== Map;
Map.MapId="WeaponsKing";

--== Game Configurations;
Map.Configurations.Set("DisableExperienceGain", true);
Map.Configurations.Set("AutoSpawning", false);
Map.Configurations.Set("RemoveForceFieldOnWeaponFire", true);
Map.Configurations.Set("UpdateTargetableEntities", {Humanoid=1; Zombie=1.5;});

--== Variables;
local killPerWeapon = 2;
local roundLength = 600;
local roundEndLength = 15;
local roundInProgress = false;

--== Script;
Map:LoadAudio(Map:GetFolder("Audio")); -- Load audio into audio library.

function Map:OnPlayerConnect(player)

end

function Map:Initialize()
	
end

return Map;