--// [설정] 접속 비밀키 (원하는 키로 변경 가능)
local KEY = "X7mQ2vLp9KaR4NzT8cY1HuDw5BjFe3Ss"

-- 중복 실행 방지
if getgenv().AFK_KEY_OK then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local plr = Players.LocalPlayer

------------------------------------------------
-- 1. 키 검증 UI (Key System GUI)
------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 90)
frame.Position = UDim2.new(.5, -120, .5, -45)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0, 220, 0, 35)
box.Position = UDim2.new(0, 10, 0, 10)
box.PlaceholderText = "Enter Key"
box.Text = ""
box.ClearTextOnFocus = false
box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
box.TextColor3 = Color3.new(1, 1, 1)
box.BorderSizePixel = 0
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 220, 0, 28)
btn.Position = UDim2.new(0, 10, 0, 50)
btn.Text = "Unlock"
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

------------------------------------------------
-- SKYBOX FUNCTION (최적화 스카이박스 생성)
------------------------------------------------
local function applySkybox()
	local oldSky = Lighting:FindFirstChild("FPSBoostSky")
	if oldSky then oldSky:Destroy() end

	local sky = Instance.new("Sky")
	sky.Name = "FPSBoostSky"
	sky.SkyboxBk = "rbxassetid://11457548274"
	sky.SkyboxDn = "rbxassetid://11457548274"
	sky.SkyboxFt = "rbxassetid://11457548274"
	sky.SkyboxLf = "rbxassetid://11457548274"
	sky.SkyboxRt = "rbxassetid://11457548274"
	sky.SkyboxUp = "rbxassetid://11457548274"
	sky.MoonTextureId = "rbxassetid://6444320592"
	sky.SunTextureId = "rbxassetid://8281961896"
	sky.Parent = Lighting

	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
end

------------------------------------------------
-- 2. 키 확인 버튼 클릭 이벤트
------------------------------------------------
btn.MouseButton1Click:Connect(function()
	-- 공백 제거 후 비교
	if tostring(box.Text):gsub("%s+", "") == KEY then
		getgenv().AFK_KEY_OK = true
		gui:Destroy() -- 키창 파괴 후 본 스크립트 실행

		------------------------------------------------
		-- 3. 본 기능 (Anti AFK & Performance Mode)
		------------------------------------------------
		local running = false
		local perfEnabled = false
		local seconds = 1

		local gui2 = Instance.new("ScreenGui")
		gui2.Name = "AntiAFK_Performance"
		gui2.Parent = game.CoreGui
		gui2.ResetOnSpawn = false

		local main = Instance.new("Frame")
		main.Size = UDim2.new(0, 330, 0, 28)
		main.Position = UDim2.new(0, 5, 0, 5)
		main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		main.BorderSizePixel = 0
		main.Parent = gui2

		Instance.new("UICorner", main).CornerRadius = UDim.new(0, 5)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0, 55, 1, 0)
		title.Position = UDim2.new(0, 6, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = "Anti AFK"
		title.TextColor3 = Color3.fromRGB(220, 220, 220)
		title.Font = Enum.Font.Code
		title.TextSize = 11
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = main

		local fpsLabel = Instance.new("TextLabel")
		fpsLabel.Size = UDim2.new(0, 55, 1, 0)
		fpsLabel.Position = UDim2.new(0, 60, 0, 0)
		fpsLabel.BackgroundTransparency = 1
		fpsLabel.Text = "0 FPS"
		fpsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		fpsLabel.Font = Enum.Font.Code
		fpsLabel.TextSize = 11
		fpsLabel.Parent = main

		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(0, 40, 1, 0)
		timeLabel.Position = UDim2.new(0, 115, 0, 0)
		timeLabel.BackgroundTransparency = 1
		timeLabel.Text = "1s"
		timeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		timeLabel.Font = Enum.Font.Code
		timeLabel.TextSize = 11
		timeLabel.Parent = main

		local minus = Instance.new("TextButton")
		minus.Size = UDim2.new(0, 18, 0, 18)
		minus.Position = UDim2.new(0, 160, 0.5, -9)
		minus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		minus.BorderSizePixel = 0
		minus.Text = "-"
		minus.TextColor3 = Color3.new(1, 1, 1)
		minus.Font = Enum.Font.Code
		minus.TextSize = 13
		minus.Parent = main
		Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)

		local plus = Instance.new("TextButton")
		plus.Size = UDim2.new(0, 18, 0, 18)
		plus.Position = UDim2.new(0, 182, 0.5, -9)
		plus.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		plus.BorderSizePixel = 0
		plus.Text = "+"
		plus.TextColor3 = Color3.new(1, 1, 1)
		plus.Font = Enum.Font.Code
		plus.TextSize = 13
		plus.Parent = main
		Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)

		local perf = Instance.new("TextButton")
		perf.Size = UDim2.new(0, 42, 0, 18)
		perf.Position = UDim2.new(0, 208, 0.5, -9)
		perf.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		perf.BorderSizePixel = 0
		perf.Text = "PERF"
		perf.TextColor3 = Color3.new(1, 1, 1)
		perf.Font = Enum.Font.Code
		perf.TextSize = 10
		perf.Parent = main
		Instance.new("UICorner", perf).CornerRadius = UDim.new(0, 4)

		local toggle = Instance.new("TextButton")
		toggle.Size = UDim2.new(0, 42, 0, 18)
		toggle.Position = UDim2.new(1, -47, 0.5, -9)
		toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		toggle.BorderSizePixel = 0
		toggle.Text = "ON"
		toggle.TextColor3 = Color3.new(1, 1, 1)
		toggle.Font = Enum.Font.Code
		toggle.TextSize = 11
		toggle.Parent = main
		Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)

		local function updateTime()
			timeLabel.Text = seconds.."s"
		end

		plus.MouseButton1Click:Connect(function()
			seconds = math.clamp(seconds + 1, 1, 1140)
			updateTime()
		end)

		minus.MouseButton1Click:Connect(function()
			seconds = math.clamp(seconds - 1, 1, 1140)
			updateTime()
		end)

		perf.MouseButton1Click:Connect(function()
			perfEnabled = not perfEnabled

			if perfEnabled then
				perf.Text = "GRAY"
				applySkybox() -- 첫 번째 코드의 스카이박스 함수 연결 보완

				Lighting.ClockTime = 14
				Lighting.Brightness = 0
				Lighting.GlobalShadows = false
				Lighting.FogEnd = 9e9
				Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)

				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Material = Enum.Material.SmoothPlastic
						v.Reflectance = 0
					end
				end

				workspace.Terrain.WaterWaveSize = 0
				workspace.Terrain.WaterWaveSpeed = 0
				workspace.Terrain.WaterReflectance = 0
				workspace.Terrain.WaterTransparency = 1
			else
				perf.Text = "PERF"
				Lighting.Brightness = 2
				Lighting.GlobalShadows = true
			end
		end)

		local fps = 0
		local last = tick()

		RunService.RenderStepped:Connect(function()
			fps += 1
			if tick() - last >= 1 then
				fpsLabel.Text = fps.." FPS"
				fps = 0
				last = tick()
			end
		end)

		toggle.MouseButton1Click:Connect(function()
			running = not running
			toggle.Text = running and "OFF" or "ON"

			task.spawn(function()
				while running do
					task.wait(seconds)

					local char = plr.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					local root = char and char:FindFirstChild("HumanoidRootPart")

					if hum and root then
						local oldPos = root.Position

						hum:Move(Vector3.new(0, 0, -1), true)
						task.wait(.35)

						root.CFrame = root.CFrame + (root.CFrame.LookVector * 5)
						task.wait(.15)

						root.CFrame = CFrame.new(oldPos)
						hum:Move(Vector3.zero, true)
					end
				end
			end)
		end)

	else
		-- 키가 틀렸을 때 예외 처리
		btn.Text = "Wrong Key"
		task.delay(2, function()
			if btn then btn.Text = "Unlock" end
		end)
	end
end)
