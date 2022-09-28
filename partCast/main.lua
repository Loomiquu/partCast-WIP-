local partCast = {}
partCast.__index = partCast

--[[

partCast Modes (as of v1)

 - 0. Humanoid Mode - 
Solely returns the player Humanoid that has collided with the castHitbox;
if there's no player Humanoid detected the functionArg will not be run.
 
 - 1. Part Mode -
Returns all hit parts to the functionArg until the cast is terminated with
cast:Terminate() if no part/collision is detected nothing happens.

 - 2. Query Mode -
Runs a query check and depending on the result of the query it will run one
of two functions. successFunc() runs if the verdict is true; failedFunc runs
if the verdict is false. [Note that nil objects will not trigger the function]

]]--

function findAttachments(toolObject)
	local newTable = {}
	for _, v in toolObject:GetDescendants() do
		if v.Name == "start" and v:IsA("Attachment") then
			newTable.firstPos = v
		end
		
		if v.Name == "end" and v:IsA("Attachment") then
			newTable.secondPos = v
		end
	end

	return newTable
end

function partCast.new()
	local self = {}
	local activeCast
	
	function self.newConstraint()
		return
			{
				["Debug"] = true,
				["ToolObject"] = nil,
				["MaxDistance"] = 250,
				["Timeout"] = 0.05,
				["CastThickness"] = 1,
				["FunctionArg"] = function(collidedObject, distance) end,
				["Type"] = 0, --Decides the partCast Mode 
				["FrontOffset"] = 0,
				["TopOffset"] = 1,
				["AutoFindAttachments"] = true,
				["StartAttachment"] = nil,
				["EndAttachment"] = nil,
				["CollisionGroup"] = "Default",
				["QueryFunction"] = function(collidedObject) end, -- Must always have a return statement!!!
				["SuccessFunc"] = function(queryTable, constraints) end,
				["FailedFunc"] = function(queryTable, constraints) end
			}
	end
	
	function self:createCast(constraints)
		if constraints.ToolObject ~= nil and activeCast == nil then
		local attachments 
			if constraints.AutoFindAttachments == true then
				attachments = findAttachments(constraints.ToolObject)
			else
				attachments = {
					["firstPos"] = constraints.StartAttachment,
					["secondPos"] = constraints.EndAttachment
				}
			end
			
			activeCast = require(script.hitboxManager):init(constraints, attachments)
		elseif activeCast then
			warn("::CANNOT RUN TWO PROCESSES WITHIN THE SAME PARTCAST CONSTRUCTOR::")
		else
			warn("::PROCESS PAUSED, TOOLOBJECT IS NIL; SET THE TOOLOBJECT::")
		end
	end
	
	function self:terminateCast()
		if activeCast ~= nil then
			activeCast:Destroy()
			activeCast = nil
		else
			warn("::ATTEMPTED TO DESTROY NIL::")
		end
	end
	
	return setmetatable(self, partCast)
end

return partCast
