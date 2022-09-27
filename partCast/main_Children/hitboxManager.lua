local hitbox = {}
local metaMethod = {}

local physicsService = game:GetService("PhysicsService")

pcall(function()
physicsService:CreateCollisionGroup("DebugCast")
physicsService:CollisionGroupSetCollidable("DebugCast", "Default", false)
end)

local activeCast
local activeCastContainer = Instance.new("Folder")
activeCastContainer.Parent = workspace.Terrain

function metaMethod:__call(constraints, activeCastTable)
	setmetatable(self, {})
	local debugVerdict = false
	local debounce = false
	
---------------------------------------------------------------- partCast Modes
	local function humanoidHandle(value: Instance, constraints) -- Mode 0 Used solely to deal damage/Obtain the humanoid
		local humanoidModel = value.Parent:IsA("Model")
		if humanoidModel then
			local humanoid = value.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and not debounce then
				
				task.spawn(function()
				debounce = true
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
				
			end
			
		end 
	end
	
	local function instanceHandle(value: Instance, constraints) -- Mode 1 Returns all instances in the hitbox, for more dynamic melee systems
		if not debounce and value:IsA("BasePart") then
			task.spawn(function()
				debounce = true
				local toolParent = constraints.ToolObject.Parent
				local distance = (toolParent.HumanoidRootPart.Position - value.Position).Magnitude
				
				debugVerdict = true
				constraints.FunctionArg(value, distance)
			
				table.insert(activeCastTable, value)
				task.wait()
				debounce = false
			end)
			
		end
	end
	
	local function queryHandle(value: Instance, constraints) -- Mode 2 runs a query then depending on the result (Boolean), it'll run one of two functions (SuccessFunc or FailedFunc)
		local queryTable = {}
		local queryVerdict = false
		
		queryVerdict = constraints.QueryFunction(value)
		table.insert(activeCastTable, value)
		
		for _, v in self do			
			if queryVerdict and v:IsA("SelectionBox") then
				v.Color3 = Color3.new(0.701961, 0, 1)
			elseif v:IsA("SelectionBox") then
				v.Color3 = Color3.new(0.6,0,0)
			end
		end

		if queryVerdict == true then
			constraints.SuccessFunc(value, constraints)
		else
			constraints.FailedFunc(value, constraints)
		end

	end
----------------------------------------------------------------
	
	for k, v in self do
		if constraints.Type == 0 then
			humanoidHandle(v, constraints)
		end	
		if constraints.Type == 1 then
			instanceHandle(v, constraints)
		end
		
		if constraints.Type == 2 then
			queryHandle(v, constraints)
		end
		
		
		if v:IsA("SelectionBox") and debugVerdict == true then
			v.Color3 = Color3.new(0.6,0,0)
		end
		
	end
	
	return activeCastTable
end

function hitbox:init(constraints, points)
	local activeCast = Instance.new("RemoteEvent")
	activeCast.Parent = game:GetService("ServerStorage")
	
	task.spawn(function()	
		local activeCastData
		local activeCastTable = {}
		table.insert(activeCastTable, constraints.ToolObject.Parent)
		while activeCast.Parent ~= nil and constraints.ToolObject.Parent ~= nil do
			
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
			
			local length = (points.secondPos.WorldPosition - points.firstPos.WorldPosition).Magnitude
			local CFrameOffset = CFrame.new(0,0,-length/2)
			local CFrameData = CFrame.lookAt(points.firstPos.WorldPosition, points.secondPos.WorldPosition) * CFrameOffset * CFrame.new(0,-constraints.FrontOffset,-constraints.TopOffset)
			local sizeData = Vector3.new(constraints.CastThickness,constraints.CastThickness,length)
	
			local function createDummy()
				
				local hitbox = Instance.new("Part")
				hitbox.Parent = activeCastContainer
				hitbox.Name = "partCastHitboxVisualizer"
				hitbox.Position = points.firstPos.WorldPosition
				hitbox.Anchored = true
				hitbox.CanCollide = false
				hitbox.CFrame = CFrameData
				hitbox.Size = sizeData
				hitbox.Transparency = 1
				pcall(function() physicsService:SetPartCollisionGroup(hitbox, "DebugCast") end)
				
				local visualizer = Instance.new("SelectionBox")
				visualizer.Adornee = hitbox
				visualizer.Parent = hitbox
				visualizer.SurfaceTransparency = 1
				visualizer.Color3 = Color3.new(0.9,0.8,0)
				visualizer.LineThickness = 0.0025
				return visualizer
			end	
			
			overlapParams.CollisionGroup = constraints.CollisionGroup
			overlapParams.FilterDescendantsInstances = activeCastTable
			local boundsData = workspace:GetPartBoundsInBox(CFrameData, sizeData, overlapParams)
			activeCastData = setmetatable(boundsData, metaMethod)
			if constraints.Debug == true then
				local visualizer = createDummy()
				table.insert(boundsData, visualizer)
			end
			
			activeCastTable = activeCastData(constraints, activeCastTable)
			task.wait(constraints.Timeout)
		end
	end)
	
	return activeCast
end


return hitbox
