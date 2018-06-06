local Print=print; local String=tostring; local Type=type; local Pairs=pairs;
local Debugger = {};
Debugger.__index = Debugger;

local function concat(c)
	local d="";
	for i, b in Pairs(c) do d=d..(i==1 and "" or ", ")..(Type(b)=="table" and i.." {"..concat(b).."}" or Type(b)=="boolean" and String(b) or String(b or "nil")) end;
	return d;
end
	
function Debugger.new(scriptName) return setmetatable({Name=scriptName; Disabled=false;}, Debugger); end
function Debugger:Print(...)
	if self.Disabled then return end;
	local a = self.Name..">>  ";
	a=a..concat({...});
	Print(a);
end

return Debugger;