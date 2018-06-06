local outputTag = script.Name..">>";
return function(self)
	self.Animate = function(self, name, fadeTime, speed, weight)
		if self.GetAnimation == nil then return end;
		local track;
		local complete, errors = pcall(function()
			track = self.GetAnimation(name);
			if track ~= nil then
				track:Play(fadeTime, weight, speed);
				if name == "Idle" then
					delay(track.Length, function() track:Stop() end);
				end
			end
		end)
		if not complete then warn(outputTag,"Error while trying to animate",name); end
		return track;
	end
	
	self.Wait = function(self, yieldTime, timer)
		self.IsWaiting = true;
		repeat yieldTime = yieldTime -1; until self.Target ~= nil or yieldTime <= 0 or not wait(timer or 1);
		self.IsWaiting = false;
	end
	
	self.WaitForEnable = function(self, timer)
		self.IsEnable = false;
		repeat self.Humanoid.WalkToPoint = self.RootPart.CFrame.p until not self.RootPart.Anchored or not wait(timer);
		self.IsEnable = true;
	end
	
	self.Stop = function() if self.StopMove ~= nil then self.StopMove(); self.StopMove = nil; end; end
	
	return self;
end