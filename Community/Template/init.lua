--== Map;
local Map = {
	MapId="Template";
};

--== Modules;
local modAudio = Library.Audio;
local modConfigurations = Library.Configurations;
local modCommunityProfile = Library.CommunityProfile;

--== Variables;
local random = Random.new();

--== Script;
function Map:OnPlayerConnect(player)

end

function Map:Initialize()
	
end

delay(5, function()
	Debugger:Log("Returning Map");
end)
return Map;