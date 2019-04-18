local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
--== Modules;
local Map = {};
local modCommunityProfile = require(game.ServerScriptService.ServerLibrary.CommunityProfile)(Map);

--== Variables;
local random = Random.new();

--== Script;
Map.MapId = "Template";

function Map.Initialize()
	
end

function Map.OnPlayerConnect(player)

end