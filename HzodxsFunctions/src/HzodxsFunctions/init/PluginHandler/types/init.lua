export type ButtonData = {
	name:string,
	tooltip:string?,
	image:string?,
	description:string?,
}

export type WidgetData = {
	name:string,
	info:DockWidgetPluginGuiInfo
}

export type module = {
	newButton: (self, buttonData:ButtonData, widgetData:WidgetData?) -> PluginToolbarButton,
	getButton: (self, name:string) -> PluginToolbarButton,
	
	newWidget: (self, widgetData:WidgetData) -> DockWidgetPluginGui,
	getWidget: (self, name:string) -> DockWidgetPluginGui,
	
	pluginData: Table
}

return nil