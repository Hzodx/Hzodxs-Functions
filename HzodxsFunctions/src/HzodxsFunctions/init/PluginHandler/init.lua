local module = {}
module.__index = module

local n = "Hz's Plugin Handler"
_G[n] = _G[n] or {}
local pluginData = _G[n]
module.pluginData = pluginData
pluginData.Widgets = pluginData.Widgets or {}

local types = require(script.types)

local function getWidgetName(family:string, name:string)
	return `Family:{family} Widget:{name}`
end

function module.new(family:string, p): types.module
	if not family then
		warn("no family provided")
		return
	end

	if not p or not p:IsA("Plugin") then
		warn("second argument must be the plugin object")
		return
	end

	pluginData[family] = pluginData[family] or {}
	pluginData[family].Buttons = pluginData[family].Buttons or {}

	return setmetatable({
		plugin = p,
		family = family,
		this = pluginData[family]
	}, module)
end

function module:getButton(name:string)
	return self.this.Buttons[name]
end

function module:getWidget(name:string)
	return pluginData.Widgets[getWidgetName(self.family, name)]
end

function restartRequired(self)
	self.this.Toolbar:Destroy()
	self.this = nil
	self.plugin:CreateToolbar(`Restart required`):CreateButton("", "Restart required", "rbxassetid://14188268048")
	
	warn("###### Restart required for plugin to load")
end

function module:newButton(buttonData:types.ButtonData, widgetData:types.WidgetData?)
	if not buttonData.name then
		warn("a button name must be provided for", self.family)
		return
	end

	self.this.Toolbar = self.this.Toolbar or self.plugin:CreateToolbar(self.family)
	self.this.Buttons[buttonData.name] = self.this.Buttons[buttonData.name] or self.this.Toolbar:CreateButton(buttonData.name, buttonData.tooltip or "", buttonData.image or "", buttonData.description or "")

	local widget
	if widgetData then
		widget = module.newWidget(self, widgetData)
		widget.Enabled = false
		self.this.Buttons[buttonData.name].Click:Connect(function()
			widget.Enabled = not widget.Enabled
		end)
	end

	return self.this.Buttons[buttonData.name], widget
end

function module:newWidget(widgetData:types.WidgetData)
	if not widgetData then
		warn("widgetData must be provided for", self.family)
		return
	end

	local name = getWidgetName(self.family, widgetData.name)
	if pluginData.Widgets[name] then
		pluginData.Widgets[name]:Destroy()
	end

	pluginData.Widgets[name] = self.plugin:CreateDockWidgetPluginGui(name, widgetData.info)
	pluginData.Widgets[name].Title = widgetData.name
	return pluginData.Widgets[name]
end

return module