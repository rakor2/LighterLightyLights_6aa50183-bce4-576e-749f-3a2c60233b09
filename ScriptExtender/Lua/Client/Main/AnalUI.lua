function Anal2Tab(p)
    local CHILD_WIN_SIZE = {554, 200}
    local winLtnFav
    local winAtmFav
    _GLL.FilteredLTNOptions = _GLL.LtnComboOptions
    _GLL.FilteredATMOptions = _GLL.AtmComboOptions

    -- p:AddText([[YOU CAN'T CHANGE ATMOSPHERE AND LIGHTING IN PHOTOMODE]])
    -- p:AddSeparator()

    -- local dddd = p:AddButton([[Get current atmosphere and lighting]])
    --     UI:Config(dddd, {
    --         OnClick = function(e)
    --             Ch.CurrentResource:RequestToServer({}, function(Response)
    --                 SetCurrentAtmosphereAndLighting(Response)
    --             end)
    --         end
    --     })
    -- p:AddText([[    IT CAN GET ONLY PRESETS THAT I CHOSE,
    -- IT CANNOT GET ALL OF THEM]])

    p:AddSeparatorText('Lighting')

    E.inpSearchLighting = p:AddInputText('')
        UI:Config(E.inpSearchLighting, {
            IDContext = 'o9irtqjwno9485839c',
            OnChange  = function()
                _GLL.FilteredLTNOptions = UI:FilterOptions(E.inpSearchLighting.Text, _GLL.LtnComboOptions)
                E.comboLighting.Options = _GLL.FilteredLTNOptions
                E.comboLighting.SelectedIndex = 0
            end
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
            IDContext     = ';oeirj4eiouh',
            Options       = _GLL.LtnComboOptions or {},
            SelectedIndex = 0,
            OnChange      = function()
                LightingPostAndUI()
            end,
            OnRightClick  = function()
                LightingPostAndUI()
            end
        })



    E.btnPrevLtn = p:AddButton('<')
        UI:Config(E.btnPrevLtn, {
            IDContext = ';olsikefnlieurhn',
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboLighting)
                LightingPostAndUI()
            end
        })



    E.btnNextLtn = p:AddButton('>')
        UI:Config(E.btnNextLtn, {
            IDContext = ';olsikefnlieur3402934u20934uhn',
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboLighting)
                LightingPostAndUI()
            end
        })



    E.btnAddToFav = p:AddButton('Add')
        UI:Config(E.btnAddToFav, {
            IDContext = 'oiurfhaieowurhi4wh5iu',
            SameLine  = true,
            OnClick   = function()
                if _GLL.FavLighting[UI:SelectedOpt(E.comboLighting)] == UI:SelectedOpt(E.comboLighting) then
                    return
                else
                    CreateSelectable(winLtnFav, _GLL.FavLighting, _GLL.FilteredLTNOptions[E.comboLighting.SelectedIndex + 1], 'FavoriteLighting', 'LL_LightingApply')
                end
            end
        })



    E.resetLtnBtn = p:AddButton('Reset')
        UI:Config(E.resetLtnBtn, {
            IDContext = 'awdpoiqawndoiwna',
            OnClick   = function()
                Ch.ResetANL:SendToServer('Lighting')
            end
        })



    E.colFav = p:AddCollapsingHeader('Favorites')
        UI:Config(E.colFav, { IDContext = 'iaeuhkbnkwbriyuwg34iy' })

    winLtnFav = E.colFav:AddChildWindow('')
    winLtnFav.Size = CHILD_WIN_SIZE



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
            IDContext = 'pfkjawpo3i4rho83hr',
            OnChange  = function(e)
                _GLL.FilteredATMOptions = UI:FilterOptions(e.Text, _GLL.AtmComboOptions)
                E.comboAtmosphere.Options = _GLL.FilteredATMOptions
                E.comboAtmosphere.SelectedIndex = 0
            end
        })



    E.btnClearSearchAtm = p:AddButton('Search')
        UI:Config(E.btnClearSearchAtm, {
            IDContext = 'oweifjw3oiufhn',
            SameLine  = true,
            OnClick   = function()
                E.inpSearchAtmosphere.Text = ''
                _GLL.FilteredATMOptions = _GLL.AtmComboOptions
                E.comboAtmosphere.Options = _GLL.AtmComboOptions
            end
        })


    E.comboAtmosphere = p:AddCombo('')
        UI:Config(E.comboAtmosphere, {
            IDContext     = ';o342342etm',
            Options       = _GLL.AtmComboOptions or {},
            SelectedIndex = 0,
            OnChange      = function(e)
                AtmospherePostAndUI()
            end,
            OnRightClick  = function(e)
                AtmospherePostAndUI()
            end
        })



    E.btnPrevAtm = p:AddButton('<')
        UI:Config(E.btnPrevAtm, {
            IDContext = ';olsikefnli4444444eurhnatm',
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboAtmosphere)
                AtmospherePostAndUI()
            end
        })



    E.btnNextAtm = p:AddButton('>')
        UI:Config(E.btnNextAtm, {
            IDContext = ';ol123123sik34uhnatm',
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboAtmosphere)
                AtmospherePostAndUI()
            end
        })



    E.btnAddToFavAtm = p:AddButton('Add')
        UI:Config(E.btnAddToFavAtm, {
            IDContext = 'oiu12312354125m',
            SameLine  = true,
            OnClick   = function()
                if _GLL.FavAtmosphere[UI:SelectedOpt(E.comboAtmosphere)] == UI:SelectedOpt(E.comboAtmosphere) then
                    return
                else
                    CreateSelectable(winAtmFav, _GLL.FavAtmosphere, _GLL.FilteredATMOptions[E.comboAtmosphere.SelectedIndex + 1], 'FavoriteAtmosphere', 'LL_AtmosphereApply')
                end
            end
        })



    E.resetAtmBtn = p:AddButton('Reset')
        UI:Config(E.resetAtmBtn, {
            IDContext = 'awpokdnawo;ikn',
            OnClick   = function()
                Ch.ResetANL:SendToServer('Atmosphere')
            end
        })



    E.colFavAtm = p:AddCollapsingHeader('Favorites')
        UI:Config(E.colFavAtm, { IDContext = 'iae1231231235156646hgdtm' })

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
                ApplyParameters()
            end
        })



    E.btnResetCLTN = p:AddButton('Reset lighting')
        UI:Config(E.btnResetCLTN, {
            SameLine     = true,
            OnClick      = function()
                ResetLTN(false)
                ApplyParameters()
            end,
            OnRightClick = function()
                ResetLTN(true)
                ApplyParameters()
            end
        })



    E.btnResetCATM = p:AddButton('Reset atmosphere')
        UI:Config(E.btnResetCATM, {
            SameLine     = true,
            OnClick      = function()
                ResetATM(false)
                ApplyParameters()
            end,
            OnRightClick = function()
                ResetATM(true)
                ApplyParameters()
            end
        })



    function SaveAsPreset(fileName, type)
        local uuid

        if type == 'Lighting' then
            uuid = ltn_templates2[UI:SelectedOpt(E.comboLighting)]
        elseif type == 'Atmosphere' then
            uuid = atm_templates2[UI:SelectedOpt(E.comboAtmosphere)]
        end

        local Lighting   = Ext.Resource.Get(uuid, type)[type]
        local Serialized = Ext.Types.Serialize(Lighting)
        local Stringify  = Ext.Json.Stringify(Serialized)
        Ext.IO.SaveFile('LightyLights/AnLPresets/'.. type .. '/' .. fileName .. '.json', Stringify)
    end



    function LoadPreset(fileName, type)
        local uuid

        if type == 'Lighting' then
            uuid = ltn_templates2[UI:SelectedOpt(E.comboLighting)]
        elseif type == 'Atmosphere' then
            uuid = atm_templates2[UI:SelectedOpt(E.comboAtmosphere)]
        end

        local Json       = Ext.IO.LoadFile('LightyLights/AnLPresets/'.. type .. '/' .. fileName .. '.json')
        local Parsed     = Ext.Json.Parse(Json)
        local Serialized = Ext.Types.Serialize(Ext.Resource.Get(uuid, type)[type])
        Serialized = Parsed
        Ext.Types.Unserialize(Ext.Resource.Get(uuid, type)[type], Serialized)

        ApplyParameters()
    end



    local collapsePreset = p:AddCollapsingHeader('Preset manager')



    E.inputPresetNameLighting = collapsePreset:AddInputText('')
        UI:Config(E.inputPresetNameLighting, {
            IDContext = 'awsdawd',
            Text      = ''
        })



    E.btnSavePresetLighting = collapsePreset:AddButton('Save lighting')
        UI:Config(E.btnSavePresetLighting, {
            IDContext = 'awdawd',
            SameLine  = true,
            OnClick   = function(e)
                local presetName = E.inputPresetNameLighting.Text
                if presetName == '' then
                    DWarn('Enter a valid preset name')
                    Imgui.BorderPulse(e, 1)
                    return
                end

                if _GLL.LightingPresets[presetName] == presetName then
                    DWarn('Preset already exists')
                    return
                end

                SaveAsPreset(presetName, 'Lighting')
                CreatePresetSelectable(winLightingPresets, _GLL.LightingPresets, presetName, 'Lighting')
            end
        })



    E.colPresetsLighting = collapsePreset:AddTree('Lighting presets')
        UI:Config(E.colPresetsLighting, { IDContext = 'adawdadad' })



    winLightingPresets = E.colPresetsLighting:AddChildWindow('')
    winLightingPresets.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/AnLPresets/_LightingNames.json') then
        pcall(function()
            _GLL.LightingPresets = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/AnLPresets/_LightingNames.json'))
            PopulatePresets(winLightingPresets, _GLL.LightingPresets, 'Lighting')
        end)
    else
        _GLL.LightingPresets = {}
    end



    E.inputPresetNameAtmosphere = collapsePreset:AddInputText('')
        UI:Config(E.inputPresetNameAtmosphere, {
            IDContext = 'awdawdawdawd',
            Text      = ''
        })



    E.btnSavePresetAtmosphere = collapsePreset:AddButton('Save atmosphere')
        UI:Config(E.btnSavePresetAtmosphere, {
            IDContext = 'dawdawda2323',
            SameLine  = true,
            OnClick   = function(e)
                local presetName = E.inputPresetNameAtmosphere.Text

                if presetName == '' then
                    DWarn('Enter a valid preset name')
                    Imgui.BorderPulse(e, 1)
                    return
                end

                if _GLL.AtmospherePresets[presetName] == presetName then
                    DWarn('Preset already exists')
                    return
                end

                SaveAsPreset(presetName, 'Atmosphere')
                CreatePresetSelectable(winAtmospherePresets, _GLL.AtmospherePresets, presetName, 'Atmosphere')
            end
        })



    E.colPresetsAtmosphere = collapsePreset:AddTree('Atmosphere Presets')
        UI:Config(E.colPresetsAtmosphere, { IDContext = 'adwwdawdawd' })


    winAtmospherePresets = E.colPresetsAtmosphere:AddChildWindow('')
    winAtmospherePresets.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/AnLPresets/_AtmosphereNames.json') then
        pcall(function()
            _GLL.AtmospherePresets = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/AnLPresets/_AtmosphereNames.json'))
            PopulatePresets(winAtmospherePresets, _GLL.AtmospherePresets, 'Atmosphere')
        end)
    else
        _GLL.AtmospherePresets = {}
    end


    p:AddSeparator()



    E.collapseParamsLTN = p:AddCollapsingHeader('Lighting')
        UI:Config(E.collapseParamsLTN, { IDContext = 'awdaowikdn' })


    E.collapseParamsATM = p:AddCollapsingHeader('Atmosphere')
        UI:Config(E.collapseParamsATM, { IDContext = 'awdaowikdn' })


    local function delayedApply()
        Utils:AntiSpam(anlApplyDelay[1], function()
            ApplyParameters()
        end)
    end

    --- TBD: UNSLOP IT WHEN IM NOT DUMB
    --- UPD: Kinda unsloped
    function CreateUI(uuid, resource, mainParent, PARAMETER_ORDER)
        Imgui.ClearChildren(mainParent)


        local function isIgnored(key)
            for _, ignoreKey in ipairs(IGNORE_PARAMS) do
                if key == ignoreKey then return true end
            end
            return false
        end


        local function getSortedKeys(tbl)
            if tbl then
                local keys = {}
                local orderMap = {}
                for i, key in ipairs(PARAMETER_ORDER) do orderMap[key] = i end
                for k in pairs(tbl) do
                    if not isIgnored(k) then table.insert(keys, k) end
                end
                table.sort(keys, function(a, b)
                    local oa, ob = orderMap[a] or 9999, orderMap[b] or 9999
                    if oa ~= ob then return oa < ob end
                    return tostring(a) < tostring(b)
                end)
                return keys
            end
        end


        local function applyChange(uuid, resource, p, value)
            local target = Resource:GetResource(uuid, resource)
            for i = 1, #p - 1 do target = target[p[i]] end

            target[p[#p]] = value
            delayedApply()
        end


        local function getConf(p)
            local conf = CONFIG[table.concat(p, ".")] or {}
            return conf.min or 0, conf.max or 1, conf.log or false
        end


        local function trev(tbl, tbl2, depth, parent, path)
            tbl2  = tbl2  or {}
            depth = depth or 1
            path  = path  or {}

            for _, k in ipairs(getSortedKeys(tbl)) do
                local v = tbl[k]
                local p = {table.unpack(path)}
                table.insert(p, k)

                if type(v) == 'table' or type(v) == 'userdata' then
                    local ok4, v4    = pcall(function() return v[4] end)
                    local ok3, v3    = pcall(function() return v[3] end)
                    local IAMok2, v2 = pcall(function() return v[2] end)
                    local isScal  = v == 'number'
                    local isVec4  = ok4 and type(v4) == 'number'
                    local isVec3  = not isVec4 and ok3 and type(v3) == 'number'
                    local isVec2  = not isVec4 and not isVec3 and IAMok2 and type(v2) == 'number'

                    if isVec4 or isVec3 then
                        local w = parent:AddColorEdit(k)
                        w.IDContext = Ext.Math.Random(1, 1000)
                        w.Color     = {v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 1}
                        w.NoAlpha   = isVec3 and true or false
                        w.OnChange  = function(e)
                            applyChange(uuid, resource, p,
                                isVec3 and {e.Color[1], e.Color[2], e.Color[3]} or {e.Color[1], e.Color[2], e.Color[3], e.Color[4]})
                        end

                    elseif isVec2 then
                        local minVal, maxVal, isLog = getConf(p)
                        local w = parent:AddSlider(k, 1, minVal, maxVal, 1)
                        w.IDContext   = Ext.Math.Random(1, 1000)
                        w.Value       = {v[1] or 0, v[2] or 0, 0, 0}
                        w.Components  = 2
                        w.Logarithmic = isLog and true or false
                        w.OnChange    = function(e)
                            applyChange(uuid, resource, p, {e.Value[1], e.Value[2]})
                        end

                    elseif not isVec4 and not isVec3 and not isVec2 then
                        tbl2[k] = {}
                        if depth == 1 then
                            trev(v, tbl2[k], depth + 1, mainParent:AddTree(k), p)
                        elseif depth == 2 then
                            trev(v, tbl2[k], depth + 1, parent:AddTree(k), p)
                        else
                            trev(v, tbl2[k], depth + 1, parent, p)
                        end
                    end
                    tbl2[k] = tbl2[k] or v

                elseif Ext.Types.GetValueType(v) == 'boolean' then
                    local w = parent:AddCheckbox(k)
                    w.IDContext = Ext.Math.Random(1, 1000)
                    w.Checked   = v
                    w.OnChange  = function(e) applyChange(uuid, resource, p, e.Checked) end

                elseif type(v) == 'string' then
                    local w = parent:AddInputText(k)
                    w.IDContext = Ext.Math.Random(1, 1000)
                    w.Text      = tostring(v)
                    w.OnChange  = function(e) applyChange(uuid, resource, p, e.Text) end

                else --- int or float
                    local minVal, maxVal, isLog = getConf(p)
                    local isInt = math.type(v) == 'integer'
                    local w = isInt and parent:AddSliderInt(k, 1, minVal, maxVal, 1) or parent:AddSlider(k, 1, minVal, maxVal, 1)
                    w.IDContext   = Ext.Math.Random(1, 1000)
                    w.Value       = {v, 0, 0, 0}
                    if isLog then w.Logarithmic = true end
                    w.OnChange    = function(e) applyChange(uuid, resource, p, e.Value[1]) end
                end
                tbl2[k] = v
            end
            return tbl2
        end
        trev(Resource:GetResource(uuid, resource), {}, 1, mainParent, {})
    end

    local uuid = '375af627-6f3c-19e8-1046-29265ae9e8f7'
    local resource = 'Lighting'
    local mainParent = E.collapseParamsLTN
    CreateUI(uuid, resource, mainParent, LTN_ORDER)



    local uuid = '73e03af9-7ab1-47a7-906b-a4e0362045ef'
    local resource = 'Atmosphere'
    local mainParent = E.collapseParamsATM
    CreateUI(uuid, resource, mainParent, LTN_ORDER)



    function LightingPostAndUI()
        Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(E.comboLighting))
        CreateUI(ltn_templates2[UI:SelectedOpt(E.comboLighting)], 'Lighting', E.collapseParamsLTN, LTN_ORDER) --yes.
    end



    function AtmospherePostAndUI()
        Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(E.comboAtmosphere))
        CreateUI(atm_templates2[UI:SelectedOpt(E.comboAtmosphere)], 'Atmosphere', E.collapseParamsATM, ATM_ORDER) --yes.
    end



    function ApplyParameters()
        LightingPostAndUI()
        AtmospherePostAndUI()

        local Data = {
            uuid = ltn_templates2[UI:SelectedOpt(E.comboLighting)]
        }
        Ch.ApplyANL:RequestToServer(Data, function(Response)
            if Response then
                LightingPostAndUI()
                AtmospherePostAndUI()
            end
        end)
    end



    function ResetLTN(all)
        if all then
            for name, uuid in pairs(ltn_templates2) do
                ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
            end
        else
            local uuid = ltn_templates2[UI:SelectedOpt(E.comboLighting)]
            ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
        end
    end



    function ResetATM(all)
        if all then
            for name, uuid in pairs(atm_templates2) do
                ApplyCachedAtmosphere(uuid, ZipBomb.CachedAtmosphere)
            end
        else
            local uuid = atm_templates2[UI:SelectedOpt(E.comboAtmosphere)]
            ApplyCachedAtmosphere(uuid, ZipBomb.CachedAtmosphere)
        end
    end



    function ApplyCachedLighting(uuid, CachedTable)
        local CachedLTN = CachedTable[uuid]
        if CachedLTN then
            local values   = CachedLTN[2]
            local lighting = Resource:GetResource(uuid, 'Lighting')
            for k, v in pairs(values) do
                lighting[k] = v
            end
        end
    end



    function ApplyCachedAtmosphere(uuid, CachedTable)
        local CachedATM = CachedTable[uuid]
        if CachedATM then
            local values     = CachedATM[2]
            local atmosphere = Resource:GetResource(uuid, 'Atmosphere')
            for k, v in pairs(values) do
                atmosphere[k] = v
            end
        end
    end


    local txtReminder = p:AddBulletText([[Don't forget that you can click on the sliders while holding ctrl
to enter a specific number]])
    txtReminder:SetColor('Text', {1, 1, 1, 1})
end