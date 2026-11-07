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



    p:AddSeparatorText('VFX')
    -- p:AddDummy(0, 20)

    -- p.DefaultOpen = true


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
                if Settings.lightSetupState then
                    e.Checked = true
                end
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





    p:AddDummy(0, 20)
    p:AddSeparatorText('Environment')



    E.btnRemoveSurface = p:AddButton('Remove blood puddles')
        UI:Config(E.btnRemoveSurface, {
            OnClick = function(e)
                Ch.RemoveSurface:SendToServer({})
            end,
            Tooltip = [[            Removes all blood puddles		]]
        })



    E.checkCrowd = p:AddCheckbox('[no workies] Disable crowd [needs savefile reload] ')
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



    E.btnRemoveCombat = p:AddButton('Disable combat for all characters [savefile persistant]')
        UI:Config(E.btnRemoveCombat, {
            OnClick = function(e)
                Ch.RemoveAllCombat:SendToServer({})
            end,
            Tooltip = [[        Do backup savefile before pressing the button.
        It just disables combat, cutscenes and other stuff still going to play]]
        })


end





function UsefulStatus(p)
    p:AddSeparatorText('Status manager thing')


    local Blocked = {
        -- ['6ef1eb35-14e2-4a26-bec4-de1ae3e6dfba'] = true,
    }

    local AllStatuses = {}

    local function GetAllStatuses()
        if not next(AllStatuses) then
            for _, statName in pairs(Ext.Stats.GetStats()) do
                local Stat = Ext.Stats.Get(statName)
                if Stat.ModifierList == 'StatusData' and not Blocked[Stat.ModId] then
                    local name = Ext.Loca.GetTranslatedString(Stat.DisplayName)
                    if name:find('A Barbarian and a Wizard') or name:find('%%%', 1, true) then
                        name = 'Unknown'
                    end
                    local statName = name .. '_' .. statName
                    table.insert(AllStatuses, statName)
                end
            end
        end
        return AllStatuses
    end



    function UpdateCurrentStatuses()
        Imgui.ClearChildren(E.winStatuses)

        OnTicks(10, function()
            local Statuses = {}

            if _C().StatusContainer then
                for k, v in pairs(_C().StatusContainer.Statuses) do
                    table.insert(Statuses, v)
                end

                for _, status in ipairs(Statuses) do
                    local selectStatus = E.winStatuses:AddSelectable(status)
                        UI:Config(selectStatus, {
                            OnClick = function(e)
                                Ch.ManageStatus:SendToServer(status)
                                selectStatus:Destroy()
                            end,
                            Tooltip = [[        ]] .. Ext.Loca.GetTranslatedString(Ext.Stats.Get(status).DisplayName)
                        })
                end
            end
        end)

    end



    E.comboAllStatuses = p:AddCombo('All available statuses')
        UI:Config(E.comboAllStatuses, {
            Options = GetAllStatuses(),
            SelectedIndex = 0,
            OnChange = function(e)
                local status = UI:SelectedOpt(e):match("_(.*)")
                Ch.ManageStatus:SendToServer(status)
                UpdateCurrentStatuses()
            end,
            OnRightClick = function(e)
                local status = UI:SelectedOpt(e):match("_(.*)")
                Ch.ManageStatus:SendToServer(status)
                UpdateCurrentStatuses()
            end,
            Tooltip = [[        Names in the list are split with a "_",
        where the part before "_" is in-game name, and part after is internal name

        You can search by in-game or internal name

        Satus is applied when you click on it in the list

        If it's a first entry, right click on the list to add/remove the status]]
        })



    E.inputSearchStatus = p:AddInputText('')
    E.inputSearchStatus.Hint = 'Search input. Example: WET'
    E.inputSearchStatus.OnChange = function(e)

        --- TBD: Fix filter options not assigning AllOptions
        if e.Text == '' then
            E.comboAllStatuses.Options = GetAllStatuses()
            return
        end

        E.comboAllStatuses.Options = UI:FilterOptions(e.Text, E.comboAllStatuses.Options)
    end



    E.btnSeachStatus = p:AddButton('Clear')
        UI:Config(E.btnSeachStatus, {
            SameLine = true,
            OnClick = function(e)
                E.inputSearchStatus.Text = ''
                E.comboAllStatuses.Options = GetAllStatuses()
            end
        })



    -- E.inputStatus = p:AddInputText('')
    -- E.inputStatus.Hint = 'WET'



    -- E.btnAddPixie = p:AddButton('Add/Remove status by name')
    --     UI:Config(E.btnAddPixie, {
    --         SameLine = true,
    --         OnClick = function(e)
    --             local status = E.inputStatus.Text
    --             Ch.ManageStatus:SendToServer(status)
    --             UpdateCurrentStatuses()
    --         end
    --     })


    p:AddSeparatorText('Current statuses')
    p:AddText('Hover over a status to see its in-game name')
    p:AddText('Click on a status to remove it')

    E.winStatuses = p:AddChildWindow('xd')
    E.winStatuses.Size = {0, 400}

    E.btnGetCurrentStatuses = p:AddButton('Get current statuses')
        UI:Config(E.btnGetCurrentStatuses, {
            OnClick = function(e)
                UpdateCurrentStatuses()
            end,
            Tooltip = [[            Statuses get automatically when
            you switch between characters when the window is opened            ]]
        })



    p:AddSeparatorText('Useful statuses')

    local x = p:AddInputText('Pixie blessing')
    x.Text = 'GLO_PIXIESHIELD'


    local x = p:AddInputText('Cloud giant strength')
    x.Text = 'POTION_OF_STRENGTH_CLOUD_GIANT'



    if Settings.degenExtendedScriptExtender then

        E.checkCinema = p:AddCheckbox('Cinematic Mode')
            UI:Config(E.checkCinema, {
                OnChange = function(e)
                   Ext.GameRenderView.GetGameRenderView().IsCinematicMode = e.Checked
                end
            })


        E.slLOD = p:AddSlider('LOD distance', 1, 0, 3)
            UI:Config(E.slLOD, {
                Value = {Ext.GameRenderView.GetLODScale(), 0,0,0},
                OnChange = function(e)
                    Ext.GameRenderView.SetLODScale(e.Value[1])
                end
            })
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