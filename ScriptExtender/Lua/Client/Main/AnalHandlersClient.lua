_GLL.LtnComboOptions = {}
_GLL.AtmComboOptions = {}
_GLL.LightingPresets = {}
_GLL.AtmospherePresets = {}


function PopulateLTNOptions()
    for _, name in ipairs(Utils:MapToArray(ltn_templates2)) do
        table.insert(_GLL.LtnComboOptions, name)
    end
end
PopulateLTNOptions()


function PopulateATMOptions()
    for _, name in ipairs(Utils:MapToArray(atm_templates2)) do
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
        Ext.Net.PostMessageToServer(hardcode2, selectable.Label)

        if hardcode2 == 'LL_LightingApply' then
            E.comboLighting.SelectedIndex = table.find(_GLL.LtnComboOptions, selectable.Label) - 1
        else
            E.comboAtmosphere.SelectedIndex = table.find(_GLL.AtmComboOptions, selectable.Label) - 1
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



function CreatePresetSelectable(parent, tbl, label, type)
    local selectable
    local id = Ext.Math.Random(1, 9999)
    local delete = parent:AddButton('X')
    delete.IDContext = id
    delete.SameLine = false
    delete.OnClick = function()
        tbl[label] = nil
        Ext.IO.SaveFile('LightyLights/AnLPresets/_' .. type .. 'Names.json', Ext.Json.Stringify(tbl))

        pcall(function()
            Ext.IO.SaveFile('LightyLights/AnLPresets/' .. type .. '/' .. label .. '.json', '')
        end)

        selectable:Destroy()
        delete:Destroy()
    end

    selectable = parent:AddButton(label)
    selectable.IDContext = id
    selectable.SameLine = true
    selectable.OnClick = function()
        LoadPreset(label, type)
    end

    tbl[label] = label
    Ext.IO.SaveFile('LightyLights/AnLPresets/_' .. type .. 'Names.json', Ext.Json.Stringify(tbl))
end


function PopulatePresets(imguiWindow, tbl, type)
    for _, label in pairs(tbl) do
        CreatePresetSelectable(imguiWindow, tbl, label, type)
    end
end



---Temporal slop (don't care, too dumb for now, don't want to learn) until Norb fixes LightingTriggers
local function stringSimilarity(a, b)
    local score = 0
    local len = math.min(#a, #b)
    for i = 1, len do
        if a:sub(i, i) == b:sub(i, i) then
            score = score + 1
        end
    end
    score = score - math.abs(#a - #b) * 0.5
    return score
end

local function findBestLtnKey(atmKey)
    local atmStripped = atmKey:gsub("^ATM_", "")

    local bestKey = nil
    local bestScore = -math.huge

    for k,_ in pairs(ltn_templates2) do
        local ltnStripped = k:gsub("^LTN_", "")
        local score = stringSimilarity(atmStripped, ltnStripped)
        if score > bestScore then
            bestScore = score
            bestKey = k
        end
    end

    return bestKey
end



function SetCurrentAtmosphereAndLighting(Response)
    for k,v in pairs(atm_templates2) do
        if Response and v == Response.uuidAtmosphere then
            local atmIndex = table.find(E.comboAtmosphere.Options, k) - 1
            E.comboAtmosphere.SelectedIndex = atmIndex
            comboAtmosphereFunc()

            ---Temporal slop until Norb maps ClientLightingTrigger
            local ltnKey = findBestLtnKey(k)
            if ltnKey and ltn_templates2[ltnKey] then
                local ltnIndex = table.find(E.comboLighting.Options, ltnKey) - 1
                E.comboLighting.SelectedIndex = ltnIndex
                comboLightingFunc()
            end
            break
        end
    end
end