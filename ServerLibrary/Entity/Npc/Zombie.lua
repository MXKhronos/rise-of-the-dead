local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local random = Random.new();

--== Modules
local modProfile = require(game.ServerScriptService.ServerLibrary.Profile);
local modNpcComponent = require(game.ServerScriptService.ServerLibrary.Entity.NpcComponent);
local modNpcMovement = require(game.ServerScriptService.ServerLibrary.Entity.NpcMovement);
local modAudio = require(game.ReplicatedStorage.Library.Audio);

-- Note; Function called for each zombie before zombie parented to workspace;
return function(npc, spawnPoint)
	local self = modNpcComponent{
		Prefab = npc;
		SpawnPoint = spawnPoint;
		Humanoid = npc:FindFirstChildWhichIsA("Humanoid");
		RootPart = npc.PrimaryPart;
		
		Properties = {
			Walkspeed = {Min=2; Max=16};
			AttackSpeed = 1;
			AttackDamage = 10;
			AttackRange = 3;
		};
	};
	
	--== public functions;
	function self.Update()
		if self.IsDead then return end;
		local targetHumanoid = self.Target and self.Target:FindFirstChildWhichIsA("Humanoid") or nil;
		if self.Target ~= nil and self.Target.PrimaryPart ~= nil and targetHumanoid.Health > 0 then
			if not self.IsFollowing then
				self.Humanoid.WalkSpeed = random:NextInteger(6, 10);
				self.IsFollowing = true;
				local pushAnimation;
				modNpcMovement:Follow(self.Humanoid, self.Target.PrimaryPart, function(stopFollowing, followingPath)
					if self.IsDead or self.Target == nil or self.RootPart.Anchored then stopFollowing(); return end;
					self.Humanoid.WalkSpeed = random:NextInteger(6, 10);
					if followingPath then
						if pushAnimation ~= nil then pushAnimation:Stop(0.5); pushAnimation = nil end;
						local distanceFromTarget = (self.Target.PrimaryPart.CFrame.p-self.RootPart.CFrame.p).Magnitude;
						if self.Properties.AttackCooldown == nil then self.Properties.AttackCooldown = tick(); end;
						if tick()-self.Properties.AttackCooldown > self.Properties.AttackSpeed and distanceFromTarget < self.Properties.AttackRange then
							self.Properties.AttackCooldown = tick();
							if targetHumanoid then
								targetHumanoid:TakeDamage(self.Properties.AttackDamage);
								self:Animate("Attack",0.05);
							end
						end
					else
						local hitPart = workspace:FindPartOnRayWithWhitelist(Ray.new(self.RootPart.CFrame.p, self.RootPart.CFrame.lookVector*2), {workspace.Environment}, true);
						if hitPart and hitPart.Transparency >= 0.5 then
							if pushAnimation == nil then pushAnimation = self:Animate("Push", 0.5); end;
						end
					end
				end)
				self.IsFollowing = false;
				self:WaitForEnable(3);
				wait(1);
				self.Update();
			end
		else
			self.Humanoid.WalkSpeed = random:NextInteger(2, 6);
			self:WaitForEnable(3);
			self:Animate("Idle");
			self:Wait(random:NextNumber(2, 10));
			self.StopMove = modNpcMovement:IdleMove(self.Humanoid, 20, nil, self.Update);
		end
	end
	
	function self.OnDeath(player)
		self.IsDead = true;
		self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
		if player then
			local playerSave = modProfile:Get(player):GetActiveSave();
			if playerSave then
				playerSave:AddStat("Kills", 1);
			end
		end
	end
	
	local forgetRate = random:NextNumber(3,7);
	local function forgetTarget()
		if tick()-self.LastTargetSet >= forgetRate then
			self.Target = nil;
			self.Properties.AttackCooldown = nil;
		else 
			delay(forgetRate, forgetTarget);
		end
	end;
	local onTargetDebounce = tick();
	function self.OnTarget(target)
		if self.IsDead then return end;
		if tick()-onTargetDebounce < 1 then return end; onTargetDebounce = tick();
		if target == nil then return end;
		if self.Target == target then self.LastTargetSet = tick(); return end;
		local humanoid = target:FindFirstChildWhichIsA("Humanoid");
		if humanoid and humanoid:IsDescendantOf(workspace) and humanoid.Health > 0 then
			delay(forgetRate, forgetTarget)
			self.Target = target;
			self.LastTargetSet = tick();
			self.Stop();
		end
	end
	
	local hurtCooldown = tick(); local lastDamaged = tick();
	self.LastHealth = self.Humanoid.Health;
	self.Humanoid.HealthChanged:Connect(function()
		self.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn; lastDamaged = tick();
		delay(2, function() if tick()-lastDamaged > 2 then self.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff end; end);
		if self.Humanoid.Health < self.LastHealth and tick()-hurtCooldown > random:NextNumber(2, 5) then
			hurtCooldown = tick();
			local hurtSound = modAudio.Play("ZombieHurt", self.RootPart);
			hurtSound.PlaybackSpeed = random:NextNumber(0.5, 0.65);
			hurtSound.Volume = random:NextNumber(0.25, 0.55);
		end
		self.LastHealth = self.Humanoid.Health;
	end)
	
	self.Update();
	return self;
end
