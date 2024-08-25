local module = {}

module.sharedDefaults = {
	["Text"] = {
		TextSize = "textSize",
		TextScaled = "textScaled",
		TextColor3 = "textColor",
		Font = "font",
		Text = "",
		BackgroundTransparency = 1,
	}
}

module.defaultElementValues = {
	["GuiObject"] = {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0,0,0),
	},

	["UIListLayout"] = {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	},

	["TextLabel"] = module.sharedDefaults.Text,
	["TextButton"] = module.sharedDefaults.Text,
	["TextBox"] = module.sharedDefaults.Text,
}

module.topLevelDefaults = {}

local function apply(element, properties, style)
	for name, value in properties do
		local s, err = pcall(function()
			if typeof(value) == "string" and typeof(element[name]) ~= "string" then
				for i,v in value:split(".") do
					value = (i == 1 and style or value)[v]
				end
			end
			
			element[name] = value
		end)
		
		if not s then
			warn("failed setting property", name, "to", value, "error:", err, "for:", element)
		end
	end
end

function newElement(self, t:string, properties)
	if script:FindFirstChild(t) then
		return require(script[t])(newElement, self, properties)
	end
	
	local element = Instance.new(t)

	for _,v in {module.defaultElementValues, module.topLevelDefaults} do
		for t, d in v do
			if not element:IsA(t) then
				continue
			end

			apply(element, d, self.style)
		end
	end

	local con if properties.onClick then
		local onclick = properties.onClick
		local function click()
			local newProperties = onclick()
			if newProperties then
				apply(element, newProperties, self.style)
			end
		end

		con = element.MouseButton1Click:Connect(click)
		properties.onClick = nil
	end

	local children = properties.children
	properties.children = nil

	apply(element, properties, self.style)

	if self.style.special then
		self.style.special(element)
	end

	if children then
		for t:string, properties in children do
			properties.Parent = properties.Parent or element
			newElement(self, t, properties)
		end
	end

	return element, con
end

local self = nil
module.functions = {
	element = newElement,

	ratioElement = function(self, n:number, parent:GuiObject)
		return module.functions.element(self, "UIAspectRatioConstraint", {
			AspectRatio = n,
			Parent = parent
		})
	end,

	fade = function(self, startPoint:number?, endPoint:number?)
		local points = {
			NumberSequenceKeypoint.new(startPoint 	or 0, 0),
			NumberSequenceKeypoint.new(endPoint	 	or 1, 1),
		}

		if startPoint ~= 0 then
			table.insert(points, 1, NumberSequenceKeypoint.new(0, 0))
		end

		return module.functions.element(self, "UIGradient", {
			Transparency = NumberSequence.new(points)
		})
	end,
}

return module