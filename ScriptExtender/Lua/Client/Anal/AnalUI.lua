local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')
local CONFIG, ATM_ORDER, LTN_ORDER, IGNORE_PARAMS, RANDOM_EXCLUDE = GetANLbsTemporary()

local AtmospherePresets = {}
local LightingPresets = {}



function Anal2Tab(p)
    local CHILD_WIN_SIZE = {554, 200}
    local winLtnFav
    local winAtmFav
    _GLL.FilteredLTNOptions = _GLL.LtnComboOptions
    _GLL.FilteredATMOptions = _GLL.AtmComboOptions

    p:AddText([[YOU CAN'T CHANGE ATMOSPHERE AND LIGHTING IN PHOTOMODE]])
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
                SetLightingAndUpdateUI()
            end,
            OnRightClick  = function()
                SetLightingAndUpdateUI()
            end
        })


    E.btnPrevLtn = p:AddButton('<')
        UI:Config(E.btnPrevLtn, {
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboLighting)
                SetLightingAndUpdateUI()
            end
        })



    E.btnNextLtn = p:AddButton('>')
        UI:Config(E.btnNextLtn, {
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboLighting)
                SetLightingAndUpdateUI()
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
                SetLightingAndUpdateUI()
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
                        ApplyParameters('Lighting')
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
                SetAtmosphereAndUpdateUI()
            end,
            OnRightClick  = function(e)
                SetAtmosphereAndUpdateUI()
            end
        })



    E.btnPrevAtm = p:AddButton('<')
        UI:Config(E.btnPrevAtm, {
            SameLine  = true,
            OnClick   = function()
                UI:PrevOption(E.comboAtmosphere)
                SetAtmosphereAndUpdateUI()
            end
        })



    E.btnNextAtm = p:AddButton('>')
        UI:Config(E.btnNextAtm, {
            SameLine  = true,
            OnClick   = function()
                UI:NextOption(E.comboAtmosphere)
                SetAtmosphereAndUpdateUI()
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
                SetAtmosphereAndUpdateUI()
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
                ApplyParameters('All')
            end
        })



    E.btnResetCLTN = p:AddButton('Reset lighting')
        UI:Config(E.btnResetCLTN, {
            SameLine = true,
            OnClick  = function()
                ResetLTN(false)
                ApplyParameters('Lighting')
                CreateUI(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting', E.collapseParamsLTN, LTN_ORDER)
            end,
            OnRightClick = function()
                ResetLTN(true)
                ApplyParameters('Lighting')
                CreateUI(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting', E.collapseParamsLTN, LTN_ORDER)
            end
        })



    E.btnResetCATM = p:AddButton('Reset atmosphere')
        UI:Config(E.btnResetCATM, {
            SameLine = true,
            OnClick  = function()
                ResetATM(false)
                ApplyParameters('Atmosphere')
                CreateUI(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)], 'Atmosphere', E.collapseParamsATM, ATM_ORDER)
            end,
            OnRightClick = function()
                ResetATM(true)
                ApplyParameters('Atmosphere')
                CreateUI(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)], 'Atmosphere', E.collapseParamsATM, ATM_ORDER)
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
        ApplyParameters(type_)
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

    E.collapseParamsLTN = p:AddCollapsingHeader('Lighting')
        UI:Config(E.collapseParamsLTN, {})


    E.collapseParamsATM = p:AddCollapsingHeader('Atmosphere')
        UI:Config(E.collapseParamsATM, {})


    -- local uuid2

    local function ApplyChange(uuid, resource, p, value)
        -- if uuid2 ~= uuid then
            -- SelectAtmosphereAndLightingFromCurrentTrigger()
        -- end
        -- uuid2 = uuid

        local Target = Resource:GetResource(uuid, resource)

        for i = 1, #p - 1 do Target = Target[p[i]] end

        Target[p[#p]] = value
        ApplyParameters(resource)
    end



    local function getConf(p)
        local conf = CONFIG[table.concat(p, ".")] or {}
        return conf.min or 0, conf.max or 1, conf.log or false
    end



    local function ResetToDefaultValue(uuid, resource, path)
        local ZipBomb = GetZipBombTemporary()
        local CachedTable

        if resource == 'Lighting' then
            CachedTable = ZipBomb.CachedLighting
        elseif resource == 'Atmosphere' then
            CachedTable = ZipBomb.CachedAtmosphere
        end

        local CachedResource = CachedTable[uuid]

        local CR = CachedResource[2]
        for _, key in ipairs(path) do
            if CR[key] == nil then return end
            CR = CR[key]
        end

        local value = CR

        local target = Resource:GetResource(uuid, resource)
        for i = 1, #path - 1 do
            target = target[path[i]]
        end

        target[path[#path]] = value
        ApplyChange(uuid, resource, path, value)

        if resource == 'Lighting' then
            CreateUI(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting', E.collapseParamsLTN, LTN_ORDER)
        elseif resource == 'Atmosphere' then
            CreateUI(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)], 'Atmosphere', E.collapseParamsATM, ATM_ORDER)
        end
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

        local function randomizeSubtree(tbl, path)
            for _, k in ipairs(tbl and getSortedKeys(tbl)) do
                local v = tbl[k]
                local pp = {table.unpack(path)}
                table.insert(pp, k)

                if RANDOM_EXCLUDE[k] or RANDOM_EXCLUDE[table.concat(pp, '.')] then

                elseif type(v) == 'table' or type(v) == 'userdata' then
                    local ok4, v4    = pcall(function() return v[4] end)
                    local ok3, v3    = pcall(function() return v[3] end)
                    local ok2, v2    = pcall(function() return v[2] end)
                    local isVec4 = ok4 and type(v4) == 'number'
                    local isVec3 = not isVec4 and ok3 and type(v3) == 'number'
                    local isVec2 = not isVec4 and not isVec3 and ok2 and type(v2) == 'number'

                    if isVec4 or isVec3 then
                        local minVal, maxVal = getConf(pp)
                        local col = {
                            minVal + math.random() * (maxVal - minVal),
                            minVal + math.random() * (maxVal - minVal),
                            minVal + math.random() * (maxVal - minVal),
                        }
                        if isVec4 then col[4] = math.random() end
                        ApplyChange(uuid, resource, pp, col)

                    elseif isVec2 then
                        local minVal, maxVal = getConf(pp)
                        ApplyChange(uuid, resource, pp, {
                            minVal + math.random() * (maxVal - minVal),
                            minVal + math.random() * (maxVal - minVal),
                        })

                    else
                        randomizeSubtree(v, pp)
                    end

                elseif Ext.Types.GetValueType(v) == 'boolean' then
                    ApplyChange(uuid, resource, pp, math.random() > 0.5)

                elseif type(v) == 'string' then

                else --- int or float
                    local minVal, maxVal = getConf(pp)
                    local isInt = math.type(v) == 'integer'
                    if isInt then
                        ApplyChange(uuid, resource, pp, math.random(math.floor(minVal), math.floor(maxVal)))
                    else
                        ApplyChange(uuid, resource, pp, minVal + math.random() * (maxVal - minVal))
                    end
                end
            end
        end



        local function trev(tbl, tbl2, depth, parent, path)
            tbl2  = tbl2  or {}
            depth = depth or 1
            path  = path  or {}

            for _, k in ipairs(tbl and getSortedKeys(tbl)) do
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
                            ApplyChange(uuid, resource, p,
                                isVec3 and {e.Color[1], e.Color[2], e.Color[3]} or {e.Color[1], e.Color[2], e.Color[3], e.Color[4]})
                        end
                        w.OnRightClick = function(e)
                            ResetToDefaultValue(uuid, resource, p)
                        end


                    elseif isVec2 then
                        local minVal, maxVal, isLog = getConf(p)
                        local w = parent:AddDrag(k, 1, minVal, maxVal)
                        w.IDContext   = Ext.Math.Random(1, 1000)
                        w.Value       = {v[1] or 0, v[2] or 0, 0, 0}
                        w.Components  = 2
                        w.Logarithmic = isLog and true or false
                        w.OnChange    = function(e)
                            ApplyChange(uuid, resource, p, {e.Value[1], e.Value[2]})
                        end
                        w.OnRightClick = function(e)
                            ResetToDefaultValue(uuid, resource, p)
                        end


                    elseif not isVec4 and not isVec3 and not isVec2 then
                        tbl2[k] = {}
                        if depth == 1 then
                            local subParent = mainParent:AddTree(k)
                            trev(v, tbl2[k], depth + 1, subParent, p)
                            local btnRandomTree = subParent:AddButton('Random')
                                UI:Config(btnRandomTree, {
                                    OnClick = function()
                                        local node = Resource:GetResource(uuid, resource)
                                        for _, key in ipairs(p) do node = node[key] end
                                        randomizeSubtree(node, p)
                                        CreateUI(uuid, resource, mainParent, PARAMETER_ORDER)
                                    end
                                })
                        elseif depth == 2 then
                            local subParent = parent:AddTree(k)
                            trev(v, tbl2[k], depth + 1, subParent, p)
                            local btnRandomTree = subParent:AddButton('Random')
                                UI:Config(btnRandomTree, {
                                    OnClick = function()
                                        local node = Resource:GetResource(uuid, resource)
                                        for _, key in ipairs(p) do node = node[key] end
                                        randomizeSubtree(node, p)
                                        CreateUI(uuid, resource, mainParent, PARAMETER_ORDER)
                                    end
                                })
                        else
                            trev(v, tbl2[k], depth + 1, parent, p)
                        end
                    end
                    tbl2[k] = tbl2[k] or v

                elseif Ext.Types.GetValueType(v) == 'boolean' then
                    local w = parent:AddCheckbox(k)
                    w.IDContext = Ext.Math.Random(1, 1000)
                    w.Checked   = v
                    w.OnChange  = function(e) ApplyChange(uuid, resource, p, e.Checked) end
                    w.OnRightClick = function(e)
                        ResetToDefaultValue(uuid, resource, p)
                    end

                elseif type(v) == 'string' then
                    local w = parent:AddInputText(k)
                    w.IDContext = Ext.Math.Random(1, 1000)
                    w.Text      = tostring(v)
                    w.OnChange  = function(e) ApplyChange(uuid, resource, p, e.Text) end
                    w.OnRightClick = function(e)
                        ResetToDefaultValue(uuid, resource, p)
                    end

                else --- int or float
                    local minVal, maxVal, isLog = getConf(p)
                    local isInt = math.type(v) == 'integer'
                    local w

                    if isInt then
                        w = parent:AddSliderInt(k, 1, minVal, maxVal)
                    elseif maxVal > 3000 then
                        w = parent:AddSlider(k, 1, minVal, maxVal)
                    else
                        w = parent:AddDrag(k, 1, minVal, maxVal)
                    end

                    w.IDContext   = Ext.Math.Random(1, 1000)
                    w.Value       = {v, 0, 0, 0}
                    if isLog then w.Logarithmic = true end
                    w.OnChange    = function(e) ApplyChange(uuid, resource, p, e.Value[1]) end
                    w.OnRightClick = function(e)
                        ResetToDefaultValue(uuid, resource, p)
                    end
                end
                tbl2[k] = v
            end
            return tbl2
        end

        trev(Resource:GetResource(uuid, resource), {}, 1, mainParent, {})

        local btnRandomAll = mainParent:AddButton('Random all')
            UI:Config(btnRandomAll, {
                OnClick = function()
                    randomizeSubtree(Resource:GetResource(uuid, resource), {})
                    CreateUI(uuid, resource, mainParent, PARAMETER_ORDER)
                end
            })
    end

    local uuid = '375af627-6f3c-19e8-1046-29265ae9e8f7'
    local resource = 'Lighting'
    local mainParent = E.collapseParamsLTN
    CreateUI(uuid, resource, mainParent, LTN_ORDER)



    local uuid = '73e03af9-7ab1-47a7-906b-a4e0362045ef'
    local resource = 'Atmosphere'
    local mainParent = E.collapseParamsATM
    CreateUI(uuid, resource, mainParent, ATM_ORDER)



    function SetLightingAndUpdateUI()
        Anl.CapturedValues = {}

        DisplayBlockedLevel()
        -- Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(E.comboLighting))
        ANL.SetLigthing(LTN_Templates[UI:SelectedOpt(E.comboLighting)])
        CreateUI(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting', E.collapseParamsLTN, LTN_ORDER) --yes.
    end



    function SetAtmosphereAndUpdateUI()
        Anl.CapturedValues = {}

        DisplayBlockedLevel()
        -- Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(E.comboAtmosphere))
        ANL.SetAtmosphere(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)])
        CreateUI(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)], 'Atmosphere', E.collapseParamsATM, ATM_ORDER) --yes.
    end



    function ApplyParameters(type_)
        if type_ == 'Lighting' or type_ == 'All' then
            ANL.SetLigthing(LTN_Templates[UI:SelectedOpt(E.comboLighting)])
            ANL.ApplyLighting()
        end

        if type_ == 'Atmosphere' or type_ == 'All' then
            ANL.SetAtmosphere(ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)])
            ANL.ApplyAtmosphere()
        end
    end



    function ResetLTN(all)
        local ZipBomb = GetZipBombTemporary()

        if all then
            for name, uuid in pairs(LTN_Templates) do
                ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
            end
        else
            local uuid = LTN_Templates[UI:SelectedOpt(E.comboLighting)]
            ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
        end
    end



    function ResetATM(all)
        local ZipBomb = GetZipBombTemporary()

        if all then
            for name, uuid in pairs(ATM_Templates) do
                ApplyCachedAtmosphere(uuid, ZipBomb.CachedAtmosphere)
            end
        else
            local uuid = ATM_Templates[UI:SelectedOpt(E.comboAtmosphere)]
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



    local txtReminder = p:AddBulletText([[Hold alt while dragging to change value slowly. Hold shift to change it fast]])
    txtReminder = p:AddBulletText([[Don't forget that you can double click on the sliders to enter a specific number]])
    txtReminder:SetColor('Text', {1, 1, 1, 1})



    -- function DumpANL()
    --     local ltnName = UI:SelectedOpt(E.comboLighting)
    --     local atmName = UI:SelectedOpt(E.comboAtmosphere)
    --     DPrint('Atmosphere UUID: %s, Name: %s', ATM_Templates[atmName], atmName)
    --     DPrint('  Lighting UUID: %s, Name: %s', LTN_Templates[ltnName], ltnName)
    -- end

    -- function DumpLTN()
    --     DDump(Ext.Resource.Get(LTN_Templates[UI:SelectedOpt(E.comboLighting)], 'Lighting').Lighting)
    -- end


    -- function Temp()
    --     local Xd = {}
    --     local Templates = Ext.Template.GetAllRootTemplates()
    --     for k, v in pairs(Templates) do
    --         table.insert(Xd, k)
    --     end
    --     DD('Templates', Xd)
    -- end

end