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
    Globals.States.bonesUnlocked = false



    function UpdateBZDummyCombo(e)
        selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1
        SetVarValuesToSliders()
        E.visTemComob.SelectedIndex = e.SelectedIndex
    end



    E.cmbBoneDummies = bz:AddCombo('Dummies')
        UI:Config(E.cmbBoneDummies, {
            SelectedIndex = E.visTemComob.SelectedIndex or 0,
            Options = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine = false,
            OnChange = function(e)
                if not LLGlobals.States.inPhotoMode then return end
                UpdateBZDummyCombo(e)
            end
        })
    selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1



    -- E.btnMap = bz:AddButton('Dump Variables')
    --     UI:Config(E.btnMap, {
    --         OnClick = function()
    --             if not LLGlobals.States.inPhotoMode then return end
    --             local entity = getSelectedDummy()
    --             DDump(GetGenomeVariablesIndicies(entity))
    --         end
    --     })



    E.checkAutoTail = bz:AddCheckbox('Disable tail physics')


    bz:AddSeparatorText('Attachies')


    E.btnGetDaggers = bz:AddButton([[Get Daniela's daggers]])
        UI:Config(E.btnGetDaggers, {
            OnClick = function(e)
                Ch.GetDaggers:SendToServer({})
            end
        })



    --- Temporal garbo
    --- 2e8cc79e-ca32-e196-0bb1-a6084c1328bb



    local function scaleAttachment(hand, value)
        local character = getSelectedDummy()
        local entity = LLGlobals.AttachedEntities[character] and LLGlobals.AttachedEntities[character][hand]
        if entity and entity.Visual then
            entity.Visual.Visual:SetWorldScale({value, value, value})
        end
    end



    local function tickAttach(e, hand)
        local character = getSelectedDummy()
        local uuid = (hand == 'Main') and E.inputAttachItem.Text or E.inputAttachItemOff.Text
        local key  = 'LL_Attachies_' .. hand .. '_' .. tostring(character)

        if e.Checked then
            if not LLGlobals.States.inPhotoMode then e.Checked = false return end

            Utils:SubUnsubToTick(1, key, function()
                if LLGlobals.States.inPhotoMode then
                    AttachObjectToHand(hand, uuid, character)
                else
                    Utils:SubUnsubToTick(0, key, _)
                    if getSelectedDummy() == character then
                        e.Checked = false
                    end
                end
            end)
        else
            Utils:SubUnsubToTick(0, key, _)
        end
    end



    E.checkAttachies = bz:AddCheckbox('Attach item main')
        UI:Config(E.checkAttachies, {
            OnChange = function(e)
                if not LLGlobals.States.inPhotoMode then e.Checked = false return end
                tickAttach(e, 'Main')
            end
        })



    E.inputAttachItem = bz:AddInputText('Item UUID main')
    E.inputAttachItem.SameLine = false



    E.slAttachScale = bz:AddSlider('Scale main', 1, 0.1, 2, 1)
        UI:Config(E.slAttachScale, {
            OnChange = function(e)
                scaleAttachment('Main', e.Value[1])
            end
        })



    E.checkAttachiesOff = bz:AddCheckbox('Attach item off')
    UI:Config(E.checkAttachiesOff, {
        OnChange = function(e)
            if not LLGlobals.States.inPhotoMode then e.Checked = false return end
            tickAttach(e, 'Off')
        end
    })



    E.inputAttachItemOff = bz:AddInputText('Item UUID off')
    E.inputAttachItemOff.SameLine = false



    E.slAttachScaleOff = bz:AddSlider('Scale off', 1, 0.1, 2, 1)
        UI:Config(E.slAttachScaleOff, {
            OnChange = function(e)
                scaleAttachment('Main', e.Value[1])
            end
        })



    bz:AddSeparatorText('Garbo')



    E.btnTposeQSAT = bz:AddButton('TPose [QSAT SLOT 10]')
        UI:Config(E.btnTposeQSAT, {
            SameLine = true,
            OnClick = function(e)
                if not Mods.QSAT then return end

                for _, AnimationSet in pairs(Mods.QSAT.BaseBodyAnimationSets) do
                    Mods.QSAT.SkizzingSataning(
                        AnimationSet,
                        '88838fb7-4548-4471-a88c-f833f7aaedad',
                        '0dbb3f66-2e8e-20b6-1d08-6331dee65e7b',
                        ''
                    )
                end
            end
        })




    -- E.resetBtn = bz:AddButton('Reload SE')
    -- E.resetBtn.SameLine = true
    -- local btnResetSE = UI:CreateConfirmButton(p, E.resetBtn, 'Reload SE', function()
    --     Ext.Debug.Reset(false, true)
    -- end)
    -- E.resetBtn.OnClick = function ()
    --     UI:Confirm(E.resetBtn, btnResetSE)
    -- end



    bz:AddText([[    No one reads, so I'll type it here.
    Not fully releasing until Skiz finishes BG3AF.
    Unfortunately there's no way to make this better right now.
    Treat this as additional pose adjustment thing for now.
    But I kinda learned bone names, so I'm almost at blender pace ong fr.
    If you want to make a pose from scratch, I recommend starting from Tpose.]])

    bz:AddDummy(1,10)
    bz:AddText([[    You can change gradient color in the settings.]])


    E.btnResetBpnes = bz:AddButton('Reset all')
    local resetId = UI:CreateConfirmButton(bz, E.btnResetBpnes, 'Reset all', function()
        ResetAllBones()
    end)
        UI:Config(E.btnResetBpnes, {
            OnClick = function()
                if not LLGlobals.States.inPhotoMode then return end
                UI:Confirm(E.btnResetBpnes, resetId, 1000)
            end
        })




    LLGlobals.States.bzSymmetry = false

    E.checkSymm = bz:AddCheckbox('Symmetry|Alt+F')
        UI:Config(E.checkSymm, {
            SameLine = true,
            OnChange = function(e)
                LLGlobals.States.bzSymmetry = e.Checked
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
        return Vector.Mul(tbl, {-1, 0, 0, 0})
    end


    E.slLockedRootM = treeLRMRot:AddSlider('', 0, MAX_ROT, MIN_ROT, 1)
        UI:Config(E.slLockedRootM, {
            OnChange = function(e)
                SetValueToVarAndTableIt('Root_M_Rot', e.Value)
                SetValueToVarAndTableIt('Spine1_M_Rot', negativeTbl(e.Value))
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



    LLGlobals.SavedPoses = LLGlobals.SavedPoses or {}



    E.btnSavePose = bz:AddButton('Save pose')
        UI:Config(E.btnSavePose, {
            SameLine = true,
            OnClick = function(e)
                if not LLGlobals.States.inPhotoMode then return end

                local catName = UI:SelectedOpt(E.comboCats)
                local poseName = E.inputPoseName.Text
                if poseName == '' then return end
                local poseDoesntExist = CreatePoseButton(catName, poseName)

                if poseDoesntExist then
                    TableBoneValues()
                    Ext.IO.SaveFile('LightyLights/Poses/' .. poseName .. '.json',
                        Ext.Json.Stringify(Globals.PoseValues[getSelectedDummyOwnerUuid()]))

                    LLGlobals.SavedPoses[catName] = LLGlobals.SavedPoses[catName] or {}

                    if not table.find(LLGlobals.SavedPoses[catName], poseName) then
                        table.insert(LLGlobals.SavedPoses[catName], poseName)
                    else
                        return DPrint('Pose already added')
                    end

                    Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(LLGlobals.SavedPoses))
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

                LLGlobals.SavedPoses[catName] = LLGlobals.SavedPoses[catName] or {}

                Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(LLGlobals.SavedPoses))
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
                                Globals.PoseValues[uuid] = SavedPose

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
        for catName, Poses in pairs(LLGlobals.SavedPoses) do
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