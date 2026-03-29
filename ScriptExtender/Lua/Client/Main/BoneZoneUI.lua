local bz

function BoneZoneTab(p)

    E.grpBZ = p:AddGroup('BZ')
    bz = E.grpBZ

    if not readTheRules then
        local txtRule = bz:AddText([[
        By using this mod to create and share poses,
        you agree that all shared poses must be licensed under CC BY-SA 4.0
        and cannot be restricted from modification by others.]])

        local dum = bz:AddDummy(34, 1)

        E.checkRule = bz:AddButton('Agree')
            UI:Config(E.checkRule, {
                SameLine = true,
                OnClick = function(e)
                    readTheRules = true
                    SettingsSave()

                    txtRule:Destroy()
                    dum:Destroy()

                    BZAgreed()
                end
            })

    else
        BZAgreed()
    end
end


function BZAgreed()

    local txtBone = bz:AddSeparatorText('BoneZone')
    _GLL.States.bonesUnlocked = false







    function UpdateBZDummyCombo(e)
        selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1
        SetVarValuesToSliders()
        E.visTemComob.SelectedIndex = e.SelectedIndex
        LoadAttachState(getSelectedDummy())
    end



    E.cmbBoneDummies = bz:AddCombo('Dummies')
        UI:Config(E.cmbBoneDummies, {
            SelectedIndex = E.visTemComob.SelectedIndex or 0,
            Options = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine = false,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then return end
                UpdateDummyCombo(e)
            end
        })
    selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1



    -- E.btnMap = bz:AddButton('Dump Variables')
    --     UI:Config(E.btnMap, {
    --         OnClick = function()
    --             if not _GLL.States.inPhotoMode then return end
    --             local entity = getSelectedDummy()
    --             DDump(GetGenomeVariablesIndicies(entity))
    --         end
    --     })



    E.checkAutoTail = bz:AddCheckbox('Disable tail physics')
    E.checkAutoHair = bz:AddCheckbox('Disable hair physics')
    E.checkAutoTent = bz:AddCheckbox('Disable tentacles physics')
    -- bz:AddDummy(10, 0).SameLine = true
    bz:AddText('You need to disable it before entering')



    bz:AddSeparatorText('Attachies')



    E.btnGetDaggers = bz:AddButton([[Get Daniela's daggers]])
        UI:Config(E.btnGetDaggers, {
            OnClick = function(e)
                Ch.GetDaggers:SendToServer({})
            end
        })



    --- Temporal garbo
    --- 2e8cc79e-ca32-e196-0bb1-a6084c1328bb
    --- d367a2d6-fcb8-5de9-d3d8-e070be782c31 star
    --- 9b7b882e-eb44-e3c6-42ac-14f37070f9d0 book
    --- c6cd7103-f493-0cdc-3f18-7f34bfeaea4a ring



    E.inputAttachItem = bz:AddInputText('')
    E.inputAttachItem.SameLine = false



    E.checkAttachies = bz:AddCheckbox('')
        UI:Config(E.checkAttachies, {
            SameLine = true,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Checked = false return end
                tickAttach(e, 'Main')
                SaveAttachState(getSelectedDummy())
            end
        })



    bz:AddText('Main hand').SameLine = true


    E.slAttachScale = bz:AddSlider('', 1, 0.1, 2, 1)
        UI:Config(E.slAttachScale, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Value = {1,0,0,0} return end
                ScaleAttachment('Main', e.Value[1])
                SaveAttachState(getSelectedDummy())
            end
        })



    bz:AddDummy(40,0).SameLine = true
    bz:AddText('Main scale').SameLine = true



    E.inputAttachItemOff = bz:AddInputText('')
    E.inputAttachItemOff.SameLine = false



    E.checkAttachiesOff = bz:AddCheckbox('')
    UI:Config(E.checkAttachiesOff, {
        SameLine = true,
        OnChange = function(e)
            if not _GLL.States.inPhotoMode then e.Checked = false return end
            tickAttach(e, 'Off')
            SaveAttachState(getSelectedDummy())
        end
    })



    bz:AddText('Off hand').SameLine = true



    E.slAttachScaleOff = bz:AddSlider('', 1, 0.1, 2, 1)
        UI:Config(E.slAttachScaleOff, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Value = {1,0,0,0} return end
                ScaleAttachment('Main', e.Value[1])
                SaveAttachState(getSelectedDummy())
            end
        })

    bz:AddDummy(40,0).SameLine = true
    bz:AddText('Off scale').SameLine = true



    bz:AddSeparatorText('Garbo')

    bz:AddText([[    If you want to make a pose from scratch,
    you should start from this T-Pose IMP_Rig_TPose]])

    bz:AddDummy(1,10)
    bz:AddText([[    You can change gradient color in the settings.]])



    E.btnTposeQSAT = bz:AddButton('IMP_Rig_TPose [QSAT SLOT 10]')
            UI:Config(E.btnTposeQSAT, {
                SameLine = false,
                OnClick = function(e)
                    if not Mods.QSAT then return end

                    for _, AnimationSet in pairs(Mods.QSAT.BaseBodyAnimationSets) do
                        Mods.QSAT.SkizzingSataning(
                            AnimationSet,
                            '88838fb7-4548-4471-a88c-f833f7aaedad',
                            'db3f767f-c553-e9b2-3a2a-08037bd484a1',
                            ''
                        )
                    end
                end
            })


    bz:AddSeparatorText('Garbo 2')



    E.btnResetBpnes = bz:AddButton('Reset all')
    local resetId = UI:CreateConfirmButton(bz, E.btnResetBpnes, 'Reset all', function()
        ResetAllBones()
    end)
        UI:Config(E.btnResetBpnes, {
            OnClick = function()
                if not _GLL.States.inPhotoMode then return end
                UI:Confirm(E.btnResetBpnes, resetId, 1000)
            end
        })



    E.btnUndo = bz:AddButton('Undo|Shift+Z')
        UI:Config(E.btnUndo, {
            SameLine = false,
            OnClick = function()
                HistoryUndo()
            end
        })



    E.btnRedo = bz:AddButton('Redo|Shift+X')
        UI:Config(E.btnRedo, {
            SameLine = true,
            OnClick = function()
                HistoryRedo()
            end
        })



    _GLL.States.bzSymmetry = false

    E.checkSymm = bz:AddCheckbox('Symmetry|Alt+F')
        UI:Config(E.checkSymm, {
            SameLine = false,
            OnChange = function(e)
                _GLL.States.bzSymmetry = e.Checked
            end
        })

    bns = bz:AddGroup('Bones')



    E.btnPose       = {}
    E.btnX2         = {}
    E.btnUpd        = {}
    E.slBZ          = {}
    E.collapseGroup = {}
    E.treeCategory  = {}
    E.collapseBone  = {}
    E.treeTrans     = {}
    E.treeRot       = {}
    E.treeScale     = {}

    ActiveGradient = Style.Gradients[defaultGradient]
    CreateContolsForEachBoneGroupAndColorize()

    -- E.slBZ['eye_l_Rot_1'].Disabled = true
    -- E.slBZ['eye_r_Rot_1'].Disabled = true



    local additionalGroup = bns:AddCollapsingHeader('Additional')

    local collapseIK = additionalGroup:AddTree('BonesBodyKindaIK')

    for _, chainDef in ipairs(IKChains) do
        CreateIKControls(collapseIK, chainDef)
    end
    collapseIK:AddSeparator()



    ---TBD: Temporal garbo
    local treeLockedRootM = additionalGroup:AddTree('Root_M_Locked')

    local treeLRMRot = treeLockedRootM:AddTree('Rotation')
    treeLRMRot.DefaultOpen = true
    treeLRMRot.IDContext   = Ext.Math.Random(1, 10000000)


    local function negativeTbl(tbl)
        return Vector.Mul(tbl, {-1, -1, -1, 0})
    end



    E.slLockedRootM = treeLRMRot:AddDrag('RootM', 0, MAX_ROT, MIN_ROT, 1)
        UI:Config(E.slLockedRootM, {
            Components = 3,
            OnChange = function(e)
                SetValueToVarAndTableIt('Root_M_Rot', e.Value)
                SetValueToVarAndTableIt('Spine1_M_Rot', negativeTbl(e.Value))

                SetVarValuesToSliders()

            end
        })



    E.slLockedRootMH = treeLRMRot:AddDrag('RootMHips', 0, MAX_ROT, MIN_ROT, 1)
        UI:Config(E.slLockedRootMH, {
            Components = 3,
            OnChange = function(e)
                SetValueToVarAndTableIt('Root_M_Rot', e.Value)
                SetValueToVarAndTableIt('Spine1_M_Rot', negativeTbl(e.Value))

                local Value = e.Value
                local c = {Value[1], -Value[2], -Value[3]}

                SetValueToVarAndTableIt('Hip_L_Rot', c)

                local Value = e.Value
                local c = {-Value[1], Value[2], -Value[3]}

                SetValueToVarAndTableIt('Hip_R_Rot', c)

                SetVarValuesToSliders()

            end
        })



    E.slLockedRootM = treeLRMRot:AddDrag('RootM', 0, MAX_ROT, MIN_ROT, 1)
        UI:Config(E.slLockedRootM, {
            Components = 3,
            OnChange = function(e)
                SetValueToVarAndTableIt('Root_M_Rot', e.Value)
                SetValueToVarAndTableIt('Spine1_M_Rot', negativeTbl(e.Value))

                SetVarValuesToSliders()

            end
        })




    additionalGroup:AddSeparator()



    bz:AddSeparatorText('Saved poses')



    E.inputSearch = bz:AddInputText('Search')
        UI:Config(E.inputSearch, {
            OnChange = function(e)
                FilterPoses(E.inputSearch.Text)
            end
        })



    E.comboCats = bz:AddCombo('Category')
        UI:Config(E.comboCats, {
            Options = SaveCategories,
            SelectedIndex = 0
        })



    E.inputPoseName = bz:AddInputText('')



    _GLL.SavedPoses = _GLL.SavedPoses or {}



    E.btnSavePose = bz:AddButton('Save pose')
        UI:Config(E.btnSavePose, {
            SameLine = true,
            OnClick = function(e)
                if not _GLL.States.inPhotoMode then return end

                local catName = UI:SelectedOpt(E.comboCats)
                local poseName = E.inputPoseName.Text
                if poseName == '' then return end
                local poseDoesntExist = CreatePoseButton(catName, poseName)

                if poseDoesntExist then
                    TableBoneValues()
                    Ext.IO.SaveFile('LightyLights/Poses/' .. poseName .. '.json',
                        Ext.Json.Stringify(_GLL.PoseValues[getSelectedDummyOwnerUuid()]))

                    _GLL.SavedPoses[catName] = _GLL.SavedPoses[catName] or {}

                    if not table.find(_GLL.SavedPoses[catName], poseName) then
                        table.insert(_GLL.SavedPoses[catName], poseName)
                    else
                        return DPrint('Pose already added')
                    end

                    Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(_GLL.SavedPoses))
                else
                    return DPrint('Pose already added')
                end

            end
        })



    E.btnLoadPose = bz:AddButton('Load pose')
        UI:Config(E.btnLoadPose, {
            SameLine = true,
            OnClick = function(e)
                local catName = UI:SelectedOpt(E.comboCats)
                local poseName = E.inputPoseName.Text
                local poseDoesntExist = AddPoseToList(catName, poseName)

                if poseDoesntExist then
                    LoadPoseList()
                    CreateCategoryTree(catName)
                    CreatePoseButton(catName, poseName)
                end
            end
        })



    E.inputCatName = bz:AddInputText('')



    E.btnAddCat = bz:AddButton('Add category')
        UI:Config(E.btnAddCat, {
            SameLine = true,
            OnClick = function(e)
                if E.inputCatName.Text == '' then return end
                local catName = E.inputCatName.Text
                CreateCategoryTree(catName)
                E.comboCats.SelectedIndex = table.find(SaveCategories, catName) - 1
                E.inputCatName.Text = ''

                _GLL.SavedPoses[catName] = _GLL.SavedPoses[catName] or {}

                Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(_GLL.SavedPoses))
            end
        })



    E.checkPoseUpd = bz:AddCheckbox('Blender to Bone Zone')
        UI:Config(E.checkPoseUpd, {
            OnChange = function(e)
                local ticks = 0
                local uuid = getSelectedDummyOwnerUuid()

                if e.Checked then
                    DPrint('Fetching started')
                    Utils:SubUnsubToTick(1, 'POSEFILEFETCH', function()
                        ticks = ticks + 1
                        if ticks % E.slFetchInterval.Value[1] == 1 then
                            DPrint('Fetched')
                            local poseName = E.inputPoseName.Text
                            -- ResetAllBones()
                            local file = Ext.IO.LoadFile('LightyLights/Poses/' .. poseName .. '.json')
                            if file then
                                local SavedPose = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Poses/' .. poseName .. '.json'))
                                _GLL.PoseValues[uuid] = SavedPose

                                SetVarValuesToSliders()
                                SetValuesToVars()
                            end
                        end
                    end)
                else
                    DPrint('Fetching stopped')
                    Utils:SubUnsubToTick(0, 'POSEFILEFETCH', _)
                end
            end
        })

    E.slFetchInterval = bz:AddSliderInt('Update interval', 10, 2, 100, 1)

    E.savedPoseParent = bz:AddChildWindow('Saved poses')
    E.savedPoseParent.Size = {-1, 500}



    function CreateCategoriesAndButtons()
        for catName, Poses in pairs(_GLL.SavedPoses) do
            CreateCategoryTree(catName)
            for _, poseName in pairs(Poses) do
                CreatePoseButton(catName, poseName)
            end
        end
    end
    CreateCategoriesAndButtons()


    E.savedPoseParent:AddText([[Deleted posed are not deleted completely, you need to delete them after in
AppData\Local\Larian Studios\Baldur's Gate 3\Script Extender\LightyLights\Poses\]])

    E.savedPoseParent:AddDummy(1,10)

    E.savedPoseParent:AddText('o overwrites saved pose')


    -- Test = {
    --     Categories = {'PETR', 'DANI', 'MooN'},
    --     Poses = {
    --         PETR = {'xd', 'XDDD'},
    --         DANI = {'RAR', 'CATHUG'},
    --         MooN = {'Kiss', ':xd:'}
    --     }
    -- }
end