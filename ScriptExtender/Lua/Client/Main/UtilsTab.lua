local xd


function Utils2Tab(p)

    E.comboLevelList = p:AddCombo('Levels')



    E.btnTp = p:AddButton('TP')
    E.btnTp.OnClick = function (e)

        local LevelTemplates = {}
        local Templates = Ext.Template.GetAllRootTemplates()
        for uuid, template in pairs(Templates) do
            if template.TemplateType == 'trigger' then
                -- LevelTemplates[template.Id] = template.Name
                DPrint(template.LevelName)
            end
        end

        DDump(LevelTemplates)

    end


    E.btnTpToZeto = p:AddButton('TP to 0')
    E.btnTpToZeto.SameLine = true

end