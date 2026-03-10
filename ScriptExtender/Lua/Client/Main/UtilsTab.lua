function Utils2Tab(p)


    local function isLightyLight(light)
        return light.Template and light.Template.Name:find('LLL_')
    end



    local WorldLights = {}

    local function TogglePreplacedLights(disable)
        if disable then
            for _, lightEnt in pairs(Ext.Entity.GetAllEntitiesWithComponent('Light')) do
                local light = lightEnt.Light

                --- rare goto PagMan
                if isLightyLight(light) or (light.Intensity == 0 and light.Gain == 0) then goto continue end

                WorldLights[lightEnt] = {
                    Intensity = light.Intensity,
                    Gain      = light.Gain,
                }

                light.Intensity = 0
                light.Gain      = 0

                ::continue::
            end

        else
            for lightEnt, saved in pairs(WorldLights) do
                local light = lightEnt.Light
                light.Intensity = saved.Intensity
                light.Gain      = saved.Gain
            end
        end
    end



    E.btnPreplaced = p:AddCheckbox('Disable pre-placed lights')
    E.btnPreplaced.Checked = false
    E.btnPreplaced.OnChange = function(e)
        TogglePreplacedLights(e.Checked)
    end



    --- TBD: OnChange, System or something?
    E.btnDisableVFX = p:AddCheckbox('Disable VFX shake and blur [PERFORMANCE HEAVY]')
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