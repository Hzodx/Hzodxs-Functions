return function(pluginName) return {
	special = function(obj:GuiObject)
		if obj:IsA("TextButton") or obj:IsA("TextBox") then			
			local uiCorner = Instance.new("UICorner", obj)
			uiCorner.CornerRadius = UDim.new(.2)
		end
	end,

	font = Enum.Font.Code,

	textColorGrayedOut = Color3.fromRGB(223, 223, 223),
	textColor = Color3.new(1,1,1),
	textScaled = true,	

	sideBarColor = Color3.fromRGB(25, 25, 25),
	sideBarFade = {
		startPoint = .9,
	},

	titleBar = {
		Text = {
			Size = UDim2.fromScale(.5, 1),
			AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.fromScale(.5, .5),
			Text = pluginName,
			BackgroundTransparency = 1,
		},
		
		Size = UDim2.fromScale(1, .1),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(0.376471, 0.266667, 0.533333),
	},

	defaults = {
		["GuiButton"] = {
			Size = UDim2.fromScale(.9, .2),
			BackgroundColor3 = Color3.new(0.498039, 0.27451, 0.74902),
			BackgroundTransparency = 0,
		},
		
		["TextBox"] = {
			Text = "",
			TextColor3 = "textColorGrayedOut",
			Size = UDim2.fromScale(.9, .2),
			BackgroundColor3 = Color3.new(0.498039, 0.27451, 0.74902),
			BackgroundTransparency = 0,
		}
	},
} end