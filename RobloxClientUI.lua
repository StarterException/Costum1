-- Costum UI — Orion-kompatible API (jensonhirst/Orion); Theme-System, Premium-Extras, Glass-Layout.
-- Referenz: https://raw.githubusercontent.com/jensonhirst/Orion/refs/heads/main/source

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	_ThemeListeners = {},
	_PremiumListeners = {},
	_PremiumVerifyFn = nil,
	_PremiumKeyList = nil,
	_PremiumPersistPath = nil,
	PremiumUnlocked = false,
	Themes = {
		Default = {
			DisplayName = "Aurora",
			Main = Color3.fromRGB(7, 9, 15),
			Second = Color3.fromRGB(16, 19, 30),
			Stroke = Color3.fromRGB(48, 58, 82),
			Divider = Color3.fromRGB(28, 33, 48),
			Text = Color3.fromRGB(252, 253, 255),
			TextDark = Color3.fromRGB(126, 136, 168),
			Accent = Color3.fromRGB(56, 189, 248),
			Accent2 = Color3.fromRGB(124, 214, 255)
		},
		Obsidian = {
			DisplayName = "Obsidian",
			Main = Color3.fromRGB(4, 6, 10),
			Second = Color3.fromRGB(12, 14, 20),
			Stroke = Color3.fromRGB(38, 42, 56),
			Divider = Color3.fromRGB(22, 24, 34),
			Text = Color3.fromRGB(245, 246, 250),
			TextDark = Color3.fromRGB(118, 124, 148),
			Accent = Color3.fromRGB(147, 197, 253),
			Accent2 = Color3.fromRGB(186, 220, 255)
		},
		Crimson = {
			DisplayName = "Crimson",
			Main = Color3.fromRGB(14, 8, 10),
			Second = Color3.fromRGB(26, 14, 18),
			Stroke = Color3.fromRGB(72, 38, 48),
			Divider = Color3.fromRGB(40, 22, 28),
			Text = Color3.fromRGB(255, 248, 250),
			TextDark = Color3.fromRGB(200, 160, 170),
			Accent = Color3.fromRGB(251, 113, 133),
			Accent2 = Color3.fromRGB(255, 180, 190)
		},
		Emerald = {
			DisplayName = "Emerald",
			Main = Color3.fromRGB(6, 12, 10),
			Second = Color3.fromRGB(14, 24, 20),
			Stroke = Color3.fromRGB(36, 62, 52),
			Divider = Color3.fromRGB(24, 42, 36),
			Text = Color3.fromRGB(240, 255, 248),
			TextDark = Color3.fromRGB(130, 168, 150),
			Accent = Color3.fromRGB(52, 211, 153),
			Accent2 = Color3.fromRGB(150, 240, 200)
		},
		Amethyst = {
			DisplayName = "Amethyst",
			Main = Color3.fromRGB(10, 8, 18),
			Second = Color3.fromRGB(20, 16, 36),
			Stroke = Color3.fromRGB(58, 48, 88),
			Divider = Color3.fromRGB(36, 30, 58),
			Text = Color3.fromRGB(248, 244, 255),
			TextDark = Color3.fromRGB(168, 156, 210),
			Accent = Color3.fromRGB(167, 139, 250),
			Accent2 = Color3.fromRGB(210, 190, 255)
		},
		Rose = {
			DisplayName = "Rose",
			Main = Color3.fromRGB(14, 8, 12),
			Second = Color3.fromRGB(24, 14, 20),
			Stroke = Color3.fromRGB(68, 40, 56),
			Divider = Color3.fromRGB(40, 24, 34),
			Text = Color3.fromRGB(255, 248, 252),
			TextDark = Color3.fromRGB(200, 170, 188),
			Accent = Color3.fromRGB(244, 114, 182),
			Accent2 = Color3.fromRGB(251, 207, 232)
		},
		Slate = {
			DisplayName = "Slate",
			Main = Color3.fromRGB(10, 12, 16),
			Second = Color3.fromRGB(20, 22, 28),
			Stroke = Color3.fromRGB(50, 54, 64),
			Divider = Color3.fromRGB(32, 36, 44),
			Text = Color3.fromRGB(248, 250, 252),
			TextDark = Color3.fromRGB(130, 140, 158),
			Accent = Color3.fromRGB(148, 163, 184),
			Accent2 = Color3.fromRGB(203, 213, 225)
		},
		Cyber = {
			DisplayName = "Cyber",
			Main = Color3.fromRGB(6, 8, 18),
			Second = Color3.fromRGB(12, 14, 32),
			Stroke = Color3.fromRGB(40, 48, 92),
			Divider = Color3.fromRGB(22, 28, 58),
			Text = Color3.fromRGB(236, 254, 255),
			TextDark = Color3.fromRGB(120, 200, 220),
			Accent = Color3.fromRGB(34, 211, 238),
			Accent2 = Color3.fromRGB(168, 85, 247)
		},
		Sunset = {
			DisplayName = "Sunset",
			Main = Color3.fromRGB(16, 10, 8),
			Second = Color3.fromRGB(28, 18, 14),
			Stroke = Color3.fromRGB(78, 48, 38),
			Divider = Color3.fromRGB(48, 30, 24),
			Text = Color3.fromRGB(255, 247, 240),
			TextDark = Color3.fromRGB(210, 170, 150),
			Accent = Color3.fromRGB(251, 146, 60),
			Accent2 = Color3.fromRGB(253, 224, 71)
		},
		Aurum = {
			DisplayName = "Aurum",
			PremiumOnly = true,
			LuxChrome = true,
			Main = Color3.fromRGB(12, 10, 6),
			Second = Color3.fromRGB(22, 18, 10),
			Stroke = Color3.fromRGB(92, 72, 38),
			Divider = Color3.fromRGB(48, 40, 22),
			Text = Color3.fromRGB(255, 250, 235),
			TextDark = Color3.fromRGB(210, 190, 150),
			Accent = Color3.fromRGB(250, 204, 21),
			Accent2 = Color3.fromRGB(255, 230, 120)
		},
		RubyLux = {
			DisplayName = "Ruby Luxe",
			PremiumOnly = true,
			LuxChrome = true,
			Main = Color3.fromRGB(14, 6, 10),
			Second = Color3.fromRGB(28, 10, 16),
			Stroke = Color3.fromRGB(92, 32, 48),
			Divider = Color3.fromRGB(52, 18, 28),
			Text = Color3.fromRGB(255, 242, 245),
			TextDark = Color3.fromRGB(220, 160, 175),
			Accent = Color3.fromRGB(255, 77, 109),
			Accent2 = Color3.fromRGB(255, 200, 120)
		},
		Nexus = {
			DisplayName = "Nexus",
			PremiumOnly = true,
			LuxChrome = true,
			Main = Color3.fromRGB(4, 8, 14),
			Second = Color3.fromRGB(10, 16, 28),
			Stroke = Color3.fromRGB(36, 58, 98),
			Divider = Color3.fromRGB(20, 34, 56),
			Text = Color3.fromRGB(240, 252, 255),
			TextDark = Color3.fromRGB(130, 180, 210),
			Accent = Color3.fromRGB(56, 189, 248),
			Accent2 = Color3.fromRGB(192, 132, 252)
		},
		Nocturne = {
			DisplayName = "Nocturne",
			PremiumOnly = true,
			LuxChrome = true,
			Main = Color3.fromRGB(6, 6, 10),
			Second = Color3.fromRGB(12, 12, 20),
			Stroke = Color3.fromRGB(48, 44, 72),
			Divider = Color3.fromRGB(26, 24, 42),
			Text = Color3.fromRGB(245, 244, 255),
			TextDark = Color3.fromRGB(150, 148, 190),
			Accent = Color3.fromRGB(196, 181, 253),
			Accent2 = Color3.fromRGB(255, 215, 128)
		}
	},
	ThemeOrder = {
		"Default", "Obsidian", "Crimson", "Emerald", "Amethyst",
		"Rose", "Slate", "Cyber", "Sunset",
		"Aurum", "RubyLux", "Nexus", "Nocturne"
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

-- Lucide (lucideblox) → rbxassetid — Quelle: https://github.com/frappedevs/lucideblox
local Icons = {}
local LUCIDE_FALLBACK = "rbxassetid://7734052925"

local Success, Response = pcall(function()
	local url = "https://raw.githubusercontent.com/frappedevs/lucideblox/master/src/modules/util/icons.json"
	local data = HttpService:JSONDecode(game:HttpGetAsync(url))
	Icons = (data and data.icons) or data or {}
end)

if not Success then
	warn("[Costum UI] Lucide-Icons konnten nicht geladen werden: ", tostring(Response))
end

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	end
	return nil
end

local function Lucide(iconName)
	if type(iconName) == "string" and Icons[iconName] ~= nil and Icons[iconName] ~= "" then
		return Icons[iconName]
	end
	return LUCIDE_FALLBACK
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
Orion.ResetOnSpawn = false
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.DisplayOrder = 550
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

-- Muss für ALLE gängigen Executor-Setups true liefern (CoreGui, gethui, PlayerGui, verschachtelt).
-- Zu enge Prüfung → AddConnection macht nichts → keine Tab-/Slider-Events, Intro wirkt „tot“.
function OrionLib:IsRunning()
	local p = Orion.Parent
	if not p then
		return false
	end
	local ok, live = pcall(function()
		return game:IsAncestorOf(p)
	end)
	return ok and live == true
end

-- Schließen/Minimize: Click + Up + optional Activated; Gate-Reset mit wait-Fallback (task.wait fehlt manchmal).
local function BindWinChromeClick(guiButton, callback, debounceSec)
	if not guiButton or type(callback) ~= "function" then
		return
	end
	local clickSig = guiButton.MouseButton1Click
	if not clickSig or type(clickSig.Connect) ~= "function" then
		return
	end
	debounceSec = debounceSec or 0.22
	local spawnFn = (type(task) == "table" and type(task.spawn) == "function" and task.spawn) or (type(spawn) == "function" and spawn)
	local waitFn = (type(task) == "table" and type(task.wait) == "function" and task.wait) or (type(wait) == "function" and wait)
	local gate = false
	local function runOnce()
		if gate then
			return
		end
		gate = true
		if spawnFn and waitFn then
			spawnFn(function()
				waitFn(debounceSec)
				gate = false
			end)
		else
			gate = false
		end
		callback()
	end
	AddConnection(clickSig, runOnce)
	local upSig = guiButton.MouseButton1Up
	if upSig and type(upSig.Connect) == "function" then
		AddConnection(upSig, runOnce)
	end
	local actSig = guiButton.Activated
	if actSig and type(actSig.Connect) == "function" then
		AddConnection(actSig, runOnce)
	end
end

local function AddConnection(Signal, Function)
	if not OrionLib:IsRunning() then
		return
	end
	if not Signal or type(Function) ~= "function" or type(Signal.Connect) ~= "function" then
		return
	end
	local ok, SignalConnect = pcall(function()
		return Signal:Connect(Function)
	end)
	if ok and SignalConnect then
		table.insert(OrionLib.Connections, SignalConnect)
		return SignalConnect
	end
	return nil
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

-- Fenster ziehen: Maus + Touch; Maus nutzt MouseMovement, Touch den gleichen Finger-Input.
local function AddDraggingFunctionality(DragPoint, Main)
	local dragging = false
	local dragUsesTouch = false
	local activeTouchInput = nil
	local pointerStart = Vector3.zero
	local frameStartPos = UDim2.new()

	AddConnection(DragPoint.InputBegan, function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragUsesTouch = false
			activeTouchInput = nil
			pointerStart = input.Position
			frameStartPos = Main.Position
		elseif input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragUsesTouch = true
			activeTouchInput = input
			pointerStart = input.Position
			frameStartPos = Main.Position
		end
	end)

	AddConnection(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end
		if dragUsesTouch then
			if input ~= activeTouchInput or input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
		elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - pointerStart
		Main.Position = UDim2.new(
			frameStartPos.X.Scale,
			frameStartPos.X.Offset + delta.X,
			frameStartPos.Y.Scale,
			frameStartPos.Y.Offset + delta.Y
		)
	end)

	AddConnection(UserInputService.InputEnded, function(input)
		if not dragging then
			return
		end
		if dragUsesTouch then
			if input == activeTouchInput then
				dragging = false
				activeTouchInput = nil
			end
		else
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end
	end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		pcall(function()
			Object[i] = v
		end)
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		pcall(function()
			Element[Property] = Value
		end)
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	local prop = ReturnProperty(Object)
	local col = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	if prop and typeof(col) == "Color3" then
		pcall(function()
			Object[prop] = col
		end)
	end
	return Object
end    

local function SetTheme()
	local palette = OrionLib.Themes[OrionLib.SelectedTheme]
	if not palette then
		return
	end
	for slotName, objects in pairs(OrionLib.ThemeObjects) do
		local C = palette[slotName]
		if typeof(C) == "Color3" then
			for _, Object in pairs(objects) do
				if Object and Object.Parent then
					local prop = ReturnProperty(Object)
					if prop then
						pcall(function()
							Object[prop] = C
						end)
					end
				end
			end
		end
	end
end

function OrionLib:SetTheme(themeKey)
	local palette = self.Themes[themeKey]
	if not palette then
		return false
	end
	if palette.PremiumOnly and not self.PremiumUnlocked then
		return false
	end
	self.SelectedTheme = themeKey
	SetTheme()
	for _, fn in ipairs(self._ThemeListeners) do
		pcall(fn)
	end
	return true
end

function OrionLib:GetThemeKey()
	return self.SelectedTheme
end

function OrionLib:RegisterPremiumListener(fn)
	if type(fn) == "function" then
		table.insert(self._PremiumListeners, fn)
	end
end

function OrionLib:SetPremiumUnlocked(value, writeDisk)
	self.PremiumUnlocked = value and true or false
	if self.PremiumUnlocked and writeDisk and self._PremiumPersistPath and writefile then
		pcall(function()
			if self.Folder and makefolder and isfolder and not isfolder(self.Folder) then
				makefolder(self.Folder)
			end
			writefile(self._PremiumPersistPath, "1")
		end)
	end
	for _, fn in ipairs(self._PremiumListeners) do
		pcall(fn)
	end
end

function OrionLib:TryUnlockWithKey(rawKey)
	local key = type(rawKey) == "string" and rawKey:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if key == "" then
		return false
	end
	if self._PremiumVerifyFn then
		local ok, res = pcall(self._PremiumVerifyFn, key)
		if ok and res then
			self:SetPremiumUnlocked(true, true)
			return true
		end
		return false
	end
	if self._PremiumKeyList then
		for _, k in ipairs(self._PremiumKeyList) do
			if k == key then
				self:SetPremiumUnlocked(true, true)
				return true
			end
		end
	end
	return false
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local resolved = ImageID
	if type(ImageID) == "string" then
		local low = string.sub(ImageID, 1, 13)
		if low ~= "rbxassetid://" and string.sub(ImageID, 1, 7) ~= "http://" and string.sub(ImageID, 1, 5) ~= "rbx://" then
			resolved = Lucide(ImageID)
		end
	end
	return Create("ImageLabel", {
		Image = resolved,
		BackgroundTransparency = 1
	})
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(244, 246, 255),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.GothamMedium,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -20, 1, -22),
	Size = UDim2.new(0, 340, 1, -28),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(_NotificationConfig)
end

function OrionLib:Init()
	if OrionLib.SaveCfg then	
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)		
	end	
end	

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local userWinW, userWinH = 680, 400
	local resizing = false
	local resizeStartMouse
	local resizeStartSize
	local resizeBeganInput = nil
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	WindowConfig.Premium = WindowConfig.Premium or false
	WindowConfig.PremiumKeys = WindowConfig.PremiumKeys or {}
	WindowConfig.PremiumPersist = WindowConfig.PremiumPersist ~= false
	WindowConfig.PremiumKeyUI = WindowConfig.PremiumKeyUI
	if WindowConfig.PremiumKeyUI == nil then
		WindowConfig.PremiumKeyUI = true
	end

	OrionLib._PremiumListeners = {}
	OrionLib._PremiumVerifyFn = type(WindowConfig.VerifyPremiumKey) == "function" and WindowConfig.VerifyPremiumKey or nil
	OrionLib._PremiumKeyList = {}
	for _, k in ipairs(WindowConfig.PremiumKeys) do
		if type(k) == "string" and k ~= "" then
			table.insert(OrionLib._PremiumKeyList, k)
		end
	end
	OrionLib._PremiumPersistPath = WindowConfig.ConfigFolder .. "/costum_premium_unlock.txt"

	OrionLib.PremiumUnlocked = false
	if WindowConfig.PremiumPersist then
		pcall(function()
			if isfile(OrionLib._PremiumPersistPath) then
				OrionLib.PremiumUnlocked = true
			end
		end)
	end
	if WindowConfig.Premium == true then
		OrionLib.PremiumUnlocked = true
	end

	local hasKeySystem = OrionLib._PremiumVerifyFn ~= nil or #OrionLib._PremiumKeyList > 0
	local showPremiumKeyEntry = WindowConfig.PremiumKeyUI
		and WindowConfig.Premium ~= true
		and hasKeySystem
		and not OrionLib.PremiumUnlocked

	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "MoonLibrary"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "layout-dashboard"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "layout-dashboard"
	WindowConfig.BrandName = WindowConfig.BrandName or "MoonHub"
	WindowConfig.BrandTag = WindowConfig.BrandTag or ""
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	local TabSearchRegistry = {}
	local SelectedTabButton = nil
	local SidebarW = 226
	local TabSearchInputRef = nil
	local PremiumCrownRef = nil
	local PremiumKeyOpenerRef = nil
	local PremiumOverlayRegistry = {}

	local SidebarFooterH = showPremiumKeyEntry and 100 or 62
	local TabHolderBottomReserve = 52 + SidebarFooterH

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 2), {
		Size = UDim2.new(1, 0, 1, -TabHolderBottomReserve),
		Position = UDim2.new(0, 0, 0, 52)
	}), {
		MakeElement("List", 0, 6),
		MakeElement("Padding", 14, 12, 12, 14)
	}), "Divider")
	TabHolder.ScrollingDirection = Enum.ScrollingDirection.Y
	TabHolder.ScrollBarImageTransparency = 0.94
	TabHolder.ScrollBarThickness = 3
	pcall(function()
		TabHolder.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	end)
	pcall(function()
		TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.None
	end)

	local function RefreshTabHolderCanvas()
		local lay = TabHolder:FindFirstChildOfClass("UIListLayout")
		if lay then
			local pad = TabHolder:FindFirstChildOfClass("UIPadding")
			local py = 28
			if pad then
				py = py + pad.PaddingTop.Offset + pad.PaddingBottom.Offset
			end
			TabHolder.CanvasSize = UDim2.new(0, 0, 0, math.max(math.ceil(lay.AbsoluteContentSize.Y + py), 4))
		end
	end

	local tabListLayout = TabHolder:FindFirstChildOfClass("UIListLayout")
	if tabListLayout then
		AddConnection(tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), RefreshTabHolderCanvas)
	end
	task.defer(RefreshTabHolderCanvas)

	-- Nur Darstellung; echte Klicks über ChromeCloseHit (darüber, sonst fangen Stroke/Divider/Theme zu).
	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 12,
		Active = false,
		Selectable = false,
		AutoButtonColor = false
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "x"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Glyph",
			Active = false,
			Selectable = false
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 12,
		Active = false,
		Selectable = false,
		AutoButtonColor = false
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "minus"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico",
			Active = false,
			Selectable = false
		}), "Text")
	})

	-- Unsichtbare Volltreffer über Minimize (links) / Close (rechts) — WinControls 88px breit ab (1,-98).
	local ChromeMinHit = SetProps(MakeElement("Button"), {
		Name = "ChromeMinHit",
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Size = UDim2.new(0, 44, 0, 38),
		Position = UDim2.new(1, -98, 0, 8),
		ZIndex = 28,
		Active = true,
		Selectable = true
	})
	local ChromeCloseHit = SetProps(MakeElement("Button"), {
		Name = "ChromeCloseHit",
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Size = UDim2.new(0, 44, 0, 38),
		Position = UDim2.new(1, -54, 0, 8),
		ZIndex = 28,
		Active = true,
		Selectable = true
	})

	-- Nur linker Titelbereich: volle Breite würde die TopBar überdecken und Close/Minimize blockieren.
	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, -368, 0, 54),
		Position = UDim2.new(0, 0, 0, 0),
		Active = true,
		ZIndex = 3,
		Name = "WindowDragStrip"
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 20), {
		Size = UDim2.new(0, SidebarW, 1, -54),
		Position = UDim2.new(0, 0, 0, 54)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
			BackgroundTransparency = 0.72
		}), "Stroke"),
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.new(0, 0, 0, 10),
			Name = "SidebarHeader"
		}), {
			AddThemeObject(SetProps(Create("Frame", {
				Size = UDim2.new(0, 3, 0, 14),
				Position = UDim2.new(0, 14, 0.5, -7),
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			}), {Name = "SidebarAccentStripe"}), "Accent"),
			AddThemeObject(SetProps(MakeElement("Label", "Navigation", 12), {
				Size = UDim2.new(1, -36, 1, 0),
				Position = UDim2.new(0, 24, 0, 0),
				Font = Enum.Font.GothamBold,
				TextTransparency = 0.42,
				TextXAlignment = Enum.TextXAlignment.Left
			}), "TextDark")
		}),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, SidebarFooterH),
			Position = UDim2.new(0, 0, 1, -SidebarFooterH),
			Name = "SidebarFooter"
		}), (function()
			local rows = {}
			if showPremiumKeyEntry then
				local premBtn = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, -24, 0, 32),
					Position = UDim2.new(0, 12, 0, 8),
					BackgroundTransparency = 0.42,
					Name = "PremiumKeyOpener"
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.82, Thickness = 1.05}), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Image", "lock"), {
						Size = UDim2.new(0, 14, 0, 14),
						Position = UDim2.new(0, 10, 0.5, -7),
						ImageTransparency = 0.2,
						Name = "PremIco"
					}), "Accent"),
					AddThemeObject(SetProps(MakeElement("Label", "Premium · Lizenz eingeben", 12), {
						Size = UDim2.new(1, -36, 1, 0),
						Position = UDim2.new(0, 28, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTransparency = 0.06
					}), "Text"),
					SetProps(MakeElement("Button"), {
						Size = UDim2.new(1, 0, 1, 0),
						Name = "PremiumKeyHit",
						BackgroundTransparency = 1
					})
				}), "Second")
				PremiumKeyOpenerRef = premBtn
				table.insert(rows, premBtn)
			end
			local brandTop = showPremiumKeyEntry and 46 or 0
			table.insert(rows, AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, -20, 0, 1),
				Position = UDim2.new(0, 10, 0, brandTop),
				BackgroundTransparency = 0.55,
				Name = "FooterLine"
			}), "Stroke"))
			table.insert(rows, AddThemeObject(SetProps(MakeElement("Label", WindowConfig.BrandName, 14), {
				Size = UDim2.new(1, -28, 0, 18),
				Position = UDim2.new(0, 14, 0, brandTop + 10),
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				ClipsDescendants = true,
				Name = "BrandTitle",
				TextXAlignment = Enum.TextXAlignment.Left
			}), "Text"))
			table.insert(rows, AddThemeObject(SetProps(MakeElement("Label", WindowConfig.BrandTag, 11), {
				Size = UDim2.new(1, -28, 0, 28),
				Position = UDim2.new(0, 14, 0, brandTop + 28),
				Font = Enum.Font.GothamMedium,
				TextTransparency = 0.12,
				TextWrapped = true,
				Visible = WindowConfig.BrandTag ~= "",
				Name = "BrandTag",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			}), "Accent"))
			return rows
		end)()),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -520, 2, 0),
		Position = UDim2.new(0, 28, 0, -26),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextTruncate = Enum.TextTruncate.AtEnd
	}), "Text")

	local PremiumCrown = SetProps(MakeElement("Image", "crown"), {
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, 26, 0, 16),
		BackgroundTransparency = 1,
		Name = "PremiumCrown",
		Visible = OrionLib.PremiumUnlocked,
		ImageTransparency = 0.08,
		ZIndex = 5
	})
	PremiumCrownRef = PremiumCrown
	AddThemeObject(PremiumCrown, "Accent2")

	local ThemeClick = SetProps(MakeElement("Button"), {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Name = "ThemeHit"
	})

	local ThemePickerBtn = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
		Size = UDim2.new(0, 92, 0, 38),
		Position = UDim2.new(1, -114, 0, 8),
		AnchorPoint = Vector2.new(1, 0),
		Name = "ThemePickerBtn",
		BackgroundTransparency = 0.42,
		ZIndex = 6
	}), {
		AddThemeObject(SetProps(MakeElement("Stroke"), {
			Transparency = 0.86,
			Thickness = 1.05,
			LineJoinMode = Enum.LineJoinMode.Round
		}), "Stroke"),
		AddThemeObject(SetProps(MakeElement("Image", "palette"), {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 12, 0.5, -8),
			ImageTransparency = 0.25,
			Name = "ThemeIco"
		}), "Accent"),
		AddThemeObject(SetProps(MakeElement("Label", "Themes", 12), {
			Size = UDim2.new(1, -32, 1, 0),
			Position = UDim2.new(0, 30, 0, 0),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.06,
			Name = "ThemeLbl"
		}), "Text"),
		ThemeClick
	}), "Second")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundTransparency = 0.35
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 24), {
		Parent = Orion,
		Position = UDim2.new(0.5, -340, 0.5, -200),
		Size = UDim2.new(0, 680, 0, 400),
		ClipsDescendants = true
	}), {
		(function()
			local chrome = AddThemeObject(SetProps(MakeElement("Stroke", nil, 1.2), {
				Name = "WindowChrome",
				Transparency = 0.78,
				LineJoinMode = Enum.LineJoinMode.Round
			}), "Accent")
			pcall(function()
				chrome.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			end)
			return chrome
		end)(),
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 54),
			Name = "TopBar",
			ZIndex = 2
		}), {
			PremiumCrown,
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
				Size = UDim2.new(0, 168, 0, 38),
				Position = UDim2.new(1, -218, 0, 8),
				AnchorPoint = Vector2.new(1, 0),
				Name = "TabSearchBar",
				BackgroundTransparency = 0.52,
				ClipsDescendants = true
			}), {
				AddThemeObject(SetProps(MakeElement("Stroke"), {
					Transparency = 0.88,
					Thickness = 1.05,
					LineJoinMode = Enum.LineJoinMode.Round
				}), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Image", "search"), {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 12, 0.5, -8),
					ImageTransparency = 0.32,
					Name = "SearchIco"
				}), "TextDark"),
				(function()
					local tb = Create("TextBox", {
						Name = "TabSearchInput",
						Size = UDim2.new(1, -40, 0, 26),
						Position = UDim2.new(0, 32, 0.5, -13),
						BackgroundTransparency = 1,
						Text = "",
						PlaceholderText = "Tabs durchsuchen…",
						TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text,
						PlaceholderColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
						TextSize = 14,
						Font = Enum.Font.GothamMedium,
						ClearTextOnFocus = false,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd
					})
					TabSearchInputRef = tb
					return tb
				end)()
			}), "Second"),
			ThemePickerBtn,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
				Size = UDim2.new(0, 88, 0, 38),
				Position = UDim2.new(1, -98, 0, 8),
				Name = "WinControls",
				BackgroundTransparency = 0.44,
				ZIndex = 15
			}), {
				AddThemeObject(SetProps(MakeElement("Stroke"), {
					Transparency = 0.85,
					Thickness = 1.05,
					LineJoinMode = Enum.LineJoinMode.Round
				}), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 0.55, 0),
					Position = UDim2.new(0.5, 0, 0.22, 0),
					BackgroundTransparency = 0.6,
					Active = false,
					Selectable = false
				}), "Stroke"),
				CloseBtn,
				MinimizeBtn
			}), "Second"),
			ChromeMinHit,
			ChromeCloseHit
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	MainWindow.BackgroundTransparency = 0.14
	WindowStuff.BackgroundTransparency = 0.36

	-- Größere Klickfläche (besonders Touch); Ende nur für den Finger / Klick der den Resize gestartet hat.
	local ResizeGrip = AddThemeObject(SetProps(Create("ImageLabel", {
		Parent = MainWindow,
		Name = "ResizeGrip",
		Active = true,
		Selectable = false,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(1, -2, 1, -2),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = Lucide("grip-vertical"),
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = 0.42,
		ZIndex = 95,
	}), {}), "TextDark")

	AddConnection(ResizeGrip.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if Minimized then
				return
			end
			resizing = true
			resizeBeganInput = input
			resizeStartMouse = input.Position
			resizeStartSize = MainWindow.AbsoluteSize
		end
	end)
	AddConnection(UserInputService.InputEnded, function(input)
		if not resizing or not resizeBeganInput then
			return
		end
		if input == resizeBeganInput then
			resizing = false
			resizeBeganInput = nil
			return
		end
		-- Manche Clients liefern bei der Maus ein anderes Input-Objekt beim Loslassen.
		if resizeBeganInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
			resizeBeganInput = nil
		end
	end)
	AddConnection(UserInputService.InputChanged, function(input)
		if not resizing or not resizeBeganInput then
			return
		end
		if Minimized then
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch then
			if input ~= resizeBeganInput then
				return
			end
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			if resizeBeganInput.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
		else
			return
		end
		local d = input.Position - resizeStartMouse
		local w = math.clamp(math.floor(resizeStartSize.X + d.X + 0.5), 520, 1100)
		local h = math.clamp(math.floor(resizeStartSize.Y + d.Y + 0.5), 340, 900)
		MainWindow.Size = UDim2.fromOffset(w, h)
		userWinW, userWinH = w, h
	end)

	local ThemeScroll = SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 2), {
		Name = "ThemeScroll",
		Size = UDim2.new(1, -24, 0, 312),
		Position = UDim2.new(0, 12, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y
	}), {
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		})
	})

	local ThemeHint = AddThemeObject(SetProps(MakeElement("Label", "", 11), {
		Size = UDim2.new(1, -24, 0, 36),
		Position = UDim2.new(0, 12, 1, -40),
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextTransparency = 0.35,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Name = "ThemeHint"
	}), "TextDark")

	local ThemeDropdown = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
		Parent = MainWindow,
		Name = "ThemeDropdown",
		Size = UDim2.new(0, 252, 0, 408),
		Position = UDim2.new(1, -12, 0, 50),
		AnchorPoint = Vector2.new(1, 0),
		Visible = false,
		ZIndex = 35,
		BackgroundTransparency = 0.06,
		ClipsDescendants = true
	}), {
		AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.8, Thickness = 1.08}), "Stroke"),
		AddThemeObject(SetProps(MakeElement("Label", "Erscheinungsbild", 14), {
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 14, 0, 10),
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Name = "ThemeMenuTitle"
		}), "Text"),
		ThemeScroll,
		ThemeHint
	}), "Second")

	local ThemeDropdownOpen = false
	local function refreshThemeHint()
		if OrionLib.PremiumUnlocked then
			ThemeHint.Text = ""
			ThemeHint.Visible = false
		else
			ThemeHint.Text = "Premium-Themes (Aurum, Ruby Luxe, Nexus, Nocturne): Lizenz in der Sidebar eingeben."
			ThemeHint.Visible = true
		end
	end
	refreshThemeHint()

	local function rebuildThemeRows()
		local kill = {}
		for _, c in ipairs(ThemeScroll:GetChildren()) do
			if not c:IsA("UIListLayout") then
				table.insert(kill, c)
			end
		end
		for _, c in ipairs(kill) do
			c:Destroy()
		end
		local ThNow = OrionLib.Themes[OrionLib.SelectedTheme]
		for order, key in ipairs(OrionLib.ThemeOrder) do
			local pal = OrionLib.Themes[key]
			local locked = pal.PremiumOnly and not OrionLib.PremiumUnlocked
			local display = pal.DisplayName or key
			local active = OrionLib.SelectedTheme == key
			local row = SetChildren(SetProps(MakeElement("Button"), {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = ThNow.Second,
				BackgroundTransparency = locked and 0.58 or (active and 0.28 or 0.48),
				Name = "ThemeRow_" .. key,
				LayoutOrder = order,
				ZIndex = 2
			}), {
				Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
				(function()
					local st = Create("UIStroke", {
						Color = active and pal.Accent or ThNow.Stroke,
						Thickness = active and 1.15 or 1.05,
						Transparency = active and 0.48 or 0.88
					})
					pcall(function()
						st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					end)
					return st
				end)(),
				Create("Frame", {
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new(0, 12, 0.5, -7),
					BackgroundColor3 = pal.Accent,
					BorderSizePixel = 0
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						Transparency = 0.65,
						Thickness = 1
					})
				}),
				SetProps(MakeElement("Label", display .. (active and "  ✓" or ""), 13), {
					Size = UDim2.new(1, -70, 1, 0),
					Position = UDim2.new(0, 34, 0, 0),
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = locked and 0.45 or 0.04,
					TextColor3 = ThNow.Text
				}),
				SetProps(MakeElement("Image", "lock"), {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(1, -28, 0.5, -8),
					BackgroundTransparency = 1,
					ImageTransparency = locked and 0.15 or 1,
					Name = "LockIco"
				})
			})
			row.Parent = ThemeScroll
			AddConnection(row.MouseButton1Click, function()
				if locked then
					return
				end
				if OrionLib:SetTheme(key) then
					ThemeDropdownOpen = false
					ThemeDropdown.Visible = false
					rebuildThemeRows()
				end
			end)
			local baseT = locked and 0.58 or (active and 0.28 or 0.48)
			AddConnection(row.MouseEnter, function()
				if not locked then
					TweenService:Create(row, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = math.max(0.14, baseT - 0.14)}):Play()
				end
			end)
			AddConnection(row.MouseLeave, function()
				if not locked then
					TweenService:Create(row, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = baseT}):Play()
				end
			end)
		end
		task.defer(function()
			local lay = ThemeScroll:FindFirstChildOfClass("UIListLayout")
			if lay then
				ThemeScroll.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 12)
			end
		end)
	end
	rebuildThemeRows()

	AddConnection(ThemeClick.MouseButton1Click, function()
		ThemeDropdownOpen = not ThemeDropdownOpen
		ThemeDropdown.Visible = ThemeDropdownOpen
		if ThemeDropdownOpen then
			rebuildThemeRows()
			refreshThemeHint()
		end
	end)

	table.insert(OrionLib._ThemeListeners, function()
		local T = OrionLib.Themes[OrionLib.SelectedTheme]
		if TabSearchInputRef and TabSearchInputRef.Parent then
			TabSearchInputRef.TextColor3 = T.Text
			TabSearchInputRef.PlaceholderColor3 = T.TextDark
		end
		local ch = MainWindow:FindFirstChild("WindowChrome", true)
		local pal = OrionLib.Themes[OrionLib.SelectedTheme]
		if ch and ch:IsA("UIStroke") and pal then
			if pal.LuxChrome then
				ch.Transparency = 0.48
				ch.Color = T.Accent2
				ch.Thickness = 1.38
			else
				ch.Transparency = 0.78
				ch.Color = T.Accent
				ch.Thickness = 1.2
			end
		end
		rebuildThemeRows()
	end)

	local PremiumUnlockLayer = SetProps(MakeElement("TFrame"), {
		Name = "PremiumUnlockLayer",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 200,
		Parent = MainWindow
	})
	local PremiumDim = Create("TextButton", {
		Name = "PremiumDim",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 201
	})
	PremiumDim.Parent = PremiumUnlockLayer
	local PremiumCard = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 20), {
		Size = UDim2.new(0, 336, 0, 248),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.08,
		ZIndex = 205,
		Name = "PremiumCard"
	}), {
		AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.65, Thickness = 1.2, Name = "CardStroke"}), "Accent"),
		Create("UIGradient", {
			Rotation = 100,
			Transparency = NumberSequence.new(0.92, 1),
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 210, 230))
		}),
		AddThemeObject(SetProps(MakeElement("Label", "Premium freischalten", 18), {
			Size = UDim2.new(1, -32, 0, 28),
			Position = UDim2.new(0, 20, 0, 20),
			Font = Enum.Font.GothamBold,
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Left,
			Name = "PremTitle"
		}), "Text"),
		AddThemeObject(SetProps(MakeElement("Label", "Gib deinen Lizenzschlüssel ein. Den erhältst du z. B. über Discord.", 12), {
			Size = UDim2.new(1, -32, 0, 36),
			Position = UDim2.new(0, 20, 0, 50),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.25,
			Name = "PremSub"
		}), "TextDark"),
		AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 12), {
			Size = UDim2.new(1, -40, 0, 40),
			Position = UDim2.new(0, 20, 0, 96),
			BackgroundTransparency = 0.5,
			Name = "KeyShell"
		}), {
			AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.85, Thickness = 1.05}), "Stroke"),
			Create("TextBox", {
				Name = "PremiumKeyInput",
				Size = UDim2.new(1, -20, 1, -8),
				Position = UDim2.new(0, 10, 0, 4),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = "XXXX-XXXX-XXXX",
				TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text,
				PlaceholderColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
				TextSize = 15,
				Font = Enum.Font.GothamMedium,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}), "Second"),
		SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 12), {
			Size = UDim2.new(0, 140, 0, 40),
			Position = UDim2.new(0, 20, 0, 152),
			BackgroundTransparency = 0.25,
			Name = "ActivateBtn"
		}), {
			AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.7, Thickness = 1.1, Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent}), "Accent"),
			AddThemeObject(SetProps(MakeElement("Label", "Aktivieren", 14), {
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				Name = "ActLbl"
			}), "Text"),
			SetProps(MakeElement("Button"), {
				Size = UDim2.new(1, 0, 1, 0),
				Name = "ActHit",
				BackgroundTransparency = 1
			})
		}),
		Create("TextButton", {
			Size = UDim2.new(0, 32, 0, 32),
			Position = UDim2.new(1, -12, 0, 12),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(40, 44, 56),
			BackgroundTransparency = 0.35,
			Text = "✕",
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(240, 242, 255),
			Name = "PremClose",
			AutoButtonColor = false,
			ZIndex = 206,
			BorderSizePixel = 0
		}, {
			Create("UICorner", {CornerRadius = UDim.new(0, 10)})
		})
	}), "Second")
	PremiumCard.Parent = PremiumUnlockLayer

	local function openPremiumModal()
		PremiumUnlockLayer.Visible = true
		local inp = PremiumCard:FindFirstChild("PremiumKeyInput", true)
		if inp then
			inp:CaptureFocus()
		end
	end
	local function closePremiumModal()
		PremiumUnlockLayer.Visible = false
	end
	local function shakePremiumCard()
		local card = PremiumCard
		local b = card.Position
		spawn(function()
			for _ = 1, 4 do
				TweenService:Create(card, TweenInfo.new(0.04, Enum.EasingStyle.Quad), {
					Position = UDim2.new(b.X.Scale, b.X.Offset + 10, b.Y.Scale, b.Y.Offset)
				}):Play()
				wait(0.05)
				TweenService:Create(card, TweenInfo.new(0.04, Enum.EasingStyle.Quad), {
					Position = UDim2.new(b.X.Scale, b.X.Offset - 10, b.Y.Scale, b.Y.Offset)
				}):Play()
				wait(0.05)
			end
			TweenService:Create(card, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {Position = b}):Play()
		end)
	end
	local function tryPremiumFromModal()
		local inp = PremiumCard:FindFirstChild("PremiumKeyInput", true)
		local raw = inp and inp.Text or ""
		if OrionLib:TryUnlockWithKey(raw) then
			closePremiumModal()
			OrionLib:MakeNotification({
				Name = "Premium",
				Content = "Freigeschaltet – alle Premium-Themes und Tabs sind aktiv.",
				Image = "crown",
				Time = 4
			})
		else
			local st = PremiumCard:FindFirstChild("CardStroke", true)
			if st and st:IsA("UIStroke") then
				st.Color = Color3.fromRGB(255, 80, 100)
				TweenService:Create(st, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent}):Play()
			end
			shakePremiumCard()
		end
	end

	AddConnection(PremiumDim.MouseButton1Click, closePremiumModal)
	local premClose = PremiumCard:FindFirstChild("PremClose")
	if premClose then
		AddConnection(premClose.MouseButton1Click, closePremiumModal)
	end
	local actHit = PremiumCard:FindFirstChild("ActHit", true)
	if actHit then
		AddConnection(actHit.MouseButton1Click, tryPremiumFromModal)
	end
	if showPremiumKeyEntry and PremiumKeyOpenerRef then
		local hit = PremiumKeyOpenerRef:FindFirstChild("PremiumKeyHit")
		if hit then
			AddConnection(hit.MouseButton1Click, openPremiumModal)
		end
	end

	local function applyPremiumVisualState()
		if PremiumCrownRef then
			PremiumCrownRef.Visible = OrionLib.PremiumUnlocked
		end
		if PremiumKeyOpenerRef then
			PremiumKeyOpenerRef.Visible = hasKeySystem and WindowConfig.Premium ~= true and not OrionLib.PremiumUnlocked
		end
		for _, ov in ipairs(PremiumOverlayRegistry) do
			if ov and ov.Parent then
				ov.Visible = not OrionLib.PremiumUnlocked
			end
		end
		refreshThemeHint()
		rebuildThemeRows()
	end
	OrionLib:RegisterPremiumListener(applyPremiumVisualState)
	applyPremiumVisualState()

	table.insert(OrionLib._ThemeListeners, function()
		local T = OrionLib.Themes[OrionLib.SelectedTheme]
		local pk = PremiumCard and PremiumCard:FindFirstChild("PremiumKeyInput", true)
		if pk and pk:IsA("TextBox") then
			pk.TextColor3 = T.Text
			pk.PlaceholderColor3 = T.TextDark
		end
	end)

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 54, 0, -26)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
		if OrionLib.PremiumUnlocked and PremiumCrownRef then
			PremiumCrownRef.Position = UDim2.new(0, 54, 0, 16)
		end
	end	

	local function ApplyTabSearchFilter()
		local bar = MainWindow.TopBar:FindFirstChild("TabSearchBar")
		if not bar then return end
		local inp = bar:FindFirstChild("TabSearchInput")
		if not inp then return end
		local raw = inp.Text or ""
		local q = string.lower((raw:gsub("^%s+", ""):gsub("%s+$", "")))
		local ph = inp.PlaceholderText or ""
		if ph ~= "" and raw == ph then
			q = ""
		end
		if #q == 0 then
			for _, entry in ipairs(TabSearchRegistry) do
				entry.Frame.Visible = true
			end
			RefreshTabHolderCanvas()
			return
		end
		for _, entry in ipairs(TabSearchRegistry) do
			local show = string.find(entry.Key, q, 1, true) ~= nil or entry.Frame == SelectedTabButton
			entry.Frame.Visible = show
		end
		RefreshTabHolderCanvas()
	end

	local searchBar = MainWindow.TopBar:FindFirstChild("TabSearchBar")
	if searchBar then
		local sInput = searchBar:FindFirstChild("TabSearchInput")
		if sInput then
			AddConnection(sInput:GetPropertyChangedSignal("Text"), ApplyTabSearchFilter)
		end
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	local TTextCol = OrionLib.Themes[OrionLib.SelectedTheme].Text
	local TAcc2Col = OrionLib.Themes[OrionLib.SelectedTheme].Accent2
	local function wireChromeHitHover(hitBtn, iconHolder, glyphName)
		local g = iconHolder and glyphName and iconHolder:FindFirstChild(glyphName)
		if not g or not g:IsA("ImageLabel") then
			return
		end
		AddConnection(hitBtn.MouseEnter, function()
			TweenService:Create(g, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = TAcc2Col, ImageTransparency = 0.02}):Play()
		end)
		AddConnection(hitBtn.MouseLeave, function()
			TweenService:Create(g, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = TTextCol, ImageTransparency = 0}):Play()
		end)
	end
	wireChromeHitHover(ChromeMinHit, MinimizeBtn, "Ico")
	wireChromeHitHover(ChromeCloseHit, CloseBtn, "Glyph")

	local function performClose()
		if not MainWindow or not MainWindow.Parent then
			return
		end
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Press RightShift to reopen the interface",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
			UIHidden = false
		end
	end)

	local minimizeBusy = false
	local function performMinimize()
		if minimizeBusy then
			return
		end
		minimizeBusy = true
		task.spawn(function()
			pcall(function()
				if Minimized then
					TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(userWinW, userWinH)}):Play()
					MinimizeBtn.Ico.Image = Lucide("minus")
					task.wait(0.02)
					MainWindow.ClipsDescendants = false
					WindowStuff.Visible = true
					WindowTopBarLine.Visible = true
				else
					userWinW = math.floor(MainWindow.AbsoluteSize.X + 0.5)
					userWinH = math.floor(MainWindow.AbsoluteSize.Y + 0.5)
					MainWindow.ClipsDescendants = true
					WindowTopBarLine.Visible = false
					MinimizeBtn.Ico.Image = Lucide("square")
					TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 176, 0, 54)}):Play()
					task.wait(0.1)
					WindowStuff.Visible = false
				end
				Minimized = not Minimized
			end)
			minimizeBusy = false
		end)
	end

	local winChromeBindsDone = false
	local function ensureWinChromeBinds()
		if winChromeBindsDone then
			return
		end
		winChromeBindsDone = true
		BindWinChromeClick(ChromeCloseHit, performClose)
		BindWinChromeClick(ChromeMinHit, performMinimize)
		pcall(function()
			ChromeCloseHit.Interactable = true
			ChromeMinHit.Interactable = true
		end)
	end

	local function LoadSequence()
		MainWindow.Visible = false
		local Acc = OrionLib.Themes[OrionLib.SelectedTheme].Accent
		local IntroLayer = Create("Frame", {
			Parent = Orion,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 100
		})
		local function finishIntro()
			if IntroLayer.Parent then
				IntroLayer:Destroy()
			end
			MainWindow.Visible = true
			-- Chrome erst nach sichtbarem Fenster binden (verhindert Phantom-Close während Intro/Layout).
			task.defer(function()
				task.wait(0.08)
				ensureWinChromeBinds()
			end)
		end
		local ok, err = pcall(function()
			local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
				Parent = IntroLayer,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.42, 0),
				Size = UDim2.new(0, 36, 0, 36),
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = 1,
				ZIndex = 101
			})
			local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 16), {
				Parent = IntroLayer,
				Size = UDim2.new(1, 0, 0, 24),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 20),
				TextXAlignment = Enum.TextXAlignment.Center,
				Font = Enum.Font.GothamBold,
				TextTransparency = 1,
				ZIndex = 101
			})
			local BarBack = Create("Frame", {
				Parent = IntroLayer,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.58, 0),
				Size = UDim2.new(0, 268, 0, 6),
				BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second,
				BackgroundTransparency = 0.52,
				BorderSizePixel = 0,
				ZIndex = 101
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			})
			local BarFill = Create("Frame", {
				Parent = BarBack,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Acc,
				BorderSizePixel = 0,
				ZIndex = 102
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			})
			TweenService:Create(BarFill, TweenInfo.new(3.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
			TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
			wait(0.75)
			TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X / 2 + 18), 0.5, 0)}):Play()
			wait(0.28)
			TweenService:Create(LoadSequenceText, TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			wait(1.55)
			TweenService:Create(LoadSequenceText, TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			TweenService:Create(LoadSequenceLogo, TweenInfo.new(.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			TweenService:Create(BarBack, TweenInfo.new(.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			TweenService:Create(BarFill, TweenInfo.new(.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			wait(0.25)
		end)
		if not ok then
			warn("[Costum UI] Intro:", err)
		end
		finishIntro()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	else
		task.defer(function()
			task.wait(0.08)
			ensureWinChromeBinds()
		end)
	end

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TAccent = OrionLib.Themes[OrionLib.SelectedTheme].Accent
		local TSecond = OrionLib.Themes[OrionLib.SelectedTheme].Second
		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 46),
			Parent = TabHolder,
			ZIndex = 2
		}), {
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
				Size = UDim2.new(1, -8, 1, -6),
				Position = UDim2.new(0, 4, 0, 3),
				Name = "TabBg",
				ZIndex = 0,
				BackgroundTransparency = 0.9
			}), {
				Create("UIStroke", {
					Name = "TabStroke",
					Color = TAccent,
					Thickness = 1.2,
					Transparency = 1,
					LineJoinMode = Enum.LineJoinMode.Round
				})
			}), "Second"),
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 14, 0.5, 0),
				ImageTransparency = 0.42,
				Name = "Ico",
				ZIndex = 2
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -42, 1, 0),
				Position = UDim2.new(0, 40, 0, 0),
				Font = Enum.Font.GothamMedium,
				TextTransparency = 0.38,
				TextSize = 14,
				Name = "Title",
				ZIndex = 2
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end	

		local function TabApplyVisual(Tab, selected)
			local bg = Tab:FindFirstChild("TabBg")
			if not bg then return end
			local stroke = bg:FindFirstChild("TabStroke")
			if selected then
				TweenService:Create(bg, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundColor3 = TAccent,
					BackgroundTransparency = 0.58
				}):Play()
				TweenService:Create(Tab.Ico, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(Tab.Title, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				Tab.Title.Font = Enum.Font.GothamBold
				if stroke then
					TweenService:Create(stroke, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 0.72}):Play()
				end
			else
				TweenService:Create(bg, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundColor3 = TSecond,
					BackgroundTransparency = 0.92
				}):Play()
				TweenService:Create(Tab.Ico, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.45, ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text}):Play()
				TweenService:Create(Tab.Title, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				Tab.Title.Font = Enum.Font.GothamMedium
				if stroke then
					TweenService:Create(stroke, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Transparency = 1}):Play()
				end
			end
		end

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
			Size = UDim2.new(1, -SidebarW, 1, -54),
			Position = UDim2.new(0, SidebarW, 0, 54),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer",
			ScrollBarImageTransparency = 0.58,
			ScrollBarThickness = 3
		}), {
			MakeElement("List", 0, 10),
			MakeElement("Padding", 22, 20, 24, 22)
		}), "Divider")
		Container.ScrollingDirection = Enum.ScrollingDirection.Y

		local function RefreshItemContainerCanvas()
			local lay = Container:FindFirstChildOfClass("UIListLayout")
			if lay then
				local pad = Container:FindFirstChildOfClass("UIPadding")
				local py = 24
				if pad then
					py = py + pad.PaddingTop.Offset + pad.PaddingBottom.Offset
				end
				Container.CanvasSize = UDim2.new(0, 0, 0, math.max(math.ceil(lay.AbsoluteContentSize.Y + py), 1))
			end
		end
		pcall(function()
			Container.AutomaticCanvasSize = Enum.AutomaticSize.None
		end)
		local itemListLayout = Container:FindFirstChildOfClass("UIListLayout")
		if itemListLayout then
			AddConnection(itemListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), RefreshItemContainerCanvas)
		end
		AddConnection(Container.ChildAdded, function()
			task.defer(RefreshItemContainerCanvas)
		end)
		task.defer(RefreshItemContainerCanvas)

		if FirstTab then
			FirstTab = false
			SelectedTabButton = TabFrame
			TabApplyVisual(TabFrame, true)
			Container.Visible = true
		end    

		AddConnection(TabFrame.MouseButton1Click, function()
			SelectedTabButton = TabFrame
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					TabApplyVisual(Tab, false)
				end    
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end    
			end  
			TabApplyVisual(TabFrame, true)
			Container.Visible = true   
		end)

		table.insert(TabSearchRegistry, { Frame = TabFrame, Key = string.lower(TabConfig.Name) })
		task.defer(RefreshTabHolderCanvas)
		task.defer(ApplyTabSearchFilter)

		local function GetElements(ItemParent)
			local ElementFunction = {}
			function ElementFunction:AddLabel(Text)
				local LAcc = OrionLib.Themes[OrionLib.SelectedTheme].Accent
				-- Kein Child namens "Content" — in neuen Roblox-Builds ist Frame.Content kein gültiger Kind-Zugriff.
				local labelTextEl = AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
					Size = UDim2.new(1, -36, 1, 0),
					Position = UDim2.new(0, 24, 0, 0),
					Font = Enum.Font.GothamBold,
					TextSize = 15,
					TextTransparency = 0.04,
					Name = "CostumLabelText"
				}), "Text")
				AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 0.48,
					Parent = ItemParent
				}), {
					Create("Frame", {
						Size = UDim2.new(0, 3, 0.52, 0),
						Position = UDim2.new(0, 14, 0.24, 0),
						BackgroundColor3 = LAcc,
						BorderSizePixel = 0,
						BackgroundTransparency = 0.08
					}, {
						Create("UICorner", {CornerRadius = UDim.new(1, 0)})
					}),
					labelTextEl
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					labelTextEl.Text = ToChange
				end
				return LabelFunction
			end
			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"
				local PAccent = OrionLib.Themes[OrionLib.SelectedTheme].Accent
				local PSecond = OrionLib.Themes[OrionLib.SelectedTheme].Second

				local paragraphTitleEl = AddThemeObject(SetProps(MakeElement("Label", Text, 19), {
					Size = UDim2.new(1, -44, 0, 28),
					Position = UDim2.new(0, 24, 0, 18),
					Font = Enum.Font.GothamBold,
					TextSize = 19,
					TextTransparency = 0.02,
					TextXAlignment = Enum.TextXAlignment.Left,
					Name = "CostumParagraphTitle"
				}), "Text")
				local paragraphBodyEl = AddThemeObject(SetProps(MakeElement("Label", "", 14), {
					Size = UDim2.new(1, -44, 0, 0),
					Position = UDim2.new(0, 24, 0, 56),
					Font = Enum.Font.GothamMedium,
					TextTransparency = 0.12,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Name = "CostumParagraphBody"
				}), "TextDark")

				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 20), {
					Size = UDim2.new(1, 0, 0, 96),
					BackgroundTransparency = 0.34,
					Parent = ItemParent
				}), {
					(function()
						local ps = SetProps(MakeElement("Stroke", PAccent, 1.15), {
							Transparency = 0.88,
							Thickness = 1.15
						})
						pcall(function()
							ps.LineJoinMode = Enum.LineJoinMode.Round
						end)
						return ps
					end)(),
					Create("UIGradient", {
						Rotation = 108,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, PSecond:Lerp(Color3.fromRGB(255, 255, 255), 0.06)),
							ColorSequenceKeypoint.new(0.45, PSecond:Lerp(PAccent, 0.07)),
							ColorSequenceKeypoint.new(1, PSecond)
						})
					}),
					paragraphTitleEl,
					Create("Frame", {
						Name = "TitleUnderline",
						Size = UDim2.new(0, 48, 0, 2),
						Position = UDim2.new(0, 24, 0, 46),
						BackgroundColor3 = PAccent,
						BorderSizePixel = 0,
						BackgroundTransparency = 0.28
					}, {
						Create("UICorner", {CornerRadius = UDim.new(1, 0)})
					}),
					paragraphBodyEl
				}), "Second")

				local function reflowParagraph()
					local titleH = math.max(paragraphTitleEl.TextBounds.Y, 24)
					paragraphTitleEl.Size = UDim2.new(1, -44, 0, titleH)
					local und = ParagraphFrame:FindFirstChild("TitleUnderline")
					if und then
						und.Position = UDim2.new(0, 24, 0, 16 + titleH + 4)
					end
					local bodyH = math.max(paragraphBodyEl.TextBounds.Y, 18)
					paragraphBodyEl.Size = UDim2.new(1, -44, 0, bodyH)
					paragraphBodyEl.Position = UDim2.new(0, 24, 0, 16 + titleH + 14)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, 22 + titleH + 14 + bodyH + 22)
				end

				AddConnection(paragraphBodyEl:GetPropertyChangedSignal("Text"), reflowParagraph)
				AddConnection(paragraphTitleEl:GetPropertyChangedSignal("Text"), reflowParagraph)

				paragraphBodyEl.Text = Content
				reflowParagraph()
				task.defer(reflowParagraph)

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					paragraphBodyEl.Text = ToChange
				end
				return ParagraphFunction
			end    
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "mouse-pointer-click"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local buttonCaptionEl = AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "CostumButtonCaption"
				}), "Text")

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 14), {
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 0.62,
					Parent = ItemParent
				}), {
					buttonCaptionEl,
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function()
						ButtonConfig.Callback()
					end)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Button:Set(ButtonText)
					buttonCaptionEl.Text = ButtonText
				end

				return Button
			end    
			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
				local TOff = Theme.Divider
				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

				local AccentBar = Create("Frame", {
					Name = "AccentBar",
					Size = UDim2.new(0, 4, 0.68, 0),
					Position = UDim2.new(0, 14, 0.16, 0),
					BackgroundColor3 = TOff,
					BackgroundTransparency = 0.35,
					BorderSizePixel = 0
				}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

				local Inner = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Theme.Main, 0, 14), {
					Size = UDim2.new(1, -36, 1, -16),
					Position = UDim2.new(0, 26, 0, 8),
					BackgroundTransparency = 0.55,
					Name = "Inner"
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.9, Thickness = 1}), "Stroke")
				}), "Main")

				local SwitchTrack = SetChildren(SetProps(MakeElement("RoundFrame", TOff, 0, 16), {
					Size = UDim2.new(0, 58, 0, 32),
					Position = UDim2.new(1, -14, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 0.22,
					Name = "SwitchTrack"
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Name = "TrackStroke", Transparency = 0.78, Thickness = 1.1}), "Stroke"),
					Create("Frame", {
						Name = "Knob",
						Size = UDim2.new(0, 26, 0, 26),
						Position = UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0,
						BorderSizePixel = 0,
						ZIndex = 2
					}, {
						Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
						Create("UIStroke", {Color = Color3.fromRGB(240, 245, 255), Transparency = 0.75, Thickness = 1.2})
					})
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
					Size = UDim2.new(1, 0, 0, 60),
					BackgroundTransparency = 0.45,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.88, Thickness = 1.08}), "Stroke"),
					AccentBar,
					Inner,
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -118, 1, 0),
						Position = UDim2.new(0, 38, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 15,
						TextTransparency = 0.03,
						Name = "Content"
					}), "Text"),
					SwitchTrack,
					Click
				}), "Second")

				local knob = SwitchTrack:FindFirstChild("Knob")
				local trackStroke = SwitchTrack:FindFirstChild("TrackStroke")

				function Toggle:Set(Value)
					Toggle.Value = Value
					local on = Toggle.Value
					local col = on and ToggleConfig.Color or TOff
					TweenService:Create(AccentBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = on and ToggleConfig.Color or TOff,
						BackgroundTransparency = on and 0.05 or 0.35
					}):Play()
					TweenService:Create(SwitchTrack, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = col,
						BackgroundTransparency = on and 0.08 or 0.22
					}):Play()
					if trackStroke and trackStroke:IsA("UIStroke") then
						TweenService:Create(trackStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Color = on and ToggleConfig.Color or Theme.Stroke,
							Transparency = on and 0.42 or 0.78
						}):Play()
					end
					if knob then
						TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Position = on and UDim2.new(0, 29, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
						}):Play()
					end
					ToggleConfig.Callback(Toggle.Value)
				end

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.32}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.45}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)

				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end
				return Toggle
			end  
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent2
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local function formatVal(v)
					local s = tostring(v)
					if SliderConfig.ValueName ~= "" then
						s = s .. " " .. SliderConfig.ValueName
					end
					return s
				end

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", Theme.Divider, 0, 1), {
					Size = UDim2.new(1, -32, 0, 10),
					Position = UDim2.new(0, 16, 0, 52),
					BackgroundTransparency = 0.42,
					Name = "SliderBar",
					ZIndex = 2
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.9, Thickness = 1}), "Stroke")
				})

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 1), {
					Size = UDim2.fromScale(0, 1),
					BackgroundTransparency = 0.04,
					ClipsDescendants = true,
					ZIndex = 2
				}), {
					Create("UIGradient", {
						Color = ColorSequence.new(
							SliderConfig.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.28),
							SliderConfig.Color
						)
					})
				})
				SliderDrag.Parent = SliderBar

				local Thumb = Create("Frame", {
					Name = "Thumb",
					Size = UDim2.new(0, 16, 0, 16),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 4
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {Color = SliderConfig.Color, Thickness = 1.5, Transparency = 0.2})
				})
				Thumb.Parent = SliderBar

				local ValueBadge = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Theme.Main, 0, 10), {
					Size = UDim2.new(0, 72, 0, 26),
					Position = UDim2.new(1, -16, 0, 12),
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 0.5,
					Name = "ValueBadge"
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.82,
						Thickness = 1,
						Color = SliderConfig.Color
					}), "Stroke"),
					SetProps(MakeElement("Label", formatVal(Slider.Value), 13), {
						Size = UDim2.new(1, -8, 1, 0),
						Position = UDim2.new(0, 4, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "ValueText",
						TextColor3 = SliderConfig.Color
					})
				}), "Second")

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
					Size = UDim2.new(1, 0, 0, 86),
					BackgroundTransparency = 0.46,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.88, Thickness = 1.05}), "Stroke"),
					Create("Frame", {
						Size = UDim2.new(0, 3, 0, 36),
						Position = UDim2.new(0, 12, 0, 14),
						BackgroundColor3 = SliderConfig.Color,
						BackgroundTransparency = 0.2,
						BorderSizePixel = 0
					}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})}),
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -120, 0, 22),
						Position = UDim2.new(0, 22, 0, 14),
						Font = Enum.Font.GothamBold,
						TextSize = 15,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", tostring(SliderConfig.Min) .. " — " .. tostring(SliderConfig.Max), 11), {
						Size = UDim2.new(1, -120, 0, 14),
						Position = UDim2.new(0, 22, 0, 34),
						Font = Enum.Font.GothamMedium,
						TextSize = 11,
						TextTransparency = 0.38,
						TextXAlignment = Enum.TextXAlignment.Left,
						Name = "RangeLbl"
					}), "TextDark"),
					ValueBadge,
					SliderBar
				}), "Second")

				local function updateThumb(scale)
					Thumb.Position = UDim2.new(scale, 0, 0.5, 0)
				end

				SliderBar.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						local sc = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / math.max(SliderBar.AbsoluteSize.X, 1), 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * sc))
						SaveCfg(game.GameId)
					end
				end)
				SliderBar.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
						local sc = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / math.max(SliderBar.AbsoluteSize.X, 1), 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * sc))
						SaveCfg(game.GameId)
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					local span = math.max(SliderConfig.Max - SliderConfig.Min, 1e-6)
					local scale = (self.Value - SliderConfig.Min) / span
					TweenService:Create(SliderDrag, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(scale, 1)}):Play()
					updateThumb(scale)
					local txt = formatVal(self.Value)
					ValueBadge.ValueText.Text = txt
					local tw = math.clamp(ValueBadge.ValueText.TextBounds.X + 22, 56, 160)
					ValueBadge.Size = UDim2.new(0, tw, 0, 26)
					SliderConfig.Callback(self.Value)
				end

				Slider:Set(Slider.Value)
				if SliderConfig.Flag then
					OrionLib.Flags[SliderConfig.Flag] = Slider
				end
				return Slider
			end  
			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
				local DAccent = Theme.Accent
				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5
				local RowH = 36
				local RowGap = 6
				local HeaderH = 46

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List", 0, RowGap)

				local DropdownContainer = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", DAccent, 3), {
					Position = UDim2.new(0, 0, 0, HeaderH),
					Size = UDim2.new(1, 0, 1, -HeaderH),
					ClipsDescendants = true,
					ScrollBarImageTransparency = 0.55,
					BorderSizePixel = 0
				}), {
					DropdownList,
					MakeElement("Padding", 10, 10, 10, 8)
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
					Size = UDim2.new(1, 0, 0, HeaderH),
					BackgroundTransparency = 0.52,
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(0.38, -8, 1, 0),
							Position = UDim2.new(0, 16, 0, 0),
							Font = Enum.Font.GothamBold,
							TextSize = 15,
							TextTransparency = 0.04,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "chevron-down"), {
							Size = UDim2.new(0, 18, 0, 18),
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -16, 0.5, 0),
							ImageTransparency = 0.2,
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(0.55, -52, 1, 0),
							Position = UDim2.new(0.38, 8, 0, 0),
							Font = Enum.Font.GothamMedium,
							TextSize = 14,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right,
							TextTruncate = Enum.TextTruncate.AtEnd
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, -32, 0, 1),
							Position = UDim2.new(0, 16, 1, -1),
							Name = "Line",
							Visible = false,
							BackgroundTransparency = 0.45
						}), "Stroke"),
						Click
					}), {
						Size = UDim2.new(1, 0, 0, HeaderH),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.9,
						Thickness = 1.05
					}), "Stroke")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, math.ceil(DropdownList.AbsoluteContentSize.Y + 20))
				end)

				local function styleOptionRow(btn, selected)
					local row = btn:FindFirstChild("RowBg")
					if not row then return end
					local title = row:FindFirstChild("Title")
					local stroke = row:FindFirstChildOfClass("UIStroke")
					TweenService:Create(row, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundTransparency = selected and 0.14 or 0.7
					}):Play()
					if title then
						TweenService:Create(title, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							TextTransparency = selected and 0.02 or 0.28
						}):Play()
					end
					if stroke then
						TweenService:Create(stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Color = selected and DAccent or Theme.Stroke,
							Transparency = selected and 0.55 or 0.9
						}):Play()
					end
				end

				local function AddOptions(Options)
					for _, Option in ipairs(Options) do
						local RowBg = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Theme.Second, 0, 10), {
							Name = "RowBg",
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 0.7,
							BorderSizePixel = 0
						}), {
							AddThemeObject(SetProps(MakeElement("Stroke"), {
								Transparency = 0.9,
								Thickness = 1.05
							}), "Stroke"),
							AddThemeObject(SetProps(MakeElement("Label", Option, 14), {
								Position = UDim2.new(0, 14, 0, 0),
								Size = UDim2.new(1, -18, 1, 0),
								Font = Enum.Font.GothamMedium,
								TextSize = 14,
								Name = "Title",
								TextXAlignment = Enum.TextXAlignment.Left
							}), "Text")
						}), "Second")

						local OptionBtn = SetChildren(SetProps(MakeElement("Button"), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, -4, 0, RowH),
							BackgroundTransparency = 1,
							AutoButtonColor = false,
							BorderSizePixel = 0
						}), {
							RowBg
						})

						AddConnection(OptionBtn.MouseEnter, function()
							if Dropdown.Value ~= Option then
								TweenService:Create(RowBg, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.52}):Play()
							end
						end)
						AddConnection(OptionBtn.MouseLeave, function()
							if Dropdown.Value ~= Option then
								TweenService:Create(RowBg, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
							end
						end)

						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)

						Dropdown.Buttons[Option] = OptionBtn
					end
				end

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _, v in pairs(Dropdown.Buttons) do
							v:Destroy()
						end
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, btn in pairs(Dropdown.Buttons) do
							styleOptionRow(btn, false)
						end
						return
					end

					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value

					for opt, btn in pairs(Dropdown.Buttons) do
						styleOptionRow(btn, opt == Value)
					end
					return DropdownConfig.Callback(Dropdown.Value)
				end

				local function openHeight()
					local listY = math.max(DropdownList.AbsoluteContentSize.Y, RowH + RowGap)
					if #Dropdown.Options > MaxElements then
						return HeaderH + (MaxElements * (RowH + RowGap)) + 18
					end
					return HeaderH + listY + 18
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Rotation = Dropdown.Toggled and 180 or 0
					}):Play()
					TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = Dropdown.Toggled and UDim2.new(1, 0, 0, openHeight()) or UDim2.new(1, 0, 0, HeaderH)
					}):Play()
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
				return Dropdown
			end
			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
				local Bind = {Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Theme.Main, 0, 10), {
					Size = UDim2.new(0, 88, 0, 34),
					Position = UDim2.new(1, -16, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 0.35,
					Name = "BindBox"
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.82,
						Thickness = 1.05
					}), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", "···", 14), {
						Size = UDim2.new(1, -16, 1, 0),
						Position = UDim2.new(0, 8, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Second")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
					Size = UDim2.new(1, 0, 0, 50),
					BackgroundTransparency = 0.52,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -112, 1, 0),
						Position = UDim2.new(0, 16, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 15,
						TextTransparency = 0.04,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.9,
						Thickness = 1.05
					}), "Stroke"),
					BindBox,
					Click
				}), "Second")

				local function resizeChip()
					local pad = 28
					local w = math.clamp(BindBox.Value.TextBounds.X + pad, 72, 220)
					TweenService:Create(BindBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, w, 0, 34)
					}):Play()
				end

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), resizeChip)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = "…"
						TweenService:Create(BindBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.12}):Play()
						local st = BindBox:FindFirstChildOfClass("UIStroke")
						if st then
							TweenService:Create(st, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
								Color = Theme.Accent,
								Transparency = 0.45
							}):Play()
						end
					end
				end)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.42}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.52}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = (Bind.Value and Bind.Value.Name) or Bind.Value or "···"
					BindBox.Value.Text = Bind.Value
					TweenService:Create(BindBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.35}):Play()
					local st = BindBox:FindFirstChildOfClass("UIStroke")
					if st then
						TweenService:Create(st, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
							Color = Theme.Stroke,
							Transparency = 0.82
						}):Play()
					end
				end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then
					OrionLib.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end  
			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Theme = OrionLib.Themes[OrionLib.SelectedTheme]

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 0
				})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, -24, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Text = "",
					PlaceholderText = "Eingabe…",
					Font = Enum.Font.GothamMedium,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					ClearTextOnFocus = false,
					ZIndex = 3
				}), "Text")
				TextboxActual.PlaceholderColor3 = Theme.TextDark
				TextboxActual.TextColor3 = Theme.Text

				local InputShell = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Theme.Main, 0, 12), {
					Size = UDim2.new(1, -32, 0, 40),
					Position = UDim2.new(0, 16, 0, 36),
					BackgroundTransparency = 0.42,
					Name = "InputShell",
					ZIndex = 2
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.88,
						Thickness = 1.05
					}), "Stroke"),
					TextboxActual
				}), "Second")

				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
					Size = UDim2.new(1, 0, 0, 92),
					BackgroundTransparency = 0.52,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 14), {
						Size = UDim2.new(1, -32, 0, 22),
						Position = UDim2.new(0, 16, 0, 10),
						Font = Enum.Font.GothamBold,
						TextSize = 14,
						TextTransparency = 0.12,
						Name = "Content"
					}), "TextDark"),
					AddThemeObject(SetProps(MakeElement("Stroke"), {
						Transparency = 0.9,
						Thickness = 1.05
					}), "Stroke"),
					InputShell,
					Click
				}), "Second")

				local function textboxFocusIn()
					TweenService:Create(InputShell, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.22}):Play()
					local st = InputShell:FindFirstChildOfClass("UIStroke")
					if st then
						TweenService:Create(st, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
							Color = Theme.Accent,
							Transparency = 0.55
						}):Play()
					end
				end

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
					end
					TweenService:Create(InputShell, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.42}):Play()
					local st = InputShell:FindFirstChildOfClass("UIStroke")
					if st then
						TweenService:Create(st, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
							Color = Theme.Stroke,
							Transparency = 0.88
						}):Play()
					end
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.42}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.52}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					textboxFocusIn()
					TextboxActual:CaptureFocus()
				end)
			end 
			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local T = OrionLib.Themes[OrionLib.SelectedTheme]
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}
				local ColorH, ColorS, ColorV = Color3.toHSV(Colorpicker.Value)
				local colorConn, hueConn = nil, nil
				local function disC()
					if colorConn then
						colorConn:Disconnect()
						colorConn = nil
					end
				end
				local function disH()
					if hueConn then
						hueConn:Disconnect()
						hueConn = nil
					end
				end

				local function rgbToHex(c)
					return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
				end

				local function rgbLine(c)
					return string.format("R %d  ·  G %d  ·  B %d", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
				end

				local fieldH = 158
				local hueColW = 30
				local CpCorner = UDim.new(0, 12)

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 22, 0, 22),
					Position = UDim2.new(ColorS, 0, 1 - ColorV, 0),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://4805639000",
					ZIndex = 5,
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ImageTransparency = 0.02
				}, {
					Create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2.2, Transparency = 0.08}),
					Create("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3.2, Transparency = 0.5})
				})

				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 26, 0, 14),
					Position = UDim2.new(0.5, 0, 1 - ColorH, 0),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "rbxassetid://4805639000",
					ZIndex = 5,
					Rotation = 90,
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ImageTransparency = 0.02
				}, {
					Create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.75, Transparency = 0.12}),
					Create("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 2.75, Transparency = 0.48})
				})

				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -(hueColW + 12), 0, fieldH),
					Position = UDim2.new(0, 0, 0, 0),
					Visible = false,
					Image = "rbxassetid://4155801252",
					BackgroundTransparency = 1,
					ZIndex = 3
				}, {
					Create("UICorner", {CornerRadius = CpCorner}),
					Create("UIStroke", {Color = T.Accent, Transparency = 0.65, Thickness = 1.2}),
					ColorSelection
				})

				local Hue = Create("Frame", {
					Size = UDim2.new(0, hueColW, 0, fieldH),
					Position = UDim2.new(1, -hueColW, 0, 0),
					Visible = false,
					BorderSizePixel = 0,
					ZIndex = 3
				}, {
					Create("UIGradient", {
						Rotation = 270,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
							ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234, 255, 0)),
							ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21, 255, 0)),
							ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 17, 255)),
							ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255, 0, 251)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))
						})
					}),
					Create("UICorner", {CornerRadius = CpCorner}),
					Create("UIStroke", {Color = T.Stroke, Transparency = 0.65, Thickness = 1.15}),
					HueSelection
				})

				local previewY = fieldH + 14
				local BigPreview = Create("Frame", {
					Name = "BigPreview",
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 0, 0, previewY),
					BackgroundColor3 = Colorpicker.Value,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 4
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
					Create("UIStroke", {Color = T.Text, Transparency = 0.5, Thickness = 1.35})
				})

				local HexLabel = AddThemeObject(SetProps(MakeElement("Label", rgbToHex(Colorpicker.Value), 13), {
					Size = UDim2.new(1, -72, 0, 22),
					Position = UDim2.new(0, 68, 0, previewY + 2),
					Font = Enum.Font.GothamBold,
					TextSize = 17,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 0.06,
					Name = "HexLabel",
					Visible = false,
					ZIndex = 4
				}), "Text")

				local RGBLabel = AddThemeObject(SetProps(MakeElement("Label", rgbLine(Colorpicker.Value), 12), {
					Size = UDim2.new(1, -72, 0, 18),
					Position = UDim2.new(0, 68, 0, previewY + 28),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 0.28,
					Name = "RGBLabel",
					Visible = false,
					ZIndex = 4
				}), "TextDark")

				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 58),
					Size = UDim2.new(1, 0, 1, -58),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Color,
					Hue,
					BigPreview,
					HexLabel,
					RGBLabel,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 16),
						PaddingRight = UDim.new(0, 16),
						PaddingBottom = UDim.new(0, 14),
						PaddingTop = UDim.new(0, 12)
					})
				})

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ColorpickerBox = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 12), {
					Size = UDim2.new(0, 40, 0, 40),
					Position = UDim2.new(1, -18, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 0,
					Name = "Swatch"
				}), {
					Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
					Create("UIStroke", {Color = T.Text, Transparency = 0.55, Thickness = 1.35})
				})
				ColorpickerBox.BackgroundColor3 = Colorpicker.Value

				local CpHeaderH = 54
				local CpOpenH = 318
				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
					Size = UDim2.new(1, 0, 0, CpHeaderH),
					BackgroundTransparency = 0.48,
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -120, 1, 0),
							Position = UDim2.new(0, 18, 0, 0),
							Font = Enum.Font.GothamBold,
							TextSize = 15,
							TextTransparency = 0.04,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, -36, 0, 1),
							Position = UDim2.new(0, 18, 1, -1),
							Name = "Line",
							Visible = false,
							BackgroundTransparency = 0.5
						}), "Stroke")
					}), {
						Size = UDim2.new(1, 0, 0, CpHeaderH),
						ClipsDescendants = true,
						Name = "F"
					}),
					Create("Frame", {
						Name = "CpAccent",
						Size = UDim2.new(1, 0, 0, 4),
						Position = UDim2.new(0, 0, 0, CpHeaderH),
						BackgroundColor3 = T.Accent,
						BorderSizePixel = 0,
						BackgroundTransparency = 0.1,
						Visible = false,
						ZIndex = 3
					}, {
						Create("UIGradient", {
							Rotation = 0,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, T.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.3)),
								ColorSequenceKeypoint.new(1, T.Accent)
							})
						})
					}),
					ColorpickerContainer,
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.88, Thickness = 1.08}), "Stroke")
				}), "Second")

				local function syncFromColor(c)
					ColorH, ColorS, ColorV = Color3.toHSV(c)
					HueSelection.Position = UDim2.new(0.5, 0, 1 - ColorH, 0)
					ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					ColorpickerBox.BackgroundColor3 = c
					HexLabel.Text = rgbToHex(c)
					RGBLabel.Text = rgbLine(c)
					BigPreview.BackgroundColor3 = c
				end

				local function UpdateColorPicker()
					local c = Color3.fromHSV(ColorH, ColorS, ColorV)
					Colorpicker.Value = c
					ColorpickerBox.BackgroundColor3 = c
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					HexLabel.Text = rgbToHex(c)
					RGBLabel.Text = rgbLine(c)
					BigPreview.BackgroundColor3 = c
					ColorpickerConfig.Callback(c)
					SaveCfg(game.GameId)
				end

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, CpOpenH) or UDim2.new(1, 0, 0, CpHeaderH)
					}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					HexLabel.Visible = Colorpicker.Toggled
					RGBLabel.Visible = Colorpicker.Toggled
					BigPreview.Visible = Colorpicker.Toggled
					local cpa = ColorpickerFrame:FindFirstChild("CpAccent")
					if cpa then
						cpa.Visible = Colorpicker.Toggled
					end
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
					if Colorpicker.Toggled then
						syncFromColor(Colorpicker.Value)
					end
				end)

				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						disC()
						colorConn = RunService.RenderStepped:Connect(function()
							local ax = math.max(Color.AbsoluteSize.X, 1)
							local ay = math.max(Color.AbsoluteSize.Y, 1)
							local ColorX = math.clamp((Mouse.X - Color.AbsolutePosition.X) / ax, 0, 1)
							local ColorY = math.clamp((Mouse.Y - Color.AbsolutePosition.Y) / ay, 0, 1)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						disC()
					end
				end)

				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						disH()
						hueConn = RunService.RenderStepped:Connect(function()
							local hy = math.max(Hue.AbsoluteSize.Y, 1)
							local HueY = math.clamp((Mouse.Y - Hue.AbsolutePosition.Y) / hy, 0, 1)
							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						disH()
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					syncFromColor(Value)
					ColorpickerConfig.Callback(Value)
				end

				syncFromColor(Colorpicker.Value)
				if ColorpickerConfig.Flag then
					OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker
				end
				return Colorpicker
			end  
			return ElementFunction   
		end	

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"
			local SAcc = OrionLib.Themes[OrionLib.SelectedTheme].Accent

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 34),
				Parent = Container
			}), {
				Create("Frame", {
					Name = "SectionAccent",
					Size = UDim2.new(0, 3, 0, 20),
					Position = UDim2.new(0, 0, 0, 8),
					BackgroundColor3 = SAcc,
					BorderSizePixel = 0,
					BackgroundTransparency = 0.12
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)})
				}),
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -22, 0, 22),
					Position = UDim2.new(0, 14, 0, 6),
					Font = Enum.Font.GothamBold,
					TextSize = 15,
					TextTransparency = 0.06,
					TextXAlignment = Enum.TextXAlignment.Left
				}), "Text"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 34),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 10)
				}),
			})

			local secList = SectionFrame.Holder:FindFirstChildOfClass("UIListLayout")
			if secList then
				AddConnection(secList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					local h = secList.AbsoluteContentSize.Y
					SectionFrame.Holder.Size = UDim2.new(1, 0, 0, math.max(h, 1))
					SectionFrame.Size = UDim2.new(1, 0, 0, math.max(h, 1) + 40)
					task.defer(RefreshItemContainerCanvas)
				end)
			end

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			local ThP = OrionLib.Themes[OrionLib.SelectedTheme]
			local gate = SetChildren(SetProps(MakeElement("RoundFrame", ThP.Main, 0, 18), {
				Name = "PremiumLockOverlay",
				Size = UDim2.new(1, 8, 1, 8),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0.25,
				ZIndex = 100,
				Visible = not OrionLib.PremiumUnlocked,
				ClipsDescendants = true
			}), {
				Create("UIGradient", {
					Rotation = 95,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.55),
						NumberSequenceKeypoint.new(1, 0.75)
					})
				}),
				AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.55, Thickness = 1.1}), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Image", "lock"), {
					Size = UDim2.new(0, 52, 0, 52),
					Position = UDim2.new(0.5, 0, 0.36, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ImageTransparency = 0.12,
					Name = "LockHero"
				}), "Accent"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium-Bereich", 20), {
					Size = UDim2.new(1, -40, 0, 28),
					Position = UDim2.new(0.5, 0, 0.5, -8),
					AnchorPoint = Vector2.new(0.5, 0),
					Font = Enum.Font.GothamBold,
					TextSize = 20,
					TextXAlignment = Enum.TextXAlignment.Center
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Schalte Premium mit deinem Lizenzschlüssel frei (Sidebar unten).", 13), {
					Size = UDim2.new(1, -48, 0, 50),
					Position = UDim2.new(0.5, 0, 0.5, 28),
					AnchorPoint = Vector2.new(0.5, 0),
					TextWrapped = true,
					TextTransparency = 0.2,
					TextXAlignment = Enum.TextXAlignment.Center
				}), "TextDark")
			})
			gate.Parent = Container
			table.insert(PremiumOverlayRegistry, gate)
		end
		return ElementFunction   
	end  
	
	TabFunction.OpenPremiumUnlock = openPremiumModal

	return TabFunction
end   

function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib
