function Settings2Tab(p)

    local imputPasspord = p:AddInputText('')
    
    local btnSubmit = p:AddButton('Enter')
    btnSubmit.SameLine = true
    btnSubmit.OnClick = function ()
        if imputPasspord.Text == 'Love' then
            textSad.Visible = true
        else
            Imgui.Jiggle(btnSubmit, 10)
            Imgui.BorderPulse(btnSubmit, 10)
            imputPasspord.Text = ''
        end
    end

    local textThePass = p:AddText('the password')
    textThePass.SameLine = true

    textSad = p:AddText([[I wish I could actually put something here. Just be happy! I guess...]])
    textSad.Visible = false


    p:AddSeparatorText('UI')




    local collapseDefault = p:AddCollapsingHeader('Opened by default')
    


    local collapseOBDMain = collapseDefault:AddTree('Main')



    E.checkMainGenOpenedByDefault = collapseOBDMain:AddCheckbox('General')
    E.checkMainGenOpenedByDefault.OnChange = function (e)
        openByDefaultMainGen = e.Checked
        SettingsSave()
    end
    E.checkMainGenOpenedByDefault.Checked = openByDefaultMainGen



    E.checkMainPointOpenedByDefault = collapseOBDMain:AddCheckbox('Point')
    E.checkMainPointOpenedByDefault.OnChange = function (e)
        openByDefaultMainPoint = e.Checked
        SettingsSave()
    end
    E.checkMainPointOpenedByDefault.Checked = openByDefaultMainPoint



    E.checkMainSpotOpenedByDefault = collapseOBDMain:AddCheckbox('Spotlight')
    E.checkMainSpotOpenedByDefault.OnChange = function (e)
        openByDefaultMainSpot = e.Checked
        SettingsSave()
    end
    E.checkMainSpotOpenedByDefault.Checked = openByDefaultMainSpot



    E.checkMainDirOpenedByDefault = collapseOBDMain:AddCheckbox('Directional')
    E.checkMainDirOpenedByDefault.OnChange = function (e)
        openByDefaultMainDir = e.Checked
        SettingsSave()
    end
    E.checkMainDirOpenedByDefault.Checked = openByDefaultMainDir


    
    E.checkMainAddOpenedByDefault = collapseOBDMain:AddCheckbox('Additional parameters')
    E.checkMainAddOpenedByDefault.OnChange = function (e)
        openByDefaultMainAdd = e.Checked
        SettingsSave()
    end
    E.checkMainAddOpenedByDefault.Checked = openByDefaultMainAdd



    E.checkMainWorldOpenedByDefault = collapseOBDMain:AddCheckbox('World relative')
    E.checkMainWorldOpenedByDefault.OnChange = function (e)
        openByDefaultMainWorld = e.Checked
        SettingsSave()
    end
    E.checkMainWorldOpenedByDefault.Checked = openByDefaultMainWorld



    E.checkMainCharOpenedByDefault = collapseOBDMain:AddCheckbox('Character relative')
    E.checkMainCharOpenedByDefault.OnChange = function (e)
        openByDefaultMainChar = e.Checked
        SettingsSave()
    end
    E.checkMainCharOpenedByDefault.Checked = openByDefaultMainChar



    E.checkMainRotOpenedByDefault = collapseOBDMain:AddCheckbox('Rotation')
    E.checkMainRotOpenedByDefault.IDContext = 'adwdawda'
    E.checkMainRotOpenedByDefault.OnChange = function (e)
        openByDefaultMainRot = e.Checked
        SettingsSave()
    end
    E.checkMainRotOpenedByDefault.Checked = openByDefaultMainRot






    local collapseOBDPM = collapseDefault:AddTree('PM')


    


    
    E.checkPMCameraOpenedByDefault = collapseOBDPM:AddCheckbox('Camera')
    E.checkPMCameraOpenedByDefault.OnChange = function (e)
        openByDefaultPMCamera = e.Checked
        SettingsSave()
    end
    E.checkPMCameraOpenedByDefault.Checked = openByDefaultPMCamera



    E.checkPMInfoOpenedByDefault = collapseOBDPM:AddCheckbox('Info')
    E.checkPMInfoOpenedByDefault.OnChange = function (e)
        openByDefaultPMInfo = e.Checked
        SettingsSave()
    end
    E.checkPMInfoOpenedByDefault.Checked = openByDefaultPMInfo



    E.checkPMPosOpenedByDefault = collapseOBDPM:AddCheckbox('Position')
    E.checkPMPosOpenedByDefault.OnChange = function (e)
        openByDefaultPMPos = e.Checked
        SettingsSave()
    end
    E.checkPMPosOpenedByDefault.Checked = openByDefaultPMPos



    E.checkPMRotOpenedByDefault = collapseOBDPM:AddCheckbox('Rotation')
    E.checkPMRotOpenedByDefault.OnChange = function (e)
        openByDefaultPMRot = e.Checked
        SettingsSave()
    end
    E.checkPMRotOpenedByDefault.Checked = openByDefaultPMRot



    E.checkPMScaleOpenedByDefault = collapseOBDPM:AddCheckbox('Scale')
    E.checkPMScaleOpenedByDefault.OnChange = function (e)
        openByDefaultPMScale = e.Checked
        SettingsSave()
    end
    E.checkPMScaleOpenedByDefault.Checked = openByDefaultPMScale



    E.checkPMLookOpenedByDefault = collapseOBDPM:AddCheckbox('Look at')
    E.checkPMLookOpenedByDefault.OnChange = function (e)
        openByDefaultPMLook = e.Checked
        SettingsSave()
    end
    E.checkPMLookOpenedByDefault.Checked = openByDefaultPMLook



    E.checkPMSaveOpenedByDefault = collapseOBDPM:AddCheckbox('Save')
    E.checkPMSaveOpenedByDefault.OnChange = function (e)
        openByDefaultPMSave = e.Checked
        SettingsSave()
    end
    E.checkPMSaveOpenedByDefault.Checked = openByDefaultPMSave


    

    local c = 0
    E.checkPickerSize = p:AddCheckbox('Bigger color picker')
    E.checkPickerSize.OnChange = function (e)
        if LLGlobals.selectedUuid then
            e.Checked = not e.Checked
            c = c + 1
            if c < 3 then
                local textColorWarning = p:AddText([[Can not apply this setting, you have lights on the scene]])
                    Helpers.Timer:OnTicks(200, function ()
                        textColorWarning:Destroy()
                    end)
                return
            else
                local textColorWarning = p:AddText([[STOP CLICKING]])
                    Helpers.Timer:OnTicks(200, function ()
                        textColorWarning:Destroy()
                    end)
                return
            end
        end
        biggerPicker = e.Checked

        Imgui.ClearChildren(mw)

        Helpers.Timer:OnTicks(10, function ()
            MainWindow(mw)
        end)
        SettingsSave()

    end
    E.checkPickerSize.Checked = biggerPicker

    
    -- E.slFadeTime = p:AddSlider('Elements fade time')
    -- E.slFadeTime.Value = {fadeTime, 0, 0, 0}
    -- E.slFadeTime.OnChange = function (e)
    --     fadeTime = e.Value[1]
    --     SettingsSave()
    -- end

    p:AddSeparatorText('Mod')

    
    E.checkDefaultType = p:AddCombo('Default type')
    E.checkDefaultType.Options = {'Point', 'Spotlight', 'Directional'}
    E.checkDefaultType.SelectedIndex = table.find(E.checkDefaultType.Options, defaultLightType) - 1
    E.checkDefaultType.OnChange = function (e)
        defaultLightType = E.checkDefaultType.Options[E.checkDefaultType.SelectedIndex +1]
        SettingsSave()
    end


    -- why do I heve this E? I don't remember...
    E.slMarkerSize = p:AddSlider('Default marker size', DEFAULT_MARKER_SCALE, 0.01, DEFAULT_MARKER_SCALE, 1)
    E.slMarkerSize.Value = {markerScale, 0, 0, 0}
    E.slMarkerSize.OnChange = function (e)
        markerScale = e.Value[1]
        SettingsSave()
        if not LLGlobals.markerEntity then return end
        LLGlobals.markerEntity.Visual.Visual:SetWorldScale({markerScale, markerScale, markerScale})
    end

    E.slDefCamSpeed = p:AddSlider('Default camera speed', 0, 0.1, 10, 1)
    E.slDefCamSpeed.Value = {defaultCameraSpeed, 0, 0, 0}
    E.slDefCamSpeed.OnChange = function (e)
        defaultCameraSpeed = e.Value[1] 
        SettingsSave()
    end

    E.checkLightSetupState = p:AddCheckbox('CharacterLight setup off by default')
    E.checkLightSetupState.Checked = lightSetupState
    E.checkLightSetupState.OnChange = function (e)
        lightSetupState = e.Checked
        SettingsSave()
    end
    

    E.checkToggleMarker = p:AddCheckbox('Marker off by default')
    E.checkToggleMarker.Checked = markerOff
    E.checkToggleMarker.OnChange = function (e)
        markerOff = e.Checked
        SettingsSave()
    end

    E.checkStickToggle = p:AddCheckbox('Disable stick on light creation')
    E.checkStickToggle.Checked = stickToggleOff
    E.checkStickToggle.OnChange = function (e)
        stickToggleOff = e.Checked
        SettingsSave()
    end

end