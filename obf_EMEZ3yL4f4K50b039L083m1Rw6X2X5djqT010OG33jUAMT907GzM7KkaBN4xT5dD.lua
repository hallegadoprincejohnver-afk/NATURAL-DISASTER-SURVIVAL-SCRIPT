--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local ZenthraUI = (function()
	local Players = game:GetService("Players");
	local TweenService = game:GetService("TweenService");
	local UserInputService = game:GetService("UserInputService");
	local ZenthraUI = {};
	ZenthraUI.__index = ZenthraUI;
	local THEME = {Background=Color3.fromRGB(7, 7, 8),Sidebar=Color3.fromRGB(8, 8, 9),Surface=Color3.fromRGB(15, 15, 17),SurfaceRaised=Color3.fromRGB(22, 22, 24),SurfaceHover=Color3.fromRGB(30, 30, 33),Input=Color3.fromRGB(47, 47, 50),Border=Color3.fromRGB(55, 55, 60),BorderSoft=Color3.fromRGB(34, 34, 38),Text=Color3.fromRGB(238, 238, 241),Muted=Color3.fromRGB(126, 126, 134),Dim=Color3.fromRGB(82, 82, 90),White=Color3.fromRGB(244, 244, 247),AccentA=Color3.fromRGB(129, 83, 255),AccentB=Color3.fromRGB(61, 143, 255),Danger=Color3.fromRGB(232, 91, 105)};
	local function create(className, properties)
		local object = Instance.new(className);
		for property, value in pairs(properties or {}) do
			if (property ~= "Parent") then
				object[property] = value;
			end
		end
		if (properties and properties.Parent) then
			object.Parent = properties.Parent;
		end
		return object;
	end
	local function addCorner(parent, radius)
		return create("UICorner", {CornerRadius=UDim.new(0, radius or 6),Parent=parent});
	end
	local function addStroke(parent, color, thickness, transparency)
		return create("UIStroke", {Color=(color or THEME.Border),Thickness=(thickness or 1),Transparency=(transparency or 0),ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=parent});
	end
	local function addPadding(parent, left, right, top, bottom)
		return create("UIPadding", {PaddingLeft=UDim.new(0, left or 0),PaddingRight=UDim.new(0, right or left or 0),PaddingTop=UDim.new(0, top or left or 0),PaddingBottom=UDim.new(0, bottom or top or left or 0),Parent=parent});
	end
	local function tween(object, duration, properties, style, direction)
		local info = TweenInfo.new(duration or 0.16, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out);
		local animation = TweenService:Create(object, info, properties);
		animation:Play();
		return animation;
	end
	local function safeCall(callback, ...)
		if (type(callback) ~= "function") then
			return;
		end
		local ok, message = pcall(callback, ...);
		if not ok then
			warn("[ZenthraUI callback] " .. tostring(message));
		end
	end
	local function clamp(value, minimum, maximum)
		return math.max(minimum, math.min(maximum, value));
	end
	local function round(value, decimals)
		local power = 10 ^ (decimals or 0);
		return math.floor((value * power) + 0.5) / power;
	end
	local function keyName(keyCode)
		local name = keyCode.Name;
		local aliases = {LeftShift="LShift",RightShift="RShift",LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",MouseButton1="M1",MouseButton2="M2",MouseButton3="M3"};
		return aliases[name] or name;
	end
	local function focusMark(parent, size, color)
		local holder = create("Frame", {Name="FocusMark",BackgroundTransparency=1,Size=UDim2.fromOffset(size, size),Parent=parent});
		local line = math.max(3, math.floor(size * 0.3));
		local thickness = 1;
		local marks = {{UDim2.fromOffset(line, thickness),UDim2.fromOffset(0, 0)},{UDim2.fromOffset(thickness, line),UDim2.fromOffset(0, 0)},{UDim2.fromOffset(line, thickness),UDim2.new(1, -line, 0, 0)},{UDim2.fromOffset(thickness, line),UDim2.new(1, -thickness, 0, 0)},{UDim2.fromOffset(line, thickness),UDim2.new(0, 0, 1, -thickness)},{UDim2.fromOffset(thickness, line),UDim2.new(0, 0, 1, -line)},{UDim2.fromOffset(line, thickness),UDim2.new(1, -line, 1, -thickness)},{UDim2.fromOffset(thickness, line),UDim2.new(1, -thickness, 1, -line)}};
		for _, mark in ipairs(marks) do
			create("Frame", {BorderSizePixel=0,BackgroundColor3=(color or THEME.Muted),Size=mark[1],Position=mark[2],Parent=holder});
		end
		return holder;
	end
	local function addHover(button, normalColor, hoverColor)
		button.MouseEnter:Connect(function()
			tween(button, 0.14, {BackgroundColor3=hoverColor});
		end);
		button.MouseLeave:Connect(function()
			tween(button, 0.14, {BackgroundColor3=normalColor});
		end);
	end
	local function resolveParent()
		local player = Players.LocalPlayer;
		if not player then
			error("ZenthraUI must be required from a LocalScript");
		end
		return player:WaitForChild("PlayerGui");
	end
	local function setFlag(window, flag, value)
		if flag then
			window.Flags[flag] = value;
		end
	end
	local function makeDraggable(window, handle, target)
		local dragging = false;
		local dragInput = nil;
		local dragStart = nil;
		local startPosition = nil;
		window:_Connect(handle.InputBegan, function(input)
			if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
				dragging = true;
				dragStart = input.Position;
				startPosition = target.Position;
				local endedConnection;
				endedConnection = input.Changed:Connect(function()
					if (input.UserInputState == Enum.UserInputState.End) then
						dragging = false;
						if endedConnection then
							endedConnection:Disconnect();
						end
					end
				end);
			end
		end);
		window:_Connect(handle.InputChanged, function(input)
			if ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
				dragInput = input;
			end
		end);
		window:_Connect(UserInputService.InputChanged, function(input)
			if (dragging and (input == dragInput) and dragStart and startPosition) then
				local delta = input.Position - dragStart;
				target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y);
			end
		end);
	end
	ZenthraUI._Connect = function(self, signal, callback)
		local connection = signal:Connect(callback);
		table.insert(self.Connections, connection);
		return connection;
	end;
	ZenthraUI.CreateWindow = function(options)
		options = options or {};
		local self = setmetatable({}, ZenthraUI);
		self.Title = options.Title or "Zenthra";
		self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift;
		self.Size = options.Size or Vector2.new(750, 475);
		self.Flags = {};
		self.Tabs = {};
		self.Connections = {};
		self.SelectedTab = nil;
		self.Visible = true;
		self.Destroyed = false;
		local screen = create("ScreenGui", {Name=(options.GuiName or "ZenthraUI"),ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=(options.DisplayOrder or 90),Parent=(options.Parent or resolveParent())});
		self.ScreenGui = screen;
		local dim = create("Frame", {Name="Dim",BackgroundColor3=Color3.new(0, 0, 0),BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1, 1),Visible=(options.DimBackground == true),Parent=screen});
		self.Dim = dim;
		local root = create("Frame", {Name="Window",AnchorPoint=Vector2.new(0.5, 0.5),Position=UDim2.fromScale(0.5, 0.5),Size=UDim2.fromOffset(self.Size.X, self.Size.Y),BackgroundColor3=THEME.Background,BorderSizePixel=0,ClipsDescendants=true,Parent=screen});
		addCorner(root, 10);
		local outerStroke = addStroke(root, THEME.Border, 1, 0.18);
		local outlineGradient = create("UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.AccentA),ColorSequenceKeypoint.new(0.28, THEME.Border),ColorSequenceKeypoint.new(0.75, THEME.Border),ColorSequenceKeypoint.new(1, THEME.AccentB)}),Rotation=90,Parent=outerStroke});
		self.Root = root;
		self.OutlineGradient = outlineGradient;
		local scale = create("UIScale", {Scale=1,Parent=root});
		self.UIScale = scale;
		local topbar = create("Frame", {Name="Topbar",BackgroundColor3=Color3.fromRGB(36, 36, 39),BorderSizePixel=0,Size=UDim2.new(1, 0, 0, 42),Active=true,Parent=root});
		create("UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 65, 68)),ColorSequenceKeypoint.new(0.35, Color3.fromRGB(43, 43, 46)),ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 13))}),Rotation=90,Parent=topbar});
		create("Frame", {Name="Highlight",BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=0.82,BorderSizePixel=0,Position=UDim2.fromOffset(9, 0),Size=UDim2.new(1, -18, 0, 1),Parent=topbar});
		local brand = create("Frame", {BackgroundTransparency=1,Position=UDim2.fromOffset(19, 12),Size=UDim2.fromOffset(130, 20),Parent=topbar});
		local brandMark = focusMark(brand, 15, THEME.Text);
		brandMark.Position = UDim2.fromOffset(0, 2);
		create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(23, 0),Size=UDim2.new(1, -23, 1, 0),Font=Enum.Font.GothamBold,Text=self.Title,TextColor3=THEME.Text,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=brand});
		local searchButton = create("TextButton", {Name="SearchButton",AutoButtonColor=false,BackgroundTransparency=1,Position=UDim2.new(1, -43, 0, 7),Size=UDim2.fromOffset(30, 28),Font=Enum.Font.GothamMedium,Text="⌕",TextColor3=THEME.Muted,TextSize=24,Parent=topbar});
		local searchBox = create("TextBox", {Name="Search",AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, -47, 0.5, 0),Size=UDim2.fromOffset(0, 27),BackgroundColor3=Color3.fromRGB(16, 16, 18),BackgroundTransparency=1,BorderSizePixel=0,ClearTextOnFocus=false,Font=Enum.Font.Gotham,PlaceholderText="Search tabs...",PlaceholderColor3=THEME.Dim,Text="",TextColor3=THEME.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,Visible=false,Parent=topbar});
		addCorner(searchBox, 6);
		addStroke(searchBox, THEME.BorderSoft, 1, 0.2);
		addPadding(searchBox, 9, 9, 0, 0);
		self.SearchBox = searchBox;
		local sidebar = create("Frame", {Name="Sidebar",BackgroundColor3=THEME.Sidebar,BorderSizePixel=0,Position=UDim2.fromOffset(0, 42),Size=UDim2.new(0, 153, 1, -42),Parent=root});
		create("Frame", {BackgroundColor3=THEME.BorderSoft,BackgroundTransparency=0.25,BorderSizePixel=0,Position=UDim2.new(1, -1, 0, 20),Size=UDim2.new(0, 1, 1, -38),Parent=sidebar});
		local navigation = create("ScrollingFrame", {Name="Navigation",BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(11, 18),Size=UDim2.new(1, -21, 1, -28),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=sidebar});
		create("UIListLayout", {Padding=UDim.new(0, 4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=navigation});
		self.Navigation = navigation;
		local content = create("Frame", {Name="Content",BackgroundColor3=THEME.Background,BorderSizePixel=0,Position=UDim2.fromOffset(153, 42),Size=UDim2.new(1, -153, 1, -42),ClipsDescendants=true,Parent=root});
		self.Content = content;
		local empty = create("TextLabel", {Name="Empty",BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5, 0.5),Position=UDim2.fromScale(0.5, 0.5),Size=UDim2.fromOffset(280, 42),Font=Enum.Font.Gotham,Text="Create a tab to begin",TextColor3=THEME.Dim,TextSize=12,Parent=content});
		self.EmptyLabel = empty;
		local toastHolder = create("Frame", {Name="Notifications",AnchorPoint=Vector2.new(1, 1),Position=UDim2.new(1, -14, 1, -14),Size=UDim2.fromOffset(265, 300),BackgroundTransparency=1,Parent=screen});
		create("UIListLayout", {Padding=UDim.new(0, 8),HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder,Parent=toastHolder});
		self.ToastHolder = toastHolder;
		local mini = create("TextButton", {Name="MiniPill",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(26, 26, 29),BorderSizePixel=0,Position=UDim2.fromOffset(8, 8),Size=UDim2.fromOffset(76, 27),Text="",Visible=false,Active=true,Parent=screen});
		addCorner(mini, 7);
		local miniStroke = addStroke(mini, THEME.Border, 1, 0.1);
		create("UIGradient", {Color=ColorSequence.new(THEME.AccentA, THEME.AccentB),Rotation=90,Parent=miniStroke});
		create("UIGradient", {Color=ColorSequence.new(Color3.fromRGB(49, 49, 52), Color3.fromRGB(12, 12, 14)),Rotation=90,Parent=mini});
		local miniMark = focusMark(mini, 11, THEME.Muted);
		miniMark.Position = UDim2.fromOffset(8, 8);
		create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(25, 0),Size=UDim2.new(1, -29, 1, 0),Font=Enum.Font.GothamMedium,Text=self.Title,TextColor3=THEME.Text,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=mini});
		self.MiniPill = mini;
		makeDraggable(self, topbar, root);
		makeDraggable(self, mini, mini);
		local searchOpen = false;
		self:_Connect(searchButton.MouseButton1Click, function()
			searchOpen = not searchOpen;
			if searchOpen then
				searchBox.Visible = true;
				tween(searchBox, 0.2, {Size=UDim2.fromOffset(170, 27),BackgroundTransparency=0,TextTransparency=0});
				task.delay(0.08, function()
					if searchBox.Parent then
						searchBox:CaptureFocus();
					end
				end);
			else
				searchBox.Text = "";
				searchBox:ReleaseFocus();
				tween(searchBox, 0.16, {Size=UDim2.fromOffset(0, 27),BackgroundTransparency=1,TextTransparency=1});
				task.delay(0.17, function()
					if (searchBox.Parent and not searchOpen) then
						searchBox.Visible = false;
					end
				end);
			end
		end);
		self:_Connect(searchBox:GetPropertyChangedSignal("Text"), function()
			local query = string.lower(searchBox.Text);
			for _, tab in ipairs(self.Tabs) do
				tab.Button.Visible = (query == "") or (string.find(string.lower(tab.Name), query, 1, true) ~= nil);
			end
		end);
		self:_Connect(mini.MouseButton1Click, function()
			self:SetVisible(true);
		end);
		self:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
			if (not gameProcessed and (input.KeyCode == self.ToggleKey)) then
				self:SetVisible(not self.Visible);
			end
		end);
		local function updateScale()
			local camera = workspace.CurrentCamera;
			if not camera then
				return;
			end
			local viewport = camera.ViewportSize;
			local fitX = (viewport.X - 24) / self.Size.X;
			local fitY = (viewport.Y - 24) / self.Size.Y;
			scale.Scale = clamp(math.min(fitX, fitY, 1), 0.38, 1);
		end
		updateScale();
		if workspace.CurrentCamera then
			self:_Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateScale);
		end
		self:_Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
			updateScale();
		end);
		return self;
	end;
	ZenthraUI.SetVisible = function(self, visible)
		if self.Destroyed then
			return;
		end
		self.Visible = visible == true;
		if self.Visible then
			self.Root.Visible = true;
			self.MiniPill.Visible = false;
			self.Root.Size = UDim2.fromOffset(self.Size.X - 18, self.Size.Y - 12);
			self.Root.BackgroundTransparency = 0.12;
			tween(self.Root, 0.2, {Size=UDim2.fromOffset(self.Size.X, self.Size.Y),BackgroundTransparency=0});
		else
			tween(self.Root, 0.16, {Size=UDim2.fromOffset(self.Size.X - 18, self.Size.Y - 12),BackgroundTransparency=0.12});
			task.delay(0.16, function()
				if (self.Root.Parent and not self.Visible) then
					self.Root.Visible = false;
					self.MiniPill.Visible = true;
				end
			end);
		end
	end;
	ZenthraUI.Toggle = function(self)
		self:SetVisible(not self.Visible);
	end;
	ZenthraUI.Notify = function(self, options)
		if self.Destroyed then
			return;
		end
		if (type(options) == "string") then
			options = {Title=self.Title,Content=options};
		end
		options = options or {};
		local toast = create("Frame", {Name="Toast",BackgroundColor3=THEME.Surface,BackgroundTransparency=0.04,BorderSizePixel=0,Size=UDim2.fromOffset(0, 72),ClipsDescendants=true,Parent=self.ToastHolder});
		addCorner(toast, 8);
		addStroke(toast, THEME.Border, 1, 0.15);
		create("Frame", {BackgroundColor3=(options.Color or THEME.White),BorderSizePixel=0,Position=UDim2.fromOffset(0, 8),Size=UDim2.new(0, 2, 1, -16),Parent=toast});
		create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(15, 11),Size=UDim2.new(1, -28, 0, 17),Font=Enum.Font.GothamBold,Text=(options.Title or self.Title),TextColor3=THEME.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=toast});
		create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(15, 31),Size=UDim2.new(1, -28, 0, 29),Font=Enum.Font.Gotham,Text=(options.Content or "Notification"),TextColor3=THEME.Muted,TextSize=10,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=toast});
		tween(toast, 0.22, {Size=UDim2.fromOffset(250, 72)});
		task.delay(options.Duration or 3.2, function()
			if toast.Parent then
				tween(toast, 0.18, {Size=UDim2.fromOffset(0, 72),BackgroundTransparency=1});
				task.delay(0.2, function()
					if toast.Parent then
						toast:Destroy();
					end
				end);
			end
		end);
	end;
	ZenthraUI.CreateTab = function(self, options)
		if (type(options) == "string") then
			options = {Name=options};
		end
		options = options or {};
		local window = self;
		local tab = {Window=window,Name=(options.Name or "Tab"),Icon=(options.Icon or "◇"),Sections={},LeftCount=0,RightCount=0};
		local button = create("TextButton", {Name=tab.Name,AutoButtonColor=false,BackgroundColor3=THEME.Sidebar,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1, 0, 0, 37),Font=Enum.Font.GothamMedium,Text="",Parent=window.Navigation});
		addCorner(button, 5);
		local activeBar = create("Frame", {Name="Active",AnchorPoint=Vector2.new(0, 0.5),Position=UDim2.new(0, 3, 0.5, 0),Size=UDim2.fromOffset(3, 0),BackgroundColor3=THEME.White,BorderSizePixel=0,Parent=button});
		addCorner(activeBar, 2);
		local icon = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(13, 0),Size=UDim2.fromOffset(18, 37),Font=Enum.Font.GothamMedium,Text=tab.Icon,TextColor3=THEME.Dim,TextSize=14,Parent=button});
		local label = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(35, 0),Size=UDim2.new(1, -39, 1, 0),Font=Enum.Font.GothamMedium,Text=tab.Name,TextColor3=THEME.Dim,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=button});
		local page = create("Frame", {Name=(tab.Name .. "Page"),BackgroundTransparency=1,Position=UDim2.fromOffset(20, 25),Size=UDim2.new(1, -36, 1, -43),Visible=false,Parent=window.Content});
		local left = create("ScrollingFrame", {Name="Left",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0.5, -8, 1, 0),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(162, 162, 168),ScrollBarImageTransparency=0.28,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=page});
		local leftLayout = create("UIListLayout", {Padding=UDim.new(0, 10),SortOrder=Enum.SortOrder.LayoutOrder,Parent=left});
		addPadding(left, 0, 7, 0, 7);
		local right = create("ScrollingFrame", {Name="Right",BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5, 8, 0, 0),Size=UDim2.new(0.5, -8, 1, 0),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(162, 162, 168),ScrollBarImageTransparency=0.28,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=page});
		local rightLayout = create("UIListLayout", {Padding=UDim.new(0, 10),SortOrder=Enum.SortOrder.LayoutOrder,Parent=right});
		addPadding(right, 0, 7, 0, 7);
		tab.Button = button;
		tab.ActiveBar = activeBar;
		tab.Label = label;
		tab.IconLabel = icon;
		tab.Page = page;
		tab.Left = left;
		tab.Right = right;
		tab.LeftLayout = leftLayout;
		tab.RightLayout = rightLayout;
		tab.Select = function(self)
			for _, other in ipairs(window.Tabs) do
				local selected = other == self;
				other.Page.Visible = selected;
				tween(other.Label, 0.14, {TextColor3=((selected and THEME.Text) or THEME.Dim)});
				tween(other.IconLabel, 0.14, {TextColor3=((selected and THEME.Text) or THEME.Dim)});
				tween(other.Button, 0.14, {BackgroundTransparency=((selected and 0.45) or 1),BackgroundColor3=((selected and THEME.Surface) or THEME.Sidebar)});
				tween(other.ActiveBar, 0.16, {Size=UDim2.fromOffset(3, (selected and 23) or 0)});
			end
			window.SelectedTab = self;
		end;
		window:_Connect(button.MouseButton1Click, function()
			tab:Select();
		end);
		button.MouseEnter:Connect(function()
			if (window.SelectedTab ~= tab) then
				tween(button, 0.12, {BackgroundTransparency=0.7,BackgroundColor3=THEME.Surface});
			end
		end);
		button.MouseLeave:Connect(function()
			if (window.SelectedTab ~= tab) then
				tween(button, 0.12, {BackgroundTransparency=1,BackgroundColor3=THEME.Sidebar});
			end
		end);
		setmetatable(tab, {__index=ZenthraUI.Tab});
		table.insert(window.Tabs, tab);
		window.EmptyLabel.Visible = false;
		if (#window.Tabs == 1) then
			tab:Select();
		end
		return tab;
	end;
	ZenthraUI.Tab = {};
	local function createSectionHeader(section, options)
		local title = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(12, 10),Size=UDim2.new(1, -42, 0, 17),Font=Enum.Font.GothamBold,Text=(options.Title or "Section"),TextColor3=THEME.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=section.Frame});
		local description = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(12, 27),Size=UDim2.new(1, -42, 0, 15),Font=Enum.Font.Gotham,Text=(options.Description or ""),TextColor3=THEME.Muted,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Visible=((options.Description ~= nil) and (options.Description ~= "")),Parent=section.Frame});
		if options.Locked then
			create("TextLabel", {BackgroundTransparency=1,Position=UDim2.new(1, -31, 0, 10),Size=UDim2.fromOffset(19, 18),Font=Enum.Font.GothamBold,Text="▢",TextColor3=THEME.Dim,TextSize=14,Parent=section.Frame});
		end
		local headerHeight = (description.Visible and 52) or 40;
		create("Frame", {BackgroundColor3=THEME.BorderSoft,BackgroundTransparency=0.1,BorderSizePixel=0,Position=UDim2.fromOffset(0, headerHeight - 1),Size=UDim2.new(1, 0, 0, 1),Parent=section.Frame});
		local body = create("Frame", {Name="Body",BackgroundTransparency=1,Position=UDim2.fromOffset(0, headerHeight),Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,Parent=section.Frame});
		create("UIListLayout", {Padding=UDim.new(0, 0),SortOrder=Enum.SortOrder.LayoutOrder,Parent=body});
		section.Body = body;
		section.TitleLabel = title;
		section.DescriptionLabel = description;
	end
	ZenthraUI.Tab.CreateSection = function(self, options)
		if (type(options) == "string") then
			options = {Title=options};
		end
		options = options or {};
		local side = options.Side;
		if ((side ~= "Left") and (side ~= "Right")) then
			side = ((self.LeftCount <= self.RightCount) and "Left") or "Right";
		end
		local parent = ((side == "Right") and self.Right) or self.Left;
		local frame = create("Frame", {Name=(options.Title or "Section"),BackgroundColor3=THEME.Surface,BackgroundTransparency=0.12,BorderSizePixel=0,Size=UDim2.new(1, 0, 0, 0),AutomaticSize=Enum.AutomaticSize.Y,ClipsDescendants=false,Parent=parent});
		addCorner(frame, 7);
		addStroke(frame, THEME.Border, 1, 0.12);
		local section = {Tab=self,Window=self.Window,Frame=frame,Body=nil,Controls={}};
		setmetatable(section, {__index=ZenthraUI.Section});
		createSectionHeader(section, options);
		if (side == "Left") then
			self.LeftCount = self.LeftCount + 1;
		else
			self.RightCount = self.RightCount + 1;
		end
		table.insert(self.Sections, section);
		return section;
	end;
	ZenthraUI.Tab.AddSection = ZenthraUI.Tab.CreateSection;
	ZenthraUI.Section = {};
	local function makeControlRow(section, height, withDivider)
		local row = create("Frame", {BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, height),Parent=section.Body});
		if (withDivider ~= false) then
			create("Frame", {BackgroundColor3=THEME.BorderSoft,BackgroundTransparency=0.24,BorderSizePixel=0,Position=UDim2.new(0, 10, 1, -1),Size=UDim2.new(1, -20, 0, 1),Parent=row});
		end
		return row;
	end
	local function makeNameLabel(row, name, position, size)
		return create("TextLabel", {BackgroundTransparency=1,Position=(position or UDim2.fromOffset(11, 0)),Size=(size or UDim2.new(1, -70, 1, 0)),Font=Enum.Font.GothamMedium,Text=(name or "Control"),TextColor3=THEME.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,Parent=row});
	end
	ZenthraUI.Section.AddToggle = function(self, options)
		if (type(options) == "string") then
			options = {Name=options};
		end
		options = options or {};
		local section = self;
		local window = self.Window;
		local state = options.Default == true;
		local keybind = options.Keybind;
		local row = makeControlRow(section, 37);
		local leftOffset = 11;
		if options.Tag then
			local tag = create("TextLabel", {BackgroundColor3=THEME.Input,BorderSizePixel=0,Position=UDim2.fromOffset(11, 10),Size=UDim2.fromOffset(28, 17),Font=Enum.Font.GothamMedium,Text=tostring(options.Tag),TextColor3=THEME.Text,TextSize=9,Parent=row});
			addCorner(tag, 4);
			leftOffset = 45;
		end
		local label = makeNameLabel(row, options.Name or "Toggle", UDim2.fromOffset(leftOffset, 0), UDim2.new(1, -112, 1, 0));
		local switch = create("TextButton", {AutoButtonColor=false,AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, -12, 0.5, 0),Size=UDim2.fromOffset(27, 15),BackgroundColor3=((state and THEME.White) or Color3.fromRGB(45, 45, 49)),BorderSizePixel=0,Text="",Parent=row});
		addCorner(switch, 8);
		addStroke(switch, (state and THEME.White) or THEME.Border, 1, 0.05);
		local knob = create("Frame", {AnchorPoint=Vector2.new(0, 0.5),Position=((state and UDim2.new(1, -13, 0.5, 0)) or UDim2.new(0, 2, 0.5, 0)),Size=UDim2.fromOffset(11, 11),BackgroundColor3=((state and Color3.fromRGB(45, 45, 49)) or THEME.Muted),BorderSizePixel=0,Parent=switch});
		addCorner(knob, 6);
		local keyChip = nil;
		if keybind then
			keyChip = create("TextButton", {AutoButtonColor=false,AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, -47, 0.5, 0),Size=UDim2.fromOffset(27, 17),BackgroundColor3=THEME.Input,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=keyName(keybind),TextColor3=THEME.Text,TextSize=9,Parent=row});
			addCorner(keyChip, 4);
		end
		local control = {};
		control.Set = function(self, value, silent)
			state = value == true;
			setFlag(window, options.Flag, state);
			tween(switch, 0.16, {BackgroundColor3=((state and THEME.White) or Color3.fromRGB(45, 45, 49))});
			tween(knob, 0.16, {Position=((state and UDim2.new(1, -13, 0.5, 0)) or UDim2.new(0, 2, 0.5, 0)),BackgroundColor3=((state and Color3.fromRGB(45, 45, 49)) or THEME.Muted)});
			if not silent then
				safeCall(options.Callback, state);
			end
		end;
		control.Get = function(self)
			return state;
		end;
		window:_Connect(switch.MouseButton1Click, function()
			control:Set(not state);
		end);
		if keyChip then
			local listening = false;
			window:_Connect(keyChip.MouseButton1Click, function()
				listening = true;
				keyChip.Text = "...";
			end);
			window:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
				if (listening and (input.KeyCode ~= Enum.KeyCode.Unknown)) then
					listening = false;
					keybind = input.KeyCode;
					keyChip.Text = keyName(keybind);
					safeCall(options.KeyChanged, keybind);
					return;
				end
				if (not gameProcessed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == keybind)) then
					control:Set(not state);
				end
			end);
		end
		control:Set(state, true);
		control.Instance = row;
		control.Label = label;
		table.insert(section.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddSlider = function(self, options)
		options = options or {};
		local section = self;
		local window = self.Window;
		local minimum = options.Min or 0;
		local maximum = options.Max or 100;
		local decimals = options.Decimals or 0;
		local value = clamp(options.Default or minimum, minimum, maximum);
		local row = makeControlRow(section, 51);
		makeNameLabel(row, options.Name or "Slider", UDim2.fromOffset(11, 4), UDim2.new(1, -70, 0, 20));
		local valueLabel = create("TextLabel", {BackgroundTransparency=1,AnchorPoint=Vector2.new(1, 0),Position=UDim2.new(1, -11, 0, 4),Size=UDim2.fromOffset(62, 20),Font=Enum.Font.GothamMedium,Text=tostring(value),TextColor3=THEME.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,Parent=row});
		local track = create("TextButton", {AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(54, 54, 58),BorderSizePixel=0,Position=UDim2.fromOffset(11, 31),Size=UDim2.new(1, -22, 0, 3),Text="",Parent=row});
		addCorner(track, 2);
		local fill = create("Frame", {BackgroundColor3=THEME.White,BorderSizePixel=0,Size=UDim2.new(0, 0, 1, 0),Parent=track});
		addCorner(fill, 2);
		local thumb = create("Frame", {AnchorPoint=Vector2.new(0.5, 0.5),Position=UDim2.fromScale(0, 0.5),Size=UDim2.fromOffset(8, 8),BackgroundColor3=THEME.White,BorderSizePixel=0,Parent=track});
		addCorner(thumb, 5);
		local control = {};
		control.Set = function(self, newValue, silent)
			value = round(clamp(tonumber(newValue) or minimum, minimum, maximum), decimals);
			local alpha = ((maximum == minimum) and 0) or ((value - minimum) / (maximum - minimum));
			fill.Size = UDim2.new(alpha, 0, 1, 0);
			thumb.Position = UDim2.new(alpha, 0, 0.5, 0);
			valueLabel.Text = (options.Prefix or "") .. tostring(value) .. (options.Suffix or "");
			setFlag(window, options.Flag, value);
			if not silent then
				safeCall(options.Callback, value);
			end
		end;
		control.Get = function(self)
			return value;
		end;
		local dragging = false;
		local function updateFromInput(input)
			local alpha = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1);
			control:Set(minimum + ((maximum - minimum) * alpha));
		end
		window:_Connect(track.InputBegan, function(input)
			if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
				dragging = true;
				updateFromInput(input);
			end
		end);
		window:_Connect(UserInputService.InputChanged, function(input)
			if (dragging and ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch))) then
				updateFromInput(input);
			end
		end);
		window:_Connect(UserInputService.InputEnded, function(input)
			if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
				dragging = false;
			end
		end);
		control:Set(value, true);
		control.Instance = row;
		table.insert(section.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddDropdown = function(self, options)
		options = options or {};
		local section = self;
		local window = self.Window;
		local values = options.Values or {};
		local selected = options.Default or values[1];
		local open = false;
		local row = makeControlRow(section, 68);
		makeNameLabel(row, options.Name or "Dropdown", UDim2.fromOffset(11, 2), UDim2.new(1, -22, 0, 21));
		local dropdown = create("Frame", {BackgroundColor3=THEME.Input,BorderSizePixel=0,Position=UDim2.fromOffset(10, 27),Size=UDim2.new(1, -20, 0, 31),ClipsDescendants=true,ZIndex=4,Parent=row});
		addCorner(dropdown, 5);
		addStroke(dropdown, THEME.Border, 1, 0.15);
		local selectButton = create("TextButton", {AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1, 0, 0, 31),Font=Enum.Font.GothamMedium,Text="",ZIndex=5,Parent=dropdown});
		local selectedLabel = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(9, 0),Size=UDim2.new(1, -34, 0, 31),Font=Enum.Font.GothamMedium,Text=tostring(selected or "Select"),TextColor3=THEME.Text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,Parent=dropdown});
		local arrow = create("TextLabel", {BackgroundTransparency=1,Position=UDim2.new(1, -28, 0, 0),Size=UDim2.fromOffset(20, 31),Font=Enum.Font.GothamBold,Text="⌄",TextColor3=THEME.Muted,TextSize=13,ZIndex=6,Parent=dropdown});
		local search = create("TextBox", {BackgroundColor3=Color3.fromRGB(24, 24, 27),BorderSizePixel=0,Position=UDim2.fromOffset(0, 31),Size=UDim2.new(1, 0, 0, 28),ClearTextOnFocus=false,Font=Enum.Font.Gotham,PlaceholderText="⌕  Search...",PlaceholderColor3=THEME.Dim,Text="",TextColor3=THEME.Text,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Visible=false,ZIndex=6,Parent=dropdown});
		addPadding(search, 8, 8, 0, 0);
		local optionsList = create("ScrollingFrame", {BackgroundColor3=Color3.fromRGB(47, 47, 50),BorderSizePixel=0,Position=UDim2.fromOffset(0, 59),Size=UDim2.new(1, 0, 0, 112),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=THEME.Muted,Visible=false,ZIndex=7,Parent=dropdown});
		create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder,Parent=optionsList});
		local optionButtons = {};
		local control = {};
		control.Set = function(self, value, silent)
			selected = value;
			selectedLabel.Text = tostring(value or "Select");
			setFlag(window, options.Flag, selected);
			if not silent then
				safeCall(options.Callback, selected);
			end
		end;
		control.Get = function(self)
			return selected;
		end;
		local function setOpen(value)
			open = value;
			search.Visible = open;
			optionsList.Visible = open;
			arrow.Text = (open and "⌃") or "⌄";
			row.Size = UDim2.new(1, 0, 0, (open and 208) or 68);
			dropdown.Size = UDim2.new(1, -20, 0, (open and 171) or 31);
			if not open then
				search.Text = "";
			end
		end
		local function rebuild(newValues)
			values = newValues or values;
			for _, oldButton in ipairs(optionButtons) do
				oldButton:Destroy();
			end
			optionButtons = {};
			for _, value in ipairs(values) do
				local option = create("TextButton", {AutoButtonColor=false,BackgroundColor3=THEME.Input,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1, 0, 0, 22),Font=Enum.Font.Gotham,Text=("  " .. tostring(value)),TextColor3=(((value == selected) and THEME.Text) or THEME.Muted),TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8,Parent=optionsList});
				addHover(option, THEME.Input, THEME.SurfaceHover);
				window:_Connect(option.MouseButton1Click, function()
					control:Set(value);
					setOpen(false);
				end);
				table.insert(optionButtons, option);
			end
		end
		control.Refresh = function(self, newValues, keepSelection)
			if not keepSelection then
				selected = (newValues and newValues[1]) or nil;
			end
			rebuild(newValues or {});
			control:Set(selected, true);
		end;
		window:_Connect(selectButton.MouseButton1Click, function()
			setOpen(not open);
		end);
		window:_Connect(search:GetPropertyChangedSignal("Text"), function()
			local query = string.lower(search.Text);
			for index, button in ipairs(optionButtons) do
				button.Visible = (query == "") or (string.find(string.lower(tostring(values[index])), query, 1, true) ~= nil);
			end
		end);
		rebuild(values);
		control:Set(selected, true);
		control.Instance = row;
		table.insert(section.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddKeybind = function(self, options)
		options = options or {};
		local section = self;
		local window = self.Window;
		local key = options.Default or Enum.KeyCode.Unknown;
		local listening = false;
		local row = makeControlRow(section, 39);
		makeNameLabel(row, options.Name or "Keybind", UDim2.fromOffset(11, 0), UDim2.new(1, -92, 1, 0));
		local keyButton = create("TextButton", {AutoButtonColor=false,AnchorPoint=Vector2.new(1, 0.5),Position=UDim2.new(1, -11, 0.5, 0),Size=UDim2.fromOffset(65, 21),BackgroundColor3=THEME.Input,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=(((key == Enum.KeyCode.Unknown) and "None") or keyName(key)),TextColor3=THEME.Text,TextSize=9,Parent=row});
		addCorner(keyButton, 4);
		addStroke(keyButton, THEME.Border, 1, 0.2);
		local control = {};
		control.Set = function(self, newKey, silent)
			key = newKey or Enum.KeyCode.Unknown;
			keyButton.Text = ((key == Enum.KeyCode.Unknown) and "None") or keyName(key);
			setFlag(window, options.Flag, key);
			if not silent then
				safeCall(options.Changed, key);
			end
		end;
		control.Get = function(self)
			return key;
		end;
		window:_Connect(keyButton.MouseButton1Click, function()
			listening = true;
			keyButton.Text = "...";
		end);
		window:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
			if (listening and (input.KeyCode ~= Enum.KeyCode.Unknown)) then
				listening = false;
				control:Set(input.KeyCode);
				return;
			end
			if (not gameProcessed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == key)) then
				safeCall(options.Callback, key);
			end
		end);
		control:Set(key, true);
		control.Instance = row;
		table.insert(section.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddButton = function(self, options)
		if (type(options) == "string") then
			options = {Name=options};
		end
		options = options or {};
		local row = makeControlRow(self, 45);
		local button = create("TextButton", {AutoButtonColor=false,BackgroundColor3=THEME.Input,BorderSizePixel=0,Position=UDim2.fromOffset(10, 9),Size=UDim2.new(1, -20, 0, 27),Font=Enum.Font.GothamMedium,Text=(options.Name or "Button"),TextColor3=THEME.Text,TextSize=10,Parent=row});
		addCorner(button, 5);
		addStroke(button, THEME.Border, 1, 0.18);
		addHover(button, THEME.Input, THEME.SurfaceHover);
		self.Window:_Connect(button.MouseButton1Click, function()
			safeCall(options.Callback);
		end);
		local control = {Instance=row,Button=button};
		table.insert(self.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddInput = function(self, options)
		options = options or {};
		local section = self;
		local window = self.Window;
		local value = tostring(options.Default or "");
		local row = makeControlRow(section, 67);
		makeNameLabel(row, options.Name or "Input", UDim2.fromOffset(11, 2), UDim2.new(1, -22, 0, 21));
		local box = create("TextBox", {BackgroundColor3=THEME.Input,BorderSizePixel=0,Position=UDim2.fromOffset(10, 28),Size=UDim2.new(1, -20, 0, 28),ClearTextOnFocus=(options.ClearOnFocus == true),Font=Enum.Font.Gotham,PlaceholderText=(options.Placeholder or "Enter text..."),PlaceholderColor3=THEME.Dim,Text=value,TextColor3=THEME.Text,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=row});
		addCorner(box, 5);
		addStroke(box, THEME.Border, 1, 0.18);
		addPadding(box, 9, 9, 0, 0);
		local control = {};
		control.Set = function(self, newValue, silent)
			value = tostring(newValue or "");
			box.Text = value;
			setFlag(window, options.Flag, value);
			if not silent then
				safeCall(options.Callback, value);
			end
		end;
		control.Get = function(self)
			return value;
		end;
		window:_Connect(box.FocusLost, function(enterPressed)
			value = box.Text;
			setFlag(window, options.Flag, value);
			safeCall(options.Callback, value, enterPressed);
		end);
		control:Set(value, true);
		control.Instance = row;
		control.TextBox = box;
		table.insert(section.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddDivider = function(self, options)
		if (type(options) == "string") then
			options = {Text=options};
		end
		options = options or {};
		local row = makeControlRow(self, 28, false);
		local text = options.Text or "Section";
		create("Frame", {BackgroundColor3=THEME.Border,BackgroundTransparency=0.18,BorderSizePixel=0,Position=UDim2.new(0, 10, 0.5, 0),Size=UDim2.new(0.5, -42, 0, 1),Parent=row});
		create("TextLabel", {BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5, 0.5),Position=UDim2.fromScale(0.5, 0.5),Size=UDim2.fromOffset(74, 20),Font=Enum.Font.GothamMedium,Text=text,TextColor3=THEME.Text,TextSize=9,Parent=row});
		create("Frame", {BackgroundColor3=THEME.Border,BackgroundTransparency=0.18,BorderSizePixel=0,Position=UDim2.new(0.5, 32, 0.5, 0),Size=UDim2.new(0.5, -42, 0, 1),Parent=row});
		local control = {Instance=row};
		table.insert(self.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddParagraph = function(self, options)
		if (type(options) == "string") then
			options = {Content=options};
		end
		options = options or {};
		local height = options.Height or 50;
		local row = makeControlRow(self, height);
		create("TextLabel", {BackgroundTransparency=1,Position=UDim2.fromOffset(11, 7),Size=UDim2.new(1, -22, 1, -14),Font=Enum.Font.Gotham,Text=(options.Content or "Text"),TextColor3=(options.Color or THEME.Muted),TextSize=(options.TextSize or 9),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=row});
		local control = {Instance=row};
		table.insert(self.Controls, control);
		return control;
	end;
	ZenthraUI.Section.AddLabel = ZenthraUI.Section.AddParagraph;
	ZenthraUI.AddTab = ZenthraUI.CreateTab;
	ZenthraUI.Tab.AddCard = ZenthraUI.Tab.CreateSection;
	ZenthraUI.Section.CreateToggle = ZenthraUI.Section.AddToggle;
	ZenthraUI.Section.CreateSlider = ZenthraUI.Section.AddSlider;
	ZenthraUI.Section.CreateDropdown = ZenthraUI.Section.AddDropdown;
	ZenthraUI.Section.CreateKeybind = ZenthraUI.Section.AddKeybind;
	ZenthraUI.Section.CreateButton = ZenthraUI.Section.AddButton;
	ZenthraUI.Section.CreateInput = ZenthraUI.Section.AddInput;
	ZenthraUI.Destroy = function(self)
		if self.Destroyed then
			return;
		end
		self.Destroyed = true;
		for _, connection in ipairs(self.Connections) do
			if connection.Connected then
				connection:Disconnect();
			end
		end
		table.clear(self.Connections);
		if self.ScreenGui then
			self.ScreenGui:Destroy();
		end
	end;
	return ZenthraUI;
end)();
ZenthraUI = (function()
	local Adapter = {};
	local WINDUI_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua";
	local function loadWindUI()
		local ok, result = pcall(function()
			local source = game:HttpGet(WINDUI_URL);
			local loader, loadError = loadstring(source, "@WindUI/dist/main.lua");
			assert(loader, loadError);
			return loader();
		end);
		assert(ok and result, "Unable to load WindUI: " .. tostring(result));
		return result;
	end
	local iconNames = {P="boxes",B="hammer",F="plane",S="settings"};
	Adapter.CreateWindow = function(options)
		options = options or {};
		local WindUI = loadWindUI();
		local requestedSize = options.Size or Vector2.new(700, 450);
		local rawWindow = WindUI:CreateWindow({Title=(options.Title or "NDS Part Control"),Author="WindUI",Folder="NDSPartControl",Icon="wind",Size=UDim2.fromOffset(requestedSize.X, requestedSize.Y),MinSize=Vector2.new(560, 350),MaxSize=Vector2.new(900, 650),Resizable=true,NewElements=true,HideSearchBar=false,ScrollBarEnabled=true,ToggleKey=(options.ToggleKey or Enum.KeyCode.LeftAlt),Topbar={Height=44,ButtonsType="Mac"},OpenButton={Title="NDS Part Control",Enabled=true,Draggable=true,OnlyMobile=false}});
		local navigation = rawWindow:Section({Title="Natural Disaster Survival",Opened=true});
		local window = {Raw=rawWindow,WindUI=WindUI,Navigation=navigation,Connections={},Flags={},Destroyed=false,Visible=true};
		window._Connect = function(self, signal, callback)
			local connection = signal:Connect(callback);
			table.insert(self.Connections, connection);
			return connection;
		end;
		window.Notify = function(self, data)
			self.WindUI:Notify({Title=tostring(data.Title or "NDS Part Control"),Content=tostring(data.Content or ""),Duration=(data.Duration or 3)});
		end;
		window.SetVisible = function(self, visible)
			visible = visible ~= false;
			if (visible == self.Visible) then
				return;
			end
			self.Visible = visible;
			if visible then
				self.Raw:Open();
			else
				self.Raw:Close();
			end
		end;
		window.Toggle = function(self)
			self.Visible = not self.Visible;
			self.Raw:Toggle();
		end;
		window.CreateTab = function(self, tabOptions)
			tabOptions = tabOptions or {};
			local rawTab = self.Navigation:Tab({Title=(tabOptions.Name or "Tab"),Icon=(iconNames[tabOptions.Icon] or tabOptions.Icon),Border=true});
			local tab = {Window=self,Raw=rawTab};
			tab.Select = function(self)
				return self.Raw:Select();
			end;
			tab.CreateSection = function(self, sectionOptions)
				sectionOptions = sectionOptions or {};
				local rawSection = self.Raw:Section({Title=(sectionOptions.Title or "Section"),Desc=sectionOptions.Description,Box=true,BoxBorder=true,Opened=true});
				local section = {Window=self.Window,Raw=rawSection};
				section.AddToggle = function(self, controlOptions)
					controlOptions = controlOptions or {};
					local value = controlOptions.Default == true;
					local suppress = true;
					local control = {};
					local rawControl = self.Raw:Toggle({Title=(controlOptions.Name or "Toggle"),Desc=controlOptions.Description,Value=value,Callback=function(newValue)
						value = newValue == true;
						if controlOptions.Flag then
							window.Flags[controlOptions.Flag] = value;
						end
						if (not suppress and controlOptions.Callback) then
							controlOptions.Callback(value);
						end
					end});
					suppress = false;
					control.Raw = rawControl;
					control.Set = function(self, newValue, silent)
						value = newValue == true;
						if controlOptions.Flag then
							window.Flags[controlOptions.Flag] = value;
						end
						suppress = silent == true;
						rawControl:Set(value, not suppress, true);
						suppress = false;
					end;
					control.Get = function(self)
						return value;
					end;
					if controlOptions.Flag then
						window.Flags[controlOptions.Flag] = value;
					end
					if controlOptions.Keybind then
						window:_Connect(game:GetService("UserInputService").InputBegan, function(input, processed)
							if (not processed and not game:GetService("UserInputService"):GetFocusedTextBox() and (input.KeyCode == controlOptions.Keybind)) then
								control:Set(not value);
							end
						end);
					end
					return control;
				end;
				section.AddSlider = function(self, controlOptions)
					controlOptions = controlOptions or {};
					local value = controlOptions.Default or controlOptions.Min or 0;
					local suppress = true;
					local control = {};
					local rawControl = self.Raw:Slider({Title=(controlOptions.Name or "Slider"),Desc=controlOptions.Description,Step=(controlOptions.Step or 1),Value={Min=(controlOptions.Min or 0),Max=(controlOptions.Max or 100),Default=value},Callback=function(newValue)
						value = tonumber(newValue) or value;
						if controlOptions.Flag then
							window.Flags[controlOptions.Flag] = value;
						end
						if (not suppress and controlOptions.Callback) then
							controlOptions.Callback(value);
						end
					end});
					suppress = false;
					control.Raw = rawControl;
					control.Set = function(self, newValue, silent)
						suppress = silent == true;
						rawControl:Set(tonumber(newValue) or value);
						suppress = false;
					end;
					control.Get = function(self)
						return value;
					end;
					if controlOptions.Flag then
						window.Flags[controlOptions.Flag] = value;
					end
					return control;
				end;
				section.AddButton = function(self, controlOptions)
					controlOptions = controlOptions or {};
					return self.Raw:Button({Title=(controlOptions.Name or "Button"),Desc=controlOptions.Description,Callback=(controlOptions.Callback or function()
					end)});
				end;
				section.AddInput = function(self, controlOptions)
					controlOptions = controlOptions or {};
					local value = tostring(controlOptions.Default or "");
					local suppress = true;
					local control = {Value=value};
					local rawControl = self.Raw:Input({Title=(controlOptions.Name or "Input"),Desc=controlOptions.Description,Value=value,Placeholder=(controlOptions.Placeholder or "Enter text..."),ClearTextOnFocus=false,Callback=function(newValue)
						value = tostring(newValue or "");
						control.Value = value;
						if controlOptions.Flag then
							window.Flags[controlOptions.Flag] = value;
						end
						if (not suppress and controlOptions.Callback) then
							controlOptions.Callback(value);
						end
					end});
					suppress = false;
					control.Raw = rawControl;
					control.TextBox = setmetatable({}, {__index=function(_, key)
						if (key == "Text") then
							return value;
						end
					end,__newindex=function(_, key, newValue)
						if (key == "Text") then
							control:Set(newValue);
						end
					end});
					control.Set = function(self, newValue, silent)
						value = tostring(newValue or "");
						control.Value = value;
						suppress = silent == true;
						rawControl:Set(value, false);
						suppress = false;
					end;
					control.Get = function(self)
						return value;
					end;
					return control;
				end;
				section.AddParagraph = function(self, controlOptions)
					controlOptions = controlOptions or {};
					return self.Raw:Paragraph({Title=(controlOptions.Name or "Information"),Desc=tostring(controlOptions.Content or controlOptions.Description or "")});
				end;
				return section;
			end;
			return tab;
		end;
		window.Destroy = function(self)
			if self.Destroyed then
				return;
			end
			self.Destroyed = true;
			for _, connection in ipairs(self.Connections) do
				pcall(function()
					connection:Disconnect();
				end);
			end
			table.clear(self.Connections);
			pcall(function()
				self.Raw:Destroy();
			end);
		end;
		return window;
	end;
	return Adapter;
end)();
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local TeleportService = game:GetService("TeleportService");
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local Mouse = LocalPlayer:GetMouse();
local GlobalEnvironment = getgenv();
local previousCleanup = GlobalEnvironment.__ZenthraNDSPartControlCleanup;
if (type(previousCleanup) == "function") then
	pcall(previousCleanup);
end
local sessionToken = {};
GlobalEnvironment.__ZenthraNDSPartControlSession = sessionToken;
local oldGui = PlayerGui:FindFirstChild("ZenthraNDSPartControl");
if oldGui then
	oldGui:Destroy();
end
local state = {bringing=false,bringStartTime=0,bringDelay=10,bringSpinAngle=0,bringSpinSpeed=15,bringRadius=3,orbiting=false,freezing=false,antiFling=true,flyEnabled=false,flySpeed=60,flyVelocity=nil,flyGyro=nil,flyCharacter=nil,target=nil,targetText=LocalPlayer.Name,verticalOffset=8,orbitRadius=18,orbitSpeed=2,orbitAngle=0,roots={},originalCFrames={},frozenCFrames={},partCanCollide={},antiFlingCanCollide={},layoutCanCollide={},layoutAppearance={},layoutAnchored={},layoutCFrames={},layoutActive=false,layoutKind=nil,layoutBase=nil,layoutStarted=0,layoutAccumulator=0,elevatorRaised=false,elevatorHeight=100,elevatorSpeed=8,elevatorCurrentY=0,yardCFrame=nil,yardHomeY=0,yardDriveEnabled=false,yardRise=false,yardLower=false,yardMoveSpeed=14,yardVerticalSpeed=6,yardLiftHeight=100,yardSmoothness=4,yardVelocity=Vector3.zero,yardButtonVector=Vector3.zero,yardButtonUntil=0,yardNudgeDistance=12,yardFenceRoots={},yardRoots={},placingMode=nil,placementDragging=false,placementGroundY=0,placementHeight=0,placementCFrame=nil,previewFolder=nil,previousMouseTargetFilter=nil,meteorActive=false,meteorThrown=false,meteorImpactTorso=nil,meteorCenter=nil,meteorDirection=Vector3.zero,meteorThrowStarted=0,meteorAngle=0,meteorLastClick=0,meteorAccumulator=0,meteorRadius=11,meteorHeight=24,meteorSpeed=135,summonStarted=0,shoulderMotor=nil,shoulderTransform=nil,safeCFrame=nil,lastSafeUpdate=0,lastScan=0,lastRadiusUpdate=0,lastStatusUpdate=0,moved=0,unowned=0,welded=0,savedSimulationRadius=nil,savedMaxSimulationRadius=nil};
local Window = ZenthraUI.CreateWindow({Title="NDS Part Control",GuiName="ZenthraNDSPartControl",ToggleKey=Enum.KeyCode.LeftAlt,Size=Vector2.new(700, 450)});
local PartsTab = Window:CreateTab({Name="Parts",Icon="P"});
local BuildTab = Window:CreateTab({Name="Build",Icon="B"});
local PlayerTab = Window:CreateTab({Name="Player",Icon="F"});
local SettingsTab = Window:CreateTab({Name="Settings",Icon="S"});
local TargetSection = PartsTab:CreateSection({Title="Target Player",Description="username or display name",Side="Left"});
local ControlSection = PartsTab:CreateSection({Title="Part Controls",Description="shared unanchored map assemblies",Side="Right"});
local BringToggle;
local OrbitToggle;
local MeteorToggle;
local ElevatorLiftToggle;
local YardDriveToggle;
local YardRiseToggle;
local YardLowerToggle;
local stopPlacement;
local stopLayout;
local stopMeteor;
local stopAllPartModes;
local TargetField = TargetSection:AddInput({Name="Username / Display Name",Default=LocalPlayer.Name,Placeholder="Type a player name...",Callback=function(value)
	state.targetText = value;
end});
local TargetStatus = TargetSection:AddInput({Name="Resolved Target",Default=(LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")});
local PartStatus = TargetSection:AddInput({Name="Part Status",Default="Ready to scan workspace.Structure"});
local function notify(title, content)
	Window:Notify({Title=title,Content=content,Duration=3});
end
local BLUE_HAMMER_NAME = "Blue Hammer";
local BLUE_HAMMER_MARKER = "ZenthraNDSBlueHammer";
local function findBlueHammer()
	local containers = {LocalPlayer.Character,LocalPlayer:FindFirstChildOfClass("Backpack")};
	for _, container in ipairs(containers) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if (child:IsA("Tool") and ((child.Name == BLUE_HAMMER_NAME) or child:GetAttribute(BLUE_HAMMER_MARKER))) then
					return child;
				end
			end
		end
	end
	return nil;
end
local function giveBlueHammer()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 3);
	local character = LocalPlayer.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	if not backpack then
		notify("Blue Hammer", "Your Backpack is not available yet.");
		return;
	end
	local existing = findBlueHammer();
	if existing then
		if (humanoid and (existing.Parent == backpack)) then
			humanoid:EquipTool(existing);
		end
		notify("Blue Hammer", "The hammer was already in your inventory, so it was equipped.");
		return;
	end
	local tool = Instance.new("Tool");
	tool.Name = BLUE_HAMMER_NAME;
	tool.ToolTip = "NDS blue hammer";
	tool.TextureId = "rbxassetid://109407938820554";
	tool.CanBeDropped = false;
	tool.RequiresHandle = true;
	tool:SetAttribute(BLUE_HAMMER_MARKER, true);
	local handle = Instance.new("Part");
	handle.Name = "Handle";
	handle.Size = Vector3.new(0.42, 3.2, 0.42);
	handle.Color = Color3.fromRGB(35, 48, 68);
	handle.Material = Enum.Material.Metal;
	handle.CanCollide = false;
	handle.CanTouch = false;
	handle.CanQuery = false;
	handle.Massless = true;
	handle.TopSurface = Enum.SurfaceType.Smooth;
	handle.BottomSurface = Enum.SurfaceType.Smooth;
	handle.Parent = tool;
	local head = Instance.new("Part");
	head.Name = "HammerHead";
	head.Size = Vector3.new(2.7, 1.05, 1.05);
	head.Color = Color3.fromRGB(34, 148, 255);
	head.Material = Enum.Material.Neon;
	head.CanCollide = false;
	head.CanTouch = false;
	head.CanQuery = false;
	head.Massless = true;
	head.TopSurface = Enum.SurfaceType.Smooth;
	head.BottomSurface = Enum.SurfaceType.Smooth;
	head.CFrame = handle.CFrame * CFrame.new(0, 1.35, 0);
	head.Parent = tool;
	local headWeld = Instance.new("WeldConstraint");
	headWeld.Name = "HeadWeld";
	headWeld.Part0 = handle;
	headWeld.Part1 = head;
	headWeld.Parent = head;
	local glow = Instance.new("PointLight");
	glow.Name = "BlueGlow";
	glow.Color = head.Color;
	glow.Brightness = 0.8;
	glow.Range = 7;
	glow.Shadows = false;
	glow.Parent = head;
	tool.Grip = CFrame.new(0, -1.05, 0);
	tool.Parent = backpack;
	if humanoid then
		humanoid:EquipTool(tool);
	end
	notify("Blue Hammer", "Added to your Backpack and equipped.");
end
local function removeBlueHammer()
	local removed = 0;
	local containers = {LocalPlayer.Character,LocalPlayer:FindFirstChildOfClass("Backpack")};
	for _, container in ipairs(containers) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				if (child:IsA("Tool") and ((child.Name == BLUE_HAMMER_NAME) or child:GetAttribute(BLUE_HAMMER_MARKER))) then
					child:Destroy();
					removed = removed + 1;
				end
			end
		end
	end
	notify("Blue Hammer", ((removed > 0) and "Removed from your inventory.") or "No blue hammer was found.");
end
local function trim(value)
	return tostring(value or ""):match("^%s*(.-)%s*$");
end
local function resolvePlayer(query)
	query = string.lower(trim(query));
	if (query == "") then
		return nil;
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if ((string.lower(player.Name) == query) or (string.lower(player.DisplayName) == query)) then
			return player;
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if ((string.sub(string.lower(player.Name), 1, #query) == query) or (string.sub(string.lower(player.DisplayName), 1, #query) == query)) then
			return player;
		end
	end
	return nil;
end
local function getRootPart(player)
	local character = player and player.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	local root = character and character:FindFirstChild("HumanoidRootPart");
	if (humanoid and (humanoid.Health > 0) and root and root:IsA("BasePart")) then
		return root;
	end
	return nil;
end
local function getTargetTorso(player)
	local character = player and player.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	if (not humanoid or (humanoid.Health <= 0)) then
		return nil;
	end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart");
	if (torso and torso:IsA("BasePart")) then
		return torso;
	end
	return nil;
end
local function resolveTarget(showNotification)
	state.targetText = TargetField.TextBox.Text;
	local player = resolvePlayer(state.targetText);
	state.target = player;
	if player then
		TargetStatus:Set(player.DisplayName .. " (@" .. player.Name .. ")", true);
		if showNotification then
			notify("Target Found", player.DisplayName .. " (@" .. player.Name .. ")");
		end
		return player;
	end
	TargetStatus:Set("No matching player", true);
	if showNotification then
		notify("Target", "No player matched that username or display name.");
	end
	return nil;
end
local function clearFlyMovers()
	if state.flyVelocity then
		state.flyVelocity:Destroy();
		state.flyVelocity = nil;
	end
	if state.flyGyro then
		state.flyGyro:Destroy();
		state.flyGyro = nil;
	end
	state.flyCharacter = nil;
end
local function stopFly(showNotification)
	state.flyEnabled = false;
	clearFlyMovers();
	local character = LocalPlayer.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	if humanoid then
		humanoid.PlatformStand = false;
		humanoid.AutoRotate = true;
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp);
	end
	if showNotification then
		notify("Fly", "Disabled");
	end
end
local function createFlyMovers()
	local character = LocalPlayer.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	local root = character and character:FindFirstChild("HumanoidRootPart");
	if (not humanoid or (humanoid.Health <= 0) or not root) then
		return false;
	end
	clearFlyMovers();
	local velocity = Instance.new("BodyVelocity");
	velocity.Name = "ZenthraFlyVelocity";
	velocity.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000);
	velocity.P = 20000;
	velocity.Velocity = Vector3.zero;
	velocity.Parent = root;
	local gyro = Instance.new("BodyGyro");
	gyro.Name = "ZenthraFlyGyro";
	gyro.MaxTorque = Vector3.new(1000000000, 1000000000, 1000000000);
	gyro.P = 30000;
	gyro.D = 650;
	gyro.CFrame = root.CFrame;
	gyro.Parent = root;
	humanoid.PlatformStand = true;
	humanoid.AutoRotate = false;
	state.flyVelocity = velocity;
	state.flyGyro = gyro;
	state.flyCharacter = character;
	return true;
end
local function startFly(showNotification)
	state.flyEnabled = true;
	if not createFlyMovers() then
		state.flyEnabled = false;
		if showNotification then
			notify("Fly", "Your living character is not available.");
		end
		return false;
	end
	if showNotification then
		notify("Fly", "Enabled - use WASD, Space, and LeftCtrl.");
	end
	return true;
end
local function updateFly()
	if not state.flyEnabled then
		return;
	end
	local character = LocalPlayer.Character;
	local root = character and character:FindFirstChild("HumanoidRootPart");
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	if (not root or not humanoid or (humanoid.Health <= 0)) then
		clearFlyMovers();
		return;
	end
	if ((state.flyCharacter ~= character) or not state.flyVelocity or not state.flyVelocity.Parent) then
		if not createFlyMovers() then
			return;
		end
	end
	local camera = workspace.CurrentCamera;
	if not camera then
		return;
	end
	local direction = Vector3.zero;
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		direction = direction + camera.CFrame.LookVector;
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		direction = direction - camera.CFrame.LookVector;
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		direction = direction + camera.CFrame.RightVector;
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		direction = direction - camera.CFrame.RightVector;
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		direction = direction + Vector3.yAxis;
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		direction = direction - Vector3.yAxis;
	end
	if (direction.Magnitude > 1) then
		direction = direction.Unit;
	end
	state.flyVelocity.Velocity = direction * state.flySpeed;
	state.flyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector, camera.CFrame.UpVector);
	humanoid.PlatformStand = true;
end
local function saveSimulationRadius()
	if (state.savedSimulationRadius ~= nil) then
		return;
	end
	if (type(gethiddenproperty) == "function") then
		local okRadius, radius = pcall(gethiddenproperty, LocalPlayer, "SimulationRadius");
		local okMax, maxRadius = pcall(gethiddenproperty, LocalPlayer, "MaximumSimulationRadius");
		if okRadius then
			state.savedSimulationRadius = radius;
		end
		if okMax then
			state.savedMaxSimulationRadius = maxRadius;
		end
	end
end
local function expandSimulationRadius()
	saveSimulationRadius();
	if (type(sethiddenproperty) ~= "function") then
		return false;
	end
	local requestedRadius = 1000;
	local okRadius = pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", requestedRadius);
	local okMax = pcall(sethiddenproperty, LocalPlayer, "MaximumSimulationRadius", requestedRadius);
	return okRadius or okMax;
end
local function restoreSimulationRadius()
	if (type(sethiddenproperty) ~= "function") then
		return;
	end
	if (state.savedSimulationRadius ~= nil) then
		pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", state.savedSimulationRadius);
	end
	if (state.savedMaxSimulationRadius ~= nil) then
		pcall(sethiddenproperty, LocalPlayer, "MaximumSimulationRadius", state.savedMaxSimulationRadius);
	end
end
local function isOwned(part)
	if (type(isnetworkowner) ~= "function") then
		return true;
	end
	local ok, owned = pcall(isnetworkowner, part);
	return ok and (owned == true);
end
local function scanAssemblies()
	local structure = workspace:FindFirstChild("Structure");
	if not structure then
		state.roots = {};
		return 0, 0;
	end
	local unique = {};
	local weldedRoots = {};
	local roots = {};
	local partCount = 0;
	for _, part in ipairs(structure:QueryDescendants("BasePart[Anchored = false]")) do
		partCount = partCount + 1;
		local root = part.AssemblyRootPart or part;
		if (root and root:IsDescendantOf(structure) and not root.Anchored and not unique[root]) then
			unique[root] = true;
			table.insert(roots, root);
			if (state.originalCFrames[root] == nil) then
				state.originalCFrames[root] = root.CFrame;
			end
		elseif (root and root.Anchored) then
			weldedRoots[root] = true;
		end
	end
	for root in pairs(state.frozenCFrames) do
		if (root.Parent and root:IsDescendantOf(structure) and not unique[root]) then
			unique[root] = true;
			table.insert(roots, root);
		end
	end
	state.roots = roots;
	state.welded = 0;
	for _ in pairs(weldedRoots) do
		state.welded = state.welded + 1;
	end
	return partCount, #roots;
end
local function zeroMotion(root)
	root.AssemblyLinearVelocity = Vector3.zero;
	root.AssemblyAngularVelocity = Vector3.zero;
end
local function disableAssemblyCollision(root)
	local ok, connected = pcall(root.GetConnectedParts, root, true);
	if not ok then
		connected = {root};
	end
	for _, part in ipairs(connected) do
		if (part:IsA("BasePart") and (state.partCanCollide[part] == nil)) then
			state.partCanCollide[part] = part.CanCollide;
			part.CanCollide = false;
		end
	end
end
local function restorePartCollision()
	for part, canCollide in pairs(state.partCanCollide) do
		if part.Parent then
			part.CanCollide = canCollide;
		end
	end
	table.clear(state.partCanCollide);
end
local function setLayoutCollision(root, enabled)
	local ok, connected = pcall(root.GetConnectedParts, root, true);
	if not ok then
		connected = {root};
	end
	for _, part in ipairs(connected) do
		if part:IsA("BasePart") then
			if (state.layoutCanCollide[part] == nil) then
				state.layoutCanCollide[part] = part.CanCollide;
			end
			part.CanCollide = enabled and (((state.layoutKind ~= "elevator") and (state.layoutKind ~= "yard")) or (part == root));
			if ((state.layoutKind == "platform") or (state.layoutKind == "yard")) then
				if (state.layoutAppearance[part] == nil) then
					state.layoutAppearance[part] = {Material=part.Material,Color=part.Color};
				end
				if (state.layoutKind == "yard") then
					local isFence = state.yardFenceRoots[root] == true;
					part.Material = (isFence and Enum.Material.WoodPlanks) or Enum.Material.Grass;
					part.Color = (isFence and Color3.fromRGB(116, 78, 48)) or Color3.fromRGB(82, 142, 70);
				else
					part.Material = Enum.Material.Concrete;
					part.Color = Color3.fromRGB(135, 135, 140);
				end
			end
		end
	end
end
local function restoreLayoutCollision()
	for part, canCollide in pairs(state.layoutCanCollide) do
		if part.Parent then
			part.CanCollide = canCollide;
		end
	end
	table.clear(state.layoutCanCollide);
	for part, appearance in pairs(state.layoutAppearance) do
		if part.Parent then
			part.Material = appearance.Material;
			part.Color = appearance.Color;
		end
	end
	table.clear(state.layoutAppearance);
end
local function restoreAntiFlingCollision()
	for part, canCollide in pairs(state.antiFlingCanCollide) do
		if part.Parent then
			part.CanCollide = canCollide;
		end
	end
	table.clear(state.antiFlingCanCollide);
end
local function applyAntiFling(now)
	local character = LocalPlayer.Character;
	local humanoid = character and character:FindFirstChildOfClass("Humanoid");
	local root = character and character:FindFirstChild("HumanoidRootPart");
	if (not humanoid or (humanoid.Health <= 0) or not root) then
		state.safeCFrame = nil;
		return;
	end
	local linearSpeed = root.AssemblyLinearVelocity.Magnitude;
	local angularSpeed = root.AssemblyAngularVelocity.Magnitude;
	if state.flyEnabled then
		state.safeCFrame = root.CFrame;
		state.lastSafeUpdate = now;
	elseif ((linearSpeed < 45) and (angularSpeed < 25) and ((now - state.lastSafeUpdate) >= 0.15)) then
		state.safeCFrame = root.CFrame;
		state.lastSafeUpdate = now;
	elseif ((linearSpeed > 95) or (angularSpeed > 55)) then
		for _, part in ipairs(character:QueryDescendants("BasePart")) do
			part.AssemblyLinearVelocity = Vector3.zero;
			part.AssemblyAngularVelocity = Vector3.zero;
		end
		if state.safeCFrame then
			root.CFrame = state.safeCFrame;
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if ((player ~= LocalPlayer) and player.Character) then
			for _, part in ipairs(player.Character:QueryDescendants("BasePart")) do
				if (state.antiFlingCanCollide[part] == nil) then
					state.antiFlingCanCollide[part] = part.CanCollide;
				end
				part.CanCollide = false;
			end
		end
	end
end
local function driveRoot(root, desiredCFrame)
	disableAssemblyCollision(root);
	root.CFrame = desiredCFrame;
	root.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0);
	root.AssemblyAngularVelocity = Vector3.zero;
end
local function placementOffset(index)
	local zeroIndex = index - 1;
	local angle = zeroIndex * 2.399963229728653;
	local radius = math.min(12, math.sqrt(zeroIndex) * 1.5);
	local height = state.verticalOffset + ((zeroIndex % 4) * 1.5);
	return CFrame.new(math.cos(angle) * radius, height, math.sin(angle) * radius);
end
local function updateStatus(partCount, rootCount)
	local mode;
	if state.placingMode then
		mode = string.upper(state.placingMode) .. " PREVIEW";
	elseif state.layoutActive then
		if (state.layoutKind == "elevator") then
			local targetY = (state.elevatorRaised and state.elevatorHeight) or 0;
			if (math.abs(state.elevatorCurrentY - targetY) <= 0.1) then
				mode = (state.elevatorRaised and "ELEVATOR TOP") or "ELEVATOR BOTTOM";
			else
				mode = (state.elevatorRaised and "ELEVATOR RISING") or "ELEVATOR LOWERING";
			end
		elseif (state.layoutKind == "yard") then
			mode = ((state.yardDriveEnabled or state.yardRise or state.yardLower or (state.yardVelocity.Magnitude > 0.1)) and "YARD MOVING") or "YARD HOLD";
		else
			mode = string.upper(state.layoutKind or "BUILD");
		end
	elseif state.meteorActive then
		if state.meteorImpactTorso then
			mode = "METEOR IMPACT";
		elseif state.meteorThrown then
			mode = "METEOR THROWN";
		else
			mode = "SUMMONING METEOR";
		end
	elseif state.bringing then
		local remaining = math.max(0, math.ceil(state.bringDelay - (os.clock() - state.bringStartTime)));
		mode = ((remaining > 0) and ("COLLECTING " .. remaining .. "s")) or "TORSO SPIN";
	elseif state.orbiting then
		mode = "ORBITING";
	elseif state.freezing then
		mode = "FROZEN";
	else
		mode = "STOPPED";
	end
	PartStatus:Set(string.format("%s | %d parts | %d movable | %d moved | %d waiting | %d welded", mode, partCount or 0, rootCount or #state.roots, state.moved, state.unowned, state.welded), true);
end
local function stopBringing(showNotification)
	state.bringing = false;
	state.bringStartTime = 0;
	state.bringSpinAngle = 0;
	for _, root in ipairs(state.roots) do
		if (root.Parent and isOwned(root)) then
			pcall(zeroMotion, root);
		end
	end
	restorePartCollision();
	state.moved = 0;
	state.unowned = 0;
	if not state.freezing then
		restoreSimulationRadius();
	end
	if showNotification then
		notify("Part Control", "Bringing stopped; parts were released in place.");
	end
end
local function stopOrbiting(showNotification)
	state.orbiting = false;
	for _, root in ipairs(state.roots) do
		if (root.Parent and isOwned(root)) then
			pcall(zeroMotion, root);
		end
	end
	restorePartCollision();
	state.moved = 0;
	state.unowned = 0;
	if (not state.bringing and not state.freezing) then
		restoreSimulationRadius();
	end
	if showNotification then
		notify("Circle Parts", "Orbit stopped and controlled parts were released.");
	end
end
local function destroyPreview()
	if state.previewFolder then
		state.previewFolder:Destroy();
		state.previewFolder = nil;
	end
	if (Mouse.TargetFilter and (Mouse.TargetFilter.Name == "__ZenthraNDSPlacementPreview")) then
		Mouse.TargetFilter = state.previousMouseTargetFilter;
	end
	state.previousMouseTargetFilter = nil;
end
local function createGhostPart(parent, size, cframe)
	local part = Instance.new("Part");
	part.Name = "PlacementGhost";
	part.Anchored = true;
	part.CanCollide = false;
	part.CanTouch = false;
	part.CanQuery = false;
	part.CastShadow = false;
	part.Material = Enum.Material.Neon;
	part.Color = Color3.fromRGB(99, 220, 255);
	part.Transparency = 0.62;
	part.Size = size;
	part.CFrame = cframe;
	part.Parent = parent;
	return part;
end
local function renderPlacementPreview()
	destroyPreview();
	if (not state.placingMode or not state.placementCFrame) then
		return;
	end
	local folder = Instance.new("Folder");
	folder.Name = "__ZenthraNDSPlacementPreview";
	folder.Parent = workspace;
	state.previewFolder = folder;
	state.previousMouseTargetFilter = Mouse.TargetFilter;
	Mouse.TargetFilter = folder;
	if (state.placingMode == "stairs") then
		for step = 0, 31 do
			local desired = state.placementCFrame * CFrame.new(0, step * 6, -step * 5);
			createGhostPart(folder, Vector3.new(16, 1, 5), desired);
		end
	elseif (state.placingMode == "elevator") then
		createGhostPart(folder, Vector3.new(50, 1, 50), state.placementCFrame);
	elseif (state.placingMode == "yard") then
		local tileIndex = 0;
		for row = -2, 2 do
			for column = -2, 2 do
				tileIndex = tileIndex + 1;
				local offset = CFrame.new(column * 12, 0, row * 12);
				local ghost = createGhostPart(folder, Vector3.new(11.6, 1, 11.6), state.placementCFrame * offset);
				ghost.Name = "YardTileGhost" .. tileIndex;
				ghost:SetAttribute("YardOffset", offset);
			end
		end
		local fences = {{Vector3.new(60, 4, 2),CFrame.new(0, 2.5, -30)},{Vector3.new(60, 4, 2),CFrame.new(0, 2.5, 30)},{Vector3.new(2, 4, 60),CFrame.new(-30, 2.5, 0)},{Vector3.new(2, 4, 60),CFrame.new(30, 2.5, 0)}};
		for index, definition in ipairs(fences) do
			local ghost = createGhostPart(folder, definition[1], state.placementCFrame * definition[2]);
			ghost.Name = "YardFenceGhost" .. index;
			ghost.Color = Color3.fromRGB(226, 184, 115);
			ghost:SetAttribute("YardOffset", definition[2]);
		end
	else
		createGhostPart(folder, Vector3.new(100, 1, 100), state.placementCFrame);
	end
end
local function updatePlacementFromMouse()
	if (not state.placingMode or not state.placementCFrame) then
		return;
	end
	local localRoot = getRootPart(LocalPlayer);
	if not localRoot then
		return;
	end
	local hitPosition = Mouse.Hit.Position;
	local flatOffset = Vector3.new(hitPosition.X - localRoot.Position.X, 0, hitPosition.Z - localRoot.Position.Z);
	if (flatOffset.Magnitude > 450) then
		flatOffset = flatOffset.Unit * 450;
	end
	local position = Vector3.new(localRoot.Position.X + flatOffset.X, state.placementGroundY + state.placementHeight, localRoot.Position.Z + flatOffset.Z);
	local forward = state.placementCFrame.LookVector;
	state.placementCFrame = CFrame.lookAt(position, position + Vector3.new(forward.X, 0, forward.Z));
	if state.previewFolder then
		if (state.placingMode == "stairs") then
			local step = 0;
			for _, ghost in ipairs(state.previewFolder:GetChildren()) do
				ghost.CFrame = state.placementCFrame * CFrame.new(0, step * 6, -step * 5);
				step = step + 1;
			end
		elseif (state.placingMode == "yard") then
			for _, ghost in ipairs(state.previewFolder:GetChildren()) do
				local offset = ghost:GetAttribute("YardOffset");
				if offset then
					ghost.CFrame = state.placementCFrame * offset;
				end
			end
		else
			local ghost = state.previewFolder:FindFirstChild("PlacementGhost");
			if ghost then
				ghost.CFrame = state.placementCFrame;
			end
		end
	end
end
function stopPlacement(showNotification)
	local wasPlacing = state.placingMode ~= nil;
	state.placingMode = nil;
	state.placementDragging = false;
	destroyPreview();
	if (showNotification and wasPlacing) then
		notify("Placement", "Preview cancelled; no map assemblies were moved.");
	end
end
local function resetSummonArm()
	if (state.shoulderMotor and state.shoulderMotor.Parent and state.shoulderTransform) then
		state.shoulderMotor.Transform = state.shoulderTransform;
	end
	state.shoulderMotor = nil;
	state.shoulderTransform = nil;
end
local function beginSummonArm()
	resetSummonArm();
	local character = LocalPlayer.Character;
	local shoulder = character and character:FindFirstChild("RightShoulder", true);
	if (shoulder and shoulder:IsA("Motor6D")) then
		state.shoulderMotor = shoulder;
		state.shoulderTransform = shoulder.Transform;
	end
end
function stopLayout(showNotification)
	local wasActive = state.layoutActive;
	local wasElevator = state.layoutKind == "elevator";
	local wasYard = state.layoutKind == "yard";
	state.layoutActive = false;
	state.layoutKind = nil;
	state.layoutBase = nil;
	state.layoutAccumulator = 0;
	state.elevatorRaised = false;
	state.elevatorCurrentY = 0;
	state.yardCFrame = nil;
	state.yardDriveEnabled = false;
	state.yardRise = false;
	state.yardLower = false;
	state.yardVelocity = Vector3.zero;
	state.yardButtonVector = Vector3.zero;
	state.yardButtonUntil = 0;
	if ElevatorLiftToggle then
		ElevatorLiftToggle:Set(false, true);
	end
	if YardDriveToggle then
		YardDriveToggle:Set(false, true);
	end
	if YardRiseToggle then
		YardRiseToggle:Set(false, true);
	end
	if YardLowerToggle then
		YardLowerToggle:Set(false, true);
	end
	for root in pairs(state.layoutAnchored) do
		if (root.Parent and isOwned(root)) then
			pcall(zeroMotion, root);
		end
		state.frozenCFrames[root] = nil;
	end
	table.clear(state.layoutAnchored);
	table.clear(state.layoutCFrames);
	table.clear(state.yardFenceRoots);
	table.clear(state.yardRoots);
	restoreLayoutCollision();
	state.freezing = next(state.frozenCFrames) ~= nil;
	if (not state.bringing and not state.orbiting and not state.meteorActive and not state.freezing) then
		restoreSimulationRadius();
	end
	if (showNotification and wasActive) then
		local stoppedName = (wasElevator and "Elevator") or (wasYard and "Yard") or "Stairs/platform";
		notify("Build Mode", stoppedName .. " stopped and assemblies were released.");
	end
end
function stopMeteor(showNotification)
	local wasActive = state.meteorActive;
	state.meteorActive = false;
	state.meteorThrown = false;
	state.meteorImpactTorso = nil;
	state.meteorCenter = nil;
	state.meteorDirection = Vector3.zero;
	state.meteorAccumulator = 0;
	resetSummonArm();
	restorePartCollision();
	if (not state.bringing and not state.orbiting and not state.layoutActive and not state.freezing) then
		restoreSimulationRadius();
	end
	if (showNotification and wasActive) then
		notify("Meteor", "Meteor stopped and controlled assemblies were released.");
	end
end
local function startPlacement(mode)
	if not getRootPart(LocalPlayer) then
		notify("Placement", "Your character is not available.");
		return;
	end
	if BringToggle then
		BringToggle:Set(false, true);
	end
	if OrbitToggle then
		OrbitToggle:Set(false, true);
	end
	if MeteorToggle then
		MeteorToggle:Set(false, true);
	end
	stopBringing(false);
	stopOrbiting(false);
	stopMeteor(false);
	stopLayout(false);
	stopPlacement(false);
	local root = getRootPart(LocalPlayer);
	local look = workspace.CurrentCamera.CFrame.LookVector;
	look = Vector3.new(look.X, 0, look.Z);
	if (look.Magnitude < 0.01) then
		look = Vector3.new(0, 0, -1);
	else
		look = look.Unit;
	end
	local position = (root.Position + (look * 30)) - Vector3.new(0, 3, 0);
	state.placingMode = mode;
	state.placementGroundY = position.Y;
	state.placementHeight = 0;
	state.placementCFrame = CFrame.lookAt(position, position + look);
	renderPlacementPreview();
	local previewName = ((mode == "stairs") and "Stairs Preview") or ((mode == "elevator") and "Elevator Preview") or ((mode == "yard") and "Yard Preview") or "Platform Preview";
	notify(previewName, "Hold left mouse and drag. Use E/Q or the wheel for up/down, then press Done.");
end
local function yardDeckCount(count)
	if (count < 12) then
		return math.max(1, count - math.max(1, math.floor(count * 0.18)));
	end
	return math.max(1, count - math.max(4, math.floor(count * 0.2)));
end
local function yardIsFenceIndex(index, count)
	return index > yardDeckCount(count);
end
local function layoutCFrame(kind, base, index, count)
	local zeroIndex = index - 1;
	if (kind == "stairs") then
		local steps = math.clamp(math.ceil(math.sqrt(count) * 3), 18, 36);
		local lanes = math.max(1, math.ceil(count / steps));
		local step = zeroIndex % steps;
		local lane = math.floor(zeroIndex / steps);
		local x = (lane - ((lanes - 1) / 2)) * 6;
		return base * CFrame.new(x, step * 6, -step * 5);
	end
	if (kind == "elevator") then
		local columns = math.max(1, math.ceil(math.sqrt(count)));
		local rows = math.max(1, math.ceil(count / columns));
		local column = zeroIndex % columns;
		local row = math.floor(zeroIndex / columns);
		local spacingX = ((columns <= 1) and 0) or math.clamp(48 / (columns - 1), 5, 10);
		local spacingZ = ((rows <= 1) and 0) or math.clamp(48 / (rows - 1), 5, 10);
		local x = (column - ((columns - 1) / 2)) * spacingX;
		local z = (row - ((rows - 1) / 2)) * spacingZ;
		return base * CFrame.new(x, 0, z);
	end
	if (kind == "yard") then
		local deckCount = yardDeckCount(count);
		if (index <= deckCount) then
			local columns = math.max(1, math.ceil(math.sqrt(deckCount)));
			local rows = math.max(1, math.ceil(deckCount / columns));
			local zeroDeck = index - 1;
			local column = zeroDeck % columns;
			local row = math.floor(zeroDeck / columns);
			local spacingX = ((columns <= 1) and 0) or math.clamp(56 / (columns - 1), 5, 8);
			local spacingZ = ((rows <= 1) and 0) or math.clamp(56 / (rows - 1), 5, 8);
			local x = (column - ((columns - 1) / 2)) * spacingX;
			local z = (row - ((rows - 1) / 2)) * spacingZ;
			return base * CFrame.new(x, 0, z);
		end
		local fenceCount = math.max(1, count - deckCount);
		local fenceIndex = (index - deckCount) - 1;
		local perimeter = (fenceIndex / fenceCount) * 4;
		local side = math.floor(perimeter) % 4;
		local alpha = perimeter - math.floor(perimeter);
		local coordinate = -28 + (alpha * 56);
		if (side == 0) then
			return base * CFrame.new(coordinate, 2.5, -29);
		end
		if (side == 1) then
			return base * CFrame.new(29, 2.5, coordinate) * CFrame.Angles(0, math.rad(90), 0);
		end
		if (side == 2) then
			return base * CFrame.new(-coordinate, 2.5, 29);
		end
		return base * CFrame.new(-29, 2.5, -coordinate) * CFrame.Angles(0, math.rad(90), 0);
	end
	local columns = math.max(1, math.ceil(math.sqrt(count)));
	local rows = math.max(1, math.ceil(count / columns));
	local column = zeroIndex % columns;
	local row = math.floor(zeroIndex / columns);
	local x = (column - ((columns - 1) / 2)) * 9;
	local z = (row - ((rows - 1) / 2)) * 9;
	return base * CFrame.new(x, 0, z);
end
local function commitPlacement()
	if (not state.placingMode or not state.placementCFrame) then
		notify("Placement", "Choose Stairs, Platform, Elevator, or Yard and position the preview first.");
		return;
	end
	stopLayout(false);
	if not expandSimulationRadius() then
		notify("Placement", "This executor cannot expand physics ownership.");
		return;
	end
	scanAssemblies();
	if (#state.roots == 0) then
		notify("Placement", "No unanchored assemblies are available on this map.");
		return;
	end
	local kind = state.placingMode;
	local base = state.placementCFrame;
	state.layoutKind = kind;
	state.layoutBase = base;
	state.layoutActive = true;
	state.layoutStarted = os.clock();
	state.layoutAccumulator = 0;
	state.elevatorRaised = false;
	state.elevatorCurrentY = 0;
	state.yardCFrame = ((kind == "yard") and base) or nil;
	state.yardHomeY = base.Position.Y;
	state.yardDriveEnabled = false;
	state.yardRise = false;
	state.yardLower = false;
	state.yardVelocity = Vector3.zero;
	state.yardButtonVector = Vector3.zero;
	state.yardButtonUntil = 0;
	if ElevatorLiftToggle then
		ElevatorLiftToggle:Set(false, true);
	end
	if YardDriveToggle then
		YardDriveToggle:Set(false, true);
	end
	if YardRiseToggle then
		YardRiseToggle:Set(false, true);
	end
	if YardLowerToggle then
		YardLowerToggle:Set(false, true);
	end
	state.moved = 0;
	state.unowned = #state.roots;
	table.clear(state.yardFenceRoots);
	if (kind == "yard") then
		state.yardRoots = table.clone(state.roots);
	else
		table.clear(state.yardRoots);
	end
	local layoutRoots = ((kind == "yard") and state.yardRoots) or state.roots;
	for index, root in ipairs(layoutRoots) do
		state.layoutCFrames[root] = layoutCFrame(kind, base, index, #layoutRoots);
		if ((kind == "yard") and yardIsFenceIndex(index, #layoutRoots)) then
			state.yardFenceRoots[root] = true;
		end
	end
	stopPlacement(false);
	local buildName = ((kind == "stairs") and "Building Stairs") or ((kind == "elevator") and "Building Elevator") or ((kind == "yard") and "Building Yard") or "Building Platform";
	notify(buildName, string.format("Holding owned assemblies with live physics so other players can see them. %d assemblies are queued; server-owned pieces remain waiting.", #state.roots));
end
local function startMeteor()
	local root = getRootPart(LocalPlayer);
	if not root then
		notify("Meteor", "Your character is not available.");
		return false;
	end
	if BringToggle then
		BringToggle:Set(false, true);
	end
	if OrbitToggle then
		OrbitToggle:Set(false, true);
	end
	stopBringing(false);
	stopOrbiting(false);
	stopPlacement(false);
	stopLayout(false);
	if not expandSimulationRadius() then
		notify("Meteor", "This executor cannot expand physics ownership.");
		return false;
	end
	scanAssemblies();
	if (#state.roots == 0) then
		notify("Meteor", "No unanchored assemblies are available.");
		return false;
	end
	state.meteorActive = true;
	state.meteorThrown = false;
	state.meteorImpactTorso = nil;
	state.meteorCenter = root.Position + Vector3.new(0, state.meteorHeight, 0);
	state.meteorDirection = Vector3.zero;
	state.meteorThrowStarted = 0;
	state.meteorAngle = 0;
	state.meteorAccumulator = 0;
	state.summonStarted = os.clock();
	state.moved = 0;
	state.unowned = 0;
	beginSummonArm();
	notify("Meteor", "Summoning above your head. Double-click the world to throw it.");
	return true;
end
local function throwMeteor()
	if (not state.meteorActive or state.meteorThrown) then
		return;
	end
	local root = getRootPart(LocalPlayer);
	if not root then
		return;
	end
	local center = state.meteorCenter or (root.Position + Vector3.new(0, state.meteorHeight, 0));
	local direction = Mouse.Hit.Position - center;
	if (direction.Magnitude < 5) then
		direction = workspace.CurrentCamera.CFrame.LookVector;
	else
		direction = direction.Unit;
	end
	state.meteorCenter = center;
	state.meteorDirection = direction;
	state.meteorThrowStarted = os.clock();
	state.meteorThrown = true;
	state.meteorImpactTorso = nil;
	resetSummonArm();
	notify("Meteor", "Meteor thrown. Nearby player torsos trigger the impact orbit.");
end
function stopAllPartModes(showNotification)
	if BringToggle then
		BringToggle:Set(false, true);
	end
	if OrbitToggle then
		OrbitToggle:Set(false, true);
	end
	if MeteorToggle then
		MeteorToggle:Set(false, true);
	end
	if ElevatorLiftToggle then
		ElevatorLiftToggle:Set(false, true);
	end
	if YardDriveToggle then
		YardDriveToggle:Set(false, true);
	end
	if YardRiseToggle then
		YardRiseToggle:Set(false, true);
	end
	if YardLowerToggle then
		YardLowerToggle:Set(false, true);
	end
	stopPlacement(false);
	stopMeteor(false);
	stopLayout(false);
	stopOrbiting(false);
	stopBringing(false);
	for root in pairs(state.frozenCFrames) do
		if root.Parent then
			root.Anchored = false;
			pcall(zeroMotion, root);
		end
	end
	table.clear(state.frozenCFrames);
	state.freezing = false;
	restorePartCollision();
	restoreLayoutCollision();
	restoreSimulationRadius();
	state.moved = 0;
	state.unowned = 0;
	if showNotification then
		notify("Stop All", "All part, build, elevator, yard, preview, and meteor modes are stopped.");
	end
end
local function updateLayout(deltaTime)
	state.layoutAccumulator = state.layoutAccumulator + deltaTime;
	if (state.layoutAccumulator < (1 / 30)) then
		return;
	end
	local step = math.min(state.layoutAccumulator, 0.1);
	state.layoutAccumulator = 0;
	local assemblyVelocity = Vector3.new(0, 0.08, 0);
	if ((state.layoutKind == "elevator") and state.layoutBase) then
		local targetY = (state.elevatorRaised and state.elevatorHeight) or 0;
		local difference = targetY - state.elevatorCurrentY;
		local movement = 0;
		if (math.abs(difference) > 0.01) then
			movement = math.sign(difference) * math.min(math.abs(difference), state.elevatorSpeed * step);
			state.elevatorCurrentY = state.elevatorCurrentY + movement;
		else
			state.elevatorCurrentY = targetY;
		end
		local verticalVelocity = ((math.abs(movement) > 0) and (movement / math.max(step, 1 / 240))) or 0.08;
		assemblyVelocity = Vector3.new(0, verticalVelocity, 0);
		local movingBase = state.layoutBase * CFrame.new(0, state.elevatorCurrentY, 0);
		table.clear(state.layoutCFrames);
		for index, root in ipairs(state.roots) do
			state.layoutCFrames[root] = layoutCFrame("elevator", movingBase, index, math.max(#state.roots, 1));
		end
	elseif ((state.layoutKind == "yard") and state.yardCFrame) then
		local currentCFrame = state.yardCFrame;
		local moveX, moveZ, moveY = 0, 0, 0;
		if (state.yardDriveEnabled and not UserInputService:GetFocusedTextBox()) then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveZ = moveZ - 1;
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveZ = moveZ + 1;
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveX = moveX - 1;
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveX = moveX + 1;
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveY = moveY + 1;
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				moveY = moveY - 1;
			end
		end
		if (os.clock() < state.yardButtonUntil) then
			moveX = moveX + state.yardButtonVector.X;
			moveZ = moveZ + state.yardButtonVector.Z;
		else
			state.yardButtonVector = Vector3.zero;
		end
		local currentHeight = currentCFrame.Position.Y - state.yardHomeY;
		if (state.yardRise and (currentHeight >= (state.yardLiftHeight - 0.05))) then
			state.yardRise = false;
			if YardRiseToggle then
				YardRiseToggle:Set(false, true);
			end
		end
		if (state.yardLower and (currentHeight <= 0.05)) then
			state.yardLower = false;
			if YardLowerToggle then
				YardLowerToggle:Set(false, true);
			end
		end
		if (state.yardRise and (currentHeight < (state.yardLiftHeight - 0.05))) then
			moveY = moveY + 1;
		end
		if (state.yardLower and (currentHeight > 0.05)) then
			moveY = moveY - 1;
		end
		local horizontal = Vector2.new(moveX, moveZ);
		if (horizontal.Magnitude > 1) then
			horizontal = horizontal.Unit;
		end
		local localHorizontal = Vector3.new(horizontal.X * state.yardMoveSpeed, 0, horizontal.Y * state.yardMoveSpeed);
		local desiredVelocity = currentCFrame:VectorToWorldSpace(localHorizontal) + Vector3.new(0, math.clamp(moveY, -1, 1) * state.yardVerticalSpeed, 0);
		local response = 1 - math.exp(-state.yardSmoothness * step);
		state.yardVelocity = state.yardVelocity:Lerp(desiredVelocity, response);
		if ((desiredVelocity.Magnitude < 0.01) and (state.yardVelocity.Magnitude < 0.05)) then
			state.yardVelocity = Vector3.zero;
		end
		local delta = state.yardVelocity * step;
		local nextY = math.clamp(currentCFrame.Position.Y + delta.Y, state.yardHomeY, state.yardHomeY + state.yardLiftHeight);
		delta = Vector3.new(delta.X, nextY - currentCFrame.Position.Y, delta.Z);
		if ((math.abs(delta.Y) < 0.0001) and (math.abs(state.yardVelocity.Y) > 0)) then
			state.yardVelocity = Vector3.new(state.yardVelocity.X, 0, state.yardVelocity.Z);
		end
		state.yardCFrame = CFrame.new(delta) * currentCFrame;
		assemblyVelocity = ((state.yardVelocity.Magnitude > 0.01) and state.yardVelocity) or Vector3.new(0, 0.08, 0);
		table.clear(state.layoutCFrames);
		table.clear(state.yardFenceRoots);
		for index, root in ipairs(state.yardRoots) do
			state.layoutCFrames[root] = layoutCFrame("yard", state.yardCFrame, index, math.max(#state.yardRoots, 1));
			if yardIsFenceIndex(index, #state.yardRoots) then
				state.yardFenceRoots[root] = true;
			end
		end
	end
	local moved = 0;
	local unowned = 0;
	for root, desired in pairs(state.layoutCFrames) do
		if root.Parent then
			if isOwned(root) then
				if root.Anchored then
					root.Anchored = false;
				end
				setLayoutCollision(root, true);
				root.CFrame = desired;
				root.AssemblyLinearVelocity = assemblyVelocity;
				root.AssemblyAngularVelocity = Vector3.zero;
				state.layoutAnchored[root] = true;
				moved = moved + 1;
			else
				unowned = unowned + 1;
			end
		end
	end
	state.freezing = false;
	state.moved = moved;
	state.unowned = unowned;
end
local function startYardDirection(localDirection, label)
	if (not state.layoutActive or (state.layoutKind ~= "yard") or not state.yardCFrame) then
		notify("Yard", "Place Yard - Drag Preview and press DONE first.");
		return false;
	end
	state.yardButtonVector = localDirection;
	state.yardButtonUntil = os.clock() + (state.yardNudgeDistance / math.max(state.yardMoveSpeed, 1));
	notify("Yard", label .. " Smooth movement started.");
	return true;
end
local function sphereOffset(index, count, radius, spinAngle)
	local sample = (index - 0.5) / math.max(count, 1);
	local y = 1 - (sample * 2);
	local ring = math.sqrt(math.max(0, 1 - (y * y)));
	local angle = (index * 2.399963229728653) + spinAngle;
	return Vector3.new(math.cos(angle) * ring * radius, y * radius, math.sin(angle) * ring * radius);
end
local function findMeteorHit(center)
	local nearestTorso;
	local nearestDistance = state.meteorRadius + 7;
	for _, player in ipairs(Players:GetPlayers()) do
		if (player ~= LocalPlayer) then
			local torso = getTargetTorso(player);
			if torso then
				local distance = (torso.Position - center).Magnitude;
				if (distance <= nearestDistance) then
					nearestTorso = torso;
					nearestDistance = distance;
				end
			end
		end
	end
	return nearestTorso;
end
local function updateSummonArm(now)
	local shoulder = state.shoulderMotor;
	if (not shoulder or not shoulder.Parent or not state.shoulderTransform) then
		return;
	end
	local alpha = math.clamp((now - state.summonStarted) / 1.6, 0, 1);
	local raised = state.shoulderTransform * CFrame.Angles(math.rad(-135), 0, math.rad(18));
	shoulder.Transform = state.shoulderTransform:Lerp(raised, alpha);
end
local function updateMeteor(deltaTime, now)
	state.meteorAccumulator = state.meteorAccumulator + deltaTime;
	if (state.meteorAccumulator < (1 / 30)) then
		updateSummonArm(now);
		return;
	end
	local step = math.min(state.meteorAccumulator, 0.1);
	state.meteorAccumulator = 0;
	local localRoot = getRootPart(LocalPlayer);
	if not localRoot then
		if MeteorToggle then
			MeteorToggle:Set(false, true);
		end
		stopMeteor(false);
		return;
	end
	local center;
	local impact = state.meteorImpactTorso;
	if (impact and impact.Parent and getTargetTorso(Players:GetPlayerFromCharacter(impact.Parent))) then
		center = impact.Position;
		state.meteorAngle = state.meteorAngle + (step * 36);
	elseif state.meteorThrown then
		state.meteorImpactTorso = nil;
		state.meteorCenter = (state.meteorCenter or localRoot.Position) + (state.meteorDirection * state.meteorSpeed * step) + Vector3.new(0, -5 * step, 0);
		center = state.meteorCenter;
		state.meteorAngle = state.meteorAngle + (step * 25);
		local hitTorso = findMeteorHit(center);
		if hitTorso then
			state.meteorImpactTorso = hitTorso;
			center = hitTorso.Position;
			notify("Meteor Impact", "Assemblies are now spinning around " .. hitTorso.Parent.Name .. ".");
		elseif ((now - state.meteorThrowStarted) > 5) then
			state.meteorThrown = false;
			state.meteorCenter = localRoot.Position + Vector3.new(0, state.meteorHeight, 0);
			state.summonStarted = now;
			beginSummonArm();
			center = state.meteorCenter;
			notify("Meteor", "Throw expired; the sphere returned above you.");
		end
	else
		center = localRoot.Position + Vector3.new(0, state.meteorHeight, 0);
		state.meteorCenter = center;
		state.meteorAngle = state.meteorAngle + (step * 3);
		updateSummonArm(now);
	end
	local moved = 0;
	local unowned = 0;
	local count = math.max(#state.roots, 1);
	local radius = (state.meteorImpactTorso and 3.5) or state.meteorRadius;
	for index, root in ipairs(state.roots) do
		if root.Parent then
			if isOwned(root) then
				if root.Anchored then
					root.Anchored = false;
				end
				local offset = sphereOffset(index, count, radius, state.meteorAngle);
				local desired = CFrame.new(center + offset) * CFrame.Angles(state.meteorAngle * 1.5, state.meteorAngle + (index * 0.2), state.meteorAngle * 2);
				driveRoot(root, desired);
				moved = moved + 1;
			else
				unowned = unowned + 1;
			end
		end
	end
	state.moved = moved;
	state.unowned = unowned;
end
BringToggle = ControlSection:AddToggle({Name="Bring All Parts",Tag="B",Default=false,Flag="BringAllParts",Callback=function(enabled)
	if not enabled then
		stopBringing(true);
		return;
	end
	if MeteorToggle then
		MeteorToggle:Set(false, true);
	end
	stopPlacement(false);
	stopMeteor(false);
	stopLayout(false);
	local target = resolveTarget(false);
	if (not target or not getTargetTorso(target)) then
		notify("Bring Parts", "Target is missing or has no living character.");
		BringToggle:Set(false, true);
		state.bringing = false;
		return;
	end
	stopOrbiting(false);
	if OrbitToggle then
		OrbitToggle:Set(false, true);
	end
	if not expandSimulationRadius() then
		notify("Bring Parts", "This executor cannot expand physics ownership.");
		BringToggle:Set(false, true);
		return;
	end
	state.target = target;
	state.bringing = true;
	state.bringStartTime = os.clock();
	state.bringSpinAngle = 0;
	state.freezing = false;
	state.moved = 0;
	state.unowned = 0;
	scanAssemblies();
	notify("Bring Parts", "Collecting ownership for 10 seconds, then spinning tightly around " .. target.Name .. "'s torso.");
end});
OrbitToggle = ControlSection:AddToggle({Name="Circle All Parts Around Me",Tag="O",Default=false,Flag="OrbitAllParts",Callback=function(enabled)
	if not enabled then
		stopOrbiting(true);
		return;
	end
	if MeteorToggle then
		MeteorToggle:Set(false, true);
	end
	stopPlacement(false);
	stopMeteor(false);
	stopLayout(false);
	if not getRootPart(LocalPlayer) then
		notify("Circle Parts", "Your character is not available.");
		OrbitToggle:Set(false, true);
		return;
	end
	if not expandSimulationRadius() then
		notify("Circle Parts", "This executor cannot expand physics ownership.");
		OrbitToggle:Set(false, true);
		return;
	end
	state.bringing = false;
	BringToggle:Set(false, true);
	state.freezing = false;
	state.orbiting = true;
	state.orbitAngle = 0;
	state.moved = 0;
	state.unowned = 0;
	scanAssemblies();
	notify("Circle Parts", "Owned detached assemblies are now orbiting you.");
end});
ControlSection:AddButton({Name="FORCE STOP ORBIT",Callback=function()
	OrbitToggle:Set(false, true);
	stopOrbiting(true);
end});
ControlSection:AddButton({Name="Find Target",Callback=function()
	resolveTarget(true);
end});
ControlSection:AddButton({Name="Stop / Release Parts",Callback=function()
	stopAllPartModes(true);
end});
ControlSection:AddButton({Name="Anchor Parts (Local)",Callback=function()
	stopAllPartModes(false);
	expandSimulationRadius();
	scanAssemblies();
	local anchored = 0;
	for _, root in ipairs(state.roots) do
		if (root.Parent and isOwned(root)) then
			zeroMotion(root);
			state.frozenCFrames[root] = root.CFrame;
			root.Anchored = true;
			anchored = anchored + 1;
		end
	end
	state.freezing = true;
	notify("Anchor Parts", string.format("Locally anchored %d controlled assemblies.", anchored));
end});
ControlSection:AddButton({Name="Unanchor / Release Parts",Callback=function()
	local released = 0;
	for root in pairs(state.frozenCFrames) do
		if root.Parent then
			released = released + 1;
		end
	end
	stopAllPartModes(false);
	notify("Release Parts", string.format("Released %d assemblies.", released));
end});
ControlSection:AddButton({Name="Restore Original Positions",Callback=function()
	stopAllPartModes(false);
	expandSimulationRadius();
	local restored = 0;
	for root, originalCFrame in pairs(state.originalCFrames) do
		if root.Parent then
			root.Anchored = false;
			if isOwned(root) then
				root.CFrame = originalCFrame;
				zeroMotion(root);
				restored = restored + 1;
			end
		end
	end
	table.clear(state.frozenCFrames);
	state.freezing = false;
	restorePartCollision();
	restoreSimulationRadius();
	notify("Restore Parts", string.format("Restored %d owned assemblies.", restored));
end});
local BlueprintSection = BuildTab:CreateSection({Title="Draggable Blueprints",Description="preview first, then commit all available assemblies",Side="Left"});
BlueprintSection:AddButton({Name="Stairs - Drag Preview",Callback=function()
	startPlacement("stairs");
end});
BlueprintSection:AddButton({Name="Concrete Platform - Drag Preview",Callback=function()
	startPlacement("platform");
end});
BlueprintSection:AddButton({Name="Elevator - Drag Preview",Callback=function()
	startPlacement("elevator");
end});
BlueprintSection:AddButton({Name="Yard - Drag Preview",Callback=function()
	startPlacement("yard");
end});
BlueprintSection:AddButton({Name="DONE - Build Here",Callback=commitPlacement});
BlueprintSection:AddButton({Name="Move Preview Up",Callback=function()
	if state.placingMode then
		state.placementHeight = state.placementHeight + 5;
		updatePlacementFromMouse();
	end
end});
BlueprintSection:AddButton({Name="Move Preview Down",Callback=function()
	if state.placingMode then
		state.placementHeight = state.placementHeight - 5;
		updatePlacementFromMouse();
	end
end});
BlueprintSection:AddButton({Name="Cancel Preview",Callback=function()
	stopPlacement(true);
end});
BlueprintSection:AddParagraph({Content="Choose Stairs, Concrete, Elevator, or Yard. Hold left mouse and drag; E/Q or the wheel changes height. The Yard preview is a 5x5 tile ground with four low fences. Press DONE, then use the Yard controls.",Height=92});
local MeteorSection = BuildTab:CreateSection({Title="Sphere Meteor",Description="summon overhead, then double-click the world",Side="Right"});
MeteorToggle = MeteorSection:AddToggle({Name="Summon Sphere Meteor",Tag="M",Default=false,Flag="MeteorEnabled",Callback=function(enabled)
	if enabled then
		if not startMeteor() then
			MeteorToggle:Set(false, true);
		end
	else
		stopMeteor(true);
	end
end});
MeteorSection:AddSlider({Name="Meteor Height",Min=16,Max=60,Default=24,Suffix=" studs",Flag="MeteorHeight",Callback=function(value)
	state.meteorHeight = value;
end});
MeteorSection:AddSlider({Name="Meteor Size",Min=7,Max=18,Default=11,Suffix=" studs",Flag="MeteorRadius",Callback=function(value)
	state.meteorRadius = value;
end});
MeteorSection:AddSlider({Name="Throw Speed",Min=70,Max=220,Default=135,Suffix=" studs/s",Flag="MeteorSpeed",Callback=function(value)
	state.meteorSpeed = value;
end});
MeteorSection:AddButton({Name="STOP ALL PART MODES",Callback=function()
	stopAllPartModes(true);
end});
MeteorSection:AddParagraph({Content="The right arm rises during summoning. Double-click away from the GUI to throw. A nearby player torso triggers a fast impact orbit. Only assemblies your client owns can replicate.",Height=88});
local ElevatorSection = BuildTab:CreateSection({Title="Debris Elevator",Description="slow replicated lift made from owned assemblies",Side="Right"});
ElevatorLiftToggle = ElevatorSection:AddToggle({Name="Raise Elevator Slowly",Description="toggle off to lower it back to the preview height",Tag="E",Default=false,Flag="ElevatorRaised",Callback=function(enabled)
	if (not state.layoutActive or (state.layoutKind ~= "elevator")) then
		if enabled then
			notify("Elevator", "Place Elevator - Drag Preview and press DONE first.");
			ElevatorLiftToggle:Set(false, true);
		end
		return;
	end
	state.elevatorRaised = enabled;
	notify("Elevator", (enabled and "Rising slowly.") or "Lowering slowly.");
end});
ElevatorSection:AddButton({Name="RAISE ELEVATOR",Callback=function()
	if (state.layoutActive and (state.layoutKind == "elevator")) then
		state.elevatorRaised = true;
		ElevatorLiftToggle:Set(true, true);
		notify("Elevator", "Rising slowly.");
	else
		notify("Elevator", "Build the elevator first.");
	end
end});
ElevatorSection:AddButton({Name="LOWER ELEVATOR",Callback=function()
	if (state.layoutActive and (state.layoutKind == "elevator")) then
		state.elevatorRaised = false;
		ElevatorLiftToggle:Set(false, true);
		notify("Elevator", "Lowering slowly.");
	else
		notify("Elevator", "Build the elevator first.");
	end
end});
ElevatorSection:AddSlider({Name="Lift Height",Min=20,Max=220,Default=100,Suffix=" studs",Flag="ElevatorHeight",Callback=function(value)
	state.elevatorHeight = value;
end});
ElevatorSection:AddSlider({Name="Lift Speed",Min=2,Max=24,Default=8,Suffix=" studs/s",Flag="ElevatorSpeed",Callback=function(value)
	state.elevatorSpeed = value;
end});
ElevatorSection:AddButton({Name="STOP ELEVATOR / RELEASE",Callback=function()
	if ElevatorLiftToggle then
		ElevatorLiftToggle:Set(false, true);
	end
	stopLayout(true);
end});
ElevatorSection:AddParagraph({Content="Players can stand on collidable debris your client owns. The lift remains unanchored and moves gradually so its physics can replicate. Server-owned pieces stay listed as waiting.",Height=88});
local YardSection = BuildTab:CreateSection({Title="Moving Yard",Description="smooth tile ground, low fences, lift, and directional travel",Side="Right"});
YardDriveToggle = YardSection:AddToggle({Name="Enable Yard Keyboard Drive",Description="W/S forward/back, A/D left/right, Space/Ctrl up/down",Tag="WASD",Default=false,Flag="YardDriveEnabled",Callback=function(enabled)
	if (enabled and (not state.layoutActive or (state.layoutKind ~= "yard"))) then
		notify("Yard", "Place Yard - Drag Preview and press DONE first.");
		YardDriveToggle:Set(false, true);
		return;
	end
	state.yardDriveEnabled = enabled;
end});
YardRiseToggle = YardSection:AddToggle({Name="Rise Yard Slowly",Description="smoothly rises toward the selected lift height",Default=false,Flag="YardRise",Callback=function(enabled)
	if (enabled and (not state.layoutActive or (state.layoutKind ~= "yard"))) then
		YardRiseToggle:Set(false, true);
		notify("Yard", "Build the yard first.");
		return;
	end
	state.yardRise = enabled;
	if enabled then
		state.yardLower = false;
		if YardLowerToggle then
			YardLowerToggle:Set(false, true);
		end
	end
end});
YardLowerToggle = YardSection:AddToggle({Name="Lower Yard Slowly",Description="smoothly returns to the original placement height",Default=false,Flag="YardLower",Callback=function(enabled)
	if (enabled and (not state.layoutActive or (state.layoutKind ~= "yard"))) then
		YardLowerToggle:Set(false, true);
		notify("Yard", "Build the yard first.");
		return;
	end
	state.yardLower = enabled;
	if enabled then
		state.yardRise = false;
		if YardRiseToggle then
			YardRiseToggle:Set(false, true);
		end
	end
end});
YardSection:AddButton({Name="RISE YARD SLOWLY",Callback=function()
	if (state.layoutActive and (state.layoutKind == "yard")) then
		state.yardRise = true;
		state.yardLower = false;
		YardRiseToggle:Set(true, true);
		YardLowerToggle:Set(false, true);
	else
		notify("Yard", "Build the yard first.");
	end
end});
YardSection:AddButton({Name="LOWER YARD SLOWLY",Callback=function()
	if (state.layoutActive and (state.layoutKind == "yard")) then
		state.yardRise = false;
		state.yardLower = true;
		YardRiseToggle:Set(false, true);
		YardLowerToggle:Set(true, true);
	else
		notify("Yard", "Build the yard first.");
	end
end});
YardSection:AddButton({Name="STOP VERTICAL YARD MOVEMENT",Callback=function()
	state.yardRise = false;
	state.yardLower = false;
	YardRiseToggle:Set(false, true);
	YardLowerToggle:Set(false, true);
end});
YardSection:AddButton({Name="MOVE YARD FORWARD",Callback=function()
	startYardDirection(Vector3.new(0, 0, -1), "Forward.");
end});
YardSection:AddButton({Name="MOVE YARD BACKWARD",Callback=function()
	startYardDirection(Vector3.new(0, 0, 1), "Backward.");
end});
YardSection:AddButton({Name="MOVE YARD LEFT",Callback=function()
	startYardDirection(Vector3.new(-1, 0, 0), "Left.");
end});
YardSection:AddButton({Name="MOVE YARD RIGHT",Callback=function()
	startYardDirection(Vector3.new(1, 0, 0), "Right.");
end});
YardSection:AddButton({Name="STOP HORIZONTAL YARD MOVEMENT",Callback=function()
	state.yardButtonVector = Vector3.zero;
	state.yardButtonUntil = 0;
end});
YardSection:AddSlider({Name="Yard Move Speed",Min=4,Max=30,Default=14,Suffix=" studs/s",Flag="YardMoveSpeed",Callback=function(value)
	state.yardMoveSpeed = value;
end});
YardSection:AddSlider({Name="Yard Vertical Speed",Min=2,Max=12,Default=6,Suffix=" studs/s",Flag="YardVerticalSpeed",Callback=function(value)
	state.yardVerticalSpeed = value;
end});
YardSection:AddSlider({Name="Yard Lift Height",Min=20,Max=180,Default=100,Suffix=" studs",Flag="YardLiftHeight",Callback=function(value)
	state.yardLiftHeight = value;
end});
YardSection:AddSlider({Name="Movement Smoothness",Min=2,Max=8,Default=4,Suffix="x",Flag="YardSmoothness",Callback=function(value)
	state.yardSmoothness = value;
end});
YardSection:AddSlider({Name="Direction Button Distance",Min=4,Max=30,Default=12,Suffix=" studs",Flag="YardNudgeDistance",Callback=function(value)
	state.yardNudgeDistance = value;
end});
YardSection:AddButton({Name="STOP YARD / RELEASE",Callback=function()
	stopLayout(true);
end});
YardSection:AddParagraph({Content="The yard keeps a fixed set of owned debris so it cannot reshuffle under riders. Acceleration and deceleration are smoothed to reduce launching. Deck roots stay collidable; low fence roots form the perimeter. Server-owned pieces remain waiting.",Height=105});
local FlightSection = PlayerTab:CreateSection({Title="Fly",Description="client-controlled character flight",Side="Left"});
local FlyToggle;
FlyToggle = FlightSection:AddToggle({Name="Fly",Tag="F",Keybind=Enum.KeyCode.F,Default=false,Flag="FlyEnabled",Callback=function(enabled)
	if enabled then
		if not startFly(true) then
			FlyToggle:Set(false, true);
		end
	else
		stopFly(true);
	end
end});
FlightSection:AddButton({Name="FORCE STOP FLY",Callback=function()
	FlyToggle:Set(false, true);
	stopFly(true);
end});
FlightSection:AddSlider({Name="Fly Speed",Min=20,Max=120,Default=60,Suffix=" studs/s",Flag="FlySpeed",Callback=function(value)
	state.flySpeed = value;
end});
FlightSection:AddParagraph({Content="Controls: WASD to move, Space to rise, LeftCtrl to descend. Press F to toggle flight.",Height=62});
local GearSection = PlayerTab:CreateSection({Title="Inventory",Description="local character tools",Side="Right"});
GearSection:AddButton({Name="GIVE / EQUIP BLUE HAMMER",Description="Adds the blue hammer to your Backpack and equips it.",Callback=giveBlueHammer});
GearSection:AddButton({Name="REMOVE BLUE HAMMER",Description="Removes the locally created hammer.",Callback=removeBlueHammer});
GearSection:AddParagraph({Content="NDS exposes the blue hammer as a permission-gated Sandbox delete-brush cursor, not as a public Backpack Tool. This button creates a matching local inventory hammer; it does not unlock server-only Sandbox editing.",Height=92});
local PlacementSection = SettingsTab:CreateSection({Title="Placement",Description="adjust where assemblies gather",Side="Left"});
PlacementSection:AddSlider({Name="Vertical Offset",Min=-25,Max=50,Default=8,Suffix=" studs",Flag="VerticalOffset",Callback=function(value)
	state.verticalOffset = value;
end});
PlacementSection:AddSlider({Name="Target Spin Radius",Min=2,Max=10,Default=3,Suffix=" studs",Flag="TargetSpinRadius",Callback=function(value)
	state.bringRadius = value;
end});
PlacementSection:AddSlider({Name="Target Spin Speed",Min=5,Max=30,Default=15,Suffix="x",Flag="TargetSpinSpeed",Callback=function(value)
	state.bringSpinSpeed = value;
end});
PlacementSection:AddSlider({Name="Orbit Radius",Min=8,Max=50,Default=18,Suffix=" studs",Flag="OrbitRadius",Callback=function(value)
	state.orbitRadius = value;
end});
PlacementSection:AddSlider({Name="Orbit Speed",Min=1,Max=10,Default=2,Suffix="x",Flag="OrbitSpeed",Callback=function(value)
	state.orbitSpeed = value;
end});
PlacementSection:AddButton({Name="Target Yourself",Callback=function()
	TargetField:Set(LocalPlayer.Name);
	state.targetText = LocalPlayer.Name;
	resolveTarget(true);
end});
local SafetySection = SettingsTab:CreateSection({Title="Safety",Description="protect your character from physics flings",Side="Right"});
SafetySection:AddToggle({Name="Anti Fling",Tag="AF",Default=true,Flag="AntiFling",Callback=function(enabled)
	state.antiFling = enabled;
	if not enabled then
		restoreAntiFlingCollision();
		state.safeCFrame = nil;
	end
	notify("Anti Fling", (enabled and "Enabled") or "Disabled");
end});
local InfoSection = SettingsTab:CreateSection({Title="Information",Side="Right"});
InfoSection:AddParagraph({Content="Detached unanchored assemblies inside workspace.Structure can move. Intact houses remain welded to the server-owned anchored island until disaster damage separates them. Local anchoring may be corrected by the server.",Height=90});
InfoSection:AddParagraph({Content="Press LeftAlt to close or reopen Zenthra.",Height=44});
local rejoinPending = false;
InfoSection:AddButton({Name="REJOIN SERVER",Description="Reconnect to this NDS server; falls back to another server if necessary.",Callback=function()
	if rejoinPending then
		notify("Rejoin", "A rejoin request is already running.");
		return;
	end
	rejoinPending = true;
	stopAllPartModes(false);
	stopFly(false);
	notify("Rejoin", "Reconnecting to the current server...");
	task.spawn(function()
		task.wait(0.35);
		local sameServer = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer);
		end);
		if not sameServer then
			pcall(function()
				TeleportService:Teleport(game.PlaceId, LocalPlayer);
			end);
		end
		task.wait(6);
		if LocalPlayer.Parent then
			rejoinPending = false;
			notify("Rejoin", "Teleport did not start. Press the button to try again.");
		end
	end);
end});
InfoSection:AddButton({Name="Destroy Interface",Callback=function()
	Window:Destroy();
end});
Window:_Connect(UserInputService.InputBegan, function(input, gameProcessed)
	if (gameProcessed or UserInputService:GetFocusedTextBox()) then
		return;
	end
	if state.placingMode then
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			state.placementDragging = true;
			updatePlacementFromMouse();
		elseif (input.KeyCode == Enum.KeyCode.E) then
			state.placementHeight = state.placementHeight + 5;
			updatePlacementFromMouse();
		elseif (input.KeyCode == Enum.KeyCode.Q) then
			state.placementHeight = state.placementHeight - 5;
			updatePlacementFromMouse();
		end
		return;
	end
	if (state.meteorActive and (input.UserInputType == Enum.UserInputType.MouseButton1)) then
		local now = os.clock();
		if ((now - state.meteorLastClick) <= 0.32) then
			state.meteorLastClick = 0;
			throwMeteor();
		else
			state.meteorLastClick = now;
		end
	end
end);
Window:_Connect(UserInputService.InputChanged, function(input)
	if not state.placingMode then
		return;
	end
	if ((input.UserInputType == Enum.UserInputType.MouseMovement) and state.placementDragging) then
		updatePlacementFromMouse();
	elseif (input.UserInputType == Enum.UserInputType.MouseWheel) then
		state.placementHeight = state.placementHeight + (input.Position.Z * 4);
		updatePlacementFromMouse();
	end
end);
Window:_Connect(UserInputService.InputEnded, function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1) then
		state.placementDragging = false;
	end
end);
Window:_Connect(Players.PlayerRemoving, function(player)
	if (state.target == player) then
		state.target = nil;
		state.bringing = false;
		BringToggle:Set(false, true);
		TargetStatus:Set("Target left the server", true);
	end
end);
Window:_Connect(RunService.Heartbeat, function(deltaTime)
	local now = os.clock();
	if ((now - state.lastScan) >= 0.5) then
		state.lastScan = now;
		local partCount, rootCount = scanAssemblies();
		if (state.layoutActive and state.layoutBase) then
			for index, root in ipairs(state.roots) do
				if (state.layoutCFrames[root] == nil) then
					state.layoutCFrames[root] = layoutCFrame(state.layoutKind, state.layoutBase, index, math.max(rootCount, 1));
				end
			end
		end
		if ((now - state.lastStatusUpdate) >= 0.5) then
			state.lastStatusUpdate = now;
			updateStatus(partCount, rootCount);
		end
	end
	if ((state.bringing or state.orbiting or state.layoutActive or state.meteorActive or state.freezing) and ((now - state.lastRadiusUpdate) >= 1)) then
		state.lastRadiusUpdate = now;
		expandSimulationRadius();
	end
	if state.bringing then
		local target = state.target;
		local targetTorso = getTargetTorso(target);
		if not targetTorso then
			state.bringing = false;
			BringToggle:Set(false, true);
			TargetStatus:Set("Target unavailable", true);
			return;
		end
		local moved = 0;
		local unowned = 0;
		local elapsed = os.clock() - state.bringStartTime;
		local spinActive = elapsed >= state.bringDelay;
		if spinActive then
			state.bringSpinAngle = state.bringSpinAngle + (deltaTime * state.bringSpinSpeed);
		end
		local count = math.max(#state.roots, 1);
		for index, root in ipairs(state.roots) do
			if root.Parent then
				if isOwned(root) then
					if spinActive then
						if root.Anchored then
							root.Anchored = false;
						end
						local angle = state.bringSpinAngle + (((index - 1) / count) * math.pi * 2);
						local layer = ((index - 1) % 7) - 3;
						local radius = state.bringRadius + (math.floor((index - 1) / 70) * 0.6);
						local position = targetTorso.Position + Vector3.new(math.cos(angle) * radius, layer * 0.45, math.sin(angle) * radius);
						local desired = CFrame.new(position) * CFrame.Angles(state.bringSpinAngle * 2, -angle, state.bringSpinAngle * 3);
						driveRoot(root, desired);
						moved = moved + 1;
					end
				else
					unowned = unowned + 1;
				end
			end
		end
		state.moved = moved;
		state.unowned = unowned;
	elseif state.orbiting then
		local localRoot = getRootPart(LocalPlayer);
		if not localRoot then
			state.orbiting = false;
			OrbitToggle:Set(false, true);
		else
			state.orbitAngle = state.orbitAngle + (deltaTime * state.orbitSpeed);
			local moved = 0;
			local unowned = 0;
			local count = math.max(#state.roots, 1);
			for index, root in ipairs(state.roots) do
				if root.Parent then
					if root.Anchored then
						root.Anchored = false;
					end
					if isOwned(root) then
						local angle = state.orbitAngle + (((index - 1) / count) * math.pi * 2);
						local layer = (index - 1) % 4;
						local radius = state.orbitRadius + (math.floor((index - 1) / 32) * 3);
						local worldPosition = localRoot.Position + Vector3.new(math.cos(angle) * radius, state.verticalOffset + (layer * 2.5), math.sin(angle) * radius);
						local desired = CFrame.new(worldPosition) * CFrame.Angles(0, -angle, 0);
						driveRoot(root, desired);
						moved = moved + 1;
					else
						unowned = unowned + 1;
					end
				end
			end
			state.moved = moved;
			state.unowned = unowned;
		end
	elseif state.layoutActive then
		updateLayout(deltaTime);
	elseif state.meteorActive then
		updateMeteor(deltaTime, now);
	elseif state.freezing then
		for root, frozenCFrame in pairs(state.frozenCFrames) do
			if (root.Parent and isOwned(root)) then
				root.CFrame = frozenCFrame;
				zeroMotion(root);
			end
		end
	end
	updateFly();
	if state.antiFling then
		applyAntiFling(now);
	end
end);
local originalDestroy = Window.Destroy;
Window.Destroy = function(self)
	if self.Destroyed then
		return;
	end
	state.bringing = false;
	state.orbiting = false;
	stopPlacement(false);
	stopMeteor(false);
	stopLayout(false);
	for root in pairs(state.frozenCFrames) do
		if root.Parent then
			root.Anchored = false;
			pcall(zeroMotion, root);
		end
	end
	table.clear(state.frozenCFrames);
	state.freezing = false;
	stopFly(false);
	restorePartCollision();
	restoreLayoutCollision();
	restoreAntiFlingCollision();
	restoreSimulationRadius();
	if (GlobalEnvironment.__ZenthraNDSPartControlSession == sessionToken) then
		GlobalEnvironment.__ZenthraNDSPartControlSession = nil;
		GlobalEnvironment.__ZenthraNDSPartControlCleanup = nil;
		GlobalEnvironment.__ZenthraNDSStopOrbit = nil;
		GlobalEnvironment.__ZenthraNDSStopFly = nil;
		GlobalEnvironment.__ZenthraNDSStopAll = nil;
		GlobalEnvironment.__ZenthraNDSElevatorState = nil;
		GlobalEnvironment.__ZenthraNDSYardState = nil;
	end
	originalDestroy(self);
end;
GlobalEnvironment.__ZenthraNDSPartControlCleanup = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession == sessionToken) and not Window.Destroyed) then
		Window:Destroy();
	end
end;
GlobalEnvironment.__ZenthraNDSStopOrbit = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession == sessionToken) and not Window.Destroyed) then
		OrbitToggle:Set(false, true);
		stopOrbiting(true);
	end
end;
GlobalEnvironment.__ZenthraNDSStopFly = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession == sessionToken) and not Window.Destroyed) then
		FlyToggle:Set(false, true);
		stopFly(true);
	end
end;
GlobalEnvironment.__ZenthraNDSStopAll = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession == sessionToken) and not Window.Destroyed) then
		stopAllPartModes(true);
	end
end;
GlobalEnvironment.__ZenthraNDSElevatorState = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession ~= sessionToken) or Window.Destroyed) then
		return false, nil, 0, false, 0, 0;
	end
	return state.layoutActive, state.layoutKind, state.elevatorCurrentY, state.elevatorRaised, state.moved, state.unowned;
end;
GlobalEnvironment.__ZenthraNDSYardState = function()
	if ((GlobalEnvironment.__ZenthraNDSPartControlSession ~= sessionToken) or Window.Destroyed) then
		return false, nil, nil, Vector3.zero, false, false, false, 0, 0, 0, 0;
	end
	local fenceCount = 0;
	for _ in pairs(state.yardFenceRoots) do
		fenceCount = fenceCount + 1;
	end
	return state.layoutActive, state.layoutKind, state.yardCFrame, state.yardVelocity, state.yardDriveEnabled, state.yardRise, state.yardLower, state.moved, state.unowned, #state.yardRoots, fenceCount;
end;
PartsTab:Select();
resolveTarget(false);
local initialParts, initialRoots = scanAssemblies();
updateStatus(initialParts, initialRoots);
notify("NDS Part Control", "Loaded. Enter a player, then enable Bring All Parts.");