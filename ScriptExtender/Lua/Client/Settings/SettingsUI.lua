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
            Checked = Settings.openByDefaultMainGen,
            OnChange = function (e)
                Settings.openByDefaultMainGen = e.Checked
                Settings:Save()
            end
        })



    E.checkMainPointOpenedByDefault = collapseOBDMain:AddCheckbox('Point')
        UI:Config(E.checkMainPointOpenedByDefault, {
            Checked = Settings.openByDefaultMainPoint,
            OnChange = function (e)
                Settings.openByDefaultMainPoint = e.Checked
                Settings:Save()
            end
        })



    E.checkMainSpotOpenedByDefault = collapseOBDMain:AddCheckbox('Spotlight')
        UI:Config(E.checkMainSpotOpenedByDefault, {
            Checked = Settings.openByDefaultMainSpot,
            OnChange = function (e)
                Settings.openByDefaultMainSpot = e.Checked
                Settings:Save()
            end
        })



    E.checkMainDirOpenedByDefault = collapseOBDMain:AddCheckbox('Directional')
        UI:Config(E.checkMainDirOpenedByDefault, {
            Checked = Settings.openByDefaultMainDir,
            OnChange = function (e)
                Settings.openByDefaultMainDir = e.Checked
                Settings:Save()
            end
        })



    E.checkMainAddOpenedByDefault = collapseOBDMain:AddCheckbox('Additional parameters')
        UI:Config(E.checkMainAddOpenedByDefault, {
            Checked = Settings.openByDefaultMainAdd,
            OnChange = function (e)
                Settings.openByDefaultMainAdd = e.Checked
                Settings:Save()
            end
        })



    E.checkMainWorldOpenedByDefault = collapseOBDMain:AddCheckbox('World relative')
        UI:Config(E.checkMainWorldOpenedByDefault, {
            Checked = Settings.openByDefaultMainWorld,
            OnChange = function (e)
                Settings.openByDefaultMainWorld = e.Checked
                Settings:Save()
            end
        })



    E.checkMainCharOpenedByDefault = collapseOBDMain:AddCheckbox('Character relative')
        UI:Config(E.checkMainCharOpenedByDefault, {
            Checked = Settings.openByDefaultMainChar,
            OnChange = function (e)
                Settings.openByDefaultMainChar = e.Checked
                Settings:Save()
            end
        })



    E.checkMainRotOpenedByDefault = collapseOBDMain:AddCheckbox('Rotation')
        UI:Config(E.checkMainRotOpenedByDefault, {
            IDContext = 'adwdawda',
            Checked = Settings.openByDefaultMainRot,
            OnChange = function (e)
                Settings.openByDefaultMainRot = e.Checked
                Settings:Save()
            end
        })



    local collapseOBDPM = collapseDefault:AddTree('PM')



    E.checkPMCameraOpenedByDefault = collapseOBDPM:AddCheckbox('Camera')
        UI:Config(E.checkPMCameraOpenedByDefault, {
            Checked = Settings.openByDefaultPMCamera,
            OnChange = function (e)
                Settings.openByDefaultPMCamera = e.Checked
                Settings:Save()
            end
        })



    E.checkPMInfoOpenedByDefault = collapseOBDPM:AddCheckbox('Info')
        UI:Config(E.checkPMInfoOpenedByDefault, {
            Checked = Settings.openByDefaultPMInfo,
            OnChange = function (e)
                Settings.openByDefaultPMInfo = e.Checked
                Settings:Save()
            end
        })



    E.checkPMPosOpenedByDefault = collapseOBDPM:AddCheckbox('Position')
        UI:Config(E.checkPMPosOpenedByDefault, {
            Checked = Settings.openByDefaultPMPos,
            OnChange = function (e)
                Settings.openByDefaultPMPos = e.Checked
                Settings:Save()
            end
        })



    E.checkPMRotOpenedByDefault = collapseOBDPM:AddCheckbox('Rotation')
        UI:Config(E.checkPMRotOpenedByDefault, {
            Checked = Settings.openByDefaultPMRot,
            OnChange = function (e)
                Settings.openByDefaultPMRot = e.Checked
                Settings:Save()
            end
        })



    E.checkPMScaleOpenedByDefault = collapseOBDPM:AddCheckbox('Scale')
        UI:Config(E.checkPMScaleOpenedByDefault, {
            Checked = Settings.openByDefaultPMScale,
            OnChange = function (e)
                Settings.openByDefaultPMScale = e.Checked
                Settings:Save()
            end
        })



    E.checkPMLookOpenedByDefault = collapseOBDPM:AddCheckbox('Look at')
        UI:Config(E.checkPMLookOpenedByDefault, {
            Checked = Settings.openByDefaultPMLook,
            OnChange = function (e)
                Settings.openByDefaultPMLook = e.Checked
                Settings:Save()
            end
        })



    E.checkPMSaveOpenedByDefault = collapseOBDPM:AddCheckbox('Save')
        UI:Config(E.checkPMSaveOpenedByDefault, {
            Checked = Settings.openByDefaultPMSave,
            OnChange = function (e)
                Settings.openByDefaultPMSave = e.Checked
                Settings:Save()
            end
        })


    E.checkBZInfoOpenByDefault = collapseOBDPM:AddCheckbox('Bone Zone info')
        UI:Config(E.checkBZInfoOpenByDefault, {
            Checked = not Settings.openByDefaultBZInfo,
            OnChange = function (e)
                Settings.openByDefaultBZInfo = not e.Checked
                Settings:Save()
            end
        })




    local c = 0
    E.checkPickerSize = p:AddCheckbox('Bigger color picker')
        UI:Config(E.checkPickerSize, {
            Checked = Settings.biggerPicker,
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

                Settings.biggerPicker = e.Checked
                Imgui.ClearChildren(E.main2)

                Helpers.Timer:OnTicks(10, function ()
                    MainTab(E.main2)
                end)
                Settings:Save()
            end
        })



    E.slFadeTime = p:AddSlider('Elements fade time')
        UI:Config(E.slFadeTime, {
            Value = {Settings.fadeTime, 0, 0, 0},
            OnChange = function (e)
                Settings.fadeTime = e.Value[1]
                Settings:Save()
            end
        })


     E.checkShowFloats = p:AddCheckbox('Show floating tabs (garbage (dont use))')
            UI:Config(E.checkShowFloats, {
                Checked = Settings.showFloats,
                OnChange = function(e)
                    Settings.showFloats = e.Checked
                    if e.Checked then
                        Garbo2Floats()
                    else
                        Imgui.ClearChildren(E.mainMenu)
                    end
                    Settings:Save()
                end,
                Tooltip = [[    I don't know how to make it better rn, I don't like it, cuz it duplicates tabs,
        but if you do, use it]]
            })


    p:AddSeparatorText('Lights')



    E.checkDefaultType = p:AddCombo('Default type')
        UI:Config(E.checkDefaultType, {
            Options = {'Point', 'Spotlight', 'Directional'},
            SelectedIndex = table.find({'Point', 'Spotlight', 'Directional'}, Settings.defaultLightType) - 1,
            OnChange = function (e)
                Settings.defaultLightType = E.checkDefaultType.Options[E.checkDefaultType.SelectedIndex + 1]
                Settings:Save()
            end
        })



    E.slLightCreDelay = p:AddSliderInt('Additional light creation delay', 0, 0, 50)
        UI:Config(E.slLightCreDelay, {
            Value = {Settings.lightCreateDelay,0,0,0},
            OnChange = function (e)
                Settings.lightCreateDelay = e.Value[1]
                Settings:Save()
            end
        })



    p:AddSeparatorText('Marker')


    E.slMarkerSize = p:AddSlider('Default marker size', DEFAULT_MARKER_SCALE, 0.01, DEFAULT_MARKER_SCALE, 1)
        UI:Config(E.slMarkerSize, {
            Value = {Settings.markerScale, 0, 0, 0},
            OnChange = function (e)
                Settings.markerScale = e.Value[1]
                Settings:Save()
                if not _GLL.markerEntity then return end
                _GLL.markerEntity.Visual.Visual:SetWorldScale({Settings.markerScale, Settings.markerScale, Settings.markerScale})
            end
        })



    E.checkColMark = p:AddCheckbox('Colorful markers')
        UI:Config(E.checkColMark, {
            Checked = Settings.colorfulMarkers,
            OnChange = function (e)
                Settings.colorfulMarkers = e.Checked
                Settings:Save()
            end
        })



    E.checkToggleMarker = p:AddCheckbox('Marker off by default')
        UI:Config(E.checkToggleMarker, {
            Checked = Settings.markerOff,
            OnChange = function (e)
                Settings.markerOff = e.Checked
                Settings:Save()
            end
        })



    p:AddSeparatorText('Atmosphere and Lighting')


    E.checkAllowCC = p:AddCheckbox('Allows switching AnL in the mirror')
        UI:Config(E.checkAllowCC, {
            Checked = Settings.allowMirror,
            OnChange = function (e)
                Settings.allowMirror = e.Checked
                Settings:Save()
            end
        })



    p:AddSeparatorText('Camera')



    E.slDefCamSpeed = p:AddSlider('Default camera speed', 0, 0.1, 10, 1)
        UI:Config(E.slDefCamSpeed, {
            Value = {Settings.defaultCameraSpeed, 0, 0, 0},
            OnChange = function (e)
                Settings.defaultCameraSpeed = e.Value[1]
                Settings:Save()
            end
        })



    E.checkStickToggle = p:AddCheckbox('Disable stick to camera on light creation')
        UI:Config(E.checkStickToggle, {
            Checked = Settings.stickToggleOff,
            OnChange = function (e)
                Settings.stickToggleOff = e.Checked
                Settings:Save()
            end
        })



    p:AddSeparatorText('Characters')



    E.checkLightSetupState = p:AddCheckbox('CharacterLight setup off by default')
        UI:Config(E.checkLightSetupState, {
            Checked = lightSetupState,
            OnChange = function (e)
                Settings.lightSetupState = e.Checked
                E.checkLightSetup.Checked = Settings.lightSetupState
                CharacterLightSetupState(Settings.lightSetupState)
                Settings:Save()
            end
        })



    E.checkDarkVisionState = p:AddCheckbox('Darkvision off by default')
        UI:Config(E.checkDarkVisionState, {
            Checked = Settings.darkVisionState,
            OnChange = function (e)
                Settings.darkVisionState = e.Checked
                E.checkVision.Checked = Settings.darkVisionState
                DarkVisionState(Settings.darkVisionState)
                Settings:Save()
            end
        })



    -- p:AddSeparatorText('Anal')



    -- E.slAnlApplyDelay = p:AddSliderInt('AnL apply delay', 500, 1, 1000, 1)
    --     UI:Config(E.slAnlApplyDelay, {
    --         Value = Settings.anlApplyDelay or {500,0,0,0},
    --         OnChange = function(e)
    --             Settings.anlApplyDelay = e.Value
    --             Settings:Save()
    --         end
    --     })



    p:AddSeparatorText('Bone Zone')



    E.comboGradients = p:AddCombo('Bone zone gradient')
        UI:Config(E.comboGradients, {
            Options = {'Rainbow','Ice','Forest','Daniela','Gold','Void','Mono'},
            SelectedIndex = Settings.defaultGradient - 1 or 0,
            OnChange = function(e)
                Settings.defaultGradient = e.SelectedIndex + 1
                Settings:Save()
                ResetBoneZoneTab()
            end
        })

    p:AddText([[    Gradients are for readability, choose the one that is most readable,
    not fashionable]])


    E.checkBzScale = p:AddCheckbox([[Enable Bone Zone Scale, I know what I'm doing, I am aware of the issue and
I know all workarounds]])
        UI:Config(E.checkBzScale, {
            Checked = Settings.bzScaleEnabled,
            OnChange = function (e)
                Settings.bzScaleEnabled = e.Checked
                Settings:Save()
                ResetBoneZoneTab()
            end
        })



    E.checkTailPhys = p:AddCheckbox('Auto disable tail physics')
        UI:Config(E.checkTailPhys, {
            Checked = Settings.autoDisablePhys,
            OnChange = function (e)
                Settings.autoDisablePhys = e.Checked
                E.checkAutoTail.Checked = Settings.autoDisablePhys
                Settings:Save()
            end
        })



    p:AddSeparatorText('Fadeables')


    E.slIntFadeDistance = p:AddSliderInt('Remove distance', 10000, 2000, 10000)
        UI:Config(E.slIntFadeDistance, {
            Value = {Settings.fadeableDistance, 0, 0, 0},
            OnChange = function (e)
                Settings.fadeableDistance = e.Value[1]
                Settings:Save()
            end
        })



    E.slIntFadeBatch = p:AddSliderInt('Batch size', 10, 10, 200)
        UI:Config(E.slIntFadeBatch, {
            Value = {Settings.fadeableBatchSize, 0, 0, 0},
            OnChange = function (e)
                Settings.fadeableBatchSize = e.Value[1]
                Settings:Save()
            end
        })


    E.slIntFadeTickInt = p:AddSliderInt('Tick interval', 10, 1, 10)
        UI:Config(E.slIntFadeTickInt, {
            Value = {Settings.fadeableTickInterval, 0, 0, 0},
            OnChange = function (e)
                Settings.fadeableTickInterval = e.Value[1]
                Settings:Save()
            end
        })


    p:AddSeparatorText('Gizmo')


    E.checkGizmoToolbar = p:AddCheckbox('Auto open Gizmo Toolbar when entering photo mode')
        UI:Config(E.checkGizmoToolbar, {
            Checked = Settings.autoOpenToolbar,
            OnChange = function (e)
                Settings.autoOpenToolbar = e.Checked
                E.checkGizmoToolbar.Checked = Settings.autoOpenToolbar
                Settings:Save()
            end
        })


    p:AddSeparatorText('Debug')



    E.slPmDelay = p:AddSliderInt('Delay before initializing PM bs', 35, 35, 200, 1)
        UI:Config(E.slPmDelay, {
            Value = Settings.pmInitDelay or {35,0,0,0},
            OnChange = function(e)
                Settings.pmInitDelay = e.Value
                Settings:Save()
            end
        })



    E.btnResetDummies = p:AddButton('Reset dummies')
        UI:Config(E.btnResetDummies, {
            OnClick = function(e)
                if not _GLL.States.inPhotoMode then return end
                Utils:SubUnsubToTick(0, 'PhotoMode')
                if E.grpGizmoDummies then Imgui.ClearChildren(E.grpGizmoDummies) end
                boneZoneInit = false
                OnPhotoModeCreate()
            end
        })



    p:AddSeparatorText('Jank')


    E.slAnlJank = p:AddSlider('Camera offset for changing anal', 0.002, 0.002, 0.010)
        UI:Config(E.slAnlJank, {
            Value = {Settings.cameraOffset, 0, 0, 0},
            OnChange = function (e)
                Settings.cameraOffset = e.Value[1]
                Settings:Save()
            end
        })


    E.checkGizmoToolbar = p:AddCheckbox([[Don't check if you want AnL being broken]])
        UI:Config(E.checkGizmoToolbar, {
            Checked = Settings.degenExtendedScriptExtender,
            OnChange = function (e)
                Settings.degenExtendedScriptExtender = e.Checked
                Settings:Save()
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


--[[
e = Ext.Entity.GetAllEntities()
for k, v in pairs(e) do
    if v.CombatParticipant and v.Uuid then
        SetCanJoinCombat(v.Uuid.EntityUuid, 0)
    end
end
]]--

