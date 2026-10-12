local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')
local CONFIG, ATM_ORDER, LTN_ORDER, IGNORE_PARAMS, RANDOM_EXCLUDE = GetANLbsTemporary()

--- I'll start calling imgui widgets as widgets and not elements like previously

Anl = {}
E.Anl = {}
E.Anl.Widgets = {}

Anl.LightingTemplates = LTN_Templates
Anl.AtmosphereTemplates = ATM_Templates



function Anal3Tab(p)
	local ltnUuid = LTN_Templates['LTN_CIN_Laezel_ROM_EV11_Dawn']
	local atmUuid = ATM_Templates['ATM_CIN_WLD_Crash_Beach_FakeNight_01']


	local Ltn = Resource:GetResource(ltnUuid, 'Lighting')
	local Atm = Resource:GetResource(atmUuid, 'Atmosphere')

	Anl.CurrentLighting   = UI:SelectedOpt(E.comboLighting)
	Anl.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)

	-- local checkLock = p:AddCheckbox('Lock')
	-- checkLock.OnChange = function(e)
	-- 	Ext.GameRenderView.GetGameRenderView().LockLightingIdChange = e.Checked
	-- 	Ext.GameRenderView.GetGameRenderView().LightingIsLocked = e.Checked
	-- 	_DS(Ext.GameRenderView.GetGameRenderView())
	-- end

    p:AddText([[YOU CAN CHANGE ATMOSPHERE AND LIGHTING IN PHOTOMODE]])
    p:AddSeparator()

	p:AddSeparatorText('Parameters')

	local collapseLighting = p:AddCollapsingHeader('Lighting')
	collapseLighting.DefaultOpen = true

	local collapseAtmosphere = p:AddCollapsingHeader('Atmosphere')
	collapseAtmosphere.DefaultOpen = false



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
			SourceTable = SourceTable[Keys[i]]
		end

		return SourceTable[Keys[#Keys]]
	end



	function Anl.SetValueForAllThree(resourceType, path, value)
		if not GRVExists() then return DError('No GameRenderView') end

	    local valueType = IsValueble(value)
	    local Target =  GetGRV()['Target' .. resourceType]
	    local Target2 = GetGRV()['Cur' .. resourceType]
	    local Target3 = GetGRV()['Prev' .. resourceType]

	    if valueType == 'table' then
	        local currentValue = Anl.GetValueThroughPath(path, Target)

	        if type(currentValue) == 'number' then
	            value = value[1]

	        elseif currentValue[1] and currentValue[2] and not currentValue[3] then
	            value = {value[1], value[2]}

	        elseif currentValue[1] and currentValue[2] and currentValue[3] then
	            value = {value[1], value[2], value[3]}
	        end
	    end

	    Anl.SetValueThroughPath(path, Target, value, resourceType)
	    Anl.SetValueThroughPath(path, Target2, value, resourceType)
	    Anl.SetValueThroughPath(path, Target3, value, resourceType)

	    --- Just in case or whatever
	    -- local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
		-- local Resource = Resource:GetResource(uuid, resourceType)
	    -- Anl.SetValueThroughPath(path, Resource, value, resourceType)
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
										Anl.SetValueForAllThree(resourceType, path, e.Checked)
									end
								})

						elseif valueType == 'table' then
							if v[1] and v[2] and not v[3] then
								W[path] = currentParent:AddDrag(k, 1, MIN, MAX)
									UI:Config(W[path], {
										Components = 2,
										OnChange = function(e)
											Anl.SetValueForAllThree(resourceType, path, e.Value)
										end
									})

							elseif v[1] and v[2] and v[3] then
								W[path] = currentParent:AddColorEdit(k)
									UI:Config(W[path], {
										NoAlpha = true,
										OnChange = function(e)
											Anl.SetValueForAllThree(resourceType, path, e.Color)
										end
									})
							end

						elseif valueType == 'string' then
							W[path] = currentParent:AddInputText(k)
								UI:Config(W[path], {
									OnChange = function(e)
										Anl.SetValueForAllThree(resourceType, path, e.Text)
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
										Anl.SetValueForAllThree(resourceType, path, e.Value)
									end
								})

						end

						W[path].OnRightClick = function(e)
							Anl.ResetValueForAllThree(resourceType, path)
						end

						if k == 'ParentGUID' then
							currentParent:AddButton('Randon all')
						end

					end
				end
			end
		end
	end



	function Anl.UpdateControlValues(resourceType)
		local uuid = Anl[resourceType .. 'Templates'][Anl['Current' .. resourceType]]
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



	Anl.IgnoreParams = {
		['SSAOSettings.Bias'] = true,
		['SSAOSettings.DirectLightInfluence'] = true,
		['SSAOSettings.Enabled'] = true,
		['SSAOSettings.Intensity'] = true,
		['SSAOSettings.Radius'] = true,

		['LinearClearColor'] = true,
		['LinearClearColorOverride'] = true,

		['TimelineFog.FogLayer0.Albedo'] = true,
		['TimelineFog.FogLayer0.Density0'] = true,
		['TimelineFog.FogLayer0.Density1'] = true,
		['TimelineFog.FogLayer0.Enabled'] = true,
		['TimelineFog.FogLayer0.Height0'] = true,
		['TimelineFog.FogLayer0.Height1'] = true,
		['TimelineFog.FogLayer0.NoiseCoverage'] = true,
		['TimelineFog.FogLayer0.NoiseFrequency'] = true,
		['TimelineFog.FogLayer0.NoiseRotation'] = true,
		['TimelineFog.FogLayer0.NoiseWind'] = true,
		['TimelineFog.FogLayer1.Albedo'] = true,
		['TimelineFog.FogLayer1.Density0'] = true,
		['TimelineFog.FogLayer1.Density1'] = true,
		['TimelineFog.FogLayer1.Enabled'] = true,
		['TimelineFog.FogLayer1.Height0'] = true,
		['TimelineFog.FogLayer1.Height1'] = true,
		['TimelineFog.FogLayer1.NoiseCoverage'] = true,
		['TimelineFog.FogLayer1.NoiseFrequency'] = true,
		['TimelineFog.FogLayer1.NoiseRotation'] = true,
		['TimelineFog.FogLayer1.NoiseWind'] = true,
		['TimelineFog.Phase'] = true,
		['TimelineFog.RenderDistance'] = true,
		['TimelineFogOverride'] = true,

		['PostProcess.ColorCorrection.Contrast'] = true,
	    ['PostProcess.ColorCorrection.DarkRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.DarkRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.DarkRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrection.GlobalRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.GlobalRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.GlobalRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrection.HighlightRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.HighlightRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.HighlightRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrection.Highlights'] = true,
	    ['PostProcess.ColorCorrection.Hue'] = true,
	    ['PostProcess.ColorCorrection.LutApplyMode'] = true,
	    ['PostProcess.ColorCorrection.LutBlendFactors'] = true,
	    ['PostProcess.ColorCorrection.MidtonesRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.MidtonesRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.MidtonesRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrection.Pivot'] = true,
	    ['PostProcess.ColorCorrection.Saturation'] = true,
	    ['PostProcess.ColorCorrection.ShadowRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.ShadowRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.ShadowRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrection.Shadows'] = true,
	    ['PostProcess.ColorCorrection.SpecularRange.ExposureShift'] = true,
	    ['PostProcess.ColorCorrection.SpecularRange.Saturation'] = true,
	    ['PostProcess.ColorCorrection.SpecularRange.XYOffset'] = true,
	    ['PostProcess.ColorCorrectionInterpolationFactor'] = true,
	    ['PostProcess.FadeOut'] = true,

	    ['PostProcess.BlendedColorCorrection.Contrast'] = true,
	    ['PostProcess.BlendedColorCorrection.DarkRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.DarkRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.DarkRange.XYOffset'] = true,
	    ['PostProcess.BlendedColorCorrection.GlobalRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.GlobalRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.GlobalRange.XYOffset'] = true,
	    ['PostProcess.BlendedColorCorrection.HighlightRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.HighlightRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.HighlightRange.XYOffset'] = true,
	    ['PostProcess.BlendedColorCorrection.Highlights'] = true,
	    ['PostProcess.BlendedColorCorrection.Hue'] = true,
	    ['PostProcess.BlendedColorCorrection.LutApplyMode'] = true,
	    ['PostProcess.BlendedColorCorrection.LutBlendFactors'] = true,
	    ['PostProcess.BlendedColorCorrection.MidtonesRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.MidtonesRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.MidtonesRange.XYOffset'] = true,
	    ['PostProcess.BlendedColorCorrection.Pivot'] = true,
	    ['PostProcess.BlendedColorCorrection.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.ShadowRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.ShadowRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.ShadowRange.XYOffset'] = true,
	    ['PostProcess.BlendedColorCorrection.Shadows'] = true,
	    ['PostProcess.BlendedColorCorrection.SpecularRange.ExposureShift'] = true,
	    ['PostProcess.BlendedColorCorrection.SpecularRange.Saturation'] = true,
	    ['PostProcess.BlendedColorCorrection.SpecularRange.XYOffset'] = true,
	    ['PostProcess.Bloom'] = true,
	    ['PostProcess.BloomAmount'] = true,
	    ['PostProcess.BloomThreshold'] = true,
	    ['PostProcess.Brightness'] = true,

	    ['PostProcess.Camera.AlternateDOF.Aperture'] = true,
	    ['PostProcess.Camera.AlternateDOF.DOF'] = true,
	    ['PostProcess.Camera.AlternateDOF.FarOnly'] = true,
	    ['PostProcess.Camera.AlternateDOF.FarSharpDistance'] = true,
	    ['PostProcess.Camera.AlternateDOF.FocalDistance'] = true,
	    ['PostProcess.Camera.AlternateDOF.NearOnly'] = true,
	    ['PostProcess.Camera.AlternateDOF.NearSharpDistance'] = true,
	    ['PostProcess.Camera.DOF.Aperture'] = true,
	    ['PostProcess.Camera.DOF.DOF'] = true,
	    ['PostProcess.Camera.DOF.FarOnly'] = true,
	    ['PostProcess.Camera.DOF.FarSharpDistance'] = true,
	    ['PostProcess.Camera.DOF.FocalDistance'] = true,
	    ['PostProcess.Camera.DOF.NearOnly'] = true,
	    ['PostProcess.Camera.DOF.NearSharpDistance'] = true,
	    ['PostProcess.Camera.DOFForcedSettingsEnabled'] = true,

	    ['EnvironmentEffectEnabledForTimeline.1'] = true,
	    ['EnvironmentEffectEnabledForTimeline.2'] = true,
	    ['EnvironmentEffectEnabledForTimeline.3'] = true,
	    ['EnvironmentEffectEnabledForTimeline.4'] = true,

	    ['PostProcess.GradingLutEnabled'] = true,
	    ['PostProcess.ToneMapHighlightsFixAmount'] = true,
	    ['PostProcess.UseViewModeHDRSettings'] = true,
	    ['PostProcess.Vignette'] = true,
	    ['PostProcess.VignetteColor'] = true,
	    ['PostProcess.VignetteIntensity'] = true,
	    ['PostProcess.VignettePower'] = true,
	    ['PostProcess.WhiteBalanceMatrix'] = true,
	    ['PostProcess.WhiteBalanceTint'] = true,
	    ['PostProcess.WhiteTemperature'] = true,
	    ['TimelineAutomaticLightingDefaultSetup'] = true,
	    ['TimelineAutomaticLightingDisableFlip'] = true,
	    ['Atmosphere'] = true,
	}



	Anl.LightingOrder = {
		'Sun.SunColor',
		'Sun.SunIntensity',
		'Sun.ScatteringIntensityScale',
		'Sun.Pitch',
		'Sun.Yaw',
		'Sun.RotationAsVec3',
		'Sun.LightDistance',
		'Sun.LightSize',
		'Sun.LocalCoverageEnabled',
		'Sun.LocalCoverageScalar',
		'Sun.CoverageSettings.EndHeight',
		'Sun.CoverageSettings.HorizonDistance',
		'Sun.CoverageSettings.Offset',
		'Sun.CoverageSettings.StartHeight',
		'Sun.CoverageSettings.TexResourceGUID',
		'Sun.ShadowEnabled',
		'Sun.ShadowBias',
		'Sun.ShadowFade',
		'Sun.ShadowFarPlane',
		'Sun.ShadowNearPlane',
		'Sun.ShadowObscurity',
		'Sun.CascadeCount',
		'Sun.CascadeSpeed',
		'Sun.SunlightObscurity',
		'Sun.Kelvin',
		'Sun.UseTemperature',
		'Sun.ColorAdjustedForIntensity',
		'Sun.ColorTemperatureAdjustment',

		'Moon.Enabled',
		'Moon.CastLightEnabled',
		'Moon.Color',
		'Moon.Intensity',
		'Moon.Pitch',
		'Moon.Yaw',
		'Moon.RotationAsVec3',
		'Moon.Distance',
		'Moon.Radius',
		'Moon.Earthshine',
		'Moon.MoonGlare',
		'Moon.TearsRotate',
		'Moon.TearsScale',
		'Moon.AlbedoTexResourceGUID',
		'Moon.Kelvin',
		'Moon.ColorAdjustedForIntensity',
		'Moon.ColorTemperatureAdjustment',
		'Moon.NormalTexResourceGUID',
		'Moon.TearsAlbedoTexResourceGUID',
		'Moon.TearsNormalTexResourceGUID',
		'Moon.UseTemperature',

		'SkyLight.CirrusCloudsAmount',
		'SkyLight.CirrusCloudsColor',
		'SkyLight.CirrusCloudsEnabled',
		'SkyLight.CirrusCloudsIntensity',
		'SkyLight.Color',
		'SkyLight.ColorAdjustedForIntensity',
		'SkyLight.ColorTemperatureAdjustment',
		'SkyLight.Intensity',
		'SkyLight.Kelvin',
		'SkyLight.PhysicalModel',
		'SkyLight.ProcStarsAmount',
		'SkyLight.ProcStarsEnabled',
		'SkyLight.ProcStarsIntensity',
		'SkyLight.ProcStarsSaturation',
		'SkyLight.ProcStarsShimmer',
		'SkyLight.RotateSkydomeEnabled',
		'SkyLight.ScatteringEnabled',
		'SkyLight.ScatteringIntensity',
		'SkyLight.ScatteringSunColor',
		'SkyLight.ScatteringSunIntensity',
		'SkyLight.SkydomeEnabled',
		'SkyLight.SkydomeTex',
		'SkyLight.UseTemperature',

		'Fog.FogLayer0.Albedo',
		'Fog.FogLayer0.Density0',
		'Fog.FogLayer0.Density1',
		'Fog.FogLayer0.Enabled',
		'Fog.FogLayer0.Height0',
		'Fog.FogLayer0.Height1',
		'Fog.FogLayer0.NoiseCoverage',
		'Fog.FogLayer0.NoiseFrequency',
		'Fog.FogLayer0.NoiseRotation',
		'Fog.FogLayer0.NoiseWind',
		'Fog.FogLayer1.Albedo',
		'Fog.FogLayer1.Density0',
		'Fog.FogLayer1.Density1',
		'Fog.FogLayer1.Enabled',
		'Fog.FogLayer1.Height0',
		'Fog.FogLayer1.Height1',
		'Fog.FogLayer1.NoiseCoverage',
		'Fog.FogLayer1.NoiseFrequency',
		'Fog.FogLayer1.NoiseRotation',
		'Fog.FogLayer1.NoiseWind',
		'Fog.Phase',
		'Fog.RenderDistance',

		'VolumetricCloudSettings.AmbientLightFactor',
		'VolumetricCloudSettings.BackwardScatteringG',
		'VolumetricCloudSettings.BaseColor',
		'VolumetricCloudSettings.BottomFade',
		'VolumetricCloudSettings.ConeRadius',
		'VolumetricCloudSettings.CoverageEndDistance',
		'VolumetricCloudSettings.CoverageSettings.EndHeight',
		'VolumetricCloudSettings.CoverageSettings.HorizonDistance',
		'VolumetricCloudSettings.CoverageSettings.Offset',
		'VolumetricCloudSettings.CoverageSettings.StartHeight',
		'VolumetricCloudSettings.CoverageSettings.TexResourceGUID',
		'VolumetricCloudSettings.CoverageStartDistance',
		'VolumetricCloudSettings.CoverageWindSpeed',
		'VolumetricCloudSettings.DarkOutline',
		'VolumetricCloudSettings.Density',
		'VolumetricCloudSettings.DetailScale',
		'VolumetricCloudSettings.Distortion',
		'VolumetricCloudSettings.DistortionScale',
		'VolumetricCloudSettings.Enabled',
		'VolumetricCloudSettings.ErosionEdgeSize',
		'VolumetricCloudSettings.ForwardScatteringG',
		'VolumetricCloudSettings.HorizonFade',
		'VolumetricCloudSettings.Intensity',
		'VolumetricCloudSettings.LODDistance',
		'VolumetricCloudSettings.RainCoverageMaxInfluence',
		'VolumetricCloudSettings.SampleScalar',
		'VolumetricCloudSettings.SampleThreshold',
		'VolumetricCloudSettings.ShadowFactor',
		'VolumetricCloudSettings.SunLightFactor',
		'VolumetricCloudSettings.SunRayLength',
		'VolumetricCloudSettings.TopColor',

		'TimelineFog.FogLayer0.Albedo',
		'TimelineFog.FogLayer0.Density0',
		'TimelineFog.FogLayer0.Density1',
		'TimelineFog.FogLayer0.Enabled',
		'TimelineFog.FogLayer0.Height0',
		'TimelineFog.FogLayer0.Height1',
		'TimelineFog.FogLayer0.NoiseCoverage',
		'TimelineFog.FogLayer0.NoiseFrequency',
		'TimelineFog.FogLayer0.NoiseRotation',
		'TimelineFog.FogLayer0.NoiseWind',
		'TimelineFog.FogLayer1.Albedo',
		'TimelineFog.FogLayer1.Density0',
		'TimelineFog.FogLayer1.Density1',
		'TimelineFog.FogLayer1.Enabled',
		'TimelineFog.FogLayer1.Height0',
		'TimelineFog.FogLayer1.Height1',
		'TimelineFog.FogLayer1.NoiseCoverage',
		'TimelineFog.FogLayer1.NoiseFrequency',
		'TimelineFog.FogLayer1.NoiseRotation',
		'TimelineFog.FogLayer1.NoiseWind',
		'TimelineFog.Phase',
		'TimelineFog.RenderDistance',
		'TimelineFogOverride',

		'SSAOSettings.Bias',
		'SSAOSettings.DirectLightInfluence',
		'SSAOSettings.Enabled',
		'SSAOSettings.Intensity',
		'SSAOSettings.Radius',

		'LinearClearColor',
		'LinearClearColorOverride',
		'ParentGUID',
	}


	Anl.AtmosphereOrder = {
		-- Ignore
	    "Atmosphere",

	    "FarPlane",
	    "NearPlane",

	    "WindSpeed",
	    "WindDirection",

	    "ClothWindSpeed",
	    "ClothMainWindSpeed",
	    "ClothWindVariance",
	    "ClothMainWindFrequency",
	    "ClothMaxWindDirectionOffset",
	    "ClothWindDirectionOffsetFrequency",

	    "PostProcess.GodRaysEnabled",
	    "PostProcess.GodRaysPower",
	    "PostProcess.GodRaysRayIntensity",
	    "PostProcess.GodRaysThreshold",
	    "PostProcess.GradingLut",

	    "EnvironmentEffect.1",
	    "EnvironmentEffect.2",
	    "EnvironmentEffect.3",
	    "EnvironmentEffect.4",
	    "EnvironmentEffectEnabled.1",
	    "EnvironmentEffectEnabled.2",
	    "EnvironmentEffectEnabled.3",
	    "EnvironmentEffectEnabled.4",

	    -- Ignore
	    "EnvironmentEffectEnabledForTimeline.1",
	    "EnvironmentEffectEnabledForTimeline.2",
	    "EnvironmentEffectEnabledForTimeline.3",
	    "EnvironmentEffectEnabledForTimeline.4",

	    "EnvironmentEffectGlobalEnabled",
	    "EnvironmentEffectOffset.1",
	    "EnvironmentEffectOffset.2",
	    "EnvironmentEffectOffset.3",
	    "EnvironmentEffectOffset.4",

	    -- Ignore
	    "GUID",
	    "InheritanceFlags",
	    "LocalLightSourceColor",
	    "LocalLightSourceEnabled",
	    "LocalLightSourceIntensity",
	    "LocalLightSourceOverrideSettings",

		-- Ignore
	    "PostProcess.BlendedColorCorrection.Contrast",
	    "PostProcess.BlendedColorCorrection.DarkRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.DarkRange.Saturation",
	    "PostProcess.BlendedColorCorrection.DarkRange.XYOffset",
	    "PostProcess.BlendedColorCorrection.GlobalRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.GlobalRange.Saturation",
	    "PostProcess.BlendedColorCorrection.GlobalRange.XYOffset",
	    "PostProcess.BlendedColorCorrection.HighlightRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.HighlightRange.Saturation",
	    "PostProcess.BlendedColorCorrection.HighlightRange.XYOffset",
	    "PostProcess.BlendedColorCorrection.Highlights",
	    "PostProcess.BlendedColorCorrection.Hue",
	    "PostProcess.BlendedColorCorrection.LutApplyMode",
	    "PostProcess.BlendedColorCorrection.LutBlendFactors",
	    "PostProcess.BlendedColorCorrection.MidtonesRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.MidtonesRange.Saturation",
	    "PostProcess.BlendedColorCorrection.MidtonesRange.XYOffset",
	    "PostProcess.BlendedColorCorrection.Pivot",
	    "PostProcess.BlendedColorCorrection.Saturation",
	    "PostProcess.BlendedColorCorrection.ShadowRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.ShadowRange.Saturation",
	    "PostProcess.BlendedColorCorrection.ShadowRange.XYOffset",
	    "PostProcess.BlendedColorCorrection.Shadows",
	    "PostProcess.BlendedColorCorrection.SpecularRange.ExposureShift",
	    "PostProcess.BlendedColorCorrection.SpecularRange.Saturation",
	    "PostProcess.BlendedColorCorrection.SpecularRange.XYOffset",
	    "PostProcess.Bloom",
	    "PostProcess.BloomAmount",
	    "PostProcess.BloomThreshold",
	    "PostProcess.Brightness",

	    -- Ignore
	    "PostProcess.Camera.AlternateDOF.Aperture",
	    "PostProcess.Camera.AlternateDOF.DOF",
	    "PostProcess.Camera.AlternateDOF.FarOnly",
	    "PostProcess.Camera.AlternateDOF.FarSharpDistance",
	    "PostProcess.Camera.AlternateDOF.FocalDistance",
	    "PostProcess.Camera.AlternateDOF.NearOnly",
	    "PostProcess.Camera.AlternateDOF.NearSharpDistance",
	    "PostProcess.Camera.DOF.Aperture",
	    "PostProcess.Camera.DOF.DOF",
	    "PostProcess.Camera.DOF.FarOnly",
	    "PostProcess.Camera.DOF.FarSharpDistance",
	    "PostProcess.Camera.DOF.FocalDistance",
	    "PostProcess.Camera.DOF.NearOnly",
	    "PostProcess.Camera.DOF.NearSharpDistance",
	    "PostProcess.Camera.DOFForcedSettingsEnabled",

	    "PostProcess.Camera.Exposure.1.Delta.Enabled",
	    "PostProcess.Camera.Exposure.1.Delta.Settings.DeltaCompensation",
	    "PostProcess.Camera.Exposure.1.Delta.Settings.DeltaMax",
	    "PostProcess.Camera.Exposure.1.Delta.Settings.DeltaMin",
	    "PostProcess.Camera.Exposure.1.Exposure",
	    "PostProcess.Camera.Exposure.1.ExposureCompensation",
	    "PostProcess.Camera.Exposure.1.ExposureMax",
	    "PostProcess.Camera.Exposure.1.ExposureMaxPercentile",
	    "PostProcess.Camera.Exposure.1.ExposureMeteringMode",
	    "PostProcess.Camera.Exposure.1.ExposureMin",
	    "PostProcess.Camera.Exposure.1.ExposureMinPercentile",
	    "PostProcess.Camera.Exposure.2.Delta.Enabled",
	    "PostProcess.Camera.Exposure.2.Delta.Settings.DeltaCompensation",
	    "PostProcess.Camera.Exposure.2.Delta.Settings.DeltaMax",
	    "PostProcess.Camera.Exposure.2.Delta.Settings.DeltaMin",
	    "PostProcess.Camera.Exposure.2.Exposure",
	    "PostProcess.Camera.Exposure.2.ExposureCompensation",
	    "PostProcess.Camera.Exposure.2.ExposureMax",
	    "PostProcess.Camera.Exposure.2.ExposureMaxPercentile",
	    "PostProcess.Camera.Exposure.2.ExposureMeteringMode",
	    "PostProcess.Camera.Exposure.2.ExposureMin",
	    "PostProcess.Camera.Exposure.2.ExposureMinPercentile",
	    "PostProcess.Camera.LensFlareChromaticDistortion",
	    "PostProcess.Camera.LensFlareEnabled",
	    "PostProcess.Camera.LensFlareGhostDispersal",
	    "PostProcess.Camera.LensFlareHaloWidth",
	    "PostProcess.Camera.LensFlareIntensity",
	    "PostProcess.Camera.LensFlareTreshold",

	    -- Ignore
	    "PostProcess.ColorCorrection.Contrast",
	    "PostProcess.ColorCorrection.DarkRange.ExposureShift",
	    "PostProcess.ColorCorrection.DarkRange.Saturation",
	    "PostProcess.ColorCorrection.DarkRange.XYOffset",
	    "PostProcess.ColorCorrection.GlobalRange.ExposureShift",
	    "PostProcess.ColorCorrection.GlobalRange.Saturation",
	    "PostProcess.ColorCorrection.GlobalRange.XYOffset",
	    "PostProcess.ColorCorrection.HighlightRange.ExposureShift",
	    "PostProcess.ColorCorrection.HighlightRange.Saturation",
	    "PostProcess.ColorCorrection.HighlightRange.XYOffset",
	    "PostProcess.ColorCorrection.Highlights",
	    "PostProcess.ColorCorrection.Hue",
	    "PostProcess.ColorCorrection.LutApplyMode",
	    "PostProcess.ColorCorrection.LutBlendFactors",
	    "PostProcess.ColorCorrection.MidtonesRange.ExposureShift",
	    "PostProcess.ColorCorrection.MidtonesRange.Saturation",
	    "PostProcess.ColorCorrection.MidtonesRange.XYOffset",
	    "PostProcess.ColorCorrection.Pivot",
	    "PostProcess.ColorCorrection.Saturation",
	    "PostProcess.ColorCorrection.ShadowRange.ExposureShift",
	    "PostProcess.ColorCorrection.ShadowRange.Saturation",
	    "PostProcess.ColorCorrection.ShadowRange.XYOffset",
	    "PostProcess.ColorCorrection.Shadows",
	    "PostProcess.ColorCorrection.SpecularRange.ExposureShift",
	    "PostProcess.ColorCorrection.SpecularRange.Saturation",
	    "PostProcess.ColorCorrection.SpecularRange.XYOffset",
	    "PostProcess.ColorCorrectionInterpolationFactor",
	    "PostProcess.FadeOut",

	    -- Ignore
	    "PostProcess.GradingLutEnabled",
	    "PostProcess.ToneMapHighlightsFixAmount",
	    "PostProcess.UseViewModeHDRSettings",
	    "PostProcess.Vignette",
	    "PostProcess.VignetteColor",
	    "PostProcess.VignetteIntensity",
	    "PostProcess.VignettePower",
	    "PostProcess.WhiteBalanceMatrix",
	    "PostProcess.WhiteBalanceTint",
	    "PostProcess.WhiteTemperature",
	    "TimelineAutomaticLightingDefaultSetup",
	    "TimelineAutomaticLightingDisableFlip",
	}


	Anl.CreateParameterControls(Ltn, collapseLighting)
	Anl.CreateParameterControls(Atm, collapseAtmosphere)

end
