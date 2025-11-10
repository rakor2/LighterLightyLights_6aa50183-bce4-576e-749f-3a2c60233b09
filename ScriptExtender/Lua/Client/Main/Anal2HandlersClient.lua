    function ResetAllATM()
        return true
    end

    function ResetAllLTN()
        return true
    end

        
    LLGlobals.LtnComboOptions = {}
    LLGlobals.AtmComboOptions = {}

    function PopulateLTNOptions()
        for _, name in ipairs(Utils:MapToArray(ltn_templates2)) do
            table.insert(LLGlobals.LtnComboOptions, name)
        end
    end
    PopulateLTNOptions()



    function PopulateATMOptions()
        for _, name in ipairs(Utils:MapToArray(atm_templates2)) do
            table.insert(LLGlobals.AtmComboOptions, name)
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
                E.comboLighting.SelectedIndex = table.find(LLGlobals.LtnComboOptions, selectable.Label) - 1
            else
                E.comboAtmosphere.SelectedIndex = table.find(LLGlobals.AtmComboOptions, selectable.Label) - 1
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
