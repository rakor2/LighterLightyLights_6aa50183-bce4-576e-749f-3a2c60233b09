local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')
local CONFIG, ATM_ORDER, LTN_ORDER, IGNORE_PARAMS, RANDOM_EXCLUDE = GetANLbsTemporary()
-- local Anl = Ext.Require('Client/Anal/Anal.lua')

local AtmospherePresets = {}
local LightingPresets = {}



function Anal3Tab(p)
    local CHILD_WIN_SIZE = {554, 200}
    local winLtnFav
    local winAtmFav
    _GLL.FilteredLTNOptions = _GLL.LtnComboOptions
    _GLL.FilteredATMOptions = _GLL.AtmComboOptions

    p:AddText([[YOU CAN'T CHANGE ATMOSPHERE AND LIGHTING IN PHOTOMODE. Yet :)]])
    p:AddSeparator()

    local dddd = p:AddButton([[Select current atmosphere and lighting]])
        UI:Config(dddd, {
            OnClick = function(e)
                SelectAtmosphereAndLightingFromCurrentTrigger()
            end,
            Tooltip = [[       Select level's atmosphere and lighting. It also selects when you open the window]]
        })

    E.grpBlocked = p:AddGroup('Blocked')

    function DisplayBlockedLevel()
        if E and E.textBlocked then
            E.textBlocked:Destroy()
        end
        for levelName, _ in pairs(ANL.Blocked) do
            if _C() and _C().Level and _C().Level.LevelName == levelName then
                local xd = string.format([[Author asked to block %s. You can't change anything. GG.]], levelName)
                E.textBlocked = E.grpBlocked:AddText(xd)
                break
            end
        end
    end
    DisplayBlockedLevel()


    p:AddSeparatorText('Lighting')

    E.inpSearchLighting = p:AddInputText('')
        UI:Config(E.inpSearchLighting, {
            OnChange  = function()
                _GLL.FilteredLTNOptions = UI:FilterOptions(E.inpSearchLighting.Text, _GLL.LtnComboOptions)
                E.comboLighting.Options = _GLL.FilteredLTNOptions
                E.comboLighting.SelectedIndex = 0
            end,
            Hint = 'night default'
        })



    E.btnClearSearch = p:AddButton('Search')
        UI:Config(E.btnClearSearch, {
            SameLine = true,
            OnClick  = function()
                E.inpSearchLighting.Text = ''
                _GLL.FilteredLTNOptions = _GLL.LtnComboOptions
                E.comboLighting.Options = _GLL.LtnComboOptions
            end
        })



    E.comboLighting = p:AddCombo('')
        UI:Config(E.comboLighting, {
            Options       = _GLL.LtnComboOptions or {},
            SelectedIndex = 0,
            ItemWidth     = COMBO_WIDTH,
            OnChange      = function()
                Anl.SetLightingAndUpdateUI()
            end,
            OnRightClick  = function()
                Anl.SetLightingAndUpdateUI()
            end
        })


    E.btnPrevLtn = p:AddButton('<')
        UI:Config(E.btnPrevLtn, {
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboLighting)
                Anl.SetLightingAndUpdateUI()
            end
        })



    E.btnNextLtn = p:AddButton('>')
        UI:Config(E.btnNextLtn, {
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboLighting)
                Anl.SetLightingAndUpdateUI()
            end
        })



    E.btnAddToFav = p:AddButton('Add to favorites')
        UI:Config(E.btnAddToFav, {
            SameLine  = true,
            OnClick   = function(e)
                if _GLL.FavLighting[UI:SelectedOpt(E.comboLighting)] == UI:SelectedOpt(E.comboLighting) then
                    UI:DisplayInfoInCombo(e, 'The lighting already added')
                    return
                else
                    CreateSelectable(winLtnFav, _GLL.FavLighting, _GLL.FilteredLTNOptions[E.comboLighting.SelectedIndex + 1], 'FavoriteLighting', 'LL_LightingApply')
                end
            end
        })



    E.resetLtnBtn = p:AddButton('Reset')
        UI:Config(E.resetLtnBtn, {
            OnClick   = function()
                ANL.ResetLightingToResourceIDs()
                SelectLightingFromCurrentTrigger()
            end
        })



    E.btnLtnRandom = p:AddButton('Random')
        UI:Config(E.btnLtnRandom, {
            SameLine  = true,
            OnClick   = function()
                UI:RandomOption(E.comboLighting)
                Anl.SetLightingAndUpdateUI()
            end
        })



    E.colFav = p:AddCollapsingHeader('Favorites')
        UI:Config(E.colFav, { IDContext = 'iaeuhkbnkwbriyuwg34iy' })

    winLtnFav = E.colFav:AddChildWindow('')
    winLtnFav.Size = CHILD_WIN_SIZE



    E.collapseLightProbes = p:AddCollapsingHeader('Harsh shadows workaround')

    E.btnParent = E.collapseLightProbes:AddButton([[I don't see harsh shadows with this lighting preset]])
        UI:Config(E.btnParent, {
            OnClick = function()
                local seleted    = UI:SelectedOpt(E.comboLighting)
                local ParentGUID = Ext.Resource.Get(LTN_Templates[seleted], 'Lighting').Lighting.ParentGUID
                _GLL.lightingParent = ParentGUID
                E.btnParentSet.Label = 'Fix harsh shadows using: ' .. seleted .. ' as parent lighting'
            end
        })



    local canClick = true

    E.btnParentSet = E.collapseLightProbes:AddButton('Fix harsh shadows using: Parent lighting in unset')
        UI:Config(E.btnParentSet, {
            OnClick = function()
                if canClick then
                    if _GLL.lightingParent then
                        local LTN = Ext.Types.Serialize(Ext.Resource.Get(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting'))
                        LTN.ParentGUID = _GLL.lightingParent
                        Ext.Types.Unserialize(Ext.Resource.Get(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting').Lighting, LTN)
                        Anl.ApplyParameters('Lighting')
                    else
                        canClick = false
                        E.btnParentSet.Label = 'Parent lighting is unset'
                        OnTicks(150, function()
                            E.btnParentSet.Label = 'Fix harsh shadows using: Parent lighting in unset'
                            canClick = true
                        end)
                    end
                end
            end
        })


    --- TBD: Move this
    function Utils.MapValueToArray(MapTbl)
        local Keys = {}
        for _, value in pairs(MapTbl) do
            table.insert(Keys, value)
        end
        return Keys
    end



    local Array_LTN_Templates = Utils.MapValueToArray(LTN_Templates)
    local ltnI = 0

    E.btnParentPrev = E.collapseLightProbes:AddButton('<')
        UI:Config(E.btnParentPrev, {
            OnClick = function()
                local ltnUuid = LTN_Templates[UI:SelectedOpt(E.comboLighting)]
                Ext.Resource.Get(ltnUuid, 'Lighting').Lighting.ParentGUID = Array_LTN_Templates[ltnI]
                DPrint(Array_LTN_Templates[ltnI])

                for k, v in pairs(LTN_Templates) do
                    if v == Array_LTN_Templates[ltnI] then
                        DPrint(k)
                    end
                end

                if ltnI <= 0 then ltnI = #Array_LTN_Templates end
                ltnI = ltnI - 1
                ANL.ApplyLighting()
                ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
            end
        })



    E.btnParentNext = E.collapseLightProbes:AddButton('>')
        UI:Config(E.btnParentNext, {
            SameLine = true,
            OnClick = function()
                local ltnUuid = LTN_Templates[UI:SelectedOpt(E.comboLighting)]
                Ext.Resource.Get(ltnUuid, 'Lighting').Lighting.ParentGUID = Array_LTN_Templates[ltnI]
                DPrint(ltnI)
                if ltnI > #Array_LTN_Templates then ltnI = 1 end
                ltnI = ltnI + 1
                ANL.ApplyLighting()
                ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
            end
        })



    if Ext.IO.LoadFile('LightyLights/FavoriteLighting.json') then
        pcall(function()
            _GLL.FavLighting = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteLighting.json'))
            PopulateLTNFavorites(winLtnFav, _GLL.FavLighting)
        end)
    else
        _GLL.FavLighting = {}
    end



    p:AddSeparatorText('Atmosphere')



    E.inpSearchAtmosphere = p:AddInputText('')
        UI:Config(E.inpSearchAtmosphere, {
            OnChange  = function(e)
                _GLL.FilteredATMOptions = UI:FilterOptions(e.Text, _GLL.AtmComboOptions)
                E.comboAtmosphere.Options = _GLL.FilteredATMOptions
                E.comboAtmosphere.SelectedIndex = 0
            end,
            Hint = 'Morning'
        })



    E.btnClearSearchAtm = p:AddButton('Search')
        UI:Config(E.btnClearSearchAtm, {
            SameLine  = true,
            OnClick   = function()
                E.inpSearchAtmosphere.Text = ''
                _GLL.FilteredATMOptions = _GLL.AtmComboOptions
                E.comboAtmosphere.Options = _GLL.AtmComboOptions
            end
        })



    E.comboAtmosphere = p:AddCombo('')
        UI:Config(E.comboAtmosphere, {
            Options       = _GLL.AtmComboOptions or {},
            SelectedIndex = 0,
            ItemWidth     = COMBO_WIDTH,
            OnChange      = function(e)
                Anl.SetAtmosphereAndUpdateUI()
            end,
            OnRightClick  = function(e)
                Anl.SetAtmosphereAndUpdateUI()
            end
        })



    E.btnPrevAtm = p:AddButton('<')
        UI:Config(E.btnPrevAtm, {
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboAtmosphere)
                Anl.SetAtmosphereAndUpdateUI()
            end
        })



    E.btnNextAtm = p:AddButton('>')
        UI:Config(E.btnNextAtm, {
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboAtmosphere)
                Anl.SetAtmosphereAndUpdateUI()
            end
        })



    E.btnAddToFavAtm = p:AddButton('Add to favorites')
        UI:Config(E.btnAddToFavAtm, {
            SameLine  = true,
            OnClick   = function()
                if _GLL.FavAtmosphere[UI:SelectedOpt(E.comboAtmosphere)] == UI:SelectedOpt(E.comboAtmosphere) then
                    UI:DisplayInfoInCombo(e, 'The atmosphere already added')
                    return
                else
                    CreateSelectable(winAtmFav, _GLL.FavAtmosphere, _GLL.FilteredATMOptions[E.comboAtmosphere.SelectedIndex + 1], 'FavoriteAtmosphere', 'LL_AtmosphereApply')
                end
            end
        })



    E.resetAtmBtn = p:AddButton('Reset')
        UI:Config(E.resetAtmBtn, {
            OnClick   = function()
                ANL.ResetAtmosphereToResourceIDs()
                SelectAtmosphereFromCurrentTrigger()
            end
        })



    E.btnAtmRandom = p:AddButton('Random')
        UI:Config(E.btnAtmRandom, {
            SameLine  = true,
            OnClick   = function()
                UI:RandomOption(E.comboAtmosphere)
                Anl.SetAtmosphereAndUpdateUI()
            end
        })



    E.colFavAtm = p:AddCollapsingHeader('Favorites')
        UI:Config(E.colFavAtm, {})



    winAtmFav = E.colFavAtm:AddChildWindow('')
    winAtmFav.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json') then
        pcall(function()
            _GLL.FavAtmosphere = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json'))
            PopulateATMFavorites(winAtmFav, _GLL.FavAtmosphere)
        end)
    else
        _GLL.FavAtmosphere = {}
    end



    p:AddSeparatorText('Parameters')


    E.btnApplyParam = p:AddButton('Apply')
        UI:Config(E.btnApplyParam, {
            OnClick = function(e)
                Anl.ApplyParameters('All')
            end
        })



    E.btnResetCLTN = p:AddButton('Reset lighting')
        UI:Config(E.btnResetCLTN, {
            SameLine = true,
            OnClick  = function()
            	Anl.ResetValues('Lighting')
            end,
            OnRightClick = function()
            	Anl.ResetValues('Lighting', true)
            end
        })



    E.btnResetCATM = p:AddButton('Reset atmosphere')
        UI:Config(E.btnResetCATM, {
            SameLine = true,
            OnClick  = function()
            	Anl.ResetValues('Atmosphere')
            end,
            OnRightClick = function()
            	Anl.ResetValues('Atmosphere', true)
            end
        })



    function SaveAsPreset(fileName, type_)
        local uuid

        if type_ == 'Lighting' then
            uuid = LTN_Templates[UI:SelectedOpt(E.comboLighting)]
        elseif type_ == 'Atmosphere' then
            uuid = ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)]
        end

        local Lighting   = Ext.Resource.Get(uuid, type_)[type_]
        local Serialized = Ext.Types.Serialize(Lighting)
        local Stringify  = Ext.Json.Stringify(Serialized)
        Ext.IO.SaveFile('LightyLights/AnLPresets/'.. type_ .. '/' .. fileName .. '.json', Stringify)
    end


    function LoadPreset(fileName, type_)
        local uuid

        if type_ == 'Lighting' then
            uuid = LTN_Templates[UI:SelectedOpt(E.comboLighting)]
        elseif type_ == 'Atmosphere' then
            uuid = ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)]
        end

        local Json        = Ext.IO.LoadFile('LightyLights/AnLPresets/'.. type_ .. '/' .. fileName .. '.json')
        local Parsed      = Ext.Json.Parse(Json)
        Parsed.ParentGUID = _GLL.lightingParent

        Ext.Types.Unserialize(Ext.Resource.Get(uuid, type_)[type_], Parsed)
        Anl.ApplyParameters(type_)
    end



    local collapsePreset = p:AddCollapsingHeader('Preset manager')



    E.inputPresetNameLighting = collapsePreset:AddInputText('')
        UI:Config(E.inputPresetNameLighting, {
            Text = ''
        })



    E.btnSavePresetLighting = collapsePreset:AddButton('Save lighting')
        UI:Config(E.btnSavePresetLighting, {
            SameLine  = true,
            OnClick   = function(e)
                local presetName = E.inputPresetNameLighting.Text
                if presetName == '' then
                    DWarn('Enter a valid preset name')
                    Imgui.BorderPulse(e, 1)
                    return
                end

                if LightingPresets[presetName] == presetName then
                    DWarn('Preset already exists')
                    return
                end

                SaveAsPreset(presetName, 'Lighting')
                CreatePresetSelectable(winLightingPresets, LightingPresets, presetName, 'Lighting')
            end
        })



    E.colPresetsLighting = collapsePreset:AddTree('Lighting presets')
        UI:Config(E.colPresetsLighting, {})



    winLightingPresets = E.colPresetsLighting:AddChildWindow('')
    winLightingPresets.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/AnLPresets/_LightingNames.json') then
        pcall(function()
            LightingPresets = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/AnLPresets/_LightingNames.json'))
            PopulatePresets(winLightingPresets, LightingPresets, 'Lighting')
        end)
    else
        LightingPresets = {}
    end



    E.inputPresetNameAtmosphere = collapsePreset:AddInputText('')
        UI:Config(E.inputPresetNameAtmosphere, {
            Text      = ''
        })



    E.btnSavePresetAtmosphere = collapsePreset:AddButton('Save atmosphere')
        UI:Config(E.btnSavePresetAtmosphere, {
            SameLine  = true,
            OnClick   = function(e)
                local presetName = E.inputPresetNameAtmosphere.Text

                if presetName == '' then
                    DWarn('Enter a valid preset name')
                    Imgui.BorderPulse(e, 1)
                    return
                end

                if AtmospherePresets[presetName] == presetName then
                    DWarn('Preset already exists')
                    return
                end

                SaveAsPreset(presetName, 'Atmosphere')
                CreatePresetSelectable(winAtmospherePresets, AtmospherePresets, presetName, 'Atmosphere')
            end
        })



    E.colPresetsAtmosphere = collapsePreset:AddTree('Atmosphere Presets')
        UI:Config(E.colPresetsAtmosphere, {})


    winAtmospherePresets = E.colPresetsAtmosphere:AddChildWindow('')
    winAtmospherePresets.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/AnLPresets/_AtmosphereNames.json') then
        pcall(function()
            AtmospherePresets = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/AnLPresets/_AtmosphereNames.json'))
            PopulatePresets(winAtmospherePresets, AtmospherePresets, 'Atmosphere')
        end)
    else
        AtmospherePresets = {}
    end


    p:AddSeparator()


    p:AddBulletText([[Don't forget to press Select current atmosphere and lighting
if you haven't selected any Lighting or Atmosphere]])

    p:AddBulletText([[Right click on any parameter will reset it]])




	local ltnUuid = LTN_Templates['LTN_CIN_Laezel_ROM_EV11_Dawn']
	local atmUuid = ATM_Templates['ATM_CIN_WLD_Crash_Beach_FakeNight_01']


	local Ltn = Resource:GetResource(ltnUuid, 'Lighting')
	local Atm = Resource:GetResource(atmUuid, 'Atmosphere')

	Anl.CurrentLighting   = UI:SelectedOpt(E.comboLighting)
	Anl.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)


	p:AddSeparatorText('Parameters')


    -- p:AddImage('a272351b-591f-35fc-39aa-b9aa76de85ee', {2048, 2048})

	local collapseLighting = p:AddCollapsingHeader('Lighting')
	collapseLighting.DefaultOpen = true

	local collapseAtmosphere = p:AddCollapsingHeader('Atmosphere')
	collapseAtmosphere.DefaultOpen = false


	Anl.CurrentLighting   = UI:SelectedOpt(E.comboLighting)
	Anl.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)

	Anl.CreateParameterControls(Ltn, collapseLighting)
	Anl.CreateParameterControls(Atm, collapseAtmosphere)

end