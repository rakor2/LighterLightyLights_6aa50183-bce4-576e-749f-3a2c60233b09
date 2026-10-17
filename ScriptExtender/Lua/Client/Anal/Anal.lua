Anl = {}


if Settings.degenExtendedScriptExtender then
	if Ext.GameRenderView and Ext.GameRenderView.GetGameRenderView() then
		DPrint('GameRenderView exists! PagMan')
	else
		DError([[GameRenderView don't exists! Not PagMan]])
	end
end



local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')
local CONFIG, ATM_ORDER, LTN_ORDER, IGNORE_PARAMS, RANDOM_EXCLUDE = GetANLbsTemporary()
local Res = Ext.Require('Client/Anal/Resources.lua')

Anl.LightingOrder, Anl.AtmosphereOrder = Ext.Require('Client/Anal/AnalOrders.lua')
Anl.IgnoreParams = Ext.Require('Client/Anal/AnalIgnored.lua')


E.Anl = {}
--- I'll start calling imgui widgets as widgets and not elements like previously
E.Anl.Widgets = {}

Anl.LightingTemplates = LTN_Templates
Anl.AtmosphereTemplates = ATM_Templates

_GLL.LtnComboOptions = {}
_GLL.AtmComboOptions = {}


local ltnUuid = LTN_Templates['LTN_CIN_Laezel_ROM_EV11_Dawn']
local atmUuid = ATM_Templates['ATM_CIN_WLD_Crash_Beach_FakeNight_01']


local Ltn = Resource:GetResource(ltnUuid, 'Lighting')
local Atm = Resource:GetResource(atmUuid, 'Atmosphere')



function PopulateLTNOptions()
    for _, name in ipairs(MapToArray(LTN_Templates)) do
        table.insert(_GLL.LtnComboOptions, name)
    end
end
PopulateLTNOptions()



function PopulateATMOptions()
    for _, name in ipairs(MapToArray(ATM_Templates)) do
        table.insert(_GLL.AtmComboOptions, name)
    end
end
PopulateATMOptions()



---@param hardcode string #yeaaah, the code is hard af B)
function CreateSelectable(parent, tbl, lable, hardcode, hardcode2)
    local selectable
    local id = Ext.Math.Random(1, 9999)
    local delete = parent:AddButton('X')
    delete.IDContext = id
    delete.SameLine = false
    delete.OnClick = function ()
        tbl[lable] = nil
        Ext.IO.SaveFile('LightyLights/' .. hardcode .. '.json', Ext.Json.Stringify(tbl))
        selectable:Destroy()
        delete:Destroy()
    end

    selectable = parent:AddButton(lable)
    selectable.IDContext = id
    selectable.SameLine = true
    selectable.OnClick = function ()
        -- Ext.Net.PostMessageToServer(hardcode2, selectable.Label)

        if hardcode2 == 'LL_LightingApply' then
            E.comboLighting.SelectedIndex = table.find(_GLL.LtnComboOptions, selectable.Label) - 1
            ANL.SetLigthing(LTN_Templates[UI:SelectedOpt(E.comboLighting)])
        else
            E.comboAtmosphere.SelectedIndex = table.find(_GLL.AtmComboOptions, selectable.Label) - 1
            ANL.SetAtmosphere(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)])
        end
    end
    tbl[lable] = lable
    Ext.IO.SaveFile('LightyLights/' .. hardcode .. '.json', Ext.Json.Stringify(tbl))
end



function PopulateLTNFavorites(imguiWindow, tbl)
    for _,lable in pairs(tbl) do
        CreateSelectable(imguiWindow, tbl, lable, 'FavoriteLighting', 'LL_LightingApply')
    end
end



function PopulateATMFavorites(imguiWindow, tbl)
    for _,lable in pairs(tbl) do
        CreateSelectable(imguiWindow, tbl, lable, 'FavoriteAtmosphere', 'LL_AtmosphereApply')
    end
end



function CreatePresetSelectable(parent, tbl, label, type_)
    local selectable
    local id = Ext.Math.Random(1, 9999)
    local delete = parent:AddButton('X')
    delete.IDContext = id
    delete.SameLine = false
    delete.OnClick = function()
        tbl[label] = nil
        Ext.IO.SaveFile('LightyLights/AnLPresets/_' .. type_ .. 'Names.json', Ext.Json.Stringify(tbl))

        pcall(function()
            Ext.IO.SaveFile('LightyLights/AnLPresets/' .. type_ .. '/' .. label .. '.json', '')
        end)

        selectable:Destroy()
        delete:Destroy()
    end

    selectable = parent:AddButton(label)
    selectable.IDContext = id
    selectable.SameLine = true
    selectable.OnClick = function()
        LoadPreset(label, type_)
    end

    tbl[label] = label
    Ext.IO.SaveFile('LightyLights/AnLPresets/_' .. type_ .. 'Names.json', Ext.Json.Stringify(tbl))
end


function PopulatePresets(imguiWindow, tbl, type_)
    for _, label in pairs(tbl) do
        CreatePresetSelectable(imguiWindow, tbl, label, type_)
    end
end



function SelectAtmosphereFromCurrentTrigger()
    local atmUuid, _ = GetAtmosphereAndLightingInCurrentTrigger()
    if not atmUuid then return end

    for k, v in pairs(ATM_Templates) do
        if v == atmUuid then
            local atmIndex = table.find(E.comboAtmosphere.Options, k) - 1
            E.comboAtmosphere.SelectedIndex = atmIndex
            -- Anl.SetAtmosphereAndUpdateUI()
            Anl.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)
            Anl.UpdateControlValues('Atmosphere', atmUuid)
        end
    end
end



function SelectLightingFromCurrentTrigger()
    local _, ltnUuid = GetAtmosphereAndLightingInCurrentTrigger()
    if not ltnUuid then return end

    for k, v in pairs(LTN_Templates) do
        if v == ltnUuid then
            local ltnIndex = table.find(E.comboLighting.Options, k) - 1
            E.comboLighting.SelectedIndex = ltnIndex
            -- Anl.SetLightingAndUpdateUI()
            Anl.CurrentLighting = UI:SelectedOpt(E.comboLighting)
            Anl.UpdateControlValues('Lighting', ltnUuid)
        end
    end
end



function SelectAtmosphereAndLightingFromCurrentTrigger()
    SelectAtmosphereFromCurrentTrigger()
    SelectLightingFromCurrentTrigger()
end



local function GetGRV()
	return Ext.GameRenderView.GetGameRenderView()
end



function GRVExists()
	if Ext.GameRenderView.GetGameRenderView() and Ext.GameRenderView.GetGameRenderView().CurLighting then
		return true
	end
end



local function ResolveObjectType(Tbl)
	return Ext.Types.GetObjectType(Tbl):match('([^:]+)$')
end


local xd = {'table', 'number', 'boolean', 'string'}

local function IsValueble(value)
	for k, v in pairs(xd) do
		if type(value) == v then
			return type(value)
		end
	end
end



local function TraverseTable(tbl)
	for k, v in pairs(tbl) do
		DPrint(k)
		if IsValueble(v) then
			DDump(v)
		end
		if ResolveObjectType(v) then
			TraverseTable(v)
		end
	end
end


-- local function TraverseTableAndGetPaths(tbl, path, paths)
-- 	paths = paths or {}
-- 	path = path or ''

-- 	for k, v in pairs(tbl) do
-- 		local currentPath = path == '' and k or path .. '.' .. k

-- 		if IsValueble(v) then
-- 			paths[#paths + 1] = currentPath
-- 		end

-- 		if ResolveObjectType(v) then
-- 			TraverseTableAndGetPaths(v, currentPath, paths)
-- 		end
-- 	end
-- 	return paths
-- end


--- Needed for jank
Anl.CapturedValues = {}

function Anl.CaptureValue(resourceType, path, value)
	Anl.CapturedValues[path] = {Value = value, Type = resourceType}
	-- DDump(Anl.CapturedValues)
	return Anl.CapturedValues
end



function Anl.RestoreCapturedValues()
	for path, Xds in pairs(Anl.CapturedValues) do
		Anl.SetValueForAllThree(Xds.Type, path, Xds.Value)
	end
	return Anl.CapturedValues
end



function Anl.Switch()
	if not _GLL.CurrentLighting and not _GLL.CurrentAtmosphere then return end
	ANL.ApplyLighting()
	ANL.ApplyAtmosphere()

	OnTicks(3, function()
		Anl.RestoreCapturedValues()
	end)
end



function Anl.SetValueThroughPath(path, DestinationTable, value, resourceType)
	local Keys = {}

	for k in path:gmatch("[^.]+") do
		Keys[#Keys + 1] = k
	end

	for i = 1, #Keys - 1 do
		DestinationTable = DestinationTable[Keys[i]]
	end

	DestinationTable[Keys[#Keys]] = value

	if resourceType then
		Anl.CaptureValue(resourceType, path, value)
	end
end



function Anl.GetValueThroughPath(path, SourceTable)
	local Keys = {}

	for k in path:gmatch("[^.]+") do
		Keys[#Keys + 1] = k
	end

	for i = 1, #Keys - 1 do
		SourceTable = SourceTable[tonumber(Keys[i]) or Keys[i]]
	end

	local Key = tonumber(Keys[#Keys]) or Keys[#Keys]

	return SourceTable[Key]
end



function Anl.SetValueForAllThree(resourceType, path, value)
	if not GRVExists() then return DError('No GameRenderView') end

    local Target =  GetGRV()['Target' .. resourceType]
    local Cur = GetGRV()['Cur' .. resourceType]
    local Prev = GetGRV()['Prev' .. resourceType]

    Anl.SetValueThroughPath(path, Target, value, resourceType)
    Anl.SetValueThroughPath(path, Cur, value, resourceType)
    Anl.SetValueThroughPath(path, Prev, value, resourceType)

    -- local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	-- local Resource = Resource:GetResource(uuid, resourceType)
    -- Anl.SetValueThroughPath(path, Resource, value, resourceType)

end



function Anl.SetResourceValue(resourceType, path, value)
    local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	local Resource = Resource:GetResource(uuid, resourceType)
    Anl.SetValueThroughPath(path, Resource, value, resourceType)

    Anl.ApplyParameters(resourceType)
end



function Anl.SetValue(resourceType, path, value)
	if Settings.degenExtendedScriptExtender then
		Anl.SetValueForAllThree(resourceType, path, value)
	else
		Anl.SetResourceValue(resourceType, path, value)
	end
end



function Anl.SetLightingAndUpdateUI()
    Anl.CapturedValues = {}

    DisplayBlockedLevel()
    ANL.SetLigthing(LTN_Templates[UI:SelectedOpt(E.comboLighting)])
    Anl.UpdateControlValues('Lighting')
end



function Anl.SetAtmosphereAndUpdateUI()
    Anl.CapturedValues = {}

    DisplayBlockedLevel()
    ANL.SetAtmosphere(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)])
    Anl.UpdateControlValues('Atmosphere')
end



function Anl.ApplyParameters(type_)
    if type_ == 'Lighting' or type_ == 'All' then
        ANL.SetLigthing(LTN_Templates[UI:SelectedOpt(E.comboLighting)])
        ANL.ApplyLighting()
    end

    if type_ == 'Atmosphere' or type_ == 'All' then
        ANL.SetAtmosphere(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)])
        ANL.ApplyAtmosphere()
    end
end



local ZipBomb = GetZipBombTemporary()

function Anl.ResetValueForAllThree(resourceType, path)
	-- DDump(resourceType)
	-- DDump(path)
	-- DDump(Anl[resourceType .. 'Templates'])
	local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	local CachedTable = ZipBomb['Cached' .. resourceType][uuid][2]
	local value = Anl.GetValueThroughPath(path, CachedTable)
	local valueType = IsValueble(value)

	-- DDump(value)
	-- DDump(valueType)
	-- DPrint(path)

	Anl.SetValueForAllThree(resourceType, path, value)

	if not Anl.IgnoreParams[path] then
		if valueType == 'boolean' then
			E.Anl.Widgets[path].Checked = value

		elseif valueType == 'table' then
			local widgetType = ResolveObjectType(E.Anl.Widgets[path])
			if widgetType == 'ColorEdit' then
				local Value = {value[1], value[2], value[3], 1}
				E.Anl.Widgets[path].Color = Value

			elseif value[1] and value[2] and not value[3] then
				E.Anl.Widgets[path].Value = {value[1], value[2], 0, 0}

			else
				E.Anl.Widgets[path].Value = value
			end

		elseif valueType == 'string' then
			E.Anl.Widgets[path].Text = value

		elseif valueType == 'number' then
			E.Anl.Widgets[path].Value = {value, 0,0,0}
		end
	end
end



function Anl.ResetResoutceValue(resourceType, path)
	local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	local CachedTable = ZipBomb['Cached' .. resourceType][uuid][2]
	local value = Anl.GetValueThroughPath(path, CachedTable)
	local valueType = IsValueble(value)

	Anl.SetResourceValue(resourceType, path, value)


	if valueType == 'boolean' then
		E.Anl.Widgets[path].Checked = value

	elseif valueType == 'table' then
		local widgetType = ResolveObjectType(E.Anl.Widgets[path])
		if widgetType == 'ColorEdit' then
			local Value = {value[1], value[2], value[3], 1}
			E.Anl.Widgets[path].Color = Value

		elseif value[1] and value[2] and not value[3] then
			E.Anl.Widgets[path].Value = {value[1], value[2], 0, 0}

		else
			E.Anl.Widgets[path].Value = value
		end

	elseif valueType == 'string' then
		E.Anl.Widgets[path].Text = value

	elseif valueType == 'number' then
		E.Anl.Widgets[path].Value = {value, 0,0,0}
	end
end



function Anl.ResetValue(resourceType, path)
	if Settings.degenExtendedScriptExtender then
		Anl.ResetValueForAllThree(resourceType, path)
	else
		Anl.ResetResoutceValue(resourceType, path)
	end
end



function Anl.ResetValues(resourceType, all)
	if Settings.degenExtendedScriptExtender then
		for _, path in pairs (Anl[resourceType .. 'Order']) do
			Anl.ResetValueForAllThree(resourceType, path)
		end
	else
		if all then
			for _, uuid in pairs(Anl[resourceType .. 'Templates']) do
				local CachedTable = ZipBomb['Cached' .. resourceType][uuid][2]
				Ext.Types.Unserialize(Resource:GetResource(uuid, resourceType), CachedTable)
			end
		else
			local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
			local CachedTable = ZipBomb['Cached' .. resourceType][uuid][2]
			Ext.Types.Unserialize(Resource:GetResource(uuid, resourceType), CachedTable)
		end

		Anl.ApplyParameters(resourceType)
		Anl.UpdateControlValues(resourceType)
	end
end



--- TBD: Combine random all and smol randoms
function RandomAll(resourceType)

	local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	local Resource = Resource:GetResource(uuid, resourceType)

	for _, parameterPath in ipairs(Anl[resourceType .. 'Order']) do
		if not Anl.IgnoreParams[parameterPath]
			and not RANDOM_EXCLUDE[parameterPath]
		then
			local value = Anl.GetValueThroughPath(parameterPath, Resource)
			local valueType = IsValueble(value)

			local min = -222
			local max = 222

			if CONFIG[parameterPath] then
				min = CONFIG[parameterPath].min or min
				max = CONFIG[parameterPath].max or max
			end

			if valueType == 'boolean' then
				value = Ext.Math.Random(0, 1) == 1

			elseif valueType == 'number' then
				if math.type(value) == 'integer' then
					value = Ext.Math.Random(math.ceil(min), math.floor(max))
				else
					-- DPrint('-------------------')
					-- DPrint(min)
					-- DPrint(max)
					-- DPrint(parameterPath)
					value = Ext.Math.Random(min, max)
				end

			elseif valueType == 'string' then
				if parameterPath:find('Coverage') then
					local rng = Ext.Math.Random(1, #Res.Coverage)
					local uuid = Res.Coverage[rng]
					value = uuid
				elseif parameterPath:find('Tears') then
				elseif parameterPath:find('AlbedoTex') then
				elseif parameterPath:find('AlbedoTex') then
				elseif parameterPath:find('NormalTex') then
				elseif parameterPath:find('Skydome') then
				elseif parameterPath:find('ParentGUID') then
				end

			elseif valueType == 'table' then
				if value[1] and value[2] and not value[3] then
					value = {
						Ext.Math.Random(min, max),
						Ext.Math.Random(min, max)
					}
				elseif value[1] and value[2] and value[3] then
					value = {
						Ext.Math.Random(0, 1),
						Ext.Math.Random(0, 1),
						Ext.Math.Random(0, 1)
					}
				end
			end
			Anl.SetValueThroughPath(parameterPath, Resource, value)
		end
	end
	Anl.ApplyParameters(resourceType)
	Anl.UpdateControlValues(resourceType)
end



function Deepfry()
	local x = 1
	Utils:SubUnsubToTick(1, 'alwkdaw', function()
		x = x + 1
		if x%10 >= 9 then
			DPrint(x)
			TestXD()
		end
	end)
end



local Paths = {}

function Anl.CreateParameterControls(Tbl, parent)
	local MIN
	local MAX
	local LOG
	local resourceType = ResolveObjectType(Tbl)

	local W = E.Anl.Widgets --- Speed

	for _, path in ipairs(Anl[resourceType .. 'Order']) do
		if not Anl.IgnoreParams[path] then
			local CurrentTbl = Tbl
			local currentParent = parent
			local currentPath = ''

			if CONFIG[path] then
				MIN = CONFIG[path].min or -222
				MAX = CONFIG[path].max or 222
				LOG = CONFIG[path].log or false
			end

			for k in path:gmatch('[^.]+') do
				currentPath = currentPath == '' and k or currentPath .. '.' .. k

				if currentPath ~= path then
					if not W[currentPath] then
						currentParent:AddSeparatorText('')
						W[currentPath] = currentParent:AddTree(k)

						local xdd = currentPath

						currentParent = W[currentPath]

						W['rng' .. currentPath] = currentParent:AddButton('Random')
						UI:Config(W['rng' .. currentPath], {
							OnClick = function(e)
								--- TBD: Refactor to a separate function
								for _, parameterPath in ipairs(Anl[resourceType .. 'Order']) do
									if not Anl.IgnoreParams[parameterPath]
										and not RANDOM_EXCLUDE[parameterPath]
										and parameterPath:sub(1, #xdd + 1) == xdd .. '.' then

										local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
										local Resource = Resource:GetResource(uuid, resourceType)

										local value = Anl.GetValueThroughPath(parameterPath, Resource)
										local valueType = IsValueble(value)

										local min = -222
										local max = 222

										if CONFIG[parameterPath] then
											min = CONFIG[parameterPath].min or min
											max = CONFIG[parameterPath].max or max
										end

										if valueType == 'boolean' then
											value = Ext.Math.Random(0, 1) == 1

										elseif valueType == 'number' then
											if math.type(value) == 'integer' then
												value = Ext.Math.Random(math.ceil(min), math.floor(max))
											else
												-- DPrint('-------------------')
												-- DPrint(min)
												-- DPrint(max)
												-- DPrint(parameterPath)
												value = Ext.Math.Random(min, max)
											end

										elseif valueType == 'string' then
											if parameterPath:find('Coverage') then
												local rng = Ext.Math.Random(1, #Coverage)
												local uuid = Res.Coverage[rng]
											elseif parameterPath:find('Tears') then
											elseif parameterPath:find('AlbedoTex') then
											elseif parameterPath:find('AlbedoTex') then
											elseif parameterPath:find('NormalTex') then
											elseif parameterPath:find('Skydome') then
											elseif parameterPath:find('ParentGUID') then
											elseif parameterPath:find('1')
												or parameterPath:find('2')
												or parameterPath:find('3')
												or parameterPath:find('4')
											then
												local rng = Ext.Math.Random(1, #Res.Effect)
												local uuid = Res.Effect[rng]
												value = uuid
											end

										elseif valueType == 'table' then
											if value[1] and value[2] and not value[3] then
												value = {
													Ext.Math.Random(min, max),
													Ext.Math.Random(min, max)
												}
											elseif value[1] and value[2] and value[3] then
												value = {
													Ext.Math.Random(0, 1),
													Ext.Math.Random(0, 1),
													Ext.Math.Random(0, 1)
												}
											end
										end

										Anl.SetValueThroughPath(parameterPath, Resource, value)
									end
								end
								Anl.UpdateControlValues(resourceType)
								Anl.ApplyParameters(resourceType)
							end
						})
					end

					currentParent = W[currentPath]
					CurrentTbl = CurrentTbl[k]

				else
					local v = CurrentTbl[k]
					local valueType = IsValueble(v)

					if valueType == 'boolean' then
						W[path] = currentParent:AddCheckbox(k)
						UI:Config(W[path], {
							OnChange = function(e)
								Anl.SetValue(resourceType, path, e.Checked)
							end
						})

					elseif valueType == 'table' then
						if v[1] and v[2] and not v[3] then
							W[path] = currentParent:AddDrag(k, 1, MIN, MAX)
							UI:Config(W[path], {
								Components = 2,
								OnChange = function(e)
									Anl.SetValue(resourceType, path, {e.Value[1], e.Value[2]})
								end
							})

						elseif v[1] and v[2] and v[3] then
							W[path] = currentParent:AddColorEdit(k)
							UI:Config(W[path], {
								NoAlpha = true,
								OnChange = function(e)
									Anl.SetValue(resourceType, path, {e.Color[1], e.Color[2], e.Color[3]})
								end
							})
						end

					elseif valueType == 'string' then
						W[path] = currentParent:AddInputText(k)
						UI:Config(W[path], {
							OnChange = function(e)
								Anl.SetValue(resourceType, path, e.Text)
							end
						})

					elseif valueType == 'number' then
						if math.type(v) == 'integer' then
							W[path] = currentParent:AddSliderInt(k, 1, MIN, MAX)
						elseif MAX > 3000 then
							W[path] = currentParent:AddSlider(k, 1, MIN, MAX)
						else
							W[path] = currentParent:AddDrag(k, 1, MIN, MAX)
						end

						UI:Config(W[path], {
							OnChange = function(e)
								Anl.SetValue(resourceType, path, e.Value[1])
							end
						})
					end

					W[path].OnRightClick = function(e)
						Anl.ResetValue(resourceType, path)
					end

					if k == 'ParentGUID' or k == 'GUID' then
						local x = currentParent:AddButton('Random all')
						x.OnClick = function()
							RandomAll(resourceType)
						end
					end
				end
			end
		end
	end
end

function Anl.UpdateControlValues(resourceType, uuid)
	local uuid = uuid or Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
	local Tbl = Resource:GetResource(uuid, resourceType)

	for _, path in pairs(Anl[resourceType .. 'Order']) do
		if not Anl.IgnoreParams[path] then
			local value = Anl.GetValueThroughPath(path, Tbl)
			local valueType = IsValueble(value)

			if valueType == 'boolean' then
				E.Anl.Widgets[path].Checked = value

			elseif valueType == 'table' then
				local widgetType = ResolveObjectType(E.Anl.Widgets[path])
				if widgetType == 'ColorEdit' then
					local Value = {value[1], value[2], value[3], 1}
					E.Anl.Widgets[path].Color = Value

				elseif value[1] and value[2] and not value[3] then
					E.Anl.Widgets[path].Value = {value[1], value[2], 0, 0}

				else
					E.Anl.Widgets[path].Value = value
				end

			elseif valueType == 'string' then
				E.Anl.Widgets[path].Text = value

			elseif valueType == 'number' then
				E.Anl.Widgets[path].Value = {value, 0,0,0}
			end
		end
	end
end


return Anl