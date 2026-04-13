function Settings2Tab(p)
    local imputPasspord = p:AddInputText('')
    local img
    local btnSubmit = p:AddButton('Enter')
        UI:Config(btnSubmit, {
            SameLine = true,
            OnClick = function ()
                if imputPasspord.Text == 'Love' then
                    img.Visible = true
                elseif imputPasspord.Text == 'Dani' then
                    img2.Visible = true
                else
                    Imgui.Jiggle(btnSubmit, 10)
                    Imgui.BorderPulse(btnSubmit, 10)
                    imputPasspord.Text = ''
                end
            end
        })

    local textThePass = p:AddText('the password')
        UI:Config(textThePass, {SameLine = true})

    img = p:AddImage('05c85d4f-6b79-0a4a-c26b-5fc9fce239ff', {512, 256})
    img.Visible = false

    img2 = p:AddText('Love you!')
    img2.Visible = false



    p:AddSeparatorText('UI')



    local collapseDefault = p:AddCollapsingHeader('Opened by default')
    local collapseOBDMain = collapseDefault:AddTree('Main')



    E.checkMainGenOpenedByDefault = collapseOBDMain:AddCheckbox('General')
        UI:Config(E.checkMainGenOpenedByDefault, {
            Checked = openByDefaultMainGen,
            OnChange = function (e)
                openByDefaultMainGen = e.Checked
                SettingsSave()
            end
        })



    E.checkMainPointOpenedByDefault = collapseOBDMain:AddCheckbox('Point')
        UI:Config(E.checkMainPointOpenedByDefault, {
            Checked = openByDefaultMainPoint,
            OnChange = function (e)
                openByDefaultMainPoint = e.Checked
                SettingsSave()
            end
        })



    E.checkMainSpotOpenedByDefault = collapseOBDMain:AddCheckbox('Spotlight')
        UI:Config(E.checkMainSpotOpenedByDefault, {
            Checked = openByDefaultMainSpot,
            OnChange = function (e)
                openByDefaultMainSpot = e.Checked
                SettingsSave()
            end
        })



    E.checkMainDirOpenedByDefault = collapseOBDMain:AddCheckbox('Directional')
        UI:Config(E.checkMainDirOpenedByDefault, {
            Checked = openByDefaultMainDir,
            OnChange = function (e)
                openByDefaultMainDir = e.Checked
                SettingsSave()
            end
        })



    E.checkMainAddOpenedByDefault = collapseOBDMain:AddCheckbox('Additional parameters')
        UI:Config(E.checkMainAddOpenedByDefault, {
            Checked = openByDefaultMainAdd,
            OnChange = function (e)
                openByDefaultMainAdd = e.Checked
                SettingsSave()
            end
        })



    E.checkMainWorldOpenedByDefault = collapseOBDMain:AddCheckbox('World relative')
        UI:Config(E.checkMainWorldOpenedByDefault, {
            Checked = openByDefaultMainWorld,
            OnChange = function (e)
                openByDefaultMainWorld = e.Checked
                SettingsSave()
            end
        })



    E.checkMainCharOpenedByDefault = collapseOBDMain:AddCheckbox('Character relative')
        UI:Config(E.checkMainCharOpenedByDefault, {
            Checked = openByDefaultMainChar,
            OnChange = function (e)
                openByDefaultMainChar = e.Checked
                SettingsSave()
            end
        })



    E.checkMainRotOpenedByDefault = collapseOBDMain:AddCheckbox('Rotation')
        UI:Config(E.checkMainRotOpenedByDefault, {
            IDContext = 'adwdawda',
            Checked = openByDefaultMainRot,
            OnChange = function (e)
                openByDefaultMainRot = e.Checked
                SettingsSave()
            end
        })



    local collapseOBDPM = collapseDefault:AddTree('PM')



    E.checkPMCameraOpenedByDefault = collapseOBDPM:AddCheckbox('Camera')
        UI:Config(E.checkPMCameraOpenedByDefault, {
            Checked = openByDefaultPMCamera,
            OnChange = function (e)
                openByDefaultPMCamera = e.Checked
                SettingsSave()
            end
        })



    E.checkPMInfoOpenedByDefault = collapseOBDPM:AddCheckbox('Info')
        UI:Config(E.checkPMInfoOpenedByDefault, {
            Checked = openByDefaultPMInfo,
            OnChange = function (e)
                openByDefaultPMInfo = e.Checked
                SettingsSave()
            end
        })



    E.checkPMPosOpenedByDefault = collapseOBDPM:AddCheckbox('Position')
        UI:Config(E.checkPMPosOpenedByDefault, {
            Checked = openByDefaultPMPos,
            OnChange = function (e)
                openByDefaultPMPos = e.Checked
                SettingsSave()
            end
        })



    E.checkPMRotOpenedByDefault = collapseOBDPM:AddCheckbox('Rotation')
        UI:Config(E.checkPMRotOpenedByDefault, {
            Checked = openByDefaultPMRot,
            OnChange = function (e)
                openByDefaultPMRot = e.Checked
                SettingsSave()
            end
        })



    E.checkPMScaleOpenedByDefault = collapseOBDPM:AddCheckbox('Scale')
        UI:Config(E.checkPMScaleOpenedByDefault, {
            Checked = openByDefaultPMScale,
            OnChange = function (e)
                openByDefaultPMScale = e.Checked
                SettingsSave()
            end
        })



    E.checkPMLookOpenedByDefault = collapseOBDPM:AddCheckbox('Look at')
        UI:Config(E.checkPMLookOpenedByDefault, {
            Checked = openByDefaultPMLook,
            OnChange = function (e)
                openByDefaultPMLook = e.Checked
                SettingsSave()
            end
        })



    E.checkPMSaveOpenedByDefault = collapseOBDPM:AddCheckbox('Save')
        UI:Config(E.checkPMSaveOpenedByDefault, {
            Checked = openByDefaultPMSave,
            OnChange = function (e)
                openByDefaultPMSave = e.Checked
                SettingsSave()
            end
        })



    local c = 0
    E.checkPickerSize = p:AddCheckbox('Bigger color picker')
        UI:Config(E.checkPickerSize, {
            Checked = biggerPicker,
            OnChange = function (e)
                if _GLL.selectedUuid then
                    e.Checked = not e.Checked
                    c = c + 1
                    if c < 3 then
                        local textColorWarning = p:AddText([[Can not apply this setting, you have lights on the scene
                    or in photo mode]])
                        Helpers.Timer:OnTicks(400, function ()
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
                Imgui.ClearChildren(E.main2)

                Helpers.Timer:OnTicks(10, function ()
                    MainTab(E.main2)
                end)
                SettingsSave()
            end
        })



    E.slFadeTime = p:AddSlider('Elements fade time')
        UI:Config(E.slFadeTime, {
            Value = {fadeTime, 0, 0, 0},
            OnChange = function (e)
                fadeTime = e.Value[1]
                SettingsSave()
            end
        })



    E.comboGradients = p:AddCombo('Bone zone gradient')
        UI:Config(E.comboGradients, {
            Options = {'Rainbow','Ice','Forest','Daniela','Gold','Void','Mono'},
            SelectedIndex = defaultGradient - 1 or 0,
            OnChange = function(e)
                defaultGradient = e.SelectedIndex + 1
                SettingsSave()
                ResetBoneZoneTab()
            end
        })

    p:AddText([[    Gradients are for readability, choose the one that is most readable,
    not fashionable]])



    p:AddSeparatorText('Mod')



    E.checkDefaultType = p:AddCombo('Default type')
        UI:Config(E.checkDefaultType, {
            Options = {'Point', 'Spotlight', 'Directional'},
            SelectedIndex = table.find({'Point', 'Spotlight', 'Directional'}, defaultLightType) - 1,
            OnChange = function (e)
                defaultLightType = E.checkDefaultType.Options[E.checkDefaultType.SelectedIndex + 1]
                SettingsSave()
            end
        })



    E.slMarkerSize = p:AddSlider('Default marker size', DEFAULT_MARKER_SCALE, 0.01, DEFAULT_MARKER_SCALE, 1)
        UI:Config(E.slMarkerSize, {
            Value = {markerScale, 0, 0, 0},
            OnChange = function (e)
                markerScale = e.Value[1]
                SettingsSave()
                if not _GLL.markerEntity then return end
                _GLL.markerEntity.Visual.Visual:SetWorldScale({markerScale, markerScale, markerScale})
            end
        })



    E.checkColMark = p:AddCheckbox('Colorful markers')
        UI:Config(E.checkColMark, {
            Checked = colorfulMarkers,
            OnChange = function (e)
                colorfulMarkers = e.Checked
                SettingsSave()
            end
        })



    E.checkToggleMarker = p:AddCheckbox('Marker off by default')
        UI:Config(E.checkToggleMarker, {
            Checked = markerOff,
            OnChange = function (e)
                markerOff = e.Checked
                SettingsSave()
            end
        })



    E.slDefCamSpeed = p:AddSlider('Default camera speed', 0, 0.1, 10, 1)
        UI:Config(E.slDefCamSpeed, {
            Value = {defaultCameraSpeed, 0, 0, 0},
            OnChange = function (e)
                defaultCameraSpeed = e.Value[1]
                SettingsSave()
            end
        })



    E.checkLightSetupState = p:AddCheckbox('CharacterLight setup off by default')
        UI:Config(E.checkLightSetupState, {
            Checked = lightSetupState,
            OnChange = function (e)
                lightSetupState = e.Checked
                E.checkLightSetup.Checked = lightSetupState
                CharacterLightSetupState(lightSetupState)
                SettingsSave()
            end
        })



    E.checkStickToggle = p:AddCheckbox('Disable stick on light creation')
        UI:Config(E.checkStickToggle, {
            Checked = stickToggleOff,
            OnChange = function (e)
                stickToggleOff = e.Checked
                SettingsSave()
            end
        })



    E.slAnlApplyDelay = p:AddSliderInt('AnL apply delay', 500, 1, 1000, 1)
        UI:Config(E.slAnlApplyDelay, {
            Value = anlApplyDelay or {500,0,0,0},
            OnChange = function(e)
                anlApplyDelay = e.Value
                SettingsSave()
            end
        })



    E.slPmDelay = p:AddSliderInt('Delay before initializing PM bs', 35, 35, 200, 1)
        UI:Config(E.slPmDelay, {
            Value = pmInitDelay or {35,0,0,0},
            OnChange = function(e)
                pmInitDelay = e.Value
                SettingsSave()
            end
        })



    E.checkBzScale = p:AddCheckbox([[Enable Bone Zone Scale, I know what I'm doing, I am aware of the issue and
I know all workarounds]])
        UI:Config(E.checkBzScale, {
            Checked = bzScaleEnabled,
            OnChange = function (e)
                bzScaleEnabled = e.Checked
                SettingsSave()
                ResetBoneZoneTab()
            end
        })


    -- function TableTest()
    --     local colCnt = 0
    --     local MAX_ROW = 5
    --     local MAX_COL = 10

    --     while colCnt ~= MAX_ROW do
    --         for col = 1, MAX_COL do
    --             local x = p:AddButton(col - 1 .. ' ' .. colCnt)

    --             if col == 1 then
    --                 x.SameLine = false
    --             else
    --                 x.SameLine = true
    --             end

    --             if col == MAX_COL then
    --                 colCnt = colCnt + 1
    --             end
    --         end
    --     end
    -- end
    -- PagMan it works
    -- TableTest()

end