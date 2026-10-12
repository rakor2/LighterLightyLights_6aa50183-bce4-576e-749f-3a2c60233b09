function Utils2Tab(p)


    local function isLightyLight(light)
        return light.Template and light.Template.Name:find('LLL_')
    end



    local WorldLights = {}

    --- TBD: fix items and spells
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
                if lightEnt and lightEnt.Light then
                    local light = lightEnt.Light
                    light.Intensity = saved.Intensity
                    light.Gain      = saved.Gain
                end
            end
        end
    end



    E.btnPreplaced = p:AddCheckbox('Disable pre-placed lights')
        UI:Config(E.btnPreplaced, {
            Checked  = false,
            OnChange = function(e)
                TogglePreplacedLights(e.Checked)
            end
        })



    E.btnDisableVFX = p:AddCheckbox('Disable VFX shake and blur')

    Ext.Entity.OnCreateDeferred('Effect', function(entity)
        if E.btnDisableVFX.Checked then
            if entity.Effect then
                local components = entity.Effect.Timeline.Components
                if components then
                    for _, component in ipairs(components) do
                        for _, values in pairs(component.Properties) do
                            if values.FullName == 'Radial Blur.Opacity' then
                                for _, keyFrame in ipairs(values.KeyFrames) do
                                    if keyFrame.Frames then
                                        for _, frame in ipairs(keyFrame.Frames) do
                                            if frame then
                                                local success, _ = pcall(function() return frame.Value end)
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



    E.checkLightSetup = p:AddCheckbox('Disable CharacterLight')
        UI:Config(E.checkLightSetup, {
            Checked  = Settings.lightSetupState,
            OnChange = function(e)
                CharacterLightSetupState(e.Checked)
            end
        })



    E.checkVision = p:AddCheckbox('Disable Darkvision')
        UI:Config(E.checkVision, {
            Checked = Settings.darkVisionState,
            OnChange = function(e)
                DarkVisionState(e.Checked)
            end
        })



    E.btnRemoveSurface = p:AddButton('Remove blood puddles')
        UI:Config(E.btnRemoveSurface, {
            OnClick = function(e)
                Ch.RemoveSurface:SendToServer({})
            end,
            Tooltip = [[            Removes all blood puddles]]
        })



    E.btnRemoveCombat = p:AddButton('Disable combat for all characters [savefile persistant]')
        UI:Config(E.btnRemoveCombat, {
            OnClick = function(e)
                Ch.RemoveAllCombat:SendToServer({})
            end,
            Tooltip = [[            Do backup savefile before pressing the button]]
        })



    E.checkCrowd = p:AddCheckbox('Disable crowd [needs savefile reload]')
        UI:Config(E.checkCrowd, {
            Checked = Settings.disableCrowd,
            OnChange = function(e)
                Settings.disableCrowd = e.Checked
                Ch.DisableCrowd:SendToServer(Settings.disableCrowd)
                Settings:Save()
            end
        })

    if Settings.disableCrowd then
        Ch.DisableCrowd:SendToServer(Settings.disableCrowd)
    end

end



--[[
e = Ext.Entity.GetAllEntitiesWithComponent('ServerCrowdCharacterTrigger')
for k, v in pairs(e) do
    v.ServerCrowdCharacterTrigger.MaxCharacters = 0
    v.ServerCrowdCharacterTrigger.GroupSizeMin = 0
    v.ServerCrowdCharacterTrigger.GroupSizeMax  = 0
    v.ServerCrowdCharacterTrigger.SpawningEnabled  = false
    v.ServerCrowdCharacterTrigger.SpawningEnabled  = false
end
]]--

--[[
e = Ext.Entity.GetAllEntitiesWithComponent('ClientRoomTrigger')
for k, v in pairs(e) do
    v.ClientRoomTrigger.RenderMethod = 0
end
]]--


--[[
e = Ext.Entity.GetAllEntities()
f = {}
for k, v in pairs(e) do
    c = v:GetAllComponentNames(false)
    for x, o in pairs(c) do
        if not f[o] then
            f[o] = true
        end
    end
end
Mods.LL2.DD('Components', f)
]]--