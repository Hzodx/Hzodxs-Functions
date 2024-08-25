local conversions = {}

conversions["NumberRange"] = function(v:NumberRange)
	return `NumberRange.new({v.Min}, {v.Max})`
end

conversions["NumberSequence"] = function(v:NumberSequence)
	local result = "NumberSequence.new({"
	for _,v in v.Keypoints do
		result ..= (`\nNumberSequenceKeypoint.new(%s,%s,%s),`):format(v.Time, v.Value, v.Envelope)
	end

	result ..= "\n})"
	return result
end

conversions["Color3"] = function(v:Color3)
	return `Color3.new({tostring(v)})`
end

conversions["string"] = function(v:string)
	return `"{v}"`
end

conversions["Vector3"] = function(v:Vector3)
	return `Vector3.new({tostring(v)})`
end

conversions["Vector2"] = function(v:Vector2)
	return `Vector2.new({tostring(v)})`
end

conversions["CFrame"] = function(v:CFrame)
	return `CFrame.new({tostring(v)})`
end

conversions.UDim2 = function(v:UDim2)
	return `UDim2.new({v.X.Scale}, {v.X.Offset}, {v.Y.Scale}, {v.Y.Offset})`
end

conversions.ColorSequence = function(v:ColorSequence)
	local result = "ColorSequence.new({"
	for _,v in v.Keypoints do
		result ..= (`\nColorSequenceKeypoint.new(%s,%s),`):format(v.Time, conversions.Color3(v.Value))
	end

	result ..= "\n})"
	return result
end

return function(value)
	if conversions[typeof(value)] then
		return conversions[typeof(value)](value)
	end

	return tostring(value)
end