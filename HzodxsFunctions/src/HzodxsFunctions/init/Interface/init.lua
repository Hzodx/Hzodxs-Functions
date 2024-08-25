local module = {}
module.__index = module

local types = require(script.types)
local selfFunctions = require(script.selfFunctions)

function module.new(style:types.Style?) : types.Module
	local self: types.Module = {}
	self.style = style or {}
	self.style.font = self.style.font or Enum.Font.SourceSans
	
	for name, defaults in selfFunctions.sharedDefaults do
		for property, value in defaults do
			if typeof(value) == "string" then
				selfFunctions.sharedDefaults[name][property] = style[value] or nil
			end
		end
	end
	
	if style.defaults then
		for i,v in style.defaults do
			selfFunctions.topLevelDefaults[i] = selfFunctions.topLevelDefaults[i] or {}
			
			for e,d in v do
				selfFunctions.topLevelDefaults[i][e] = d
			end
		end
	end
	
	for i,v in selfFunctions.functions do
		self[i] = v
	end

	local body = self:element("Frame", {
		BackgroundColor3 = self.style.bodyColor or Color3.new(.3,.3,.3),
		Size = UDim2.fromScale(1,1),
	})
	
	self:element("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, .89),
		Position = UDim2.fromScale(1, .995),
		AnchorPoint = Vector2.new(1,1),
		Parent = body
	})
	
	local titleBar do
		local text = self.style.titleBar.Text
		self.style.titleBar.Text = nil
		
		self.style.titleBar.Parent = body
		titleBar = self:element("Frame", self.style.titleBar)
		
		text.Parent = titleBar
		self:element("TextLabel", text)
	end
	
	local sideBar:Frame do
		local sideBarOpenSize = UDim2.fromScale(.4, .9)
		local sideBarClosedSize = UDim2.fromScale(-.1, .9)
		
		sideBar = self:element("Frame", {
			Name = "SideBar",
			Size = sideBarClosedSize,
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = self.style.sideBarColor or Color3.new(0,0,0),
			Parent = body
		})
		
		self:element("ScrollingFrame", {
			Name = "Buttons",
			Size = UDim2.fromScale(.9, .9),
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			BackgroundTransparency = 1,

			CanvasSize = UDim2.fromScale(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,

			children = {
				["UIListLayout"] = {
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 10),
				}
			},

			Parent = sideBar
		})
		
		if self.style.sideBarFade then
			self:fade(self.style.sideBarFade.startPoint, self.style.sideBarFade.endPoint).Parent = sideBar
		end
		
		local hamburger:ImageButton = self:element("ImageButton", {
			Size = UDim2.fromScale(.1, 1),
			Position = UDim2.fromScale(.01, 0),
			BackgroundTransparency = 1,
			Image = self.style.hamburgerIcon or "rbxassetid://11326672122",
			Parent = titleBar,
			
			onClick = function()
				self:ToggleSideBar()
			end,
		})
		
		function self:ToggleSideBar()
			sideBar:TweenSize(sideBar.Size == sideBarOpenSize and sideBarClosedSize or sideBarOpenSize, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, .2, true)
		end
				
		self:ratioElement(1, hamburger)
	end
	
	self.body = body
	self.tab = nil
	
	return setmetatable(self, module)
end

local tab = {}
tab.__index = tab

local card = {}
card.__index = card

function card:element(elementName:string, properties)
	properties.Parent = properties.Parent or self.card.Body
	return self.top:element(elementName, properties)
end

function card:button(properties)
	properties.Parent = properties.Parent or self.card.Body
	return self.top:element("TextButton", properties)
end

function card:textBox(properties, validatorFunction:(text:string) -> nil?)
	properties.Parent = properties.Parent or self.card.Body
	local textBox:TextBox = self.top:element("TextBox", properties)
	
	if validatorFunction then
		local lastText = ""
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if textBox.Text == "" then
				lastText = ""
				return
			end
			
			local newText = validatorFunction(textBox.Text)
			if not newText then
				textBox.Text = lastText
				return
			end
			
			lastText = newText
			textBox.Text = newText
		end)
	end
	
	return textBox
end

function tab:NewCard(name:string?, createLayout:boolean?)
	local cardFrame = self.top:element("Frame", {
		Size = UDim2.fromScale(.4, .65),
		Parent = self.tab
	})
	
	if createLayout == nil then
		createLayout = true
	end
	
	self.top:element("ScrollingFrame", {
		Name = "Body",
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		Size = name and UDim2.fromScale(1, .9) or UDim2.fromScale(1, 1),

		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		
		[createLayout and "children"] = {
			["UIListLayout"] = {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
			}
		},
		
		Parent = cardFrame
	})
	
	if name then 
		self.top:element("TextLabel", {
			Text = name,
			TextScaled = true,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, .1),
			Parent = cardFrame
		}) 
	end
	
	return setmetatable({card = cardFrame, top = self.top}, card)
end

function module:AddTab(name:string)
	local TabButton:TextButton = self:element("TextButton", {
		Text = name,
		Size = UDim2.fromScale(.8, .1),
		Parent = self.body.SideBar.Buttons
	})
	
	local TabFrame:Frame = self:element("ScrollingFrame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		
		Parent = self.body.Tabs
	})
		
	self:element("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		VerticalFlex = Enum.UIFlexAlignment.Fill,
		Wraps = true,
		Padding = UDim.new(0, 10),
		Parent = TabFrame,
	})
		
	if self.tab then
		TabFrame.Visible = false
	else
		self.tab = TabFrame
		TabFrame.Visible = true
	end
	
	TabButton.MouseButton1Click:Connect(function()
		self:ToggleSideBar()

		if self.tab == TabFrame then
			return
		end
				
		if self.tab then
			self.tab.Visible = false
		end
		
		self.tab = TabFrame
		self.tab.Visible = TabFrame
	end)
	
	return setmetatable({name = name, top = self, tab = TabFrame}, tab)
end

return module