local mode = {}

mode[0] = function(value, constraints, debugVerdict, debounce, activeCastTable)
local humanoidModel = value.Parent:IsA("Model")
if humanoidModel then
	local humanoid = value.Parent:FindFirstChildOfClass("Humanoid")
		
	if humanoid and not debounce then
	debounce = true
		task.spawn(function()
				
			local toolParent = constraints.ToolObject.Parent
			local distance = (toolParent.HumanoidRootPart.Position - humanoid.RootPart.Position).Magnitude

			if distance <= constraints.MaxDistance then
				constraints.FunctionArg(humanoid, distance)
				debugVerdict = true 
				table.insert(activeCastTable, value.Parent)
			end
				
			task.wait()
			debounce = false
		end)
		task.wait()
	end
end
	
return activeCastTable, debugVerdict, debounce
	
end

mode[1] = function(value, constraints, debugVerdict, debounce, activeCastTable)
	if not debounce and value:IsA("BasePart") then
		debounce = true
		table.insert(activeCastTable, value)
		task.spawn(function()
				
			local toolParent = constraints.ToolObject.Parent
			local distance = (toolParent.HumanoidRootPart.Position - value.Position).Magnitude

			debugVerdict = true
			constraints.FunctionArg(value, distance)

			task.wait()
			debounce = false
			end)
			task.wait()
		end
	return activeCastTable, debugVerdict, debounce
end

mode[2] = function(value, constraints, debugVerdict, debounce, activeCastTable)
	local queryTable = {}
	local queryVerdict = false

	queryVerdict = constraints.QueryFunction(value)
	table.insert(activeCastTable, value)

	if queryVerdict == true then
		debugVerdict = "success"
		constraints.SuccessFunc(value, constraints)
	else
		debugVerdict = "failed"
		constraints.FailedFunc(value, constraints)
	end
	return activeCastTable, debugVerdict, debounce
end

return mode