local ZenthraUI = (function()
-- ZenthraUI v2
-- A dependency-free Roblox UI library inspired by the supplied black/silver Zenthra reference.
-- Put this ModuleScript in ReplicatedStorage and require it from a LocalScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ZenthraUI = {}
ZenthraUI.__index = ZenthraUI

local Theme = {
	Background = Color3.fromRGB(4, 4, 5),
	Background2 = Color3.fromRGB(8, 8, 10),
	Sidebar = Color3.fromRGB(7, 7, 9),
	TopbarA = Color3.fromRGB(44, 44, 48),
	TopbarB = Color3.fromRGB(9, 9, 11),
	Surface = Color3.fromRGB(13, 13, 16),
	SurfaceRaised = Color3.fromRGB(18, 18, 22),
	SurfaceHover = Color3.fromRGB(25, 25, 30),
	Input = Color3.fromRGB(38, 38, 43),
	InputHover = Color3.fromRGB(48, 48, 54),
	Border = Color3.fromRGB(64, 64, 72),
	BorderSoft = Color3.fromRGB(34, 34, 39),
	Text = Color3.fromRGB(242, 242, 245),
	Muted = Color3.fromRGB(145, 145, 154),
	Dim = Color3.fromRGB(86, 86, 96),
	Silver = Color3.fromRGB(219, 219, 225),
	Success = Color3.fromRGB(126, 220, 167),
	Danger = Color3.fromRGB(236, 108, 123),
}

local function create(className, properties)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		if property ~= "Parent" then
			(object :: any)[property] = value
		end
	end
	if properties and properties.Parent then
		object.Parent = properties.Parent
	end
	return object
end

local function addCorner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent,
	})
end

local function addStroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function addPadding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingTop = UDim.new(0, top or left or 0),
		PaddingBottom = UDim.new(0, bottom or top or left or 0),
		Parent = parent,
	})
end

local function addList(parent, padding, direction)
	return create("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

local function tween(object, duration, properties, style, direction)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.16,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	animation:Play()
	return animation
end

local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, message = pcall(callback, ...)
	if not ok then
		warn("[ZenthraUI callback] " .. tostring(message))
	end
end

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function round(value, decimals)
	local power = 10 ^ (decimals or 0)
	return math.floor(value * power + 0.5) / power
end

local function keyName(keyCode)
	local aliases = {
		LeftShift = "LShift",
		RightShift = "RShift",
		LeftControl = "LCtrl",
		RightControl = "RCtrl",
		LeftAlt = "LAlt",
		RightAlt = "RAlt",
		MouseButton1 = "M1",
		MouseButton2 = "M2",
		MouseButton3 = "M3",
	}
	return aliases[keyCode.Name] or keyCode.Name
end

local function resolveParent()
	local player = Players.LocalPlayer
	if not player then
		error("ZenthraUI must run from a LocalScript")
	end
	return player:WaitForChild("PlayerGui")
end

local function makeFocusMark(parent, size, color)
	local holder = create("Frame", {
		Name = "FocusMark",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	local line = math.max(3, math.floor(size * 0.34))
	local thickness = 1
	local segments = {
		{ UDim2.fromOffset(line, thickness), UDim2.fromOffset(0, 0) },
		{ UDim2.fromOffset(thickness, line), UDim2.fromOffset(0, 0) },
		{ UDim2.fromOffset(line, thickness), UDim2.new(1, -line, 0, 0) },
		{ UDim2.fromOffset(thickness, line), UDim2.new(1, -thickness, 0, 0) },
		{ UDim2.fromOffset(line, thickness), UDim2.new(0, 0, 1, -thickness) },
		{ UDim2.fromOffset(thickness, line), UDim2.new(0, 0, 1, -line) },
		{ UDim2.fromOffset(line, thickness), UDim2.new(1, -line, 1, -thickness) },
		{ UDim2.fromOffset(thickness, line), UDim2.new(1, -thickness, 1, -line) },
	}
	for _, segment in ipairs(segments) do
		create("Frame", {
			BackgroundColor3 = color or Theme.Silver,
			BorderSizePixel = 0,
			Size = segment[1],
			Position = segment[2],
			Parent = holder,
		})
	end
	return holder
end

local function makeLockIcon(parent, position)
	local holder = create("Frame", {
		Name = "Lock",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = position or UDim2.new(1, -12, 0, 11),
		Size = UDim2.fromOffset(14, 16),
		Parent = parent,
	})
	local body = create("Frame", {
		BackgroundColor3 = Theme.Dim,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(2, 7),
		Size = UDim2.fromOffset(10, 8),
		Parent = holder,
	})
	addCorner(body, 2)
	addStroke(body, Theme.Muted, 1, 0.35)
	local shackle = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 1),
		Size = UDim2.fromOffset(6, 8),
		Parent = holder,
	})
	addCorner(shackle, 5)
	addStroke(shackle, Theme.Muted, 1, 0.25)
	create("Frame", {
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(1, 5),
		Size = UDim2.fromOffset(8, 4),
		Parent = shackle,
	})
	return holder
end

local function addHover(button, normalColor, hoverColor)
	button.MouseEnter:Connect(function()
		tween(button, 0.14, { BackgroundColor3 = hoverColor })
	end)
	button.MouseLeave:Connect(function()
		tween(button, 0.14, { BackgroundColor3 = normalColor })
	end)
end

local function setFlag(window, flag, value)
	if flag then
		window.Flags[flag] = value
	end
end

local function makeDraggable(window, handle, target)
	local dragging = false
	local dragInput
	local dragStart
	local startPosition

	window:_Connect(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
			local endedConnection
			endedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if endedConnection then
						endedConnection:Disconnect()
					end
				end
			end)
		end
	end)

	window:_Connect(handle.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	window:_Connect(UserInputService.InputChanged, function(input)
		if dragging and input == dragInput and dragStart and startPosition then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
			if target == window.Root and window.Shadows then
				for _, shadow in ipairs(window.Shadows) do
					shadow.Position = target.Position
				end
			end
		end
	end)
end

function ZenthraUI:_Connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function ZenthraUI.CreateWindow(options)
	options = options or {}
	local self = setmetatable({}, ZenthraUI)
	self.Title = options.Title or "Zenthra"
	self.Subtitle = options.Subtitle or "Your advantage. Automated."
	self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	self.Size = options.Size or Vector2.new(820, 500)
	self.Flags = {}
	self.Tabs = {}
	self.Connections = {}
	self.SelectedTab = nil
	self.Visible = true
	self.Destroyed = false

	local screen = create("ScreenGui", {
		Name = options.GuiName or "ZenthraUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = options.DisplayOrder or 90,
		Parent = options.Parent or resolveParent(),
	})
	self.ScreenGui = screen

	local dim = create("Frame", {
		Name = "Dim",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = options.DimBackground and 0.42 or 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = options.DimBackground == true,
		Parent = screen,
	})
	self.Dim = dim

	local shadow3 = create("Frame", {
		Name = "Shadow3",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(self.Size.X + 28, self.Size.Y + 28),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Parent = screen,
	})
	addCorner(shadow3, 21)
	local shadow2 = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(self.Size.X + 16, self.Size.Y + 16),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Parent = screen,
	})
	addCorner(shadow2, 18)
	self.Shadows = { shadow3, shadow2 }

	local root = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(self.Size.X, self.Size.Y),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screen,
	})
	addCorner(root, 14)
	local outerStroke = addStroke(root, Theme.Silver, 1, 0.48)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 248, 250)),
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(94, 94, 104)),
			ColorSequenceKeypoint.new(0.72, Color3.fromRGB(47, 47, 53)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 214, 220)),
		}),
		Rotation = 90,
		Parent = outerStroke,
	})
	self.Root = root

	local scale = create("UIScale", { Scale = 1, Parent = root })
	self.UIScale = scale
	for _, shadow in ipairs(self.Shadows) do
		create("UIScale", { Scale = 1, Parent = shadow })
	end

	local topbar = create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = Theme.TopbarA,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		Active = true,
		Parent = root,
	})
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 72, 78)),
			ColorSequenceKeypoint.new(0.22, Color3.fromRGB(38, 38, 42)),
			ColorSequenceKeypoint.new(1, Theme.TopbarB),
		}),
		Rotation = 90,
		Parent = topbar,
	})
	create("Frame", {
		Name = "TopHighlight",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.62,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 0, 1),
		Parent = topbar,
	})
	create("Frame", {
		Name = "TopbarBottom",
		BackgroundColor3 = Theme.BorderSoft,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = topbar,
	})

	local brand = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 13),
		Size = UDim2.fromOffset(250, 26),
		Parent = topbar,
	})
	local mark = makeFocusMark(brand, 17, Theme.Text)
	mark.Position = UDim2.fromOffset(0, 4)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -26, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = self.Title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = brand,
	})

	local closeButton = create("TextButton", {
		Name = "CloseButton",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 9),
		Size = UDim2.fromOffset(34, 34),
		Font = Enum.Font.GothamMedium,
		Text = "×",
		TextColor3 = Theme.Dim,
		TextSize = 22,
		Parent = topbar,
	})
	closeButton.MouseEnter:Connect(function()
		tween(closeButton, 0.12, { TextColor3 = Theme.Text })
	end)
	closeButton.MouseLeave:Connect(function()
		tween(closeButton, 0.12, { TextColor3 = Theme.Dim })
	end)

	local searchButton = create("TextButton", {
		Name = "SearchButton",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -50, 0, 10),
		Size = UDim2.fromOffset(32, 32),
		Font = Enum.Font.GothamMedium,
		Text = "⌕",
		TextColor3 = Theme.Muted,
		TextSize = 24,
		Parent = topbar,
	})
	local searchBox = create("TextBox", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -88, 0.5, 0),
		Size = UDim2.fromOffset(0, 29),
		BackgroundColor3 = Color3.fromRGB(11, 11, 14),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Search tabs...",
		PlaceholderColor3 = Theme.Dim,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		Visible = false,
		Parent = topbar,
	})
	addCorner(searchBox, 7)
	addStroke(searchBox, Theme.BorderSoft, 1, 0.15)
	addPadding(searchBox, 10, 10, 0, 0)
	self.SearchBox = searchBox

	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(0, 176, 1, -52),
		Parent = root,
	})
	create("Frame", {
		BackgroundColor3 = Theme.BorderSoft,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -1, 0, 16),
		Size = UDim2.new(0, 1, 1, -30),
		Parent = sidebar,
	})
	local sidebarHeader = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(17, 18),
		Size = UDim2.new(1, -31, 0, 48),
		Parent = sidebar,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = "NAVIGATION",
		TextColor3 = Theme.Dim,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebarHeader,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 17),
		Size = UDim2.new(1, 0, 0, 24),
		Font = Enum.Font.Gotham,
		Text = self.Subtitle,
		TextColor3 = Theme.Muted,
		TextSize = 9,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = sidebarHeader,
	})

	local navigation = create("ScrollingFrame", {
		Name = "Navigation",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 76),
		Size = UDim2.new(1, -19, 1, -86),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = sidebar,
	})
	addList(navigation, 4)
	self.Navigation = navigation

	local content = create("Frame", {
		Name = "Content",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(176, 52),
		Size = UDim2.new(1, -176, 1, -52),
		ClipsDescendants = true,
		Parent = root,
	})
	create("UIGradient", {
		Color = ColorSequence.new(Theme.Background2, Theme.Background),
		Rotation = 90,
		Parent = content,
	})
	self.Content = content

	local empty = create("TextLabel", {
		Name = "Empty",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 50),
		Font = Enum.Font.Gotham,
		Text = "Create a tab to begin",
		TextColor3 = Theme.Dim,
		TextSize = 12,
		Parent = content,
	})
	self.EmptyLabel = empty

	local toastHolder = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(280, 330),
		BackgroundTransparency = 1,
		Parent = screen,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toastHolder,
	})
	self.ToastHolder = toastHolder

	local mini = create("TextButton", {
		Name = "MiniPill",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.SurfaceRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(112, 34),
		Text = "",
		Visible = false,
		Active = true,
		Parent = screen,
	})
	addCorner(mini, 10)
	addStroke(mini, Theme.Silver, 1, 0.45)
	create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(45, 45, 50), Theme.Surface),
		Rotation = 90,
		Parent = mini,
	})
	local miniMark = makeFocusMark(mini, 13, Theme.Muted)
	miniMark.Position = UDim2.fromOffset(10, 10)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(31, 0),
		Size = UDim2.new(1, -37, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = self.Title,
		TextColor3 = Theme.Text,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = mini,
	})
	self.MiniPill = mini

	makeDraggable(self, topbar, root)
	makeDraggable(self, mini, mini)

	local searchOpen = false
	self:_Connect(searchButton.MouseButton1Click, function()
		searchOpen = not searchOpen
		if searchOpen then
			searchBox.Visible = true
			tween(searchBox, 0.2, {
				Size = UDim2.fromOffset(180, 29),
				BackgroundTransparency = 0,
				TextTransparency = 0,
			})
			task.delay(0.08, function()
				if searchBox.Parent then
					searchBox:CaptureFocus()
				end
			end)
		else
			searchBox.Text = ""
			searchBox:ReleaseFocus()
			tween(searchBox, 0.16, {
				Size = UDim2.fromOffset(0, 29),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			})
			task.delay(0.17, function()
				if searchBox.Parent and not searchOpen then
					searchBox.Visible = false
				end
			end)
		end
	end)

	self:_Connect(searchBox:GetPropertyChangedSignal("Text"), function()
		local query = string.lower(searchBox.Text)
		for _, tab in ipairs(self.Tabs) do
			tab.Button.Visible = query == ""
				or string.find(string.lower(tab.Name), query, 1, true) ~= nil
		end
	end)

	self:_Connect(closeButton.MouseButton1Click, function()
		self:SetVisible(false)
	end)
	self:_Connect(mini.MouseButton1Click, function()
		self:SetVisible(true)
	end)
	self:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.ToggleKey then
			self:SetVisible(not self.Visible)
		end
	end)

	local function updateScale()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		local fitX = (viewport.X - 24) / self.Size.X
		local fitY = (viewport.Y - 24) / self.Size.Y
		local value = clamp(math.min(fitX, fitY, 1), 0.42, 1)
		scale.Scale = value
		for _, shadow in ipairs(self.Shadows) do
			local shadowScale = shadow:FindFirstChildOfClass("UIScale")
			if shadowScale then
				shadowScale.Scale = value
			end
		end
	end
	updateScale()
	if workspace.CurrentCamera then
		self:_Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateScale)
	end
	self:_Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), updateScale)

	return self
end

function ZenthraUI:SetVisible(visible)
	if self.Destroyed then
		return
	end
	self.Visible = visible == true
	if self.Visible then
		self.Root.Visible = true
		for _, shadow in ipairs(self.Shadows) do
			shadow.Visible = true
		end
		self.MiniPill.Visible = false
		self.Root.Size = UDim2.fromOffset(self.Size.X - 16, self.Size.Y - 12)
		self.Root.BackgroundTransparency = 0.12
		tween(self.Root, 0.2, {
			Size = UDim2.fromOffset(self.Size.X, self.Size.Y),
			BackgroundTransparency = 0,
		})
	else
		tween(self.Root, 0.16, {
			Size = UDim2.fromOffset(self.Size.X - 18, self.Size.Y - 12),
			BackgroundTransparency = 0.12,
		})
		task.delay(0.16, function()
			if self.Root.Parent and not self.Visible then
				self.Root.Visible = false
				for _, shadow in ipairs(self.Shadows) do
					shadow.Visible = false
				end
				self.MiniPill.Visible = true
			end
		end)
	end
end

function ZenthraUI:Toggle()
	self:SetVisible(not self.Visible)
end

function ZenthraUI:Notify(options)
	if self.Destroyed then
		return
	end
	if type(options) == "string" then
		options = { Title = self.Title, Content = options }
	end
	options = options or {}
	local toast = create("Frame", {
		Name = "Toast",
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 76),
		ClipsDescendants = true,
		Parent = self.ToastHolder,
	})
	addCorner(toast, 10)
	addStroke(toast, Theme.Silver, 1, 0.62)
	create("UIGradient", {
		Color = ColorSequence.new(Theme.SurfaceRaised, Theme.Surface),
		Rotation = 90,
		Parent = toast,
	})
	create("Frame", {
		BackgroundColor3 = options.Color or Theme.Silver,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 10),
		Size = UDim2.new(0, 2, 1, -20),
		Parent = toast,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(15, 12),
		Size = UDim2.new(1, -30, 0, 17),
		Font = Enum.Font.GothamBold,
		Text = options.Title or self.Title,
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toast,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(15, 33),
		Size = UDim2.new(1, -30, 0, 31),
		Font = Enum.Font.Gotham,
		Text = options.Content or "Notification",
		TextColor3 = Theme.Muted,
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = toast,
	})
	tween(toast, 0.22, { Size = UDim2.fromOffset(266, 76) })
	task.delay(options.Duration or 3.2, function()
		if toast.Parent then
			tween(toast, 0.18, {
				Size = UDim2.fromOffset(0, 76),
				BackgroundTransparency = 1,
			})
			task.delay(0.2, function()
				if toast.Parent then
					toast:Destroy()
				end
			end)
		end
	end)
end

ZenthraUI.Tab = {}
ZenthraUI.Tab.__index = ZenthraUI.Tab
ZenthraUI.Section = {}
ZenthraUI.Section.__index = ZenthraUI.Section

function ZenthraUI:CreateTab(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local tab = setmetatable({}, ZenthraUI.Tab)
	tab.Window = self
	tab.Name = options.Name or "Tab"
	tab.Icon = options.Icon or "◇"
	tab.Sections = {}
	tab.LeftCount = 0
	tab.RightCount = 0

	local button = create("TextButton", {
		Name = tab.Name,
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 39),
		Text = "",
		Parent = self.Navigation,
	})
	addCorner(button, 6)
	local activeBar = create("Frame", {
		Name = "Active",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(2, 0),
		BackgroundColor3 = Theme.Silver,
		BorderSizePixel = 0,
		Parent = button,
	})
	addCorner(activeBar, 2)
	local icon = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 0),
		Size = UDim2.fromOffset(22, 39),
		Font = Enum.Font.GothamMedium,
		Text = tab.Icon,
		TextColor3 = Theme.Muted,
		TextSize = 13,
		Parent = button,
	})
	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(41, 0),
		Size = UDim2.new(1, -48, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = tab.Name,
		TextColor3 = Theme.Muted,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local page = create("Frame", {
		Name = tab.Name .. "Page",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.Content,
	})
	local header = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.new(1, -40, 0, 38),
		Parent = page,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = tab.Name,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 15),
		Font = Enum.Font.Gotham,
		Text = options.Description or "Configure your controls",
		TextColor3 = Theme.Dim,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local columns = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 62),
		Size = UDim2.new(1, -40, 1, -78),
		Parent = page,
	})
	local left = create("ScrollingFrame", {
		Name = "Left",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.5, -7, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Border,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = columns,
	})
	addList(left, 10)
	local right = create("ScrollingFrame", {
		Name = "Right",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 7, 0, 0),
		Size = UDim2.new(0.5, -7, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Border,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = columns,
	})
	addList(right, 10)

	tab.Button = button
	tab.ActiveBar = activeBar
	tab.IconLabel = icon
	tab.NameLabel = label
	tab.Page = page
	tab.Left = left
	tab.Right = right

	self:_Connect(button.MouseEnter, function()
		if self.SelectedTab ~= tab then
			tween(button, 0.12, { BackgroundTransparency = 0.3, BackgroundColor3 = Theme.SurfaceRaised })
		end
	end)
	self:_Connect(button.MouseLeave, function()
		if self.SelectedTab ~= tab then
			tween(button, 0.12, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Sidebar })
		end
	end)
	self:_Connect(button.MouseButton1Click, function()
		tab:Select()
	end)

	table.insert(self.Tabs, tab)
	self.EmptyLabel.Visible = false
	if not self.SelectedTab then
		tab:Select()
	end
	return tab
end

function ZenthraUI.Tab:Select()
	local window = self.Window
	if window.Destroyed then
		return
	end
	for _, tab in ipairs(window.Tabs) do
		local selected = tab == self
		tab.Page.Visible = selected
		if selected then
			tween(tab.Button, 0.15, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.SurfaceRaised,
			})
			tween(tab.ActiveBar, 0.16, { Size = UDim2.fromOffset(2, 20) })
			tween(tab.IconLabel, 0.15, { TextColor3 = Theme.Text })
			tween(tab.NameLabel, 0.15, { TextColor3 = Theme.Text })
		else
			tween(tab.Button, 0.15, {
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme.Sidebar,
			})
			tween(tab.ActiveBar, 0.16, { Size = UDim2.fromOffset(2, 0) })
			tween(tab.IconLabel, 0.15, { TextColor3 = Theme.Muted })
			tween(tab.NameLabel, 0.15, { TextColor3 = Theme.Muted })
		end
	end
	window.SelectedTab = self
end

function ZenthraUI.Tab:CreateSection(options)
	if type(options) == "string" then
		options = { Title = options }
	end
	options = options or {}
	local side = options.Side
	if side ~= "Left" and side ~= "Right" then
		side = self.LeftCount <= self.RightCount and "Left" or "Right"
	end
	local parent = side == "Right" and self.Right or self.Left

	local section = setmetatable({}, ZenthraUI.Section)
	section.Window = self.Window
	section.Tab = self
	section.Title = options.Title or "Section"
	section.Controls = {}

	local card = create("Frame", {
		Name = section.Title,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	addCorner(card, 10)
	addStroke(card, Theme.BorderSoft, 1, 0.05)
	create("UIGradient", {
		Color = ColorSequence.new(Theme.SurfaceRaised, Theme.Surface),
		Rotation = 90,
		Parent = card,
	})
	local header = create("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, options.Description and 50 or 38),
		Parent = card,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -42, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = section.Title,
		TextColor3 = Theme.Text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	if options.Description then
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(13, 27),
			Size = UDim2.new(1, -42, 0, 15),
			Font = Enum.Font.Gotham,
			Text = options.Description,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})
	end
	makeLockIcon(header, UDim2.new(1, -12, 0, 10))
	create("Frame", {
		BackgroundColor3 = Theme.BorderSoft,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = header,
	})

	local controls = create("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, header.Size.Y.Offset),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	addList(controls, 0)
	section.Card = card
	section.ControlsHolder = controls

	if side == "Right" then
		self.RightCount += 1
	else
		self.LeftCount += 1
	end
	table.insert(self.Sections, section)
	return section
end

local function makeControlRow(section, height, divider)
	local row = create("Frame", {
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		Parent = section.ControlsHolder,
	})
	if divider ~= false then
		create("Frame", {
			Name = "Divider",
			BackgroundColor3 = Theme.BorderSoft,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 1, -1),
			Size = UDim2.new(1, -24, 0, 1),
			Parent = row,
		})
	end
	return row
end

local function makeNameLabel(row, text, position, size, textSize)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Position = position,
		Size = size,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = textSize or 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
end

local function makeDescription(row, text, position, size)
	if not text or text == "" then
		return nil
	end
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Position = position,
		Size = size,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = Theme.Muted,
		TextSize = 8,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = row,
	})
end

function ZenthraUI.Section:AddToggle(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local section = self
	local window = self.Window
	local state = options.Default == true
	local rowHeight = options.Description and 61 or 49
	local row = makeControlRow(section, rowHeight)

	local leftOffset = 13
	if options.Tag then
		local tag = create("TextLabel", {
			BackgroundColor3 = Theme.Input,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(13, 13),
			Size = UDim2.fromOffset(24, 18),
			Font = Enum.Font.GothamBold,
			Text = tostring(options.Tag),
			TextColor3 = Theme.Silver,
			TextSize = 8,
			Parent = row,
		})
		addCorner(tag, 4)
		addStroke(tag, Theme.Border, 1, 0.25)
		leftOffset = 45
	end
	makeNameLabel(row, options.Name or "Toggle", UDim2.fromOffset(leftOffset, 9), UDim2.new(1, -118, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(leftOffset, 27), UDim2.new(1, -118, 0, 24))

	if options.Keybind then
		local keyText = typeof(options.Keybind) == "EnumItem" and keyName(options.Keybind) or tostring(options.Keybind)
		local keyTag = create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -62, 0.5, 0),
			Size = UDim2.fromOffset(27, 18),
			BackgroundColor3 = Theme.Input,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = keyText,
			TextColor3 = Theme.Muted,
			TextSize = 8,
			Parent = row,
		})
		addCorner(keyTag, 4)
		addStroke(keyTag, Theme.Border, 1, 0.25)
	end

	local toggle = create("TextButton", {
		Name = "Toggle",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),
		Size = UDim2.fromOffset(36, 20),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Text = "",
		Parent = row,
	})
	addCorner(toggle, 10)
	addStroke(toggle, Theme.Border, 1, 0.25)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Theme.Dim,
		BorderSizePixel = 0,
		Parent = toggle,
	})
	addCorner(knob, 7)

	local control = {}
	function control:Set(value, silent)
		state = value == true
		setFlag(window, options.Flag, state)
		if state then
			tween(toggle, 0.16, { BackgroundColor3 = Color3.fromRGB(225, 225, 232) })
			tween(knob, 0.16, {
				Position = UDim2.new(1, -17, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 24),
			})
		else
			tween(toggle, 0.16, { BackgroundColor3 = Theme.Input })
			tween(knob, 0.16, {
				Position = UDim2.new(0, 3, 0.5, 0),
				BackgroundColor3 = Theme.Dim,
			})
		end
		if not silent then
			safeCall(options.Callback or options.Changed, state)
		end
	end
	function control:Get()
		return state
	end

	window:_Connect(toggle.MouseButton1Click, function()
		if options.Locked then
			window:Notify({ Title = options.Name or "Locked", Content = options.LockMessage or "This option is locked." })
			return
		end
		control:Set(not state)
	end)
	if typeof(options.Keybind) == "EnumItem" then
		window:_Connect(UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == options.Keybind then
				control:Set(not state)
			end
		end)
	end
	control:Set(state, true)
	control.Instance = row
	table.insert(section.Controls, control)
	return control
end

function ZenthraUI.Section:AddSlider(options)
	options = options or {}
	local section = self
	local window = self.Window
	local minimum = options.Min or 0
	local maximum = options.Max or 100
	local decimals = options.Decimals or 0
	local value = clamp(options.Default or minimum, minimum, maximum)
	local row = makeControlRow(section, options.Description and 73 or 62)
	makeNameLabel(row, options.Name or "Slider", UDim2.fromOffset(13, 7), UDim2.new(1, -84, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(13, 24), UDim2.new(1, -26, 0, 18))
	local valueLabel = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, 7),
		Size = UDim2.fromOffset(62, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = tostring(value),
		TextColor3 = Theme.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local barY = options.Description and 52 or 40
	local bar = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(13, barY),
		Size = UDim2.new(1, -26, 0, 5),
		Text = "",
		Parent = row,
	})
	addCorner(bar, 3)
	local fill = create("Frame", {
		BackgroundColor3 = Theme.Silver,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = bar,
	})
	addCorner(fill, 3)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Theme.Silver,
		BorderSizePixel = 0,
		Parent = bar,
	})
	addCorner(knob, 5)
	addStroke(knob, Color3.fromRGB(255, 255, 255), 1, 0.4)

	local dragging = false
	local control = {}
	function control:Set(newValue, silent)
		value = clamp(round(tonumber(newValue) or minimum, decimals), minimum, maximum)
		local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = tostring(value) .. (options.Suffix or "")
		setFlag(window, options.Flag, value)
		if not silent then
			safeCall(options.Callback or options.Changed, value)
		end
	end
	function control:Get()
		return value
	end

	local function setFromInput(input)
		local alpha = clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		control:Set(minimum + ((maximum - minimum) * alpha))
	end
	window:_Connect(bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromInput(input)
		end
	end)
	window:_Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromInput(input)
		end
	end)
	window:_Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	control:Set(value, true)
	control.Instance = row
	table.insert(section.Controls, control)
	return control
end

function ZenthraUI.Section:AddDropdown(options)
	options = options or {}
	local section = self
	local window = self.Window
	local values = options.Values or {}
	local selected = options.Default or values[1]
	local open = false
	local baseHeight = options.Description and 75 or 64
	local row = makeControlRow(section, baseHeight)
	makeNameLabel(row, options.Name or "Dropdown", UDim2.fromOffset(13, 6), UDim2.new(1, -26, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(13, 23), UDim2.new(1, -26, 0, 17))
	local buttonY = options.Description and 44 or 29
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(13, buttonY),
		Size = UDim2.new(1, -26, 0, 27),
		Font = Enum.Font.Gotham,
		Text = "",
		Parent = row,
	})
	addCorner(button, 5)
	addStroke(button, Theme.Border, 1, 0.2)
	addHover(button, Theme.Input, Theme.InputHover)
	local selectedLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -34, 1, 0),
		Font = Enum.Font.Gotham,
		Text = tostring(selected or "None"),
		TextColor3 = Theme.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})
	local arrow = create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -7, 0, 0),
		Size = UDim2.fromOffset(18, 27),
		Font = Enum.Font.GothamBold,
		Text = "⌄",
		TextColor3 = Theme.Muted,
		TextSize = 12,
		Parent = button,
	})
	local list = create("Frame", {
		BackgroundColor3 = Theme.SurfaceRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(13, buttonY + 32),
		Size = UDim2.new(1, -26, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = row,
	})
	addCorner(list, 6)
	addStroke(list, Theme.Border, 1, 0.15)
	local listLayout = addList(list, 1)
	local optionButtons = {}

	local control = {}
	function control:Set(value, silent)
		selected = value
		selectedLabel.Text = tostring(selected or "None")
		setFlag(window, options.Flag, selected)
		if not silent then
			safeCall(options.Callback or options.Changed, selected)
		end
	end
	function control:Get()
		return selected
	end
	function control:Close()
		open = false
		tween(arrow, 0.15, { Rotation = 0 })
		tween(list, 0.15, { Size = UDim2.new(1, -26, 0, 0) })
		tween(row, 0.15, { Size = UDim2.new(1, 0, 0, baseHeight) })
		task.delay(0.16, function()
			if list.Parent and not open then
				list.Visible = false
			end
		end)
	end
	function control:Open()
		open = true
		list.Visible = true
		local target = math.min(#values * 29 + 4, 150)
		tween(arrow, 0.15, { Rotation = 180 })
		tween(list, 0.16, { Size = UDim2.new(1, -26, 0, target) })
		tween(row, 0.16, { Size = UDim2.new(1, 0, 0, baseHeight + target + 6) })
	end
	function control:SetValues(newValues)
		values = newValues or {}
		for _, optionButton in ipairs(optionButtons) do
			optionButton:Destroy()
		end
		table.clear(optionButtons)
		for _, item in ipairs(values) do
			local optionButton = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = Theme.SurfaceRaised,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				Font = Enum.Font.Gotham,
				Text = "  " .. tostring(item),
				TextColor3 = Theme.Muted,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = list,
			})
			addHover(optionButton, Theme.SurfaceRaised, Theme.SurfaceHover)
			window:_Connect(optionButton.MouseButton1Click, function()
				control:Set(item)
				control:Close()
			end)
			table.insert(optionButtons, optionButton)
		end
	end
	window:_Connect(button.MouseButton1Click, function()
		if open then
			control:Close()
		else
			control:Open()
		end
	end)
	control:SetValues(values)
	control:Set(selected, true)
	control.Instance = row
	control.ListLayout = listLayout
	table.insert(section.Controls, control)
	return control
end

function ZenthraUI.Section:AddKeybind(options)
	options = options or {}
	local section = self
	local window = self.Window
	local key = options.Default or Enum.KeyCode.Unknown
	local listening = false
	local row = makeControlRow(section, options.Description and 57 or 43)
	makeNameLabel(row, options.Name or "Keybind", UDim2.fromOffset(13, 7), UDim2.new(1, -100, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(13, 24), UDim2.new(1, -100, 0, 20))
	local keyButton = create("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),
		Size = UDim2.fromOffset(70, 23),
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = key == Enum.KeyCode.Unknown and "None" or keyName(key),
		TextColor3 = Theme.Text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(keyButton, 5)
	addStroke(keyButton, Theme.Border, 1, 0.2)
	addHover(keyButton, Theme.Input, Theme.InputHover)
	local control = {}
	function control:Set(newKey, silent)
		key = newKey or Enum.KeyCode.Unknown
		keyButton.Text = key == Enum.KeyCode.Unknown and "None" or keyName(key)
		setFlag(window, options.Flag, key)
		if not silent then
			safeCall(options.Changed, key)
		end
	end
	function control:Get()
		return key
	end
	window:_Connect(keyButton.MouseButton1Click, function()
		listening = true
		keyButton.Text = "..."
	end)
	window:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
		if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
			listening = false
			control:Set(input.KeyCode)
			return
		end
		if not gameProcessed and not UserInputService:GetFocusedTextBox() and input.KeyCode == key then
			safeCall(options.Callback, key)
		end
	end)
	control:Set(key, true)
	control.Instance = row
	table.insert(section.Controls, control)
	return control
end

function ZenthraUI.Section:AddButton(options)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local row = makeControlRow(self, options.Description and 66 or 52)
	makeNameLabel(row, options.Name or "Button", UDim2.fromOffset(13, 6), UDim2.new(1, -26, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(13, 23), UDim2.new(1, -26, 0, 17))
	local buttonY = options.Description and 42 or 24
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(13, buttonY),
		Size = UDim2.new(1, -26, 0, 25),
		Font = Enum.Font.GothamMedium,
		Text = options.ButtonText or options.Name or "Run",
		TextColor3 = Theme.Text,
		TextSize = 9,
		Parent = row,
	})
	addCorner(button, 5)
	addStroke(button, Theme.Border, 1, 0.18)
	addHover(button, Theme.Input, Theme.InputHover)
	self.Window:_Connect(button.MouseButton1Click, function()
		if options.Locked then
			self.Window:Notify({ Title = options.Name or "Locked", Content = options.LockMessage or "This action is locked." })
			return
		end
		tween(button, 0.08, { BackgroundColor3 = Theme.Silver, TextColor3 = Theme.Background })
		task.delay(0.1, function()
			if button.Parent then
				tween(button, 0.15, { BackgroundColor3 = Theme.Input, TextColor3 = Theme.Text })
			end
		end)
		safeCall(options.Callback)
	end)
	local control = { Instance = row, Button = button }
	table.insert(self.Controls, control)
	return control
end

function ZenthraUI.Section:AddInput(options)
	options = options or {}
	local section = self
	local window = self.Window
	local value = tostring(options.Default or "")
	local row = makeControlRow(section, options.Description and 78 or 66)
	makeNameLabel(row, options.Name or "Input", UDim2.fromOffset(13, 5), UDim2.new(1, -26, 0, 18), 10)
	makeDescription(row, options.Description, UDim2.fromOffset(13, 22), UDim2.new(1, -26, 0, 17))
	local boxY = options.Description and 42 or 27
	local box = create("TextBox", {
		BackgroundColor3 = Theme.Input,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(13, boxY),
		Size = UDim2.new(1, -26, 0, 27),
		ClearTextOnFocus = options.ClearOnFocus == true,
		Font = Enum.Font.Gotham,
		PlaceholderText = options.Placeholder or "Enter text...",
		PlaceholderColor3 = Theme.Dim,
		Text = value,
		TextColor3 = Theme.Text,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	addCorner(box, 5)
	addStroke(box, Theme.Border, 1, 0.18)
	addPadding(box, 9, 9, 0, 0)
	local control = {}
	function control:Set(newValue, silent)
		value = tostring(newValue or "")
		box.Text = value
		setFlag(window, options.Flag, value)
		if not silent then
			safeCall(options.Callback, value)
		end
	end
	function control:Get()
		return value
	end
	window:_Connect(box.FocusLost, function(enterPressed)
		value = box.Text
		setFlag(window, options.Flag, value)
		safeCall(options.Callback, value, enterPressed)
	end)
	control:Set(value, true)
	control.Instance = row
	control.TextBox = box
	table.insert(section.Controls, control)
	return control
end

function ZenthraUI.Section:AddDivider(options)
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}
	local row = makeControlRow(self, 30, false)
	local text = options.Text or "Section"
	create("Frame", {
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 13, 0.5, 0),
		Size = UDim2.new(0.5, -48, 0, 1),
		Parent = row,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(84, 20),
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 8,
		Parent = row,
	})
	create("Frame", {
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 35, 0.5, 0),
		Size = UDim2.new(0.5, -48, 0, 1),
		Parent = row,
	})
	local control = { Instance = row }
	table.insert(self.Controls, control)
	return control
end

function ZenthraUI.Section:AddParagraph(options)
	if type(options) == "string" then
		options = { Content = options }
	end
	options = options or {}
	local height = options.Height or 54
	local row = makeControlRow(self, height)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -26, 1, -16),
		Font = Enum.Font.Gotham,
		Text = options.Content or "Text",
		TextColor3 = options.Color or Theme.Muted,
		TextSize = options.TextSize or 9,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = row,
	})
	local control = { Instance = row }
	table.insert(self.Controls, control)
	return control
end

ZenthraUI.Section.AddLabel = ZenthraUI.Section.AddParagraph
ZenthraUI.AddTab = ZenthraUI.CreateTab
ZenthraUI.Tab.AddCard = ZenthraUI.Tab.CreateSection
ZenthraUI.Section.CreateToggle = ZenthraUI.Section.AddToggle
ZenthraUI.Section.CreateSlider = ZenthraUI.Section.AddSlider
ZenthraUI.Section.CreateDropdown = ZenthraUI.Section.AddDropdown
ZenthraUI.Section.CreateKeybind = ZenthraUI.Section.AddKeybind
ZenthraUI.Section.CreateButton = ZenthraUI.Section.AddButton
ZenthraUI.Section.CreateInput = ZenthraUI.Section.AddInput

function ZenthraUI:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	for _, connection in ipairs(self.Connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(self.Connections)
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return ZenthraUI
end)()

-- Answer or Die interface integration.
-- This lower section is the existing helper logic, now using ZenthraUI v2.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local previousGui = PlayerGui:FindFirstChild("ZenthraAnswerHelper")
if previousGui then
	previousGui:Destroy()
end

local questions = require(
	ReplicatedStorage:WaitForChild("Common")
		:WaitForChild("Modules")
		:WaitForChild("Databases")
		:WaitForChild("Questions")
)

local function normalizeQuestion(value)
	value = tostring(value or "")
	value = value:gsub("<[^>]->", "")
	value = value:lower()
	return value:gsub("[%p%c%s]+", "")
end

local questionsByText = {}
for _, question in pairs(questions) do
	if type(question) == "table" and type(question.value) == "string" then
		questionsByText[normalizeQuestion(question.value)] = question
	end
end

local state = {
	autoType = false,
	strategy = "Longest",
	answer = "",
	questionText = "",
	lastDetectedText = nil,
	lastTypedQuestion = nil,
}

local Window = ZenthraUI.CreateWindow({
	Title = "Zenthra",
	Subtitle = "Answer intelligence",
	GuiName = "ZenthraAnswerHelper",
	ToggleKey = Enum.KeyCode.RightShift,
	Size = Vector2.new(790, 480),
})

local AnswerTab = Window:CreateTab({
	Name = "Answers",
	Icon = "A",
	Description = "Live question detection and answer controls",
})
local SettingsTab = Window:CreateTab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Selection strategy and interface options",
})

local CurrentSection = AnswerTab:CreateSection({
	Title = "Current Round",
	Description = "Live question and accepted answer",
	Side = "Left",
})

local ActionSection = AnswerTab:CreateSection({
	Title = "Actions",
	Description = "Type or copy without auto-submitting",
	Side = "Right",
})

local QuestionField = CurrentSection:AddInput({
	Name = "Current Question",
	Description = "Detected from the active round",
	Default = "Waiting for a question...",
})

local AnswerField = CurrentSection:AddInput({
	Name = "Best Answer",
	Description = "Selectable answer selected from the database",
	Default = "Waiting for a question...",
	Callback = function(value)
		if value ~= "" and value ~= "Waiting for a question..." and value ~= "No matching answer found" then
			state.answer = value
		end
	end,
})

local StatusField = CurrentSection:AddInput({
	Name = "Database Status",
	Default = string.format("%d questions loaded", #questions),
})

local function notify(title, content)
	Window:Notify({
		Title = title,
		Content = content,
		Duration = 3,
	})
end

local function getGameAnswerBox()
	local main = PlayerGui:FindFirstChild("Main")
	local answer = main and main:FindFirstChild("Answer")
	local leftBg = answer and answer:FindFirstChild("LeftBg")
	local textBox = leftBg and leftBg:FindFirstChild("TextBox")
	if textBox and textBox:IsA("TextBox") then
		return textBox
	end
	return nil
end

local function typeCurrentAnswer(showNotification)
	if state.answer == "" then
		if showNotification then
			notify("Answer", "No answer is available yet.")
		end
		return false
	end

	local textBox = getGameAnswerBox()
	if not textBox then
		if showNotification then
			notify("Answer", "The game's answer box is not available.")
		end
		return false
	end

	textBox.Text = state.answer
	textBox.CursorPosition = #state.answer + 1
	if showNotification then
		notify("Answer Typed", state.answer)
	end
	return true
end

local function selectAnswer(question)
	local selected = nil
	local selectedScore = -1
	local count = 0
	for _, entry in ipairs(question.answers or {}) do
		local value = type(entry) == "table" and entry.value or entry
		if type(value) == "string" and value ~= "" then
			count += 1
			if state.strategy == "First" then
				if not selected then
					selected = value
				end
			else
				local score = #(value:gsub("%s+", ""))
				if score > selectedScore then
					selected = value
					selectedScore = score
				end
			end
		end
	end
	return selected, count
end

local function detectCurrentQuestion(force)
	local main = PlayerGui:FindFirstChild("Main")
	local questionFrame = main and main:FindFirstChild("Question")
	local bg = questionFrame and questionFrame:FindFirstChild("Bg")
	local questionLabel = bg and bg:FindFirstChild("QuestionTxt")
	if not questionLabel or not questionLabel:IsA("TextLabel") then
		return
	end

	local displayedText = questionLabel.Text
	if not force and displayedText == state.lastDetectedText then
		return
	end

	state.lastDetectedText = displayedText
	state.questionText = displayedText
	QuestionField:Set(displayedText ~= "" and displayedText or "Waiting for a question...", true)

	local question = questionsByText[normalizeQuestion(displayedText)]
	if not question then
		state.answer = ""
		AnswerField:Set("No matching answer found", true)
		StatusField:Set(string.format("%d questions loaded - no match", #questions), true)
		return
	end

	local selected, answerCount = selectAnswer(question)
	state.answer = selected or ""
	AnswerField:Set(selected or "No matching answer found", true)
	StatusField:Set(string.format("Question #%s - %d accepted answers", tostring(question.id or "?"), answerCount), true)

	local questionKey = tostring(question.id or normalizeQuestion(displayedText))
	if state.autoType and selected and state.lastTypedQuestion ~= questionKey then
		state.lastTypedQuestion = questionKey
		task.defer(typeCurrentAnswer, false)
	end
end

ActionSection:AddToggle({
	Name = "Auto Type Answer",
	Description = "Fills the answer box whenever a new question appears",
	Tag = "AT",
	Default = false,
	Flag = "AutoTypeAnswer",
	Callback = function(enabled)
		state.autoType = enabled
		if enabled then
			state.lastTypedQuestion = nil
			detectCurrentQuestion(true)
			typeCurrentAnswer(false)
		end
		notify("Auto Type", enabled and "Enabled" or "Disabled")
	end,
})

ActionSection:AddButton({
	Name = "Type Answer Now",
	Description = "Places the current answer into the answer box",
	ButtonText = "Type current answer",
	Callback = function()
		typeCurrentAnswer(true)
	end,
})

ActionSection:AddButton({
	Name = "Copy Answer",
	ButtonText = "Copy current answer",
	Callback = function()
		if state.answer == "" then
			notify("Copy Answer", "No answer is available yet.")
			return
		end

		local copyFunction = setclipboard or toclipboard
		if type(copyFunction) ~= "function" then
			notify("Copy Answer", "Clipboard API unavailable; select the answer field instead.")
			return
		end

		local ok = pcall(copyFunction, state.answer)
		notify("Copy Answer", ok and "Copied to clipboard." or "Clipboard copy failed.")
	end,
})

ActionSection:AddButton({
	Name = "Refresh Detection",
	ButtonText = "Refresh question",
	Callback = function()
		detectCurrentQuestion(true)
		notify("Detection", "Question and answer refreshed.")
	end,
})

ActionSection:AddParagraph({
	Content = "Auto Type only fills the answer field. It does not press Submit, so you remain in control.",
	Height = 58,
})

local DetectionSection = SettingsTab:CreateSection({
	Title = "Answer Selection",
	Description = "Choose which accepted answer is shown",
	Side = "Left",
})

DetectionSection:AddDropdown({
	Name = "Strategy",
	Description = "Longest usually gives more characters",
	Values = { "Longest", "First" },
	Default = "Longest",
	Flag = "AnswerStrategy",
	Callback = function(value)
		state.strategy = value
		state.lastTypedQuestion = nil
		detectCurrentQuestion(true)
	end,
})

local InterfaceSection = SettingsTab:CreateSection({
	Title = "Interface",
	Description = "Window behavior and status",
	Side = "Right",
})

InterfaceSection:AddKeybind({
	Name = "Toggle Interface",
	Description = "Press the assigned key to hide or restore Zenthra",
	Default = Enum.KeyCode.RightShift,
	Callback = function()
		Window:Toggle()
	end,
})

InterfaceSection:AddParagraph({
	Content = "The interface automatically scales for desktop, tablet, and mobile screens.",
	Height = 50,
})

InterfaceSection:AddButton({
	Name = "Destroy Interface",
	ButtonText = "Unload Zenthra",
	Callback = function()
		Window:Destroy()
	end,
})

AnswerTab:Select()
detectCurrentQuestion(true)

task.spawn(function()
	while not Window.Destroyed do
		local ok, message = pcall(detectCurrentQuestion, false)
		if not ok then
			warn("[AnswerOrDie Zenthra] " .. tostring(message))
		end
		task.wait(0.2)
	end
end)

notify("Zenthra", "Interface loaded. RightShift toggles the window.")
