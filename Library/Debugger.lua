--== Configurations;
local TupleSeperator = ", "; -- Try: "/" "\t" "\n"

--== Script;
local Print=print; local Warn=warn; local String=tostring; local Type=type; local Pairs=pairs; local random = Random.new(); local Http = game:GetService("HttpService"); local RunService = game:GetService("RunService"); local TextService = game:GetService("TextService");
local GuiDataRemote; local rayInfo, rayInstance; local colorsList = {Color3.fromRGB(196, 40, 28); Color3.fromRGB(13, 105, 172); Color3.fromRGB(245, 205, 48); Color3.fromRGB(75, 151, 75); Color3.fromRGB(170, 0, 170); Color3.fromRGB(218, 133, 65); Color3.fromRGB(18, 238, 212);};
local Debugger = {}; 
Debugger.__index = Debugger;


local function concat(c, useKey)
	local d="";
	local index = 1;
	for i, b in Pairs(c) do
		d=d..(index==1 and "" or (TupleSeperator or " "))..(useKey and (Type(i) == "string" and '"'..i..'"' or i)..":" or "")..(Type(b)=="table" and "{"..concat(b, true).."}" or Type(b)=="boolean" and String(b) or String(b or "nil"))
		index = index +1;
	end;
	return d;
end

--[[**
	Enable Debugger on to script.
	@param name string
	
	Name of the script or name of the output title.
	@returns Debugger
	
	Returns Debugger instance with properties Name and Disabled. Setting "Debugger.Disabled = true" will disable logging.
**--]]
function Debugger.new(name) return setmetatable({Name=name; Disabled=false;}, Debugger); end

--[[**
	Visualize a ray. If rayHit is nil, the shown ray will be greyed out.
	@param ray Ray
	
	Ray object. (e.g. Ray.new());
	@param rayHit BasePart
	
	The object the ray hits. (Optional)
	@param rayPoint Vector3
	
	The end point of the ray. (Optional)
	@param rayNormal Vector3
	
	The normal of the end point of the ray. (Optional)
**--]]
function Debugger:Ray(ray, rayHit, rayPoint, rayNormal)
	if self.Disabled then return end;
	if rayInstance == nil then
		local A = Instance.new("Part"); A.Name = "A";
		A.Anchored = true;
		A.CanCollide = false;
		A.Material = Enum.Material.Glass;
		A.TopSurface = Enum.SurfaceType.Smooth;
		A.BottomSurface = Enum.SurfaceType.Smooth;
		A.Locked = true;
		A.Size = Vector3.new(0.2, 0.2, 0.2);
		A.Shape = Enum.PartType.Ball;
		local B = Instance.new("Part"); B.Name = "B";
		B.Anchored = true;
		B.CanCollide = false;
		B.Material = Enum.Material.Glass;
		B.TopSurface = Enum.SurfaceType.Smooth;
		B.BottomSurface = Enum.SurfaceType.Smooth;
		B.Locked = true;
		B.Size = Vector3.new(0.4, 0.4, 0.1);
		--B.Shape = Enum.PartType.Cylinder;
		B.Parent = A;
		local C = Instance.new("Part"); C.Name = "C";
		C.Anchored = true;
		C.CanCollide = false;
		C.Material = Enum.Material.Glass;
		C.TopSurface = Enum.SurfaceType.Smooth;
		C.BottomSurface = Enum.SurfaceType.Smooth;
		C.Locked = true;
		--C.Shape = Enum.PartType.Cylinder;
		C.Parent = B;
		A.Parent = script;
		rayInstance = A;
	end
	if rayInfo == nil then
		rayInfo = script:FindFirstChild("RayDebug");
		if rayInfo == nil then
			rayInfo = Instance.new("BillboardGui");
			rayInfo.Parent = script;
			rayInfo.AlwaysOnTop = true;
			rayInfo.Name = "RayDebug";
			rayInfo.Size = UDim2.new(2, 0, 0.6, 0);
			local infoTag = Instance.new("ImageLabel");
			infoTag.Name = "InfoTag";
			infoTag.Parent = rayInfo;
			infoTag.BackgroundTransparency = 1;
			infoTag.Size = UDim2.new(1, 0, 1, 0);
			infoTag.TextColor3 = Color3.fromRGB(255, 255, 255);
			infoTag.TextSize = 14;
			infoTag.TextStrokeTransparency = 0.5;
			infoTag.TextXAlignment = Enum.TextXAlignment.Center;
			infoTag.TextYAlignment = Enum.TextYAlignment.Center;
		end
	end
	if ray then
		local rayA = rayInstance:Clone();
		local rayB = rayA:WaitForChild("B");
		local rayC = rayB:WaitForChild("C");
		
		local rayOrigin, rayDirection = ray.Origin, ray.Direction;
		rayA.CFrame = CFrame.new(rayOrigin);
		if rayPoint == nil then rayPoint = rayOrigin+rayDirection; end
		rayB.CFrame = CFrame.new(rayPoint, rayPoint+(rayNormal or Vector3.new()));
		
		local distance = (rayPoint-rayOrigin).Magnitude;
		rayC.Size = Vector3.new(0.06, 0.06, distance);
		rayC.CFrame = CFrame.new(rayPoint-(rayPoint-rayOrigin)/2, rayPoint);
		
		local hud = rayInfo:Clone();
		local label = hud:WaitForChild("InfoTag");
		label.Text = "Distance: "..math.floor(distance*100+0.5)/100;
		hud.Adornee = rayB;
		hud.Parent = rayB;
		
		if rayHit then
			local color = colorsList[random:NextInteger(1, #colorsList)];
			rayA.Color = color;
			rayB.Color = color;
			rayC.Color = color;
			--rayB.Shape = Enum.PartType.Cylinder;
		else
			local color = Color3.fromRGB(180, 180, 180);
			rayA.Color = color;
			rayB.Color = color;
			rayC.Color = color;
			rayB.Shape = Enum.PartType.Ball;
		end
		rayA.Parent = workspace.CurrentCamera;
		rayA.Archivable = false;
		rayB.Archivable = false;
		rayC.Archivable = false;
		return rayA;
	end
end

--[[**
	Log message;
	@param ... Tuple
	
	Message of the log. Example: Debugger:Log("Hello", "Again");
**--]]
function Debugger:Log(...)
	if self.Disabled then return end;
	local a = (self.Name or script.Name)..">>  ";
	if #{...} <= 0 then
		a=a.."nil"
	else
		a=a..concat({...});
	end;
	Print(a);
end

--[[**
	Log warning;
	@param ... Tuple
	
	Message of the warning. Example: Debugger:Warn("Oh no!", "404");
**--]]
function Debugger:Warn(...)
	if self.Disabled then return end;
	local a = (self.Name or script.Name)..">>  ";
	if #{...} <= 0 then
		a=a.."nil"
	else
		a=a..concat({...});
	end;
	Warn(a);
end

--[[**
	Format table into string;
	@param input table
	
	Table that you want to format into a string.
	@returns string
	
	Returns the formatted table in string.
**--]]
function Debugger:FormatTable(input)
	local cache = {};
	local function sortAlpha(t)
		table.sort(t, function(A, B)
			local A = {A.Key:byte(1,5)};
			local aSize = 0;
			local B = {B.Key:byte(1,5)};
			local bSize = 0;
			for a=1, 5 do
				if A[a] ~= nil then
					aSize = aSize+A[a];
				else
					aSize = aSize+65;
				end
				if B[a] ~= nil then
					bSize = bSize+B[a];
				else
					bSize = bSize+65;
				end
			end
			return aSize < bSize;
		end)
	end
	local function extract(t, index)
		local syntax = string.rep("    ", index);
		for key, value in pairs(t) do
			if type(value) == "table" then
				table.insert(cache, {Key=syntax..(type(key) == "string" and ('["$Var"]'):gsub("$Var", key) or ('[$Var]'):gsub("$Var", key)); Value="{";});
				extract(value, index+1);
				table.insert(cache, {Key=syntax; Value="}";});
			else
				table.insert(cache, {Key=syntax..key; Value=(value or "nil");});
			end
		end
	end
	local function indentifier(v)
		local r = String(v);
		if type(v) == "string" then
			return ('"$Var"'):gsub("$Var", r);
		elseif type(v) == "boolean" then
			return ("[$Var]"):gsub("$Var", r);
		elseif type(v) == "userdata" then
			return ("($Var)"):gsub("$Var", r);
		end
		return r;
	end
	extract(input, 0);
	local output = "";
	for a=1, #cache do
		local linkSyntax = " = ";
		local key = cache[a].Key;
		local value = cache[a].Value;
		if String(cache[a].Value) == "}" then
			linkSyntax = "";
		elseif String(cache[a].Value) == "{" then
		else
			value = indentifier(cache[a].Value);
		end
		output = output..key..linkSyntax..value.."\n"
	end
	return output;
end

--[[**
	Display debug;
	@param data table
	
	Table of data to display.
	@param whitelist Player/Players
	
	Player or a table of players to display debug data to. Leaving this null will display debug to all players.
**--]]
function Debugger:Display(data, whitelist)
	if self.Disabled then return end;
	whitelist = whitelist and type(whitelist) ~= "table" and {whitelist} or whitelist;
	if RunService:IsServer() then
		if whitelist then
			for a=1, #whitelist do
				if whitelist[a]:IsA("Player") then
					GuiDataRemote:FireClient(whitelist[a], self.Name, Http:JSONEncode(data));
				end
			end
		else
			GuiDataRemote:FireAllClients(self.Name, Http:JSONEncode(data));
		end
	else
		UpdateDebuggerGui(self.Name, Http:JSONEncode(data));
	end
end

if RunService:IsClient() then
	local DebuggerGui = nil;
	local ListFrame = nil;
	
	local ListSizeMin = Vector2.new(300, 600);
	local ListSizeMax = Vector2.new(1000, 1600);
	function UpdateDebuggerGui(scriptName, data)
		DebuggerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DebuggerGui");
		ListFrame = DebuggerGui and DebuggerGui:FindFirstChild("ListFrame");
		if DebuggerGui == nil then
			DebuggerGui = Instance.new("ScreenGui");
			DebuggerGui.Name = "DebuggerGui";
			DebuggerGui.Parent = game.Players.LocalPlayer.PlayerGui;
			DebuggerGui.DisplayOrder = 10;
			
			ListFrame = Instance.new("ScrollingFrame");
			ListFrame.Name = "ListFrame";
			ListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35);
			ListFrame.BackgroundTransparency = 1;
			ListFrame.BorderSizePixel = 0;
			ListFrame.Position = UDim2.new(0, 50, 0, 50);
			ListFrame.Size = UDim2.new(0, ListSizeMin.X, 0, 0);
			ListFrame.ScrollBarThickness = 2;
			ListFrame.Parent = DebuggerGui;
			
			local listLayout = Instance.new("UIListLayout");
			listLayout.Padding = UDim.new(0, 10);
			listLayout.Parent = ListFrame;
			
			local listSizeConstraint = Instance.new("UISizeConstraint");
			listSizeConstraint.MinSize = ListSizeMin;
			listSizeConstraint.MaxSize = ListSizeMax;
			
			local hintLabel = Instance.new("TextLabel");
			hintLabel.BackgroundTransparency = 1;
			hintLabel.Name = "Hint";
			hintLabel.Size = UDim2.new(0, ListSizeMin.X, 0, 10);
			hintLabel.Position = UDim2.new(0, 60, 0, 35);
			hintLabel.TextColor3 = Color3.fromRGB(35, 35, 35);
			hintLabel.TextXAlignment = Enum.TextXAlignment.Left;
			hintLabel.TextYAlignment = Enum.TextYAlignment.Top;
			hintLabel.Font = Enum.Font.Code;
			hintLabel.TextSize = 10;
			hintLabel.Text = "Debug Log (Press [F2] to hide)"
			hintLabel.Parent = DebuggerGui;
				
			listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				wait();
				ListFrame.Size = UDim2.new(0, listLayout.AbsoluteContentSize.X, 0, listLayout.AbsoluteContentSize.Y);
				ListFrame.CanvasSize = UDim2.new(0, listLayout.AbsoluteContentSize.X, 0, listLayout.AbsoluteContentSize.Y);
			end)
		end
		
		if ListFrame then
			local frame = ListFrame:FindFirstChild(scriptName);
			local label = frame and frame:FindFirstChild("Label");
			if frame == nil then
				frame = Instance.new("Frame");
				frame.Name = scriptName;
				frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35);
				frame.BackgroundTransparency = 0.15;
				frame.BorderSizePixel = 0;
				frame.Size = UDim2.new(1, 0, 0, 0);
				frame.Parent = ListFrame;
				
				local labelPadding = Instance.new("UIPadding");
				labelPadding.PaddingTop = UDim.new(0, 10);
				labelPadding.PaddingLeft = UDim.new(0, 10);
				labelPadding.Parent = frame;
			
				label = Instance.new("TextLabel");
				label.BackgroundTransparency = 1;
				label.Name = "Label";
				label.Size = UDim2.new(1, 0, 1, 0);
				label.TextColor3 = Color3.fromRGB(255, 255, 255);
				label.TextXAlignment = Enum.TextXAlignment.Left;
				label.TextYAlignment = Enum.TextYAlignment.Top;
				label.Font = Enum.Font.Code;
				label.TextSize = 14;
				label.Parent = frame;
			end
			
			if label ~= nil and data ~= nil then
				local raw = Http:JSONDecode(data);
				label.Text = Debugger:FormatTable(raw);
				local textBounds = TextService:GetTextSize(label.Text, label.TextSize, label.Font, ListSizeMax);
				frame.Size = UDim2.new(0, textBounds.X+20, 0, textBounds.Y+10);
			end
		end
	end
	
	local UserInputService = game:GetService("UserInputService");
	
	UserInputService.InputBegan:Connect(function(inputObject, eventType)
		if inputObject.KeyCode == Enum.KeyCode.F2 and DebuggerGui then
			DebuggerGui.Enabled = not DebuggerGui.Enabled;
		end
	end)
	
	coroutine.wrap(function()
		local waitForTick = tick();
		repeat GuiDataRemote = script:FindFirstChild("RemoteEvent"); if tick()-waitForTick >= 5 then return end; until GuiDataRemote ~= nil and not wait();
		GuiDataRemote.OnClientEvent:Connect(UpdateDebuggerGui);
	end)();
else
	-- IsServer;
	GuiDataRemote = Instance.new("RemoteEvent", script);
end

Debugger.Print = Debugger.Log;
return Debugger;