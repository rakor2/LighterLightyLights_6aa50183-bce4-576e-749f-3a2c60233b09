local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')

_GLL.LtnComboOptions = {}
_GLL.AtmComboOptions = {}



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
            Anl.SetAtmosphereAndUpdateUI()
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
            Anl.SetLightingAndUpdateUI()
        end
    end
end



function SelectAtmosphereAndLightingFromCurrentTrigger()
    SelectAtmosphereFromCurrentTrigger()
    SelectLightingFromCurrentTrigger()
end
