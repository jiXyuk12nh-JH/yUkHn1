-- Bloxstrap with Obsidian UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

if not isfile("Bloxstrap/FFlags.json") then 
    writefile("Bloxstrap/FFlags.json", "[]") 
end

local function loadFunction(func: string)
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Functions/"..func..".lua"))()
end

local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
local players = cloneref(game:GetService('Players'))
local lplr = cloneref(game:GetService('Players')).LocalPlayer
local humanoid = lplr.Character:FindFirstChild('Humanoid')
local HttpService = cloneref(game.GetService(game, "HttpService"))
local UserInputService = cloneref(game.GetService(game, "UserInputService"))
local getgenv = getgenv or _G
local files: table = {}

local writefile = writefile or function(name: string, src: string)
    files[name] = src
end

local isfile = isfile or function(file: string)
    return readfile(file) ~= nil and true or false
end

getgenv().Bloxstrap = {}
Bloxstrap.TouchEnabled = UserInputService.TouchEnabled

Bloxstrap.Config = setmetatable({
    OofSound = false,
    FPS = 120,
    AntiAliasingQuality = "Automatic",
    LightingTechnology = "Chosen by game",
    TextureQuality = "Automatic",
    DisablePlayerShadows = false,
    DisablePostFX = false,
    DisableTerrainTextures = false,
    GraySky = false,
    Desync = false,
    HitregFix = false,
    customfonttoggle = false,
    customfontroblox = '',
    customtopbar = false,
    CustomFont = '',
    CameraSensitivity = 1,
    CrosshairImage = '',
    TouchUiSize = 1,
    DeRendering = false,
    GUIScale = false,
    TouchUI = false,
    Crosshair = false,
    RotatingHotbar = false,
    DisplayFPS = false
}, {
    __index = function(s, i)
        s[i] = false
        return s[i]
    end
})

local conf = Bloxstrap.Config
Bloxstrap.canUpdate = false

Bloxstrap.UpdateConfig = function(obj: string, val: any)
    if not Bloxstrap.canUpdate then 
        Bloxstrap.Config = conf 
        return 
    end
    Bloxstrap.Config[obj] = val
end

Bloxstrap.SaveConfig = function()
    return writefile("Bloxstrap/Main/Configs/Default.json", HttpService:JSONEncode(Bloxstrap.Config))
end

if isfile("Bloxstrap/Main/Configs/Default.json") then
    Bloxstrap.Config = HttpService:JSONDecode(readfile("Bloxstrap/Main/Configs/Default.json"))
    conf = Bloxstrap.Config
end

local notif = function(a, b)
    cloneref(game:GetService("StarterGui")):SetCore("SendNotification", {
        Title = 'Bloxstrap', 
        Text = a,
        Duration = b or 6
    })
end

Bloxstrap.error = notif
Bloxstrap.success = notif
Bloxstrap.info = notif
Bloxstrap.ToggleFFlag = loadFunc("ToggleFFlag")
Bloxstrap.GetFFlag = loadFunc("GetFFlag")

-- Window 만들기
local Window = Library:CreateWindow({
    Title = "Bloxstrap",
    Footer = "v1.0",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- Tabs
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Mods = Window:AddTab("Mods", "wrench"),
    Engine = Window:AddTab("Engine", "settings"),
    Appearance = Window:AddTab("Appearance", "paintbrush-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ===== MAIN TAB =====
local MainGroup = Tabs.Main:AddLeftGroupbox("General Settings", "boxes")

MainGroup:AddToggle("OofSound", {
    Text = isfile('Bloxstrap/deathsound.mp3') and 'Custom Death Sound' or 'Old Death Sound',
    Default = Bloxstrap.Config.OofSound,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("OofSound", Value)
        if Value then
            local deathsoundConnection
            local function addcon()
                if getcustomasset == nil then return end
                if deathsoundConnection then
                    deathsoundConnection:Disconnect()
                    deathsoundConnection = nil
                end
                if not lplr.Character then
                    repeat task.wait() until lplr.Character
                end
                if not lplr.Character:FindFirstChild('Humanoid') then
                    repeat task.wait() until lplr.Character:FindFirstChild('Humanoid')
                end
                local humanoid = lplr.Character.Humanoid
                repeat task.wait() until humanoid.Parent ~= nil
                deathsoundConnection = humanoid.HealthChanged:Connect(function()
                    if humanoid.Health <= 0 then
                        game:GetService("Players").LocalPlayer.PlayerScripts.RbxCharacterSounds.Enabled = false
                        local sound = Instance.new("Sound", workspace)
                        sound.SoundId = isfile('Bloxstrap/deathsound.mp3') and getcustomasset('Bloxstrap/deathsound.mp3') or isfile('Bloxstrap/oofsound.mp3') and getcustomasset('Bloxstrap/oofsound.mp3')
                        sound.PlayOnRemove = true 
                        sound.Volume = 0.5
                        sound:Destroy()
                    end
                end)
            end
            addcon()
            lplr.CharacterAdded:Connect(addcon)
        end
    end
})

MainGroup:AddToggle("DisplayFPS", {
    Text = "Display FPS",
    Default = Bloxstrap.Config.DisplayFPS,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("DisplayFPS", Value)
        Bloxstrap.ToggleFFlag('FFlagDebugDisplayFPS', Value)
    end
})

MainGroup:AddSlider("CameraSensitivity", {
    Text = "Camera Sensitivity",
    Min = 1,
    Max = 7,
    Increase = 0.1,
    Default = Bloxstrap.Config.CameraSensitivity,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('CameraSensitivity', Value)
        pcall(function()
            local camerascript = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
            local old = camerascript.getRotation
            camerascript.getRotation = function(...)
                return old(...) * Value
            end
        end)
    end
})

-- ===== MODS TAB =====
local ModsGroup = Tabs.Mods:AddLeftGroupbox("Fast Flags", "wrench")

ModsGroup:AddToggle("GraySky", {
    Text = "Gray Sky",
    Description = "Turns the sky gray (Requires rejoin)",
    Default = Bloxstrap.Config.GraySky,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("GraySky", Value)
        Bloxstrap.ToggleFFlag("FFlagDebugSkyGray", Value)
    end
})

ModsGroup:AddToggle("Desync", {
    Text = "Desync",
    Description = "Lags your character behind on other screens",
    Default = Bloxstrap.Config.Desync,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("Desync", Value)
        Bloxstrap.ToggleFFlag("DFIntS2PhysicsSenderRate", Value and 38000 or 15)
    end
})

ModsGroup:AddToggle("HitregFix", {
    Text = "Hitreg Fix",
    Description = "Makes hitreg better in most games",
    Default = Bloxstrap.Config.HitregFix,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("HitregFix", Value)
        local FFlags = [[
        { 
          "DFIntCodecMaxIncomingPackets": "100",
          "DFIntCodecMaxOutgoingFrames": "10000",
          "DFIntLargePacketQueueSizeCutoffMB": "1000",
          "DFIntMaxProcessPacketsJobScaling": "10000",
          "DFIntMaxProcessPacketsStepsAccumulated": "0",
          "DFIntMaxProcessPacketsStepsPerCyclic": "5000",
          "DFIntMegaReplicatorNetworkQualityProcessorUnit": "10",
          "DFIntNetworkLatencyTolerance": "1",
          "DFIntNetworkPrediction": "120",
          "DFIntOptimizePingThreshold": "50",
          "DFIntPlayerNetworkUpdateQueueSize": "20",
          "DFIntPlayerNetworkUpdateRate": "60",
          "DFIntRaknetBandwidthInfluxHundredthsPercentageV2": "10000",
          "DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
          "DFIntRakNetLoopMs": "1",
          "DFIntRakNetResendRttMultiple": "1",
          "DFIntServerPhysicsUpdateRate": "60",
          "DFIntServerTickRate": "60",
          "DFIntWaitOnRecvFromLoopEndedMS": "100",
          "DFIntWaitOnUpdateNetworkLoopEndedMS": "100",
          "FFlagOptimizeNetwork": "true",
          "FFlagOptimizeNetworkRouting": "true",
          "FFlagOptimizeNetworkTransport": "true",
          "FFlagOptimizeServerTickRate": "true",
          "FIntRakNetResendBufferArrayLength": "128"
        }]]
        FFlags = HttpService:JSONDecode(FFlags:gsub('"True"', "true"):gsub('"False"', "false"))
        for i, v in FFlags do
            Bloxstrap.ToggleFFlag(i, v)
        end
    end
})

-- ===== ENGINE TAB =====
local EngineGroup = Tabs.Engine:AddLeftGroupbox("Engine Settings", "settings")

EngineGroup:AddTextBox("FramerateLimit", {
    Text = "Framerate Limit",
    Description = "Set to 0 for unlimited FPS",
    Default = tostring(Bloxstrap.Config.FPS),
    Callback = function(Value)
        local fps = tonumber(Value)
        if fps == nil then return end
        Bloxstrap.UpdateConfig("FPS", fps)
        Bloxstrap.ToggleFFlag('FFlagTaskSchedulerLimitTargetFpsTo2402', fps and fps >= 70)
        if fps > 0 then
            setfpscap(fps)
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", fps)
        else
            setfpscap(9e9)
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", 120)
        end
    end
})

EngineGroup:AddDropdown("AntiAliasingQuality", {
    Text = "Anti-aliasing Quality",
    Options = {"Automatic", "1x", "2x", "4x"},
    Default = Bloxstrap.Config.AntiAliasingQuality,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("AntiAliasingQuality", Value)
        if not UserInputService.TouchEnabled then return end
        local msaa = Value:find("x") and Value:gsub("x", "") or 0
        Bloxstrap.ToggleFFlag("FIntDebugForceMSAASamples", msaa)
    end
})

EngineGroup:AddDropdown("LightingTechnology", {
    Text = "Lighting Technology",
    Options = {"Chosen by game", "Voxel (Phase 1)", "Shadow Map (Phase 2)", "Future (Phase 3)"},
    Default = Bloxstrap.Config.LightingTechnology,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("LightingTechnology", Value)
        pcall(function()
            local str = Value:lower()
            if str:find("voxel") then
                sethiddenproperty(game.Lighting, "Technology", "Voxel")
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", true)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
            elseif str:find("shadow") then
                sethiddenproperty(game.Lighting, "Technology", "ShadowMap")
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", true)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
            elseif str:find("future") then
                sethiddenproperty(game.Lighting, "Technology", "Future")
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", true)
            else
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
                Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
            end
        end)
    end
})

EngineGroup:AddDropdown("TextureQuality", {
    Text = "Texture Quality",
    Options = {"Automatic", "Lowest (Requires rejoin)", "Low", "Medium", "High", "Highest"},
    Default = Bloxstrap.Config.TextureQuality,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("TextureQuality", Value)
        local str = Value:lower()
        if str:find("lowest") then
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
            Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
            Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 2)
        elseif str:find("low") then
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
            Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
            Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        elseif str:find("medium") then
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
            Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 1)
            Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        elseif str:find("high") and not str:find("highest") then
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
            Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 2)
            Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        elseif str:find("highest") then
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
            Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 3)
            Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        else
            Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", false)
        end
    end
})

local EngineGroup2 = Tabs.Engine:AddRightGroupbox("Performance", "settings")

EngineGroup2:AddToggle("DisablePlayerShadows", {
    Text = "Disable Player Shadows",
    Default = Bloxstrap.Config.DisablePlayerShadows,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("DisablePlayerShadows", Value)
        Bloxstrap.ToggleFFlag("FIntRenderShadowIntensity", Value and 0 or 1)
    end
})

EngineGroup2:AddToggle("DisablePostFX", {
    Text = "Disable Post-Processing Effects",
    Default = Bloxstrap.Config.DisablePostFX,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("DisablePostFX", Value)
        Bloxstrap.ToggleFFlag("FFlagDisablePostFx", Value)
    end
})

EngineGroup2:AddToggle("DisableTerrainTextures", {
    Text = "Disable Terrain Textures",
    Default = Bloxstrap.Config.DisableTerrainTextures,
    Callback = function(Value)
        Bloxstrap.UpdateConfig("DisableTerrainTextures", Value)
        Bloxstrap.ToggleFFlag("FIntTerrainArraySliceSize", Value and 0 or 4)
    end
})

-- ===== APPEARANCE TAB =====
local AppearanceGroup = Tabs.Appearance:AddLeftGroupbox("Visuals", "paintbrush-2")

AppearanceGroup:AddToggle("DeRendering", {
    Text = "De-Rendering",
    Description = "Stops effects and player animations from rendering",
    Default = Bloxstrap.Config.DeRendering,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('DeRendering', Value)
        Bloxstrap.ToggleFFlag('FFlagDisablePostFx', Value)
        if Value then
            task.spawn(function()
                repeat
                    for i,v in players:GetPlayers() do
                        if not lplr.Character or not lplr.Character:FindFirstChild('Humanoid') or lplr.Character.Humanoid.Health <= 0 then break end
                        if v ~= lplr and v.Character and v.Character:FindFirstChild('Humanoid') and v.Character.Humanoid.Health > 0 then
                            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            for i,v in v.Character.Humanoid:GetPlayingAnimationTracks() do
                                v:AdjustSpeed(mag <= 100 and 1 or 0)
                            end
                        end
                    end
                    task.wait()
                until not Bloxstrap.Config.DeRendering
            end)
        end
    end
})

AppearanceGroup:AddToggle("GUIScale", {
    Text = "GUI Scaler",
    Description = "Decrease Roblox GUI scales",
    Default = Bloxstrap.Config.GUIScale,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('GUIScale', Value)
        local guisets = {}
        local funnycon
        if Value then
            funnycon = lplr.PlayerGui.ChildAdded:Connect(function(v)
                if v.Name == 'TouchGui' then return end
                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale = 0.5
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
            end)
            for i,v in lplr.PlayerGui:GetChildren() do
                if v.Name == 'TouchGui' then continue end
                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale = 0.5
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
            end
            for i,v in game.CoreGui:GetChildren() do
                local oldui = v:FindFirstChildWhichIsA('UIScale')
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale -= 0.3
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
            end
        else
            pcall(function() funnycon:Disconnect() funnycon = nil end)
            for i,v in guisets do
                if v.oldscale == 9e9 then
                    v.scaler:Destroy()
                else
                    v.scaler.Scale = v.oldscale
                end
            end
            table.clear(guisets)
        end
    end
})

AppearanceGroup:AddToggle("TouchUI", {
    Text = "Touch GUI Size",
    Description = "Increases touch GUI size",
    Default = Bloxstrap.Config.TouchUI,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('TouchUI', Value)
        local touchuiscale
        if Value then
            touchuiscale = Instance.new('UIScale', lplr.PlayerGui.TouchGui)
            touchuiscale.Scale = Bloxstrap.Config.TouchUiSize or 1.2
        else
            if touchuiscale then
                touchuiscale:Destroy()
            end
        end
    end
})

AppearanceGroup:AddSlider("TouchUiSize", {
    Text = "Touch UI Scale",
    Min = 1,
    Max = 2,
    Increase = 0.1,
    Default = Bloxstrap.Config.TouchUiSize or 1.2,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('TouchUiSize', Value)
    end
})

AppearanceGroup:AddToggle("Crosshair", {
    Text = "Crosshair",
    Default = Bloxstrap.Config.Crosshair,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('Crosshair', Value)
        local screengui = Instance.new('ScreenGui', game.CoreGui)
        screengui.IgnoreGuiInset = true
        local imagelabel
        local chosenimage = Bloxstrap.Config.CrosshairImage or ''
        if Value then
            imagelabel = Instance.new('ImageLabel', screengui)
            imagelabel.Size = UDim2.new(0, 19, 0, 19)
            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            imagelabel.BackgroundTransparency = 1
            imagelabel.Image = chosenimage
            imagelabel.Visible = true
            task.spawn(function()
                repeat
                    task.wait()
                    if not lplr.Character or not lplr.Character:FindFirstChild('Head') then continue end
                    local mag = (lplr.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).magnitude
                    imagelabel.Visible = (mag <= 3)
                until not Bloxstrap.Config.Crosshair
            end)
        else
            if imagelabel then
                imagelabel:Destroy()
            end
        end
    end
})

AppearanceGroup:AddDropdown("CrosshairImage", {
    Text = "Crosshair Image",
    Options = listfiles('Bloxstrap/Images'),
    Default = Bloxstrap.Config.CrosshairImage,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('CrosshairImage', Value)
    end
})

-- Custom Topbar (Appearance Right)
local AppearanceGroup2 = Tabs.Appearance:AddRightGroupbox("Customization", "paintbrush-2")

AppearanceGroup2:AddToggle("customtopbar", {
    Text = "Custom Topbar",
    Description = "Replaces Roblox topbar with custom design",
    Default = Bloxstrap.Config.customtopbar,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('customtopbar', Value)
        if Value then
            pcall(function()
                local fakerobloxbutton = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
                fakerobloxbutton.BorderSizePixel = 0
                fakerobloxbutton.BackgroundTransparency = 0.07
                fakerobloxbutton.Text = ''
                fakerobloxbutton.Name = 'funni'
                fakerobloxbutton.ZIndex = 999
                fakerobloxbutton.BackgroundColor3 = Color3.new()
                fakerobloxbutton.Size = UDim2.new(0, 44, 0, 44)
                fakerobloxbutton.Position = UDim2.new(0, -52, 0, 0)
                fakerobloxbutton.Visible = true
                fakerobloxbutton.MouseButton1Click:Connect(function()
                    firesignal(game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.Activated)
                end)
                local imagelabel = Instance.new('ImageLabel', fakerobloxbutton)
                imagelabel.Size = UDim2.new(0, 22, 0, 22)
                imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
                imagelabel.BackgroundTransparency = 1
                imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
                imagelabel.ImageColor3 = Color3.new(1, 1, 1)
                Instance.new('UICorner', fakerobloxbutton).CornerRadius = UDim.new(1, 0)
                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Visible = false
            end)
        else
            pcall(function()
                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Visible = true
                for i,v in game:GetService("CoreGui").TopBarApp.UnibarLeftFrame:GetChildren() do
                    if v.Name == 'funni' then v:Destroy() end
                end
            end)
        end
    end
})

AppearanceGroup2:AddToggle("RotatingHotbar", {
    Text = "Spin Hotbar",
    Description = "Spins the Roblox logo around",
    Default = Bloxstrap.Config.RotatingHotbar,
    Callback = function(Value)
        Bloxstrap.UpdateConfig('RotatingHotbar', Value)
        if Value then
            task.spawn(function()
                repeat
                    pcall(function()
                        game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation += 1.5
                    end)
                    task.wait()
                until not Bloxstrap.Config.RotatingHotbar
            end)
        else
            pcall(function()
                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation = 0
            end)
        end
    end
})

-- Font Settings
local AppearanceGroup3 = Tabs.Appearance:AddRightGroupbox("Fonts", "paintbrush-2")

local font = 'Arimo'
local currentcustomfont = nil
local updatedfonts = {}
local uriekfqjkfjqekf = false
local funnycon84

AppearanceGroup3:AddToggle("customfonttoggle", {
    Text = "Change Game Fonts",
    Description = "Changes game font to selected one",
    Default = Bloxstrap.Config.customfonttoggle,
    Callback = function(Value)
        uriekfqjkfjqekf = Value
        Bloxstrap.UpdateConfig('customfonttoggle', Value)
        if Value then
            funnycon84 = game.DescendantAdded:Connect(function(v)
                if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and uriekfqjkfjqekf and font ~= nil then
                    local currfont = font
                    table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                        if currentcustomfont then
                            v.FontFace = currentcustomfont
                        else
                            v.Font = Enum.Font[currfont]
                        end
                    end)})
                    if currentcustomfont then
                        v.FontFace = currentcustomfont
                    else
                        v.Font = Enum.Font[currfont]
                    end
                end
            end)
            for i,v in game:GetDescendants() do
                if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and font ~= nil then
                    local currfont = font
                    pcall(function() 
                        table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                            if currentcustomfont then
                                v.FontFace = currentcustomfont
                            else
                                v.Font = Enum.Font[currfont]
                            end
                        end)}) 
                    end)
                    if currentcustomfont then
                        v.FontFace = currentcustomfont
                    else
                        v.Font = Enum.Font[currfont]
                    end
                end
            end
        else
            pcall(function() funnycon84:Disconnect() end)
            for i,v in updatedfonts do
                v.connection:Disconnect()
                v.connection = nil
                v.inst.Font = Enum.Font[v.font]
            end
            table.clear(updatedfonts)
        end
    end
})

local fontlist = {}
for i,v in Enum.Font:GetEnumItems() do
    table.insert(fontlist, tostring(v):split('.')[3])
end

AppearanceGroup3:AddDropdown("customfontroblox", {
    Text = "Preset Fonts",
    Options = fontlist,
    Default = Bloxstrap.Config.customfontroblox or '',
    Callback = function(Value)
        Bloxstrap.UpdateConfig('customfontroblox', Value)
        font = Value
    end
})

local fontlists = {'none'}
for i,v in listfiles('Bloxstrap/Main/Fonts') do
    if v:find('.ttf') then
        table.insert(fontlists, v)
    end
end

AppearanceGroup3:AddDropdown("CustomFont", {
    Text = "Custom Fonts",
    Options = fontlists,
    Description = 'Fonts in "Bloxstrap/Main/Fonts" folder',
    Default = Bloxstrap.Config.CustomFont,
    Callback = function(Value)
        if Value == 'none' then
            currentcustomfont = nil
            return Bloxstrap.UpdateConfig('CustomFont', '')
        end
        Bloxstrap.UpdateConfig('CustomFont', Value)
        local json = Value:gsub('.ttf', '.json')
        if not isfile(json) then
            writefile(json, HttpService:JSONEncode({name = 'font', faces = {
                {
                    name = 'Regular',
                    weight = 600,
                    style = 'normal',
                    assetId = getcustomasset(Value)
                }
            }}))
        end
        currentcustomfont = Font.new(getcustomasset(json), Enum.FontWeight.Regular)
        if Bloxstrap.Config.customfonttoggle then
            -- Toggle off and on to refresh
            local toggle = Tabs.Appearance:GetToggle("customfonttoggle")
            if toggle then
                toggle:Toggle(false)
                toggle:Toggle(true)
            end
        end
    end
})

-- ===== UI SETTINGS TAB =====
local UIGroup = Tabs["UI Settings"]:AddLeftGroupbox("UI Settings", "settings")

UIGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        -- Obsidian library handles this
    end
})

-- Bloxstrap start
Bloxstrap.canUpdate = true

-- Add icon button to topbar
pcall(function()
    local button = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.07
    button.Text = ''
    button.BackgroundColor3 = Color3.new()
    button.Size = UDim2.new(0, 44, 0, 44)
    button.Position = UDim2.new(0, 103, 0, 0)

    local imagelabel = Instance.new('ImageLabel', button)
    imagelabel.Size = UDim2.new(0, 22, 0, 22)
    imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
    imagelabel.BackgroundTransparency = 1
    imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
    imagelabel.ImageColor3 = Color3.new(1, 1, 1)

    local grad = Instance.new('UIGradient', imagelabel)
    grad.Rotation = 60
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
    })

    Instance.new('UICorner', button).CornerRadius = UDim.new(1, 0)
    
    button.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
end)

return Bloxstrap