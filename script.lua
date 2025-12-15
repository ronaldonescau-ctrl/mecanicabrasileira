-------------------------------------------------
-- 🔥 LIMPEZA TOTAL
-------------------------------------------------
if getgenv().PAIFF_HUB_LOADED then
	if getgenv().PAIFF_CONN then
		pcall(function() getgenv().PAIFF_CONN:Disconnect() end)
	end
	if getgenv().PAIFF_GUI then
		pcall(function() getgenv().PAIFF_GUI:Destroy() end)
	end
end
getgenv().PAIFF_HUB_LOADED = true

repeat task.wait() until game:IsLoaded()

-------------------------------------------------
-- SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-------------------------------------------------
-- FUNÇÕES
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

local function setNoClip(model, state)
	for _,p in pairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = not state
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
frame.Size = UDim2.new(0,340,0,420)
frame.Position = UDim2.new(0.02,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(12,12,12)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

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
		local delta = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-------------------------------------------------
-- HEADER RGB
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
		title.TextColor3 = Color3.fromHSV(h,0.9,1)
		task.wait()
	end
end)

-------------------------------------------------
-- ESTADO
-------------------------------------------------
local flying = false
local noclipEnabled = false
local SPEED = 160
local conn

-------------------------------------------------
-- VEHICLE FLY (FIXADO)
-------------------------------------------------
local function vehicleFly(destination)
	if flying then return end

	local seat = getSeat()
	if not seat then return end

	local vehicle = seat.Parent
	local char = player.Character
	flying = true
	noclipEnabled = true

	conn = RunService.Heartbeat:Connect(function()
		if not flying then return end

		setNoClip(vehicle,true)
		if char then setNoClip(char,true) end

		local delta = destination - seat.Position
		local dir = Vector3.new(delta.X,0,delta.Z)
		local dist = dir.Magnitude

		local speed = math.clamp(dist * 2,50,SPEED)

		if dist < 10 then
			flying = false
			conn:Disconnect()
			conn = nil

			-- PARA TOTAL
			seat.AssemblyLinearVelocity = Vector3.zero
			seat.AssemblyAngularVelocity = Vector3.zero

			-- ESPERA FÍSICA ASSENTAR
			task.wait(0.35)

			-- DESLIGA NOCLIP DE VERDADE
			setNoClip(vehicle,false)
			if char then setNoClip(char,false) end
			noclipEnabled = false

			noclipBtn.Text = "NOCLIP: OFF"
			noclipBtn.TextColor3 = Color3.fromRGB(255,80,80)
			return
		end

		local vel = dir.Unit * speed
		seat.AssemblyLinearVelocity = Vector3.new(vel.X,0,vel.Z)
	end)
end

-------------------------------------------------
-- GRID
-------------------------------------------------
local grid = Instance.new("Frame", frame)
grid.Position = UDim2.new(0.05,0,0.15,0)
grid.Size = UDim2.new(0.9,0,0.6,0)
grid.BackgroundTransparency = 1

local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.new(0,140,0,42)
layout.CellPadding = UDim2.new(0,10,0,10)

local destinations = {
	{"Base 1", Vector3.new(-25666.7,36,-5945.2)},
	{"Base 2", Vector3.new(-3667,63,-2511)},
	{"Base 3", Vector3.new(-3344,70,-3411)},
	{"Base 4", Vector3.new(-2990,63,-3683)},
	{"Base 5", Vector3.new(-3145,66,-4233)},
	{"Base 6", Vector3.new(-3837,62,-4900)},
	{"Base 7", Vector3.new(-4100,65,-5200)},
	{"Base 8", Vector3.new(-4500,68,-5600)},
}

for _,info in pairs(destinations) do
	local b = Instance.new("TextButton", grid)
	b.Text = info[1]
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)

	b.MouseButton1Click:Connect(function()
		vehicleFly(info[2])
	end)
end

-------------------------------------------------
-- NOCLIP STATUS
-------------------------------------------------
noclipBtn = Instance.new("TextLabel", frame)
noclipBtn.Size = UDim2.new(0.9,0,0,36)
noclipBtn.Position = UDim2.new(0.05,0,0.8,0)
noclipBtn.Text = "NOCLIP: OFF"
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextScaled = true
noclipBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
noclipBtn.TextColor3 = Color3.fromRGB(255,80,80)
Instance.new("UICorner", noclipBtn)
