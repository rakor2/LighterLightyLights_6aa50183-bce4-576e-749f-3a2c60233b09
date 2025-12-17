local xd


function Utils2Tab(p)

    -- E.comboLevelList = p:AddCombo('Levels')



    -- E.btnTp = p:AddButton('TP')
    -- E.btnTp.OnClick = function (e)

    --     local LevelTemplates = {}
    --     local Templates = Ext.Template.GetAllRootTemplates()
    --     for uuid, template in pairs(Templates) do
    --         if template.TemplateType == 'trigger' then
    --             -- LevelTemplates[template.Id] = template.Name
    --             DPrint(template.LevelName)
    --         end
    --     end

    --     DDump(LevelTemplates)

    -- end


    -- E.btnTpToZeto = p:AddButton('TP to 0')
    -- E.btnTpToZeto.SameLine = true


    E.btnPreplaced = p:AddButton('Disable pre-placed lights')
    E.btnPreplaced.OnClick = function (e)
        for _, lightEnt in pairs(Ext.Entity.GetAllEntitiesWithComponent('Light')) do
            if lightEnt.Light.Template then
                lightEnt.Light.Template.Enabled = false
            end
        end
        textPreplace.Visible = true

        Helpers.Timer:OnTicks(300, function ()
            textPreplace.Visible = false
        end)

    end

    textPreplace = p:AddText([[Don't forget to save/load or load]])
    textPreplace.SameLine = true
    textPreplace.Visible = false



    E.btnDisableVFX = p:AddCheckbox('Disable VFX shake and blur')
    E.btnDisableVFX.OnChange = function (e)



    Utils:SubUnsubToTick('sub', 'LL_VFX', function()
        if not e.Checked then Utils:SubUnsubToTick('unsub', 'LL_VFX',_) return end
        local effects = Ext.Entity.GetAllEntitiesWithComponent('Effect')
        for _, entity in ipairs(effects) do
            if entity.Effect and string.find(entity.Effect.EffectName, 'VFX_') then
                local components = entity.Effect.Timeline.Components
                if components then
                    for _, component in ipairs(components) do
                        for property, values in pairs(component.Properties) do
                            if values.FullName == 'Radial Blur.Opacity' then
                                for _, keyFrame in ipairs(values.KeyFrames) do
                                    if keyFrame.Frames then
                                        for _, frame in ipairs(keyFrame.Frames) do
                                            if frame then
                                                local success, value = pcall(function() return frame.Value end)
                                                if success then
                                                    frame.Value = 0
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if values.FullName == 'Falloff Start-End' then
                                values.Min = 0
                                values.Max = 0
                            end
                        end
                    end
                end
            end
        end
    end)
    end


    E.checkLightSetup = p:AddCheckbox('Disable CharacterLight')
    E.checkLightSetup.Checked = lightSetupState
    E.checkLightSetup.OnChange = function (e)
        CharacterLightSetupState(e.Checked)
    end


end