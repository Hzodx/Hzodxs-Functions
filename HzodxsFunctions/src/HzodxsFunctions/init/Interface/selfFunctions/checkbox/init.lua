local images = {
	[false] = "rbxassetid://14187539043",
	[true] = "rbxassetid://14187538370"
}

return function(element, self, properties)
	local state = properties.state or false
		
	return element(self, "TextLabel", {
		Parent = properties.Parent,
		Text = properties.Text,
		Name = properties.Name,
		
		children = {
			["ImageButton"] = {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(.2, .5),
				Position = UDim2.fromScale(1, .5),
				AnchorPoint = Vector2.new(1, .5),
				Image = images[state],
				onClick = function()
					state = not state
					
					if properties.onClick then
						task.spawn(properties.onClick, state)
					end
					
					return {
						["Image"] = images[state]
					}
				end,
				
				children = {
					["UIAspectRatioConstraint"] = { AspectRatio = 1 }
				}
			}
		}
	})
end