-- GUIがすでに存在していれば削除
pcall(function()
    local oldGui = game.CoreGui:FindFirstChild("KANO-HUB")
    if oldGui then
        oldGui:Destroy()
    end
end)

-- 🔇 掴まれたときのサウンド（泣き声・叫び声）を無効化する
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function muteGrabSounds(character)
	for _, sound in ipairs(character:GetDescendants()) do
		if sound:IsA("Sound") and (sound.Name:lower():find("scream") or sound.Name:lower():find("cry")) then
			sound:Stop()
			sound.Volume = 0
			sound.Playing = false
		end
	end
end

local function setupCharacter(char)
	RunService.Heartbeat:Connect(function()
		muteGrabSounds(char)
	end)
end

-- 自分自身のキャラにも適用
if Players.LocalPlayer.Character then
	setupCharacter(Players.LocalPlayer.Character)
end
Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- 📦 必要なサービス
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 🧍 ローカルプレイヤーとイベント
local localPlayer = Players.LocalPlayer
local CharacterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents") or {}
local Struggle = CharacterEvents:FindFirstChild("Struggle")

-- 🌐 グローバル変数
local walkSpeedEnabled = false
local walkSpeedValue = 5
local jumpPowerValue = 24
getgenv().NoclipEnabled = false
local autoStruggleCoroutine = nil
local antiExplosionConnection = nil

-- 🚀 初期ジャンプパワー変数（スライダーで使う）
N = N or {}
N.jps = 50

-- 🔍 GrabPartsの部品を取得してテーブルに格納
local function getDescendantParts(name)
    local parts = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Part") and d.Name == name then
            table.insert(parts, d)
        end
    end
    return parts
end

-- 🧪 Grab用パーツ取得
local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")

-- 🧪 Grabタイプに応じた効果を与える共通関数（毒 / 放射能）
local function grabHandler(grabType)
    while true do
        task.wait()
        pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child:FindFirstChild("GrabPart") then
                local weld = child.GrabPart:FindFirstChild("WeldConstraint")
                if weld and weld.Part1 then
                    local head = weld.Part1.Parent and weld.Part1.Parent:FindFirstChild("Head")
                    if head then
                        local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2)
                            part.Transparency = 1
                            part.Position = head.Position
                        end
                        task.wait()
                        for _, part in pairs(partsTable) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end
        end)
    end
end

-- 🚪 Noclip Grab（キャラパーツのCanCollideをfalseに）
local function noclipGrab()
    while true do
        task.wait()
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if grabParts then
                local grabPart = grabParts:FindFirstChild("GrabPart")
                if grabPart then
                    local weld = grabPart:FindFirstChild("WeldConstraint")
                    if weld and weld.Part1 then
                        local character = weld.Part1.Parent
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end)
    end
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- 💥 Anti Explosion: Ragdoll中はアンカーする
local function setupAntiExplosion(character)
    local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
    if partOwner then
        antiExplosionConnection = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Anchored = partOwner.Value
                end
            end
        end)
    end
end

-- 🎯 キャラクターが変更されるたびに適用
local function setupCharacter(char)
    RunService.Heartbeat:Connect(function()
        preventVoidFall(char)
    end)
    setupAntiExplosion(char)
end

-- 🚀 ローカルプレイヤーに適用
if Players.LocalPlayer.Character then
    setupCharacter(Players.LocalPlayer.Character)
end
Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- 🧍‍♂️ ローカル情報を格納するテーブル
local O = {
	me = localPlayer,
	backpack = localPlayer:WaitForChild("Backpack")
}

-- Rayfield UIの読み込み
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

task.spawn(function()
    -- 🔁 FOVを変更（スマホ・PC共通で動作）
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = 120
    end

    -- 🔁 Blitz（FTAP）スクリプトを起動
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/refs/heads/main/FTAP.lua"))()
end)

-- ウィンドウ作成
local Window = Rayfield:CreateWindow({
    Name = "FTAP-HUB",
    LoadingTitle = "Loading…",
    LoadingSubtitle = "Owner: player",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ftaphub",
        FileName = "KeyConfig"
    },
    KeySystem = false
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.Stepped:Connect(function()
    if not getgenv().NoclipEnabled then return end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)


-- Home tab
local HomeTab = Window:CreateTab("Home", 11632424326)

HomeTab:CreateParagraph({
    Title = "hello!",
    Content = [[
Thank you for using FTAP HUB! I made everything from scratch! I also created a Discord server, so please join if you'd like！
    ]]
})

-- Grabタブ追加
local grabtab = Window:CreateTab("Grab", 10723404472)

-- Detect when a GrabParts model is added to the workspace
Workspace.ChildAdded:Connect(function(model)
   if model.Name == "GrabParts" then
      local grabPart = model:FindFirstChild("GrabPart")
      if grabPart and grabPart:FindFirstChild("WeldConstraint") then
         currentPart = grabPart.WeldConstraint.Part1
         print("Target part set.")

         -- Reset currentPart if the model is removed
         model:GetPropertyChangedSignal("Parent"):Connect(function()
            if not model.Parent then
               currentPart = nil
            end
         end)
      end
   end
end)


local Paragraph = grabtab:CreateParagraph({Title = "Grab stuff", Content = "These effects apply when you grab someone"})

-- 🐍 Poison Grab トグル
local poisonGrabCoroutine = nil
grabtab:CreateToggle({
    Name = "Poison grab",
    CurrentValue = false,
    Flag = "PoisonGrab",
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function()
                grabHandler("poison")
            end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
            end
        end
    end
})

-- ☢️ Radioactive Grab トグル
local radioactiveGrabCoroutine = nil
grabtab:CreateToggle({
    Name = "Radioactive grab",
    CurrentValue = false,
    Flag = "RadioactiveGrab",
    Callback = function(enabled)
        if enabled then
            radioactiveGrabCoroutine = coroutine.create(function()
                grabHandler("radioactive")
            end)
            coroutine.resume(radioactiveGrabCoroutine)
        else
            if radioactiveGrabCoroutine then
                coroutine.close(radioactiveGrabCoroutine)
                radioactiveGrabCoroutine = nil
            end
        end
    end
})

-- 🚪 Noclip Grab トグル
local noclipGrabCoroutine = nil
grabtab:CreateToggle({
    Name = "noclip grab",
    CurrentValue = false,
    Flag = "NoclipGrab",
    Callback = function(enabled)
        if enabled then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        else
            if noclipGrabCoroutine then
                coroutine.close(noclipGrabCoroutine)
                noclipGrabCoroutine = nil
            end
        end
    end
})

local AntiTab = Window:CreateTab("anti", 10734951847)

local Toggle = AntiTab:CreateToggle({
    Name = "anti grab",
    CurrentValue = false,
    Flag = "AutoStruggle", 
    Callback = function(enabled)
        if enabled then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner then
                        Struggle:FireServer()
                        ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        while localPlayer.IsHeld.Value do
                            wait()
                        end
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
        else
            if autoStruggleCoroutine then
                autoStruggleCoroutine:Disconnect()
                autoStruggleCoroutine = nil
            end
        end
    end
})

local Toggle = AntiTab:CreateToggle({
    Name = "anti Explosion",
    CurrentValue = false,
    Flag = "AntiExplosion", 
    Callback = function(enabled)
        if enabled then
            if localPlayer.Character then
                setupAntiExplosion(localPlayer.Character)
            end
            characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
                if antiExplosionConnection then
                    antiExplosionConnection:Disconnect()
                end
                setupAntiExplosion(character)
            end)
        else
            if antiExplosionConnection then
                antiExplosionConnection:Disconnect()
                antiExplosionConnection = nil
            end
            if characterAddedConn then
                characterAddedConn:Disconnect()
                characterAddedConn = nil
            end
        end
    end
})

local AntiLag = AntiTab:CreateToggle({
    Name = "anti lag",
    CurrentValue = false,
    Flag = "AntiLag",
    Callback = function(Value)
        AntiLaggg = Value
        local charScript = O.me:FindFirstChild("PlayerScripts") and O.me.PlayerScripts:FindFirstChild("CharacterAndBeamMove")
        if charScript then
            charScript.Disabled = Value
        else
            warn("[AntiLag] CharacterAndBeamMove スクリプトが見つかりませんでした。")
        end
    end,
})

AntiTab:CreateToggle({
    Name = "Freeze",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        antiGrabEnabled = Value
        if antiGrabEnabled then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        else
            game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end,
})

local PlayerTab = Window:CreateTab("Player",  11632434473)

PlayerTab:CreateButton({
    Name = "Fixcam",
    Callback = function()
        game.Players.LocalPlayer.CameraMaxZoomDistance = 8000000
        game.Players.LocalPlayer.CameraMode = "Classic"
    end,
})

-- 🔘 Walk Speed トグル
PlayerTab:CreateToggle({
    Name = "walk speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle", 
    Callback = function(Value)
        walkSpeedEnabled = Value
        while walkSpeedEnabled do
            local char = localPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local moveDir = char.Humanoid.MoveDirection
                hrp.CFrame = hrp.CFrame + moveDir * (walkSpeedValue / 10)
            end
            task.wait()
        end
        -- 無効化時に速度リセット
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end,
})

-- 🎚 Walk Speed スライダー
PlayerTab:CreateSlider({
    Name = "speed",
    Range = {0, 300},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        walkSpeedValue = Value
    end,
})

-- Infinite Jump 設定
local infiniteJumpEnabled = false
local UIS = game:GetService("UserInputService")
local jumpConnection

PlayerTab:CreateToggle({
    Name = "Infinite jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            jumpConnection = UIS.JumpRequest:Connect(function()
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end,
})

-- 🎚 ジャンプパワースライダー（即時反映）
jumpSliderObject = PlayerTab:CreateSlider({
    Name = "jump Power",
    Range = {24, 300},
    Increment = 1,
    Suffix = "",
    CurrentValue = jumpPowerValue,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        jumpPowerValue = Value

        -- ジャンプ力反映
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
    end,
})

-- ✅ Add ESP Tab to existing Rayfield Window
local ESPTab = Window:CreateTab("ESP", 4483345998)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State
local espEnabled, lineEnabled = false, false
local hue, Billboards, Lines = 0, {}, {}

-- Remove ESP for a player
local function removeESP(player)
	if Billboards[player] then
		pcall(function() Billboards[player].Parent:Destroy() end)
		Billboards[player] = nil
	end
	if Lines[player] then
		pcall(function() Lines[player]:Remove() end)
		Lines[player] = nil
	end
end

-- Create BillboardGui for ESP
local function createBillboard(player, character)
	removeESP(player)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	local hum = character:FindFirstChild("Humanoid")
	if not (hrp and hum) then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "ESP"
	gui.Adornee = head or hrp
	gui.Size = UDim2.new(0, 160, 0, 40)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Text = ""

	Billboards[player] = label
end

-- Setup for each player
local function setupPlayer(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		task.wait(0.1)
		createBillboard(player, char)
	end)
	if player.Character then
		createBillboard(player, player.Character)
	end
	player.AncestryChanged:Connect(function(_, parent)
		if not parent then removeESP(player) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

-- Render loop
RunService.RenderStepped:Connect(function()
	if not (espEnabled or lineEnabled) then return end
	hue = (hue + 1) % 360
	local color = Color3.fromHSV(hue / 360, 1, 1)

	for player, label in pairs(Billboards) do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and espEnabled then
			local hrp = char.HumanoidRootPart
			local dist = 0
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			end
			local hp = math.floor(char.Humanoid.Health)
			label.Text = ("%s | %d | %d"):format(player.DisplayName, dist, hp)
			label.Parent.Enabled = true
		else
			if label and label.Parent then label.Parent.Enabled = false end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and lineEnabled then
				if not Lines[player] then
					local line = Drawing.new("Line")
					line.Thickness = 1
					line.Visible = true
					line.ZIndex = 1
					Lines[player] = line
				end

				local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
					local to = Vector2.new(screenPos.X, screenPos.Y)
					Lines[player].From = from
					Lines[player].To = to
					Lines[player].Color = color
					Lines[player].Visible = true
				else
					Lines[player].Visible = false
				end
			else
				if Lines[player] then
					Lines[player].Visible = false
				end
			end
		end
	end
end)

ESPTab:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Callback = function(v)
		espEnabled = v
		for _, l in pairs(Billboards) do
			if l.Parent then
				l.Parent.Enabled = v
			end
		end
	end
})

ESPTab:CreateToggle({
	Name = "line",
	CurrentValue = false,
	Callback = function(v)
		lineEnabled = v
	end
})

local TeleportTab = Window:CreateTab("Teleport", 11647702726)

TeleportTab:CreateButton({
    Name = "Purple House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(255, -7, 449))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Green House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(-534, -7, 93))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Blue House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(512, 83, -343))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Chinese  House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(548, 123, -73))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "RED House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(-493, -7, -165))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "spawn",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(0, -7, 0))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Farm House",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(-192, 60, -282))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Slot1",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(54, -7, -115))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Slot2",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(170, -7, 527))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Slot3",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(-213, 86, 421))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Slot4",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(Vector3.new(-540, -7, -40))
        end
    end,
})

-- Script Tab
local ScriptTab = Window:CreateTab("Scripts", 7733920644)

ScriptTab:CreateButton({
    Name = "IY",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
    end,
})

ScriptTab:CreateButton({
    Name = "fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

ScriptTab:CreateButton({
    Name = "vfly",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Vehicle-Fly-by-WR-33440"))()
    end,
})

ScriptTab:CreateButton({
    Name = "Ghost-hub",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub'))()
    end,
})

ScriptTab:CreateButton({
    Name = "Elysium-Hub",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Fling-Things-and-People-Elysium-Hub-25967"))()
    end,
})

ScriptTab:CreateButton({
    Name = "coordinate",
    Callback = function()
        local S = Instance.new("ScreenGui")
local L = Instance.new("Frame")
local D = Instance.new("Frame")
local T = Instance.new("TextButton")
local X = Instance.new("TextBox")
local Z = Instance.new("TextBox")
local Y = Instance.new("TextBox")
local V = Instance.new("TextLabel")
local H = Instance.new("TextLabel")
local C = Instance.new("TextButton")

--- This sets the PlaceHolderText to the players current CFrame ---
local P = game.Players.LocalPlayer.Character.HumanoidRootPart
local CF = P.CFrame
local Cx, Cy, Cz, m11, m12, m13, m21, m22, m23, m31, m32, m33 = CF:components()
--- This sets the PlaceHolderText to the players current CFrame ---

S.Name = "S"
S.Parent = game:WaitForChild("CoreGui")
S.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

L.Name = "L"
L.Parent = S
L.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
L.BorderColor3 = Color3.fromRGB(110, 110, 110)
L.Position = UDim2.new(0.321100891, 0, 0.282937378, 0)
L.Size = UDim2.new(0, 350, 0, 200)
L.Active = true
L.Draggable = true

D.Name = "D"
D.Parent = L
D.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
D.BorderColor3 = Color3.fromRGB(110, 110, 110)
D.Position = UDim2.new(0.042857144, 0, 0.200000003, 0)
D.Size = UDim2.new(0, 320, 0, 145)

T.Name = "T"
T.Parent = D
T.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
T.BorderColor3 = Color3.fromRGB(84, 92, 38)
T.Position = UDim2.new(0.046875, 0, 0.551724136, 0)
T.Size = UDim2.new(0, 289, 0, 50)
T.Font = Enum.Font.Gotham
T.Text = "Teleport"
T.TextColor3 = Color3.fromRGB(255, 255, 255)
T.TextSize = 15.000
T.MouseButton1Click:connect(function()
P.CFrame = CFrame.new(X.Text, Y.Text, Z.Text)
end)

X.Name = "X"
X.Parent = D
X.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
X.BorderColor3 = Color3.fromRGB(96, 12, 12)
X.Position = UDim2.new(0.046875, 0, 0.103448279, 0)
X.Size = UDim2.new(0, 86, 0, 50)
X.Font = Enum.Font.Gotham
X.PlaceholderText = Cx
X.Text = ""
X.TextColor3 = Color3.fromRGB(255, 255, 255)
X.TextSize = 14.000

Z.Name = "Z"
Z.Parent = D
Z.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Z.BorderColor3 = Color3.fromRGB(96, 12, 12)
Z.Position = UDim2.new(0.681249976, 0, 0.103448279, 0)
Z.Size = UDim2.new(0, 86, 0, 50)
Z.Font = Enum.Font.Gotham
Z.PlaceholderText = Cz
Z.Text = ""
Z.TextColor3 = Color3.fromRGB(255, 255, 255)
Z.TextSize = 14.000

Y.Name = "Y"
Y.Parent = D
Y.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Y.BorderColor3 = Color3.fromRGB(96, 12, 12)
Y.Position = UDim2.new(0.365624994, 0, 0.103448279, 0)
Y.Size = UDim2.new(0, 85, 0, 50)
Y.Font = Enum.Font.Gotham
Y.PlaceholderText = Cy
Y.Text = ""
Y.TextColor3 = Color3.fromRGB(255, 255, 255)
Y.TextSize = 14.000

V.Name = "V"
V.Parent = L
V.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
V.BackgroundTransparency = 1.000
V.BorderSizePixel = 0
V.Position = UDim2.new(0.042857144, 0, 0, 0)
V.Size = UDim2.new(0, 140, 0, 40)
V.Font = Enum.Font.GothamBold
V.Text = "o u s e V 3 r m"
V.TextColor3 = Color3.fromRGB(255, 255, 255)
V.TextSize = 14.000

H.Name = "H"
H.Parent = L
H.BackgroundColor3 = Color3.fromRGB(186, 3, 3)
H.BackgroundTransparency = 1.000
H.BorderSizePixel = 0
H.Position = UDim2.new(0.042857144, 0, 0, 0)
H.Size = UDim2.new(0, 25, 0, 40)
H.Font = Enum.Font.GothamBold
H.Text = "H"
H.TextColor3 = Color3.fromRGB(186, 3, 3)
H.TextSize = 16.000

C.Name = "C"
C.Parent = L
C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
C.BackgroundTransparency = 1.000
C.BorderSizePixel = 0
C.Position = UDim2.new(0.885714352, 0, 0, 0)
C.Size = UDim2.new(0, 40, 0, 40)
C.Font = Enum.Font.GothamBold
C.Text = "X"
C.TextColor3 = Color3.fromRGB(255, 255, 255)
C.TextSize = 14.000
C.MouseButton1Click:connect(function()
S:Destroy()
end)

--- This auto-updates the PlaceHolderText to the players current CFrame ---
while true do
  function update ()
    local P = game.Players.LocalPlayer.Character.HumanoidRootPart
    local CF = P.CFrame
    local Cx, Cy, Cz, m11, m12, m13, m21, m22, m23, m31, m32, m33 = CF:components()
    X.PlaceholderText = math.floor(Cx+0.5)
    Y.PlaceholderText = math.floor(Cy+0.5)
    Z.PlaceholderText = math.floor(Cz+0.5)
  end
  pcall ( update )
  wait()
end
--- This auto-updates the PlaceHolderText to the players current CFrame ---
    end,
})

ScriptTab:CreateButton({
    Name = "Bliz_T",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/refs/heads/main/FTAP.lua"))()
    end,
})

ScriptTab:CreateButton({
    Name = "dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

-- CHAT Tab
local CHATTab = Window:CreateTab("notification", 7733678388)

-- 通知の有効フラグ
local notifyEnabled = false

-- トグルスイッチの追加
CHATTab:CreateToggle({
    Name = "Join＆Leave",
    CurrentValue = false,
    Flag = "PlayerJoinLeaveToggle",
    Callback = function(Value)
        notifyEnabled = Value
    end,
})

-- 通知機能
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    if notifyEnabled and player ~= Players.LocalPlayer then
        Rayfield:Notify({
            Title = "welcome!!",
            Content = player.DisplayName .. "joined the game!",
            Duration = 6
        })
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if notifyEnabled and player ~= Players.LocalPlayer then
        Rayfield:Notify({
            Title = "Bye bye...",
            Content = player.DisplayName .. "has left the game.",
            Duration = 6
        })
    end
end)


-- weather Tab
local weatherTab = Window:CreateTab("Sky", 7733774602)

-- 🌤 時間スライダー
weatherTab:CreateSlider({
    Name = "time",
    Range = {0, 23},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 14,
    Flag = "TimeSlider",
    Callback = function(Value)
        game.Lighting.ClockTime = Value
    end,
})

-- 🌈 空の色スライダー（Ambient）
weatherTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 255},
    Increment = 1,
    Suffix = "",
    CurrentValue = 128,
    Flag = "AmbientSlider",
    Callback = function(Value)
        game.Lighting.Ambient = Color3.fromRGB(Value, Value, Value)
    end,
})


local CoinTab = Window:CreateTab("coin", 10734964441)

local Input = CoinTab:CreateInput({
    Name = "Number of coins",
    CurrentValue = "",
    PlaceholderText = "input",
    RemoveTextAfterFocusLost = false,
    Flag = "Coin",
    Callback = function(Text)
        skolko = Text 
    end,
})

local Button = CoinTab:CreateButton({
    Name = "get coin",
    Callback = function()
        local coinAmount = tonumber(skolko) or 0 
        game.Players.LocalPlayer.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text = tostring(coinAmount)
    end,
})

-- 🔧 前提：バインドタブ作成
local bindtab = Window:CreateTab("binds", 7733799901)

bindtab:CreateKeybind({
    Name = "Click TP",
    CurrentKeybind = "", -- ←ここに "Q" とか入れてもOK
    HoldToInteract = false,
    Flag = "ClickTPBind", 
    Callback = function()
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local targetPos = mouse.Hit and mouse.Hit.Position

        if hrp and targetPos then
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0)) -- ちょっと浮かせる
        end
    end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function get_all12(part)
    local model = part and part:FindFirstAncestorOfClass("Model")
    if not model then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    return hrp, hum, head, hrp, hum, head
end

local function check_hum(hum)
    return hum and hum.Health > 0
end

local function check_prem(model)
    return true
end

local function fling_target(hrp)
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(9999, 9999, 9999)
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.P = 1e5
    bv.Parent = hrp
    game.Debris:AddItem(bv, 0.2)
end

bindtab:CreateKeybind({
    Name = "fling player",
    CurrentKeybind = "",
    HoldToInteract = false,
    Flag = "FlingPlayerBind",
    Callback = function()
        local target = Mouse.Target
        local hrp, hum, _, hrp1, hum1 = get_all12(target)
        if hum and check_hum(hum) and hum1 and check_hum(hum1) and check_prem(hrp1.Parent) then
            fling_target(hrp)
        end
    end,
})

local OwnerTab = Window:CreateTab("Owner Info", 138601761823259)

OwnerTab:CreateSection("Owner")

OwnerTab:CreateParagraph({
    Title = "About the Owner",
    Content = "Hello! This tab contains information about the owner."
})

OwnerTab:CreateSection("Developer Info")

OwnerTab:CreateParagraph({
    Title = "Created By",
    Content = "Script Creator: ftapplayer_0723\nAlso known as: FTAPplayer\nCreated on: 2025/06/12\n\nContact me on Discord:\nftaphub"
})

OwnerTab:CreateButton({
    Name = "roblox",
    Callback = function()
        setclipboard("ftapplayer_0723")
        Rayfield:Notify({
            Title = "Copied！",
            Content = "Copied the owner's Roblox ID!",
            Duration = 3
        })
    end
})

OwnerTab:CreateButton({
    Name = "Discord Server",
    Callback = function()
        setclipboard("https://discord.gg/SDyvWyy7ye")
        Rayfield:Notify({
            Title = "Copied",
            Content = "Discord server link has been copied to clipboard",
            Duration = 3
        })
    end,
})

-- 🔗 TikTok リンク（コピー用）
OwnerTab:CreateButton({
    Name = "TikTok",
    Callback = function()
        setclipboard("tiktok.com/@ftapplayer")
        Rayfield:Notify({
            Title = "Copied!",
            Content = "TikTok link copied to clipboard!",
            Duration = 3
        })
    end
})

OwnerTab:CreateButton({
    Name = "X（Twitter）",
    Callback = function()
        setclipboard("https://x.com/FTAPplayer")
        Rayfield:Notify({
            Title = "Copied!",
            Content = "Copied the owner's X (Twitter) profile link!",
            Duration = 3
        })
    end
})

-- Infoタブ
local InfoTab = Window:CreateTab("account Info", 11472832266)

local player = game.Players.LocalPlayer

InfoTab:CreateParagraph({
    Title = "User name",
    Content = player.Name
})

InfoTab:CreateParagraph({
    Title = "Display Name",
    Content = player.DisplayName
})


InfoTab:CreateParagraph({
    Title = "User ID",
    Content = tostring(player.UserId)
})

InfoTab:CreateParagraph({
    Title = "account Time",
    Content = player.Name .. ": " .. tostring(player.AccountAge) .. " "
})

local MarketplaceService = game:GetService("MarketplaceService")
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

if success and info then
    InfoTab:CreateParagraph({
        Title = "game Name",
        Content = info.Name
    })
else
    InfoTab:CreateParagraph({
        Title = "ゲーム名",
        Content = "取得失敗"
    })
end

InfoTab:CreateParagraph({
    Title = "Game ID",
    Content = tostring(game.PlaceId)
})
