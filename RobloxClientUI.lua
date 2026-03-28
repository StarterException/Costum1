-- Costum UI — Orion-kompatible API (jensonhirst/Orion); Premium-Glass-Layout & Lyphix-Theme.
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
	Themes = {
		Default = {
			Main = Color3.fromRGB(7, 9, 15),
			Second = Color3.fromRGB(16, 19, 30),
			Stroke = Color3.fromRGB(48, 58, 82),
			Divider = Color3.fromRGB(28, 33, 48),
			Text = Color3.fromRGB(252, 253, 255),
			TextDark = Color3.fromRGB(126, 136, 168),
			Accent = Color3.fromRGB(56, 189, 248),
			Accent2 = Color3.fromRGB(124, 214, 255)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
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

function OrionLib:IsRunning()
	local p = Orion.Parent
	if not p then
		return false
	end
	if gethui then
		local h = gethui()
		if h and p == h then
			return true
		end
	end
	return p == game:GetService("CoreGui")
end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end   

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
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
		Element[Property] = Value
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
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		local C = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		if C then
			for _, Object in pairs(Type) do
				Object[ReturnProperty(Object)] = C
			end
		end
	end
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
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
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

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = math.max(NotificationConfig.Time or 5, 1.2)

		local Th = OrionLib.Themes[OrionLib.SelectedTheme]
		local Acc = Th.Accent
		local MainC = Th.Main

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = -math.floor(tick() * 1000) % 2147483647,
			Parent = NotificationHolder
		})

		local dur = NotificationConfig.Time

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", MainC, 0, 22), {
			Parent = NotificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, 120, 0, 0),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 0.62,
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
			ZIndex = 2
		}), {
			Create("Frame", {
				Name = "CardShadow",
				ZIndex = 0,
				Size = UDim2.new(1, 14, 1, 14),
				Position = UDim2.new(0.5, 0, 0.5, 6),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.86,
				BorderSizePixel = 0
			}, {
				Create("UICorner", {CornerRadius = UDim.new(0, 24)})
			}),
			Create("UIGradient", {
				Rotation = 108,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.82),
					NumberSequenceKeypoint.new(0.45, 0.9),
					NumberSequenceKeypoint.new(1, 0.94)
				}),
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Acc:Lerp(Color3.fromRGB(255, 255, 255), 0.35)),
					ColorSequenceKeypoint.new(0.4, MainC:Lerp(Acc, 0.08)),
					ColorSequenceKeypoint.new(1, MainC)
				})
			}),
			SetProps(MakeElement("Stroke", Acc, 1.45), {
				Transparency = 0.48,
				Name = "CardStroke"
			}),
			Create("Frame", {
				Name = "AccentRail",
				Size = UDim2.new(0, 5, 0, 56),
				Position = UDim2.new(0, 13, 0, 15),
				BackgroundColor3 = Acc,
				BorderSizePixel = 0,
				BackgroundTransparency = 0,
				ZIndex = 2
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
				Create("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Acc:Lerp(Color3.fromRGB(255, 255, 255), 0.2)),
						ColorSequenceKeypoint.new(1, Acc:Lerp(MainC, 0.35))
					})
				}),
				Create("UIStroke", {
					Color = Acc:Lerp(Color3.fromRGB(255, 255, 255), 0.5),
					Thickness = 1,
					Transparency = 0.55
				})
			}),
			SetChildren(SetProps(MakeElement("RoundFrame", Th.Second, 0, 16), {
				Size = UDim2.new(0, 52, 0, 52),
				Position = UDim2.new(0, 24, 0, 17),
				Name = "IconWrap",
				BackgroundTransparency = 0.28,
				ZIndex = 2
			}), {
				Create("UIGradient", {
					Rotation = 135,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Th.Second)
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.88),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				SetProps(MakeElement("Stroke", Acc, 1.2), {Transparency = 0.38, Name = "IconRing"}),
				SetProps(MakeElement("Image", NotificationConfig.Image), {
					Size = UDim2.new(0, 28, 0, 28),
					Position = UDim2.new(0.5, -14, 0.5, -14),
					ImageColor3 = Color3.fromRGB(252, 253, 255),
					ImageTransparency = 0.02,
					Name = "Icon",
					ZIndex = 2
				})
			}),
			SetChildren(SetProps(MakeElement("Label", "Hinweis", 11), {
				Size = UDim2.new(0, 0, 0, 20),
				AutomaticSize = Enum.AutomaticSize.X,
				Position = UDim2.new(0, 88, 0, 16),
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextTransparency = 0.15,
				TextXAlignment = Enum.TextXAlignment.Left,
				Name = "Tag",
				Text = string.upper(NotificationConfig.Name),
				TextColor3 = Acc,
				ZIndex = 2,
				BackgroundColor3 = Acc,
				BackgroundTransparency = 0.9
			}), {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
				Create("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2)
				})
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 16), {
				Size = UDim2.new(1, -100, 0, 28),
				Position = UDim2.new(0, 88, 0, 38),
				Font = Enum.Font.GothamBold,
				TextSize = 19,
				TextXAlignment = Enum.TextXAlignment.Left,
				Name = "Title",
				ZIndex = 2
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, -100, 0, 0),
				Position = UDim2.new(0, 88, 0, 68),
				Font = Enum.Font.GothamMedium,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Th.TextDark,
				TextTransparency = 0.08,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				LineHeight = 1.18,
				ZIndex = 2
			}),
			Create("Frame", {
				Name = "ProgressBack",
				Size = UDim2.new(1, -28, 0, 6),
				Position = UDim2.new(0, 14, 1, -16),
				BackgroundColor3 = Th.Divider,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				ZIndex = 2
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
				Create("UIStroke", {
					Color = Color3.fromRGB(255, 255, 255),
					Transparency = 0.92,
					Thickness = 1
				}),
				Create("Frame", {
					Name = "ProgressFill",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Acc,
					BorderSizePixel = 0,
					BackgroundTransparency = 0.06,
					ZIndex = 2
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIGradient", {
						Rotation = 0,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Acc:Lerp(Color3.fromRGB(255, 255, 255), 0.15)),
							ColorSequenceKeypoint.new(0.55, Acc),
							ColorSequenceKeypoint.new(1, Acc:Lerp(Color3.fromRGB(0, 0, 0), 0.15))
						})
					}),
					Create("Frame", {
						Name = "ProgressSheen",
						Size = UDim2.new(0.35, 0, 1.4, 0),
						Position = UDim2.new(0.15, 0, -0.2, 0),
						BackgroundTransparency = 0.65,
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						ZIndex = 3
					}, {
						Create("UIGradient", {
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.5, 0.55),
								NumberSequenceKeypoint.new(1, 1)
							})
						})
					})
				})
			}),
			MakeElement("Padding", 24, 20, 22, 18)
		})

		NotificationFrame.ProgressBack.AnchorPoint = Vector2.new(0, 1)
		NotificationFrame.ProgressBack.Position = UDim2.new(0, 14, 1, -14)

		local iw = NotificationFrame:FindFirstChild("IconWrap")
		if iw and iw:FindFirstChild("Icon") then
			iw.Icon.Rotation = -6
			TweenService:Create(iw.Icon, TweenInfo.new(0.65, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Rotation = 0}):Play()
		end

		TweenService:Create(NotificationFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.12
		}):Play()

		local fill = NotificationFrame.ProgressBack:FindFirstChild("ProgressFill")
		if fill then
			fill.Size = UDim2.new(1, 0, 1, 0)
			TweenService:Create(fill, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		end

		wait(dur - 0.35)

		local wrap = NotificationFrame:FindFirstChild("IconWrap")
		local wrapIcon = wrap and wrap:FindFirstChild("Icon")
		if wrapIcon then
			TweenService:Create(wrapIcon, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		end
		if wrap then
			local ring = wrap:FindFirstChild("IconRing")
			if ring and ring:IsA("UIStroke") then
				TweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			end
		end
		local ar = NotificationFrame:FindFirstChild("AccentRail")
		if ar then
			TweenService:Create(ar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			local ars = ar:FindFirstChildOfClass("UIStroke")
			if ars then
				TweenService:Create(ars, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
			end
		end
		local sh = NotificationFrame:FindFirstChild("CardShadow")
		if sh then
			TweenService:Create(sh, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		end
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		TweenService:Create(NotificationFrame.Tag, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		local cs = NotificationFrame:FindFirstChild("CardStroke")
		if cs and cs:IsA("UIStroke") then
			TweenService:Create(cs, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		end
		if NotificationFrame.ProgressBack then
			TweenService:Create(NotificationFrame.ProgressBack, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			local pf = NotificationFrame.ProgressBack:FindFirstChild("ProgressFill")
			if pf then
				TweenService:Create(pf, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
			end
		end
		wait(0.15)

		TweenService:Create(NotificationFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 100, 0, 0)
		}):Play()
		wait(0.6)
		NotificationParent:Destroy()
	end)
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
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.BrandName = WindowConfig.BrandName or "Lyphix"
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
	local WinAccent = OrionLib.Themes[OrionLib.SelectedTheme].Accent

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 2), {
		Size = UDim2.new(1, 0, 1, -112),
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

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Glyph"
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 54)
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
			Create("Frame", {
				Size = UDim2.new(0, 3, 0, 14),
				Position = UDim2.new(0, 14, 0.5, -7),
				BackgroundColor3 = WinAccent,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			}),
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
			Size = UDim2.new(1, 0, 0, 62),
			Position = UDim2.new(0, 0, 1, -62)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, -20, 0, 1),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 0.55
			}), "Stroke"),
			AddThemeObject(SetProps(MakeElement("Label", WindowConfig.BrandName, 14), {
				Size = UDim2.new(1, -28, 0, 18),
				Position = UDim2.new(0, 14, 0, 12),
				Font = Enum.Font.GothamBold,
				TextSize = 15,
				ClipsDescendants = true,
				Name = "BrandTitle",
				TextXAlignment = Enum.TextXAlignment.Left
			}), "Text"),
			SetProps(MakeElement("Label", WindowConfig.BrandTag, 11), {
				Size = UDim2.new(1, -28, 0, 28),
				Position = UDim2.new(0, 14, 0, 30),
				Font = Enum.Font.GothamMedium,
				TextColor3 = WinAccent,
				TextTransparency = 0.12,
				TextWrapped = true,
				Visible = WindowConfig.BrandTag ~= "",
				Name = "BrandTag",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			})
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -320, 2, 0),
		Position = UDim2.new(0, 28, 0, -26),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextTruncate = Enum.TextTruncate.AtEnd
	}), "Text")

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
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
				Size = UDim2.new(0, 196, 0, 38),
				Position = UDim2.new(1, -304, 0, 8),
				Name = "TabSearchBar",
				BackgroundTransparency = 0.52,
				ClipsDescendants = true
			}), {
				AddThemeObject(SetProps(MakeElement("Stroke"), {
					Transparency = 0.88,
					Thickness = 1.05,
					LineJoinMode = Enum.LineJoinMode.Round
				}), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://6031094677"), {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 14, 0.5, -8),
					ImageTransparency = 0.32,
					Name = "SearchIco"
				}), "TextDark"),
				Create("TextBox", {
					Name = "TabSearchInput",
					Size = UDim2.new(1, -44, 0, 26),
					Position = UDim2.new(0, 36, 0.5, -13),
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
			}), "Second"),
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
				Size = UDim2.new(0, 88, 0, 38),
				Position = UDim2.new(1, -98, 0, 8),
				Name = "WinControls",
				BackgroundTransparency = 0.44
			}), {
				AddThemeObject(SetProps(MakeElement("Stroke"), {
					Transparency = 0.85,
					Thickness = 1.05,
					LineJoinMode = Enum.LineJoinMode.Round
				}), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 0.55, 0),
					Position = UDim2.new(0.5, 0, 0.22, 0),
					BackgroundTransparency = 0.6
				}), "Stroke"), 
				CloseBtn,
				MinimizeBtn
			}), "Second"), 
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	MainWindow.BackgroundTransparency = 0.14
	WindowStuff.BackgroundTransparency = 0.36

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 54, 0, -26)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
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
	local function wireWinHover(btn, glyphName)
		local g = glyphName and btn:FindFirstChild(glyphName) or btn:FindFirstChild("Glyph") or btn:FindFirstChild("Ico")
		if not g or not g:IsA("ImageLabel") then return end
		AddConnection(btn.MouseEnter, function()
			TweenService:Create(g, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = TAcc2Col, ImageTransparency = 0.02}):Play()
		end)
		AddConnection(btn.MouseLeave, function()
			TweenService:Create(g, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = TTextCol, ImageTransparency = 0}):Play()
		end)
	end
	wireWinHover(CloseBtn, "Glyph")
	wireWinHover(MinimizeBtn, "Ico")

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap RightShift to reopen the interface",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 400)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"

			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 176, 0, 54)}):Play()
			wait(0.1)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

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
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 16), {
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
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -36, 1, 0),
						Position = UDim2.new(0, 24, 0, 0),
						Font = Enum.Font.GothamBold,
						TextSize = 15,
						TextTransparency = 0.04,
						Name = "Content"
					}), "Text")
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end
			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"
				local PAccent = OrionLib.Themes[OrionLib.SelectedTheme].Accent
				local PSecond = OrionLib.Themes[OrionLib.SelectedTheme].Second

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
					AddThemeObject(SetProps(MakeElement("Label", Text, 19), {
						Size = UDim2.new(1, -44, 0, 28),
						Position = UDim2.new(0, 24, 0, 18),
						Font = Enum.Font.GothamBold,
						TextSize = 19,
						TextTransparency = 0.02,
						TextXAlignment = Enum.TextXAlignment.Left,
						Name = "Title"
					}), "Text"),
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
					AddThemeObject(SetProps(MakeElement("Label", "", 14), {
						Size = UDim2.new(1, -44, 0, 0),
						Position = UDim2.new(0, 24, 0, 56),
						Font = Enum.Font.GothamMedium,
						TextTransparency = 0.12,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						Name = "Content"
					}), "TextDark")
				}), "Second")

				local function reflowParagraph()
					local titleH = math.max(ParagraphFrame.Title.TextBounds.Y, 24)
					ParagraphFrame.Title.Size = UDim2.new(1, -44, 0, titleH)
					local und = ParagraphFrame:FindFirstChild("TitleUnderline")
					if und then
						und.Position = UDim2.new(0, 24, 0, 16 + titleH + 4)
					end
					local bodyH = math.max(ParagraphFrame.Content.TextBounds.Y, 18)
					ParagraphFrame.Content.Size = UDim2.new(1, -44, 0, bodyH)
					ParagraphFrame.Content.Position = UDim2.new(0, 24, 0, 16 + titleH + 14)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, 22 + titleH + 14 + bodyH + 22)
				end

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), reflowParagraph)
				AddConnection(ParagraphFrame.Title:GetPropertyChangedSignal("Text"), reflowParagraph)

				ParagraphFrame.Content.Text = Content
				reflowParagraph()
				task.defer(reflowParagraph)

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end    
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 14), {
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 0.62,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
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
					ButtonFrame.Content.Text = ButtonText
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

				local TrackShadow = Create("Frame", {
					Name = "TrackShadow",
					Size = UDim2.new(1, -40, 0, 18),
					Position = UDim2.new(0, 22, 0, 102),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.82,
					BorderSizePixel = 0,
					ZIndex = 1
				}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", Theme.Divider, 0, 1), {
					Size = UDim2.new(1, -40, 0, 16),
					Position = UDim2.new(0, 20, 0, 100),
					BackgroundTransparency = 0.5,
					Name = "SliderBar",
					ZIndex = 2
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.86, Thickness = 1.05}), "Stroke")
				})

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 1), {
					Size = UDim2.fromScale(0, 1),
					BackgroundTransparency = 0.06,
					ClipsDescendants = true,
					ZIndex = 2
				}), {
					Create("UIGradient", {
						Rotation = 0,
						Color = ColorSequence.new(SliderConfig.Color, SliderConfig.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.35))
					})
				})
				SliderDrag.Parent = SliderBar

				local Thumb = Create("Frame", {
					Name = "Thumb",
					Size = UDim2.new(0, 22, 0, 22),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 4
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {Color = SliderConfig.Color, Thickness = 2, Transparency = 0.25}),
					Create("Frame", {
						Size = UDim2.new(0.45, 0, 0.45, 0),
						Position = UDim2.new(0.275, 0, 0.275, 0),
						BackgroundColor3 = SliderConfig.Color,
						BorderSizePixel = 0,
						BackgroundTransparency = 0.2
					}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
				})
				Thumb.Parent = SliderBar

				local ValueBig = AddThemeObject(SetProps(MakeElement("Label", formatVal(Slider.Value), 22), {
					Size = UDim2.new(1, -40, 0, 36),
					Position = UDim2.new(0, 20, 0, 52),
					Font = Enum.Font.GothamBold,
					TextSize = 26,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 0.02,
					Name = "ValueBig"
				}), "Text")

				local RangeLbl = AddThemeObject(SetProps(MakeElement("Label", tostring(SliderConfig.Min) .. " → " .. tostring(SliderConfig.Max), 11), {
					Size = UDim2.new(1, -40, 0, 16),
					Position = UDim2.new(0, 20, 0, 86),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextTransparency = 0.4,
					TextXAlignment = Enum.TextXAlignment.Left,
					Name = "RangeLbl"
				}), "TextDark")

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
					Size = UDim2.new(1, 0, 0, 134),
					BackgroundTransparency = 0.45,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Stroke"), {Transparency = 0.88, Thickness = 1.08}), "Stroke"),
					Create("Frame", {
						Size = UDim2.new(0, 4, 0.55, 0),
						Position = UDim2.new(0, 12, 0.2, 0),
						BackgroundColor3 = SliderConfig.Color,
						BackgroundTransparency = 0.25,
						BorderSizePixel = 0
					}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})}),
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -48, 0, 24),
						Position = UDim2.new(0, 24, 0, 14),
						Font = Enum.Font.GothamBold,
						TextSize = 15,
						Name = "Content"
					}), "Text"),
					ValueBig,
					RangeLbl,
					TrackShadow,
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
					TweenService:Create(SliderDrag, TweenInfo.new(0.12, Enum.EasingStyle.Quint), {Size = UDim2.fromScale(scale, 1)}):Play()
					updateThumb(scale)
					ValueBig.Text = formatVal(self.Value)
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
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
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
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end  
	
	return TabFunction
end   

function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib
