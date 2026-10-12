local bz
local bz2

function BoneZoneTab(p)
    E.grpBZ = p:AddGroup('BZ')
    bz  = E.grpBZ
    E.grpBZAgreed = p:AddGroup('BZ2')
    bz2 = E.grpBZAgreed
    bz2.Visible = false

    if not Settings.readTheRules then
        DPrint([[User haven't agreed]])
        local txtRule = bz:AddText([[
        By using this mod to create and share poses,
        you agree that all shared poses must be licensed under CC BY-SA 4.0
        and cannot be restricted from modification by others.]])

        local dum = bz:AddDummy(34, 1)

        E.checkRule = bz:AddButton('Agree')
            UI:Config(E.checkRule, {
                SameLine = true,
                OnClick = function(e)
                    Settings.readTheRules = true
                    Settings:Save()
                    bz:Destroy()
                    bz2.Visible = true
                end
            })
    else
        bz2.Visible = true
        DPrint([[User has agreed]])
    end



    local txtBone = bz2:AddSeparatorText('BoneZone')
    _GLL.States.bonesUnlocked = false

    E.collapseBZGuide = bz2:AddCollapsingHeader('Bone Zone Info [must read]')
    E.collapseBZGuide.DefaultOpen = Settings.openByDefaultBZInfo

    E.txtBZGuide = E.collapseBZGuide:AddText([[
x - delete (double-click)
o - overwrite saved pose (double-click)
m - apply pose as mask (overlay onto current pose)
e - export category as mod (double-click)

Deleted poses are not fully removed automatically.
Please delete them manually from:
AppData\Local\Larian Studios\Baldur's Gate 3\Script Extender\LightyLights\Poses\

If you plan to export poses, please be respectful to others and
help keep the experience good for everyone, I recommend to follow
Larian's animation naming convention (partially).

For singular character: HUM_F_BendOver_Left
Where HUM - race, F - body type, BendOver - action, Left - direction of the actions (optional)

For multiple characters pose: HUM_F_BendOver_A, HUM_F_BendOver_B
Where A, B, C, D, etc. represent each character.

For individual body parts: HUM_F_Mask_Hand_Fist
Where Mask - keyword for mask, Hand - body part, Fist - action

You can find all races and body types on the BG3 Community Wiki:
]])
    local link = E.collapseBZGuide:AddInputText('copy me')
    link.Text = 'https://wiki.bg3.community/en/Information/races'
    E.collapseBZGuide:AddDummy(1,20)



    function UpdateBZDummyCombo(e)
        selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1
        DPrint('UpdateBZDummyCombo, character: %s', selectedCharacter)
        SetVarValuesToSliders()
        E.comboDummies.SelectedIndex = e.SelectedIndex
        LoadAttachState(getSelectedDummy())
    end



    E.cmbBoneDummies = bz2:AddCombo('Dummies')
        UI:Config(E.cmbBoneDummies, {
            SelectedIndex = E.comboDummies.SelectedIndex or 0,
            Options = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine = false,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then return end
                UpdateDummyCombo(e)
            end
        })
    selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1



    E.checkAutoTail = bz2:AddCheckbox('Disable tail physics')
    E.checkAutoTail.Checked = Settings.autoDisablePhys or false

    E.checkAutoHair  = bz2:AddCheckbox('Disable hair physics')
    E.checkAutoHair.SameLine = true
    E.checkAutoHair.Disabled = true

    E.checkAutoTent  = bz2:AddCheckbox('Disable tentacles physics')
    E.checkAutoTent.SameLine = true

    E.checkAutoWings = bz2:AddCheckbox('Disable wings physics')

    E.checkAutoDick  = bz2:AddCheckbox('Disable dick physics')
    E.checkAutoDick.SameLine = true

    bz2:AddText('You need to disable it before entering')



    bz2:AddSeparatorText('Attachies')



    E.btnGetDaggers = bz2:AddButton([[Get Daniela's daggers]])
        UI:Config(E.btnGetDaggers, {
            OnClick = function(e)
                Ch.GetDaggers:SendToServer({})
            end
        })



    E.inputAttachItem = bz2:AddInputText('')
    E.inputAttachItem.SameLine = false



    E.checkAttachies = bz2:AddCheckbox('')
        UI:Config(E.checkAttachies, {
            SameLine = true,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Checked = false return end
                tickAttach(e, 'Main')
                SaveAttachState(getSelectedDummy())
            end
        })



    bz2:AddText('Main hand').SameLine = true



    E.slAttachScale = bz2:AddDrag('', 1, 0.001, 1000, 1)
        UI:Config(E.slAttachScale, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Value = {1,0,0,0} return end
                ScaleAttachment('Main', e.Value[1]/100)
                SaveAttachState(getSelectedDummy())
            end
        })



    bz2:AddDummy(40,0).SameLine = true
    bz2:AddText('Main scale').SameLine = true



    E.inputAttachItemOff = bz2:AddInputText('')
    E.inputAttachItemOff.SameLine = false



    E.checkAttachiesOff = bz2:AddCheckbox('')
    UI:Config(E.checkAttachiesOff, {
        SameLine = true,
        OnChange = function(e)
            if not _GLL.States.inPhotoMode then e.Checked = false return end
            tickAttach(e, 'Off')
            SaveAttachState(getSelectedDummy())
        end
    })



    bz2:AddText('Off hand').SameLine = true



    E.slAttachScaleOff = bz2:AddDrag('', 1, 0.001, 1000, 1)
        UI:Config(E.slAttachScaleOff, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then e.Value = {1,0,0,0} return end
                ScaleAttachment('Off', e.Value[1]/100)
                SaveAttachState(getSelectedDummy())
            end
        })

    bz2:AddDummy(40,0).SameLine = true
    bz2:AddText('Off scale').SameLine = true

    bz2:AddText('Dummy_R/L_Hand bones to control item position')

    bz2:AddSeparatorText('Garbo')

    bz2:AddText([[    If you want to make a pose from scratch,
    you should start from this T-Pose IMP_Rig_TPose.]])

    bz2:AddDummy(1,10)
    bz2:AddText([[    You can change gradient color in the settings.]])



    bz2:AddSeparatorText('Garbo 2')



    E.btnTposeQSAT = bz2:AddButton('TPOSE [You need QSAT for this to work]')
            UI:Config(E.btnTposeQSAT, {
                SameLine = false,
                OnClick = function(e)
                    if not Mods.QSAT then E.btnTposeQSAT.Label = 'You need QSAT mod for this to work' return end
                    local dummy = getSelectedDummy()
                    local id = Mods.QSAT._GLL.OriginNames[Mods.QSAT.E.comboCharacters.SelectedIndex + 1]

                    for _, AnimationSet in pairs(Mods.QSAT.BaseBodyAnimationSets) do
                        Mods.QSAT.SkizzingSataning(
                            AnimationSet,
                            Mods.QSAT._GLL.CharacterBodyMapKeyMap[id],
                            'db3f767f-c553-e9b2-3a2a-08037bd484a1',
                            ''
                        )
                    end

                    if _GLL.States.inPhotoMode then
                        dummy.DummyAnimationState.State.PhotoModeState = 'AnimationPlaying'
                        dummy.DummyAnimationState.State.Pose = Mods.QSAT._GLL.CharacterBodyMapKeyMap[id]
                        dummy:MarkChanged('DummyAnimationState')
                    end
                end
            })



    E.btnResetBpnes = bz2:AddButton('Reset all')
    local resetId = UI:CreateConfirmButton(bz2, E.btnResetBpnes, 'Reset all', function()
        ResetAllBones()
        SetVarValuesToSliders()
    end)
        UI:Config(E.btnResetBpnes, {
            OnClick = function()
                if not _GLL.States.inPhotoMode then return end
                UI:Confirm(E.btnResetBpnes, resetId, 1000)
            end
        })



    E.btnUndo = bz2:AddButton('Undo|Shift+Z')
        UI:Config(E.btnUndo, {
            SameLine = false,
            OnClick = function()
                HistoryUndo()
            end
        })



    E.btnRedo = bz2:AddButton('Redo|Shift+X')
        UI:Config(E.btnRedo, {
            SameLine = true,
            OnClick = function()
                HistoryRedo()
            end
        })



    _GLL.States.bzSymmetry = false

    E.checkSymm = bz2:AddCheckbox('Symmetry|Alt+F')
        UI:Config(E.checkSymm, {
            SameLine = false,
            OnChange = function(e)
                _GLL.States.bzSymmetry = e.Checked

                if e.Checked then
                    -- tab = mainTabBar:AddTabItem('Sym')
                else
                    -- tab:Destroy()
                end

            end
        })


    E.btnQuickSave = bz2:AddButton('QuickSave|Shift+S')
        UI:Config(E.btnQuickSave, {
            OnClick = function()
                BZ.QuickSave()
            end
        })

    -- E.checkBoneGizmo = bz2:AddCheckbox('Enable bone gizmo')
    --     UI:Config(E.checkBoneGizmo, {
    --         SameLine = false,
    --         OnChange = function(e)
    --             if not _GLL.States.inPhotoMode then e.Checked = false return end

    --             if e.Checked then
    --                 JointLoopOnce(getSelectedDummy())
    --                 _GLL.gizmo:SetActive(false)
    --                 _GLL.boneGizmo:SetActive(true)
    --                 _GLL.boneGizmo:SetSpace('Local')

    --             else
    --                 -- JointLoopStop()
    --                 DeleteJoint()
    --                 _GLL.gizmo:SetActive(true)
    --                 _GLL.boneGizmo:SetActive(false)
    --             end
    --         end
    --     })

    bns = bz2:AddGroup('Bones')


    E.inputSearchBones = bns:AddInputText('')
        UI:Config(E.inputSearchBones, {
            Hint = 'head m for bone or arms for whole tree',
            OnChange = function(e)
                FilterBones(E.inputSearchBones.Text)
            end
        })

    E.btnClearSearchBones = bns:AddButton('Clear')
    E.btnClearSearchBones.SameLine = true
    E.btnClearSearchBones.OnClick = function() E.inputSearchBones.Text = ''; FilterBones(E.inputSearchBones.Text) end


    E.btnPose       = {}
    E.btnX2         = {}
    E.btnUpd        = {}
    E.btnMask       = {}
    E.btnExp        = {}
    E.slBZ          = {}
    E.collapseGroup = {}
    E.treeCategory  = {}
    E.collapseBone  = {}
    E.treeTrans     = {}
    E.treeRot       = {}
    E.treeScale     = {}
    E.btnX          = {}
    E.catTree       = {}



    if Settings.bzScaleEnabled then --- Disabled due to Larian being Larian
        AxesNames.Scale = {'SX','SY','SZ'}
    else
        AxesNames.Scale = nil
    end
    SaveCategories = {}


    ActiveGradient = Style.Gradients[Settings.defaultGradient] or Style.Gradients[7]

    --- MAIN BONES TREES INITIALIZATION
    --- MAIN BONES TREES INITIALIZATION
    --- MAIN BONES TREES INITIALIZATION

    CreateContolsForEachBoneGroupAndColorize()

    local additionalGroup = bns:AddCollapsingHeader('Additional')

    local collapseIK = additionalGroup:AddTree('BonesBodyKindaIK')

    for _, chainDef in ipairs(IKChains) do
        CreateIKControls(collapseIK, chainDef)
    end
    collapseIK:AddSeparator()



    ---TBD: Temporal garbo
    local treeLockedRootM = additionalGroup:AddTree('Root_M_Locked')

    local txt = treeLockedRootM:AddText('THIS IS GARBO, BE CAREFUL')

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



    bz2:AddSeparatorText('Saved poses')



    E.inputSearch = bz2:AddInputText('Search')
        UI:Config(E.inputSearch, {
            OnChange = function(e)
                FilterPoses(E.inputSearch.Text)
            end
        })



    E.comboCats = bz2:AddCombo('Category')
        UI:Config(E.comboCats, {
            Options = SaveCategories,
            SelectedIndex = 0
        })



    E.inputPoseName = bz2:AddInputText('')



    _GLL.SavedPoses = _GLL.SavedPoses or {}

    E.btnSavePose = bz2:AddButton('Save pose')
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
                    Ext.IO.SaveFile('LightyLights/Poses/' .. catName:gsub(' | Local$', '') .. '/' .. poseName .. '.json',
                        Ext.Json.Stringify(StripDefaultBoneValues(getSelectedDummyOwnerUuid())))

                    _GLL.SavedPoses[catName] = _GLL.SavedPoses[catName] or {}

                    if not table.find(_GLL.SavedPoses[catName], poseName) then
                        table.insert(_GLL.SavedPoses[catName], poseName)
                    else
                        return DPrint('Pose already added')
                    end

                    local ToSave = {}
                    for k, v in pairs(_GLL.SavedPoses) do
                        if not k:find('| Shared') then
                            ToSave[k:gsub(' | Local$', '')] = v
                        end
                    end
                    Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(ToSave))
                else
                    return DPrint('Pose already added')
                end

            end
        })



    E.btnLoadPose = bz2:AddButton('Load pose')
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


    E.inputCatName = bz2:AddInputText('')



    E.btnAddCat = bz2:AddButton('Add category')
        UI:Config(E.btnAddCat, {
            SameLine = true,
            OnClick = function(e)
                if E.inputCatName.Text == '' then return end
                local catName = E.inputCatName.Text .. ' | Local'
                CreateCategoryTree(catName)
                E.comboCats.SelectedIndex = (table.find(SaveCategories, catName) or 1) - 1
                E.inputCatName.Text = ''

                _GLL.SavedPoses[catName] = _GLL.SavedPoses[catName] or {}

                local ToSave = {}
                for k, v in pairs(_GLL.SavedPoses) do
                    if not k:find('| Shared') then
                        ToSave[k:gsub(' | Local$', '')] = v
                    end
                end
                Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(ToSave))
            end
        })



    -- E.checkPoseUpd = bz2:AddCheckbox('Blender to Bone Zone')
    --     UI:Config(E.checkPoseUpd, {
    --         OnChange = function(e)
    --             local ticks = 0
    --             local uuid = getSelectedDummyOwnerUuid()

    --             if e.Checked then
    --                 DPrint('Fetching started')
    --                 Utils:SubUnsubToTick(1, 'POSEFILEFETCH', function()
    --                     ticks = ticks + 1
    --                     if ticks % E.slFetchInterval.Value[1] == 1 then
    --                         DPrint('Fetched')
    --                         -- local poseName = E.inputPoseName.Text
    --                         local poseName = 'BBZ'
    --                         -- ResetAllBones()
    --                         local File = Ext.IO.LoadFile('LightyLights/Poses/Blender/' .. poseName .. '.json')
    --                         if File then
    --                             local SavedPose = Ext.Json.Parse(File)
    --                             _GLL.PoseValues[uuid] = SavedPose
    --                             SetValuesToVars()
    --                         else
    --                             DPrint('No file')
    --                         end
    --                     end
    --                 end)
    --             else
    --                 SetVarValuesToSliders()
    --                 DPrint('Fetching stopped')
    --                 Utils:SubUnsubToTick(0, 'POSEFILEFETCH', _)
    --             end
    --         end
    --     })

    -- E.slFetchInterval = bz2:AddSliderInt('Update interval', 10, 2, 100, 1)

    E.savedPoseParent = bz2:AddChildWindow('Saved poses')
    E.savedPoseParent.Size = {-1, 500}



    function CreateCategoriesAndButtons()
        local CategoryOrder = {}

        for catName, Poses in pairs(_GLL.SavedPoses) do
            table.insert(CategoryOrder, catName)
        end
        table.sort(CategoryOrder)

        for _, catName in pairs(CategoryOrder) do
            CreateCategoryTree(catName)
            for _, poseName in pairs(_GLL.SavedPoses[catName]) do
                CreatePoseButton(catName, poseName)
            end
        end
    end
    CreateCategoriesAndButtons()



    -- Test = {
    --     Categories = {'PETR', 'DANI', 'MooN'},
    --     Poses = {
    --         PETR = {'xd', 'XDDD'},
    --         DANI = {'RAR', 'CATHUG'},
    --         MooN = {'Kiss', ':xd:'}
    --     }
    -- }
end
