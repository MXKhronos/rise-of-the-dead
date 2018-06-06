local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local random = Random.new();
local animationLibrary = game.ServerStorage.PrefabStorage.Animations;

return function(npcModule, npcName)
	local humanoid = npcModule.Humanoid;
	local properties = npcModule.Properties;
	local animationsPrefabs = animationLibrary[npcName];
	local animations = {};
	
	local function loadAnimations(category)
		local animationsLoaded, errorRespond = pcall(function()
			if animationsPrefabs:FindFirstChild(category) then
				local anim = animationsPrefabs[category]:GetChildren();
				local animationsMeta = {};
				animations[category] = setmetatable({}, animationsMeta);
				animationsMeta.__index = animationsMeta;
				animationsMeta.TotalChance = 0;
				
				for a=1, #anim do
					local animationChance = anim[a]:FindFirstChild("Weight") and anim[a].Weight.Value or 1;
					table.insert(animations[category], {
						Track=humanoid:LoadAnimation(anim[a]);
						ChanceRange={Min=animationsMeta.TotalChance; Max=animationsMeta.TotalChance + animationChance};
					});
					animationsMeta.TotalChance = animationsMeta.TotalChance + animationChance;
				end
			end
		end)
		if not animationsLoaded then warn("NpcAnimator>> Error occured when loading",npcName,category,"animations.",errorRespond); end;
	end
	
	function npcModule.GetAnimation(name)
		if animations[name] == nil then loadAnimations(name); end
		if animations[name] == nil then warn("NpcAnimator>> Failed to get",npcName,":",name,"animation.") return; end
		local rollChance = random:NextNumber(0, animations[name].TotalChance);
		for a=1, #animations[name] do
			local anim = animations[name][a];
			if rollChance >= animations[name][a].ChanceRange.Min and rollChance < animations[name][a].ChanceRange.Max then
				return anim.Track;
			end
		end
	end
	
	if humanoid == nil then warn("NpcAnimator>>",npcName,"is missing humanoid."); return end;
	if animationsPrefabs:FindFirstChild("Core") then npcModule:Animate("Core", true); end;
	if animationsPrefabs:FindFirstChild("Running") then
		loadAnimations("Running")
		local runAnimation;
		humanoid.Running:Connect(function(velocity)
			if velocity > 0.5 then
				if runAnimation then return end;
				runAnimation = npcModule:Animate("Running", 0.2, (properties.WalkSpeed and (velocity/properties.WalkSpeed.Max) or velocity/16));
			else
				if runAnimation then runAnimation:Stop(0.2); runAnimation = nil; end
			end
		end)
	end
end;
