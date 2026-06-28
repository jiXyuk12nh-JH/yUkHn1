-- ----------------------------------------------------
-- 안전장치: 제공해주신 게임 ID와 완전히 일치하지 않으면 즉시 킥(Kick)
-- ----------------------------------------------------
local TARGET_PLACE_ID = 95099570361956  -- 요청하신 정확한 게임 고유 ID

if game.PlaceId ~= TARGET_PLACE_ID then
	game:GetService("Players").LocalPlayer:Kick("❌ 허용되지 않은 게임입니다. 스크립트 실행이 차단되었습니다.")
	return
end

-- 익스큐터 중복 실행 방지
if game:GetService("CoreGui"):FindFirstChild("AutoSeatGui") then
	game:GetService("CoreGui").AutoSeatGui:Destroy()
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- 상태 변수
local isAutoSearching = true
local isServerHopEnabled = true
local currentSeat = nil

-- ----------------------------------------------------
-- 키 설정 (추가됨)
-- ----------------------------------------------------
local SCRIPT_KEY = "0068114e-3ae8-4061-82ae-0e592eb6114b"
local EXTERNAL_SCRIPT_URL = "https://api.jnkie.com/api/v1/luascripts/public/2ddebb6cd08f6ad0826e2d014d767bf5d2325d19a761871459ee47a0b5982ad9/download"

-- ----------------------------------------------------
-- 1. 가로 확장 UI 생성 (가로 360, 세로 40으로 와이드하게 조정)
-- ----------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSeatGui"
if syn and syn.protect_gui then syn.protect_gui(screenGui) end 
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 40) -- 가로를 360으로 쫙 넓힘
mainFrame.Position = UDim2.new(0.5, -180, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainFrame

-- 오토 토글 버튼 (좌측 - 와이드)
local autoButton = Instance.new("TextButton")
autoButton.Name = "AutoButton"
autoButton.Size = UDim2.new(0, 110, 1, -10) -- 가로 너비 확장
autoButton.Position = UDim2.new(0, 6, 0, 5)
autoButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
autoButton.Text = "오토 매칭: ON"
autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoButton.Font = Enum.Font.SourceSansBold
autoButton.TextSize = 13
autoButton.Parent = mainFrame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 4)
btnCorner1.Parent = autoButton

-- 15분 자동 이동 토글 버튼 (중앙 - 와이드)
local hopButton = Instance.new("TextButton")
hopButton.Name = "HopButton"
hopButton.Size = UDim2.new(0, 120, 1, -10) -- 가로 너비 확장
hopButton.Position = UDim2.new(0, 122, 0, 5)
hopButton.BackgroundColor3 = Color3.fromRGB(130, 30, 180)
hopButton.Text = "15분 자동이동: ON"
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.Font = Enum.Font.SourceSansBold
hopButton.TextSize = 12
hopButton.Parent = mainFrame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 4)
btnCorner2.Parent = hopButton

-- 즉시 강제 서버 이동 버튼 (우측 - 와이드)
local forceHopButton = Instance.new("TextButton")
forceHopButton.Name = "ForceHopButton"
forceHopButton.Size = UDim2.new(0, 106, 1, -10) -- 가로 너비 확장
forceHopButton.Position = UDim2.new(0, 248, 0, 5)
forceHopButton.BackgroundColor3 = Color3.fromRGB(210, 100, 10)
forceHopButton.Text = "지금 강제이동"
forceHopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
forceHopButton.Font = Enum.Font.SourceSansBold
forceHopButton.TextSize = 13
forceHopButton.Parent = mainFrame

local btnCorner3 = Instance.new("UICorner")
btnCorner3.CornerRadius = UDim.new(0, 4)
btnCorner3.Parent = forceHopButton

-- UI 드래그 기능 (모바일/PC 지원)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ----------------------------------------------------
-- 2. 서버 이동(Server Hop) 및 차기 서버 자동 실행 등록
-- ----------------------------------------------------
local function serverHop()
	pcall(function()
		local queue = syn and syn.queue_on_teleport or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or (OXYGEN_LOADED and queue_on_teleport)
		if queue then
			queue([[
				repeat task.wait() until game:IsLoaded()
				local key = "0068114e-3ae8-4061-82ae-0e592eb6114b"
				local url = "https://api.jnkie.com/api/v1/luascripts/public/2ddebb6cd08f6ad0826e2d014d767bf5d2325d19a761871459ee47a0b5982ad9/download"
				-- 외부 스크립트를 로드만 하고 실행하지 않음 (원본 방식 유지)
				loadstring(game:HttpGet(url))()
			]])
		end
	end)

	pcall(function()
		local apiPage = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		local servers = apiPage and apiPage.data
		if servers then
			for _, server in pairs(servers) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
					break
				end
			end
		end
	end)
end

-- 15분(900초) 카운트다운 루프
task.spawn(function()
	while true do
		task.wait(900)
		if isServerHopEnabled then
			autoButton.Text = "이동 중..."
			serverHop()
		end
	end
end)

-- ----------------------------------------------------
-- 3. 외부 스크립트 및 끈질긴 추적 시스템
-- ----------------------------------------------------
local function runExternalScript()
	if not isAutoSearching then return end
	pcall(function()
		-- 원본 방식 유지: 로드만 하고 실행하지 않음
		loadstring(game:HttpGet(EXTERNAL_SCRIPT_URL))()
	end)
end

local function findNearestSeat()
	if not rootPart then return nil end
	local closestSeat = nil
	local shortestDistance = math.huge

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			if obj.Occupant == nil and obj:IsDescendantOf(workspace) then
				pcall(function()
					local distance = (rootPart.Position - obj.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						closestSeat = obj
					end
				end)
			end
		end
	end
	return closestSeat
end

local function moveToSeatUntilSat()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	runExternalScript()

	currentSeat = findNearestSeat()
	if currentSeat and currentSeat:IsDescendantOf(workspace) then
		while isAutoSearching and humanoid.SeatPart == nil and currentSeat.Occupant == nil do
			pcall(function()
				humanoid:MoveTo(currentSeat.Position)
			end)
			task.wait(0.1)
		end
	end
end

-- ----------------------------------------------------
-- 4. 버튼 이벤트 및 토글 연동
-- ----------------------------------------------------
local function turnOff()
	isAutoSearching = false
	autoButton.Text = "오토 매칭: OFF"
	autoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	if humanoid and rootPart then humanoid:MoveTo(rootPart.Position) end
end

local function turnOn()
	if humanoid and humanoid.SeatPart then return end
	isAutoSearching = true
	autoButton.Text = "오토 매칭: ON"
	autoButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
	task.spawn(moveToSeatUntilSat)
end

autoButton.MouseButton1Click:Connect(function()
	if isAutoSearching then turnOff() else turnOn() end
end)

hopButton.MouseButton1Click:Connect(function()
	isServerHopEnabled = not isServerHopEnabled
	if isServerHopEnabled then
		hopButton.Text = "15분 자동이동: ON"
		hopButton.BackgroundColor3 = Color3.fromRGB(130, 30, 180)
	else
		hopButton.Text = "15분 자동이동: OFF"
		hopButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end)

forceHopButton.MouseButton1Click:Connect(function()
	forceHopButton.Text = "이동 요청 중"
	forceHopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	serverHop()
end)

-- 메인 루프 (자동 의자 찾기 시스템)
task.spawn(function()
	while true do
		if isAutoSearching and humanoid and humanoid.SeatPart == nil then
			moveToSeatUntilSat()
		end
		task.wait(0.3)
	end
end)

-- 앉기 / 일어나기 자동 연동 리스너
local function setupSeatListener(char)
	local hum = char:WaitForChild("Humanoid")
	hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
		if hum.SeatPart then
			if isAutoSearching then turnOff() end
		else
			task.wait(0.5)
			turnOn()
		end
	end)
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	setupSeatListener(newChar)
	if isAutoSearching then turnOn() end
end)

if character then 
	setupSeatListener(character)
	task.spawn(moveToSeatUntilSat) 
end
