local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local random = Random.new();

--== Modules
local modProfile = require(game.ServerScriptService.ServerLibrary.Profile);
local modNpcComponent = require(game.ServerScriptService.ServerLibrary.Entity.NpcComponent);
local modNpcMovement = require(game.ServerScriptService.ServerLibrary.Entity.NpcMovement);

return function(npc, spawnPoint)
	local self = modNpcComponent{
		Prefab = npc;
		SpawnPoint = spawnPoint;
		Humanoid = npc:FindFirstChildWhichIsA("Humanoid");
		RootPart = npc.PrimaryPart;
		
		Properties = {
			Walkspeed = {Min=5; Max=5};
		};
	};
	
	function self.Update()
		modNpcMovement:Move(self.Humanoid, Vector3.new(33.87, 2.853, 40.8), function()
			modNpcMovement:Face(self.Humanoid, Vector3.new(33.87, 2.853, 44.026));
			wait(random:NextNumber(4,8));
			modNpcMovement:Move(self.Humanoid, Vector3.new(38.603, 2.819, 11.923), function()
				modNpcMovement:Face(self.Humanoid, Vector3.new(32.915, 2.819, 14.004));
				wait(random:NextNumber(10,15))
				modNpcMovement:Move(self.Humanoid, Vector3.new(16.115, 2.819, 14.601), function()
					modNpcMovement:Face(self.Humanoid, Vector3.new(15.079, 2.838, 13.056));
					wait(10);
					self:Animate("Idle");
					wait(random:NextNumber(10,30));
					self.Update();
				end);
			end);
		end);
	end
	
	self.Update();
	return self;
end
