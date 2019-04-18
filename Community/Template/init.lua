local function debugEnv()
	print("Debug ENV:");
	for k, v in pairs(getfenv()) do print(k,"=",v); end;
	print("End Debug ENV:");
end
debugEnv();

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

Debugger:Log("Returning Map");
return Map;