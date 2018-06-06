local Debugger = require(game.ReplicatedStorage.Library.Debugger).new(script.Name);
local module = {}

local warnTag = script.Name..">>  "; local ActiveDebugging = false;
local PathfindingService = game:GetService("PathfindingService");
local random = Random.new();

function Face(self, humanoid, point)
	local rootPart = humanoid.RootPart;
	if rootPart == nil then warn(warnTag.."Move cancelled because RootPart does not exist in humanoid.") return end;
	
	local bodyGyro = rootPart:FindFirstChildWhichIsA("BodyGyro");
	if bodyGyro == nil then bodyGyro = Instance.new("BodyGyro"); bodyGyro.Parent = rootPart; end;
	bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0); bodyGyro.P = 15000;
	bodyGyro.CFrame = CFrame.new(rootPart.CFrame.p, point);
	delay(1, function() bodyGyro.MaxTorque = Vector3.new(0, 0, 0); end);
end

local function GeneratePath(humanoid, start, finish)
	local path = PathfindingService:FindPathAsync(start, finish);
	if path.Status ~= Enum.PathStatus.Success then
		--warn(warnTag..humanoid.Parent.Name.." failed to find path. ", path.Status);
		return nil;
	end
	return path, path:GetWaypoints();
end

function Move(self, humanoid, finish, stopCallback)
	local rootPart = humanoid.RootPart;
	if rootPart == nil then warn(warnTag.."Move cancelled because RootPart does not exist in humanoid.") return end;
	local start = rootPart.CFrame.p;
	if rootPart:CanSetNetworkOwnership() then rootPart:SetNetworkOwner(nil); end
	
	local path, waypoints = GeneratePath(humanoid, start, finish);
	if path ~= nil then
		local waypointIndex = 2;
		local breakWaypoints = false;
		local indexReached = 1;
		
		local moveToFinished;
		local moveToNext;
		local function StopMove()
			if moveToFinished then moveToFinished:Disconnect() end;
			breakWaypoints = true;
			humanoid:MoveTo(rootPart.CFrame.p);
			if stopCallback then stopCallback() end;
		end
		
		local function moveToWaypoint()
			if breakWaypoints then return end;
			local waypointCurr = waypoints[waypointIndex]; if waypointCurr == nil then return end;
			local waypointNext = (waypointIndex+1 <= #waypoints) and waypoints[waypointIndex + 1] or nil;
			
			if humanoid.Sit then humanoid.Jump = true; end
			humanoid:MoveTo(waypointCurr.Position);	
			if waypointCurr.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true; end
			delay(3, function() if waypointIndex < indexReached then moveToNext(); end end);
			
			if ActiveDebugging then
				spawn(function()
					local debugPoint = Instance.new("Part");
					if waypointNext then
						debugPoint.CFrame = CFrame.new(waypointCurr.Position, waypointNext.Position);
						debugPoint.FrontSurface = Enum.SurfaceType.Hinge;
					else
						debugPoint.CFrame = CFrame.new(waypointCurr.Position);
					end
					debugPoint.TopSurface = Enum.SurfaceType.Smooth;
					debugPoint.BottomSurface = Enum.SurfaceType.Smooth;
					debugPoint.Anchored = true;
					debugPoint.CanCollide = false;
					debugPoint.Transparency = 0.4;
					debugPoint.Locked = true;
					debugPoint.Size = Vector3.new(0.6, 0.6, 0.6);
					debugPoint.Parent = workspace.Camera;
					game.Debris:AddItem(debugPoint, 3);
			 
					local waypointType = waypointCurr.Action;	
					if waypointType == Enum.PathWaypointAction.Jump then
						debugPoint.Color = Color3.new(1, 1, 0);
					else
						debugPoint.Color = Color3.new(0, 1, 0);
					end
				end)
			end
		end
		
		local nextPathIsBlocked = false;
		moveToNext = function(reached)
			if not nextPathIsBlocked and waypointIndex+1 <= #waypoints and not rootPart.Anchored then
				waypointIndex = waypointIndex +1;
				indexReached = waypointIndex;
				moveToWaypoint();
				local nextBlockage = waypointIndex+1 <= #waypoints and path:CheckOcclusionAsync(waypointIndex+1);
				if nextBlockage and nextBlockage == waypointIndex+1 then nextPathIsBlocked = true; end
			else
				StopMove();
			end
		end
		
		moveToFinished = humanoid.MoveToFinished:Connect(moveToNext);
		
		moveToWaypoint();
		return StopMove;
	else
		if stopCallback then stopCallback() end;
	end
end

function Follow(self, humanoid, basePart, stepCallback)
	local rootPart = humanoid.RootPart; if rootPart == nil then warn(warnTag.."Follow cancelled because RootPart does not exist in humanoid.") return end;
	local followPart = basePart; if followPart == nil or not followPart:IsA("BasePart") then warn(warnTag.."Follow cancelled because followPart is invalid.") return end;
	local breakFollow = false;
	if rootPart:CanSetNetworkOwnership() then rootPart:SetNetworkOwner(nil); end
	
	local moveToNext;
	local function stopFollowing()
		breakFollow = true;
		humanoid:MoveTo(rootPart.CFrame.p);
	end
	
	local waypointIndex = 2;
	local path, waypoints = GeneratePath(humanoid, rootPart.CFrame.p, followPart.CFrame.p);
	local nextPathIsBlocked = false;
	local pathLocated = false;
	local function moveToWaypoint()
		if not followPart:IsDescendantOf(workspace) then return end;
		if waypointIndex >= 5 or nextPathIsBlocked then path, waypoints = GeneratePath(humanoid, rootPart.CFrame.p, followPart.CFrame.p); waypointIndex = 2; nextPathIsBlocked = false; end
		pathLocated = false;
		if path ~= nil then
			if waypointIndex <= #waypoints then
				local targetWaypoint = waypoints[waypointIndex];
				
				if humanoid.Sit then humanoid.Jump = true; end
				humanoid:MoveTo(targetWaypoint.Position);	
				if targetWaypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true; end
				local nextBlockage = path:CheckOcclusionAsync(waypointIndex);
				if nextBlockage and nextBlockage == waypointIndex+1 then nextPathIsBlocked = true; end
				pathLocated = true;
				
				if ActiveDebugging then
					spawn(function()
						local debugPoint = Instance.new("Part");
						debugPoint.CFrame = CFrame.new(targetWaypoint.Position);
						debugPoint.TopSurface = Enum.SurfaceType.Smooth;
						debugPoint.BottomSurface = Enum.SurfaceType.Smooth;
						debugPoint.Anchored = true;
						debugPoint.CanCollide = false;
						debugPoint.Transparency = 0.4;
						debugPoint.Locked = true;
						debugPoint.Size = Vector3.new(0.6, 0.6, 0.6);
						debugPoint.Parent = workspace.Camera;
						game.Debris:AddItem(debugPoint, 3);
				 
						local waypointType = targetWaypoint.Action;	
						if waypointType == Enum.PathWaypointAction.Jump then
							debugPoint.Color = Color3.new(1, 1, 0);
						else
							debugPoint.Color = Color3.new(0, 0, 1);
						end
					end)
				end
			end
		end
		if not pathLocated then
			humanoid:MoveTo(followPart.CFrame.p);
		end
	end
	
	local bind = Instance.new("BindableEvent");
	repeat
		stepCallback(stopFollowing, pathLocated);
		if not breakFollow then
			waypointIndex = waypointIndex +1;
			moveToWaypoint();
			spawn(function() delay(pathLocated and 3 or 5,function() bind:Fire(); end) humanoid.MoveToFinished:Wait(); bind:Fire(); end);
			bind.Event:Wait();
		else
			wait();
		end
	until breakFollow or rootPart.Anchored or not followPart:IsDescendantOf(workspace);
end

function IdleMove(self, humanoid, radius, region, stopCallback)
	local rootPart = humanoid.RootPart; if rootPart == nil then warn(warnTag.."IdleMove cancelled because RootPart does not exist in humanoid.") return end;
	if rootPart:CanSetNetworkOwnership() then rootPart:SetNetworkOwnershipAuto() end

	local randomPoint;
	if region ~= nil then
		local tries = 0;
		repeat 
			randomPoint = rootPart.CFrame.p + Vector3.new(random:NextNumber(-radius, radius), 0, random:NextNumber(-radius, radius)); tries = tries+1; 
		until randomPoint.X > region.Min.X and randomPoint.Z > region.Min.Z and randomPoint.X < region.Max.X and randomPoint.Z < region.Max.Z and not wait() or tries > 5;
	else
		randomPoint = rootPart.CFrame.p + Vector3.new(random:NextNumber(-radius, radius), 0, random:NextNumber(-radius, radius));
	end
	
	return Move(self, humanoid, randomPoint, stopCallback);
end

module.Move = Move;
module.Follow = Follow;
module.IdleMove = IdleMove;
module.Face = Face;

return module
