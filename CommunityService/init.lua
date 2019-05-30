local Debugger = require(game.ReplicatedStorage:WaitForChild("Library", 60):WaitForChild("Debugger")).new(script.Name);

--== Modules;
local SandboxService = require(game.ServerScriptService.ServerLibrary.SandboxService);

--== Variable;


--== Script;
local function OnPlayerAdded(player)
	if not serverInitiated then
		local teleportData = player:GetJoinData().TeleportData;
		local gameId = teleportData and teleportData.GameId or 2244111535;
		serverInitiated = true;
		coroutine.wrap(function()
			if gameId and modCommunity.GetGame(gameId) then
				LoadCommunityMap(gameId);
			else
				warn("The map id ("..(gameId or "null")..") does not exist. Loading default map.");
				LoadCommunityMap(overrideMapId);
			end
		end)();
	end
end

for _, player in pairs(game.Players:GetPlayers()) do OnPlayerAdded(player) end;
game.Players.PlayerAdded:Connect(OnPlayerAdded);