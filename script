-------------------------------------------------
-- LIMPEZA
-------------------------------------------------
pcall(function()
	if getgenv().PAIFF_CONN then getgenv().PAIFF_CONN:Disconnect() end
	if getgenv().PAIFF_GUI then getgenv().PAIFF_GUI:Destroy() end
end)

repeat task.wait() until game:IsLoaded()

-------------------------------------------------
-- SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
repeat task.wait() until player.Character

-------------------------------------------------
-- NOCLIP (SAFE)
-------------------------------------------------
local useCollisionGroup = true
pcall(function()
	PhysicsService:CreateCollisionGroup("PAIFF_NOCLIP")
	PhysicsService:CollisionGroupSetCollidable("PAIFF_NOCLIP", "Default", false)
end)

if not pcall(function()
	PhysicsService:GetCollisionGroupId("PAIFF_NOCLIP")
end) then
	useCollisionGroup = false
end

local function setNoClip(model, state)
	for _,p in pairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			if useCollisionGroup then
				pcall(function()
					PhysicsService:SetPartCollisionGroup(
						p,
						state and "PAIFF_NOCLIP" or "Default"
					)
				end)
			else
				p.CanCollide = not state
			end
		end
	end
end

-------------------------------------------------
-- KEEP VEHICLE ALIVE (rodas não somem)
-------------------------------------------------
local function keepVehicleAlive(vehicle)
	for _,p in pairs(vehicle:GetDescendants()) do
		if p:IsA("BasePart") then
			p:SetNetworkOwner(player)
			p.AssemblyLinearVelocity += Vector3.new(0, 0.05, 0)
		end
	end
end

-------------------------------------------------
-- GET SEAT
-------------------------------------------------
local function getSeat()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("VehicleSeat")
		and v.Occupant
		and v.Occupant.Parent == player.Character then
			return v
		end
	end
end

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "PAIFF_HUB"
gui.ResetOnSpawn = false
getgenv().PAIFF_GUI = gui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,0,0,0)
frame.Position = UDim2.new(0.02,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(12,12,12)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

TweenService:Create(
	frame,
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	{Size = UDim2.new(0,340,0,430)}
):Play()

-------------------------------------------------
-- DRAG
-------------------------------------------------
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = frame.Position
	end
end)
frame.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + d.X,
			startPos.Y.Scale,
			startPos.Y.Offset + d.Y
		)
	end
end)

-------------------------------------------------
-- TITLE RGB
-------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.Text = "PAIFF HUB"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BackgroundTransparency = 1

task.spawn(function()
	local h = 0
	while gui.Parent do
		h = (h + 0.01) % 1
		title.TextColor3 = Color3.fromHSV(h,1,1)
		task.wait()
	end
end)

-------------------------------------------------
-- GRID
-------------------------------------------------
local grid = Instance.new("Frame", frame)
grid.Position = UDim2.new(0.05,0,0.15,0)
grid.Size = UDim2.new(0.9,0,0.65,0)
grid.BackgroundTransparency = 1

local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.new(0,140,0,42)
layout.CellPadding = UDim2.new(0,10,0,10)

-------------------------------------------------
-- VEHICLE FLY CONFIG
-------------------------------------------------
local MAX_SPEED = 220
local MIN_SPEED = 40
local FLY_HEIGHT = 6

local flying = false
local conn

-------------------------------------------------
-- VEHICLE FLY FINAL
-------------------------------------------------
local function vehicleFly(dest)
	if flying then return end

	local seat = getSeat()
	if not seat then return end

	local vehicle = seat.Parent
	local char = player.Character
	flying = true

	setNoClip(vehicle,true)
	if char then setNoClip(char,true) end

	conn = RunService.Heartbeat:Connect(function()
		keepVehicleAlive(vehicle)

		local pos = seat.Position
		local delta = Vector3.new(dest.X - pos.X, 0, dest.Z - pos.Z)
		local dist = delta.Magnitude

		if dist < 8 then
			flying = false
			conn:Disconnect()

			seat.AssemblyLinearVelocity = Vector3.zero
			seat.AssemblyAngularVelocity = Vector3.zero

			-- descer pro chão
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {vehicle}
			params.FilterType = Enum.RaycastFilterType.Blacklist

			local result = workspace:Raycast(pos, Vector3.new(0,-50,0), params)
			if result then
				seat.CFrame = CFrame.new(
					pos.X,
					result.Position.Y + 2.5,
					pos.Z
				)
			end

			task.wait(0.4)
			setNoClip(vehicle,false)
			if char then setNoClip(char,false) end
			return
		end

		local speed = math.clamp(dist * 3, MIN_SPEED, MAX_SPEED)
		local vel = delta.Unit * speed

		seat.AssemblyLinearVelocity = Vector3.new(
			vel.X,
			FLY_HEIGHT,
			vel.Z
		)
	end)
end

-------------------------------------------------
-- DESTINOS
-------------------------------------------------
local destinos = {
	{"Base 1", Vector3.new(-25666.7,36,-5945.2)},
	{"Base 2", Vector3.new(-3667,63,-2511)},
	{"Base 3", Vector3.new(-3344,70,-3411)},
	{"Base 4", Vector3.new(-2990,63,-3683)},
	{"Base 5", Vector3.new(-3145,66,-4233)},
	{"Base 6", Vector3.new(-3837,62,-4900)},
	{"Base 7", Vector3.new(-4100,65,-5200)},
	{"Base 8", Vector3.new(-4500,68,-5600)},
}

for _,d in pairs(destinos) do
	local b = Instance.new("TextButton", grid)
	b.Text = d[1]
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)

	b.MouseButton1Click:Connect(function()
		vehicleFly(d[2])
	end)
end
