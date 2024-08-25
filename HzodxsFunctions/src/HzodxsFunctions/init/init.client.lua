local family = "Hzodx's Functions"

local pluginName = "Hzodx's Functions"
local widgetName = pluginName.." Widget"

local thisPlugin = require(script.PluginHandler).new(family, plugin)
thisPlugin:newButton({
	name = pluginName,
	tooltip = `Open {pluginName}`,
	image = "rbxassetid://11551970814"
}, {
	name = widgetName,
	info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true, 
		false, 
		350,
		300,
		350,
		300
) } )

if game:GetService("RunService"):IsRunMode() then
	thisPlugin:newButton({
		name = "Bring character",
		tooltip = "Brings players to the camera",
		image = "",
	}).Click:Connect(function()
		for _,v in game:GetService("Players"):GetPlayers() do
			if not v.Character then
				continue
			end
			
			v.Character:PivotTo(workspace.CurrentCamera.CFrame)
		end
	end)
end

local widget = thisPlugin:getWidget(widgetName)

--// INTERFACE

local interface = require(script.Interface).new(
	require(script.style)(pluginName)
)

local home do
	home = interface:AddTab("Home")
	home:NewCard("Changelogs"):element("TextLabel", {
		Text = "New UI library i made for this ong",
		Size = UDim2.fromScale(1, .1)
	})
end

local util do
	util = interface:AddTab("Utility")
	
	local Package do
		Package = util:NewCard("Packages")
		Package:button {
			Text = "Pack Selected",
			onClick = function()
				local selection = game:GetService("Selection"):Get()
				if #selection == 0 then
					warn("must select something to pack it!")
					return
				end

				local parentFolder = Instance.new("Folder")
				parentFolder.Name = `{selection[1].Name} Package`

				local function getFolder(n:string)
					if parentFolder:FindFirstChild(n) then
						return parentFolder[n]
					end

					local folder = Instance.new("Folder")
					folder.Name = n
					folder.Parent = parentFolder

					return folder
				end

				for _,v:Instance in selection do
					local directory = v:GetFullName()
					local split = directory:split(".")
					if split[1] == "StarterPlayer" then
						getFolder(split[2]).Parent = getFolder(split[1])
						v.Parent = getFolder(split[1])

						continue
					end

					if #split > 2 then
						warn("Must select top most objects in a service in order to pack it")
						continue
					end

					v.Parent = getFolder(split[1])
				end

				parentFolder.Parent = game:GetService("ServerStorage")
				game:GetService("Selection"):Set({parentFolder})
			end,
		}

		Package:button {
			Text = "Unpack",
			onClick = function()
				local selection = game:GetService("Selection"):Get()
				local function unpackObj(v)
					if game:FindFirstChild(v.Name) then
						for _, child in v:GetChildren() do
							child.Parent = game[v.Name]
						end
					end
				end

				for _,d in selection do
					for _,v in d:GetChildren() do
						if v.Name == "StarterPlayer" then
							for _,v in v:GetChildren() do
								unpackObj(v)
							end

							continue
						end

						unpackObj(v)
					end
				end
			end,
		}
	end
	
	local Replacer do
		Replacer = util:NewCard("Replacer")
		local replacer
		local replacingWithText = Replacer:element("TextLabel", {
			Text = "Replacer not set.",
			Size = "defaults.GuiButton.Size"
		})

		local setReplacer = Replacer:button {
			Text = "Set Replacer",
			TextColor3 = "textColorGrayedOut",
			onClick = function()
				local s = game:GetService("Selection"):Get()[1]
				if not s then
					warn("Must select object to make it a replacer!")
					return
				end
				
				if not s:IsA("BasePart") and not s:IsA("Model") then
					warn("Replacer must either be a basepart or a model")
					return
				end
				
				replacer = s
				replacingWithText.Text = s.Name
			end,
		}

		local replace = Replacer:button {
			Text = "Replace",
			TextColor3 = "textColorGrayedOut",
			onClick = function()
				local selection = game:GetService("Selection"):Get()
				for _,v in selection do
					if v:IsA("BasePart") or v:IsA("Model") then
						local newObj = replacer:Clone()
						newObj:PivotTo(v:GetPivot())
						newObj.Parent = v.Parent
						
						v:Remove()
					end
				end
				
				game:GetService("ChangeHistoryService"):SetWaypoint("Build")
			end,
		}

		for _,v in {setReplacer, replace} do
			v.Size = UDim2.fromScale(v.Size.X.Scale/2, v.Size.Y.Scale)
		end
	end
	
	local Building do
		Building = util:NewCard("Building")
		--[[stairs]] do
			local stairAmmount = Building:textBox({
				PlaceholderText = "Ammount of stairs to build."
			}, function(s)
				return s == "-" and s or tonumber(s) and math.round(s)
			end)

			Building:button {
				Text = "Create Stairs",
				onClick = function()
					local ammount = tonumber(stairAmmount.Text)
					if not ammount or ammount == 0 then
						return
					end

					local model = game:GetService("Selection"):Get()[1]

					local parts = model:GetChildren()
					table.sort(parts, function(a,b)
						return a:GetPivot().Position.Y < b:GetPivot().Position.Y 
					end)

					local direction = -(parts[1]:GetPivot().Position-parts[2]:GetPivot().Position)
					local isNegative

					if ammount < 0 then
						ammount = -ammount
						direction = -direction
						isNegative = true
					end

					local nextPart = parts[isNegative and 1 or #parts]
					for i = 1, ammount or 1 do
						local newPart = nextPart:Clone()
						newPart:PivotTo(newPart:GetPivot() + direction)
						newPart.Parent = model

						nextPart = newPart
					end

					game:GetService("ChangeHistoryService"):SetWaypoint("Build")
				end,
			}
		end

		local parentOut = function()
			local selection = game:GetService("Selection"):Get()
			for _,v in selection do
				v.Parent = v.Parent.Parent
			end
		end

		Building:button {
			Text = "Parent Out",
			onClick = parentOut,
		}
		
		plugin:CreatePluginAction(
			"parentOutAction",
			"Parent out selected",
			"Parents selected objects into their parent",
			""
		).Triggered:Connect(parentOut)

		local center = function()
			local selection = game:GetService("Selection"):Get()
			if not selection[1] then
				warn("Nothing is selected")
				return
			end

			if #selection < 3 then
				warn("Must select atleast 3 objects to center")
				return
			end

			if not selection[1]:IsA("BasePart") and not selection[1]:IsA("Model") then
				warn("Object to center must be either a basepart or a model")
				return
			end

			local position = Vector3.zero
			for i,v in selection do
				if i == 1 then
					continue
				end

				if not v:IsA("BasePart") and not v:IsA("Model") then
					warn("One of the selected objects is neither a basepart nor a model")

					return
				end

				position += v:GetPivot().Position
			end

			local orientation = (selection[1]:GetPivot()-selection[1]:GetPivot().Position)
			selection[1]:PivotTo(CFrame.new(position/(#selection-1)) * orientation)
		end
	
		Building:button {
			Text = "Center",
			onClick = center,
		}
		
		plugin:CreatePluginAction(
			"centerAction",
			"Center selected",
			"Centers first selected object between others",
			""
		).Triggered:Connect(center)
		
		if not game:GetService("Players").LocalPlayer then
			repeat task.wait() until game:GetService("Players").LocalPlayer
		end

		local cons = {}
		local lightsEnabled
		local n = "lightBillboard"..game:GetService("Players").LocalPlayer.UserId
		if game.StarterGui:FindFirstChild(n) then
			game.StarterGui[n]:Destroy()
		end

		local function getUi()
			if game.StarterGui:FindFirstChild(n) then
				return game.StarterGui:FindFirstChild(n) 
			end

			local ui = Instance.new("ScreenGui")
			ui.Name = n
			ui.Archivable = false
			ui.Parent = game.StarterGui

			return ui
		end
		
		local showLights = function()
				lightsEnabled = not lightsEnabled

				if not lightsEnabled then
					getUi():Destroy()
					for _, v:RBXScriptConnection in cons do
						v:Disconnect()
					end
					return {Text = "Show Lights"}
				end

				local function newObj(obj:Light)
					if not obj:IsA("Light") then
						return
					end

					local billboard = Instance.new("BillboardGui")
					billboard.Active = true
					billboard.AlwaysOnTop = true
					billboard.ClipsDescendants = true
					billboard.LightInfluence = 1
					billboard.Size = UDim2.fromScale(5,5)
					billboard.Adornee = obj.Parent
					billboard.button.img.ImageColor3 = obj.Color
					billboard.Archivable = false
					billboard.Parent = getUi()
						
					local button = Instance.new("ImageButton")
					button.Image = "rbxassetid://12975600954"
					button.ImageColor3 = Color3.new(0, 0, 0)
					button.Name = button
					button.BackgroundColor3 = Color3.new(0, 0, 0)
					button.BackgroundTransparency = 1
					button.BorderColor3 = Color3.new(0, 0, 0)
					button.BorderSizePixel = 0
					button.Size = UDim2.fromScale(1,1)
					button.Parent = billboard
					
					local img = Instance.new("ImageLabel")
					img.Image = "rbxassetid://12975600954"
					img.Name = img
					img.AnchorPoint = Vector2.new(0.5, 0.5)
					img.BackgroundColor3 = Color3.new(1, 1, 1)
					img.BackgroundTransparency = 1
					img.BorderColor3 = Color3.new(0, 0, 0)
					img.BorderSizePixel = 0
					img.Position = UDim2.fromScale(.5,.5)
					img.Size = UDim2.fromScale(0.99, 0.99)

					table.insert(cons, obj.AncestryChanged:Connect(function()
						if not obj:IsDescendantOf(workspace) then
							billboard.Adornee = nil
						else
							billboard.Adornee = obj
						end
					end))

					table.insert(cons, obj.Destroying:Connect(function()
						billboard:Destroy()
					end))

					table.insert(cons, obj:GetPropertyChangedSignal("Color"):Connect(function()
						billboard.button.img.ImageColor3 = obj.Color
					end))

					billboard.button.MouseButton1Click:Connect(function()
						game:GetService("Selection"):Set({obj})
					end)
				end

				table.insert(cons, workspace.DescendantAdded:Connect(newObj))
				for _,v in workspace:GetDescendants() do
					newObj(v)
				end

				return {Text = "Hide Lights"}
			end

		Building:button {
			Text = "Show Lights",
			onClick = showLights,
		}
		
		plugin:CreatePluginAction(
			"toggleLightsAction",
			"Toggles lights",
			"Toggles the light billboard gui's",
			""
		).Triggered:Connect(showLights)
	end
end

local convert do
	convert = interface:AddTab("Convert")
	local card = convert:NewCard("Convert")
	
	local scrollingFrame
	card:textBox({
		Name = "A",
		PlaceholderText = "Search"
	}, function(new:string)
		if new == "" then
			for _,v in scrollingFrame:GetChildren() do
				if v:IsA("GuiButton") then
					v.Visible = true
				end
			end
		else
			for _,v in scrollingFrame:GetChildren() do
				if v:IsA("GuiButton") then
					v.Visible = v.Name:lower():find(new) and true or false
				end
			end
		end
		
		return new
	end)
	
	scrollingFrame = card:element("ScrollingFrame", {
		Name = "B",
		Size = UDim2.fromScale(.9, .65),
		
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		
		children = {
			["UIListLayout"] = {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
			}
		}
	})
	
	local fullList = require(script.Parent.PropertiesList)
	local list, sharedProperties = fullList[1], fullList[2]
	for objectClass, propertyList in list do
		card:button({
			Parent = scrollingFrame,
			Name = objectClass,
			Text = objectClass,
			onClick = function()
				for _, selection in game:GetService("Selection"):Get() do
					local object:Instance = Instance.new(objectClass)

					for _,v in selection:GetChildren() do
						v.Parent = object
					end

					for _, property in propertyList do
						pcall(function()
							object[property] = selection[property]
						end)
					end

					for objectType, properties in sharedProperties do
						if object:IsA(objectType) and selection:IsA(objectType) then
							for _, property in properties do
								pcall(function()
									object[property] = selection[property]
								end)
							end
						end
					end	

					for i,v in selection:GetAttributes() do
						object:SetAttribute(i, v)
					end

					for _,v in selection:GetTags() do
						object:AddTag(v)
					end

					object.Parent = selection.Parent
					selection:Remove()
				end
				
				game:GetService("ChangeHistoryService"):SetWaypoint("ConvertObject")
			end,
		})
	end
	
	local other = convert:NewCard("Other")
	other:button({
		Name = "Stringify Object",
		Text = "Stringify Object",
		onClick = function()
			local n = ""
			local function serialize(instance:Instance)
				if not instance then
					return print(nil)
				end
				
				local _, defaultObject = pcall(function()
					return Instance.new(instance.ClassName)
				end)
				
				if not defaultObject then
					warn("object cant be stringified")
					return
				end
				
				local props = list[instance.ClassName]
				local name = instance.Name
				n ..= `local {name} = Instance.new("{instance.ClassName}")\n`
				
				local toString = require(script.Parent.PropertiesList.stringify)
					
				for isa, v in sharedProperties do
					if instance:IsA(isa) then
						for _,v in v do
							table.insert(props, v)
						end
					end
				end
				
				table.remove(props, table.find(props, "Parent"))
				
				for _,v in props do
					local _, value = pcall(function()
						return instance[v]
					end)
					
					if not value then
						continue
					end
					
					local s = pcall(function()
						instance[v] = value
					end)
					
					if not s then
						continue
					end
					
					if value == defaultObject[v] then
						continue
					end
					
					n ..= `{name}.{v} = {toString(value)}\n`
				end
				
				n ..= `{name}.Parent = {instance.Parent:GetFullName()}`
			end
			
			serialize(game:GetService("Selection"):Get()[1])
			
			print(n)
		end,
	})
end

local scan do
	scan = interface:AddTab("Scan")
	
	local duplicateCard = scan:NewCard("Duplicates")
	
	local scanProperties = {"Name", "CFrame", "Size", "ClassName", "Material", "MaterialVariant", "CanCollide", "Anchored"}
	local scrollingFrame = duplicateCard:element("ScrollingFrame", {
		Name = "A",
		Size = UDim2.fromScale(.9, .7),
		
		children = {
			["UIGridLayout"] = {
				CellSize = UDim2.fromScale(.9, .1),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}
		}
	})
	
	local intitialState = true
	local t = {}
	for i, v in scanProperties do
		t[v] = intitialState
		duplicateCard:element("checkBox", {
			Parent = scrollingFrame,
			Name = v,
			Text = v,
			state = intitialState,
			
			onClick = function(state)
				t[v] = state
			end,
		})
	end
	
	duplicateCard:button {
		Text = "Scan",
		onClick = function()
			if not game:GetService("Selection"):Get()[1] then
				warn("Must select a directory to scan within")
				return
			end
			
			local scanned = {}
			local duplicates = {}

			for _, object in game:GetService("Selection"):Get()	 do
				for _, part in object:GetDescendants() do
					if not part:IsA("BasePart") then continue end

					local stringA = ""

					for v, s in t do
						if not s then
							continue
						end
						
						local PropertyValue = part[v]
						if PropertyValue then
							stringA = string.format("%s%s:'%s'", stringA, v, tostring(PropertyValue))
						end
					end

					if scanned[stringA] then
						table.insert(duplicates,part)
					else
						scanned[stringA] = true
					end
				end
			end
			
			print("duplicate parts:", duplicates)
			game:GetService("Selection"):Set(duplicates)
		end,
	}
	
	local scanCard = scan:NewCard("Scan")
	scanCard:button {
		Text = "Find Scripts",
		onClick = function()
			local found = {}
			local selection = game:GetService("Selection"):Get()
			
			for _,v in selection do
				for _,v in v:GetDescendants() do
					if v:IsA("BaseScript") or v:IsA("ModuleScript") then
						table.insert(found, v)
					end
				end
			end
			
			game:GetService("Selection"):Set(found)
			print("found scripts:", found)
		end,
	}
	
	scanCard:button {
		Text = "Find Empty Models",
		onClick = function()
			local found = {}
			local selection = game:GetService("Selection"):Get()

			for _,v in selection do
				for _,v in v:GetDescendants() do
					if v:IsA("Model") and #v:GetChildren() == 0 then
						table.insert(found, v)
					end
				end
			end

			game:GetService("Selection"):Set(found)
			print("empty models found:", found)
		end,
	}
	
	scanCard:button {
		Text = "Find Empty Meshes",
		onClick = function()
			local found = {}
			local selection = game:GetService("Selection"):Get()

			for _,v in selection do
				for _,v in v:GetDescendants() do
					if v:IsA("MeshPart") and #v:GetChildren() == 0 and v.MeshId == "" and v.TextureId == "" then
						table.insert(found, v)
					end
				end
			end

			game:GetService("Selection"):Set(found)
			print("empty meshes found:", found)
		end,
	}
end

local debug do
	debug = interface:AddTab("Debug")
	local card = debug:NewCard("debug")
	card:button({
		Text = "Put ui in selection",
		onClick = function()
			interface.body.Parent = game.Selection:Get()[1]
		end,
	})
end

interface.body.Parent = widget