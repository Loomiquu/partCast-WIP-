local methods = {}
local activeCast

--[[

      - METHODS -

 - - newConstraint() - -
Creates a new set of partCast 
constraints that can be editted
by changing the values of your
declared variable for newConstraint()

 - - createCast() - -
Launches the Cast method
and calculates hitboxes with
your provided Constraints

- - - Only one Method per Constructor

 - - terminateCast() - -
Terminates the concurrent Cast
method within its respective 
constructor, allowing for the
creation of a new Cast method

 - - debugCleanUp - - 
Destroys the hitbox outlines
that are created by partCast

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

methods.CurrentVer = 1.01

function methods.newConstraint()
	return
		{
			["Debug"] = true,
			["ToolObject"] = nil,
			["MaxDistance"] = 250,
			["Timeout"] = 0.05,
			["CastThickness"] = 1,
			["FunctionArg"] = function(collidedObject, distance) end,
			["Mode"] = 0, --Decides the partCast Mode 
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

function methods:createCast(constraints)
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

		activeCast = require(script.Parent.hitboxManager):init(constraints, attachments)
		elseif activeCast then
			warn("::CANNOT RE-RUN THIS METHOD IN THE SAME CONSTRUCTOR, UNLESS YOU TERMINATE THE CAST::")
		else
			warn("::METHOD PAUSED, TOOLOBJECT IS NIL; SET THE TOOLOBJECT::")
	end
end

function methods:terminateCast()
	if activeCast ~= nil then
		activeCast:Destroy()
		activeCast = nil
	else
		warn("::ATTEMPTED TO DESTROY NIL::")
	end
end

function methods:debugCleanUp()
	for _, v in workspace.Terrain.Folder:GetChildren() do
		if v.Name == "partCastHitboxVisualizer" then
			v:Destroy()
			task.wait(0.025)
		end
	end
end

return methods