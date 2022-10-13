local hitbox = {}
local metaMethod = {}
local partCastModes = require(script.Parent:WaitForChild("partCastModes"))

local activeCast
local activeCastContainer = Instance.new("Folder")
activeCastContainer.Parent = workspace.Terrain

function metaMethod:__call(constraints, activeCastTable)
	setmetatable(self, {})
	local debugVerdict = false
	local debounce = false
	
	for _, v: Instance in self do
		if not (v:FindFirstChildOfClass("StringValue") and v:FindFirstChild("Ignore")) then
		activeCastTable, debugVerdict, debounce = partCastModes[constraints.Mode](v, constraints, debugVerdict, debounce, activeCastTable)
		end
		
		if v:IsA("SelectionBox") then
			if debugVerdict == true then
			v.Color3 = Color3.new(0.6,0,0)
			end
			
			if debugVerdict == "success" then
				v.Color3 = Color3.new(1, 0, 1)
			end
			
			if debugVerdict == "failed" then
				v.Color3 = Color3.new(0, 0.5, 1)
			end
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
				local dontHit = Instance.new("StringValue")
				dontHit.Parent = hitbox
				dontHit.Name = "Ignore"
				
				local visualizer = Instance.new("SelectionBox")
				visualizer.Adornee = hitbox
				visualizer.Parent = hitbox
				visualizer.SurfaceTransparency = 1
				visualizer.Color3 = Color3.new(0.9,0.8,0)
				visualizer.LineThickness = 0.0025
				local dontHit = Instance.new("StringValue")
				dontHit.Parent = visualizer
				dontHit.Name = "Ignore"
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