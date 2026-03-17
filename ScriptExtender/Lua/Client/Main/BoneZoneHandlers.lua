local xd



function getDummyOwnerUuid(entity)
    if entity then
        local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
        if characterUuid then
            return characterUuid
        end
    end
end



function getSelectedDummy()
    if not _GLL.DummyNameMap then return end
    local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
    return entity
end



function getSelectedDummyOwnerUuid()
    local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
    if entity then
        local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
        if characterUuid then
            return characterUuid
        end
    end
end



local function stripToBoneName(varName)
    return varName:match('^(.+)_[^_]+$')
end



local TailVisualResources = {
    ['63ac4e80-72f2-55bb-1fe7-eb8c7a7e020b'] = 'd31d958e-306a-c81c-50d2-5fd86749b48e', -- TIF_F_Tail_Base
    ['ffc0935c-375d-6f84-c13b-d545205f0301'] = '4c0140a2-6e9d-2aea-34a0-b4280e78b7d2', -- TIF_M_Tail_Base
    ['6906e3cc-7b8d-a860-dccf-9ad5c87f0e13'] = '0922a138-5ea8-1273-334f-80013492e0d3', -- TIF_FS_Tail_Base
    ['e79ec35d-aec2-59f7-3ad3-81fd9c2ccfae'] = '04f9b403-e37e-7fc4-973f-967e603989ff', -- TIF_MS_Tail_Base
    ['6c6547c2-ea33-c498-20e9-1e5447e2ab9a'] = '0922a138-5ea8-1273-334f-80013492e0d3', -- DGB_F_Tail_Base
    ['7b35abc8-bf7b-6810-e2a0-28091ecac7d1'] = '04f9b403-e37e-7fc4-973f-967e603989ff', -- DGB_M_Tail_Base
    ['a91e0478-7d63-8f19-1506-9f5d6e9ef5da'] = 'd31d958e-306a-c81c-50d2-5fd86749b48e', -- CAMBION_F_Tail_Base
    ['370eee4b-3ea4-dd11-51d6-a5d9f6d26154'] = '04f9b403-e37e-7fc4-973f-967e603989ff', -- CAMBION_M_Tail_Base
}



function DisableTailPhysics()
    for resource, tailSpring in pairs(TailVisualResources) do
        Ext.Resource.Get(resource, 'Skeleton').SpringResourceID = ''
    end
end



function EnableTailPhysics()
    for resource, tailSpring in pairs(TailVisualResources) do
        Ext.Resource.Get(resource, 'Skeleton').SpringResourceID = tailSpring
    end
end



function LoadPoseList()
    if Ext.IO.LoadFile('LightyLights/Poses/_POSE_LIST.json') then
        _GLL.SavedPoses = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Poses/_POSE_LIST.json'))
    end
end
LoadPoseList()



local IndexNameMap = {}
local HasIndexNameMap = {}
function GetGenomeVariablesIndicies(entity)
    if not HasIndexNameMap[entity] then
        local VarsResource = entity.AnimationBlueprint.Resource.Blueprints[1].Variables
        IndexNameMap[entity] = {}

        for index, var in ipairs(VarsResource) do
            IndexNameMap[entity][tostring(index)] = var.Name
        end

        HasIndexNameMap[entity] = true
    end
    return IndexNameMap[entity]
end



function SetValueToGenomeVariable(entity, varName, value)
    local VarsInstance = entity.AnimationBlueprint.Instance.Variables
    for index, name in pairs(IndexNameMap[entity]) do
        if VarsInstance[index] and name == varName then
            local varType = VarsInstance[index].Type -- TBD: CHECK IK FEET BUG

            VarsInstance[index] = {Type = varType, Value = value}
            return VarsInstance[index]
        end
    end
end



function GetValueFromGenomeVariable(entity, varName)
    if varName then
        local VarsInstance = entity.AnimationBlueprint.Instance.Variables
        for index, name in pairs(IndexNameMap[entity]) do
            if name == varName then
                return VarsInstance[index]
            end
        end
    end
end



_GLL.PoseValues = {}

function SetValueToVarAndTableIt(varName, value)
    local X = 1
    local Y = 1
    local newValue
    local characterUuid = getSelectedDummyOwnerUuid()
    local entity = getSelectedDummy()
    Utils:EnsureTable(_GLL.PoseValues, characterUuid, varName)


    if varName:find('_Trans') or varName:find('_Scale') then
        newValue = {value[1]/X,value[2]/X,value[3]/X}
    else
        local Quats = Math.EulerToQuats({value[1]/X,value[2]/X,value[3]/X})
        _GLL.PoseValues[characterUuid][varName]['Quats'] = Quats
        newValue = Quats
    end

    _GLL.PoseValues[characterUuid][varName]['HumanValue'] = value
    SetValueToGenomeVariable(entity, varName, newValue)

    _GLL.States.bzLastModifiedVar = varName
end



function SetVarValuesToSliders()
    local characterUuid = getSelectedDummyOwnerUuid()
    if not _GLL.PoseValues[characterUuid] then return end

    local function restoreGroup(slTable, postfix, defaultValue)
        for boneGroupName, BoneCategories in pairs(AllBones) do
            for boneCategory, Bones in pairs(BoneCategories) do
                for _, boneName in pairs(Bones) do
                    local varName = boneName .. postfix
                    local poseData = _GLL.PoseValues[characterUuid][varName]
                    for i = 1, 3 do
                        local sl = slTable[varName .. '_' .. i]
                        if sl then
                            if poseData and poseData.HumanValue then
                                sl.Value = {poseData.HumanValue[i], 0, 0, 0}
                            else
                                sl.Value = {defaultValue, 0, 0, 0}
                            end
                        end
                    end
                end
            end
        end
    end

    restoreGroup(E.slBZ, '_Trans', 0)
    restoreGroup(E.slBZ, '_Rot',   0)
    restoreGroup(E.slBZ, '_Scale', 1)
end



function ResetSliderValue()
    local function resetGroup(slTable, postfix, defaultValue)
        for boneGroupName, BoneCategories in pairs(AllBones) do
            for boneCategory, Bones in pairs(BoneCategories) do
                for _, boneName in pairs(Bones) do
                    for i = 1, 3 do
                        local sl = slTable[boneName .. postfix .. '_' .. i]
                        if sl then
                            sl.Value = {defaultValue, 0, 0, 0}
                        end
                    end
                end
            end
        end
    end

    resetGroup(E.slBZ, '_Trans', 0)
    resetGroup(E.slBZ, '_Rot',   0)
    resetGroup(E.slBZ, '_Scale', 1)
end



function SetValuesToVars(entity)
    local entity = entity or getSelectedDummy()
    local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid or getSelectedDummyOwnerUuid()

    if _GLL.PoseValues[characterUuid] then
        for varName, value in pairs(_GLL.PoseValues[characterUuid]) do
            if varName and value then
                if varName:find('_Scale') or varName:find('_Trans') then
                    newValue = {value.HumanValue[1], value.HumanValue[2], value.HumanValue[3]}
                else
                    newValue = value.Quats
                end

                SetValueToGenomeVariable(entity, varName, newValue)
            end
        end
    end
end



function PopulateWithDefaultValues(characterUuid, varName)
    if _GLL.PoseValues[characterUuid][varName] then return end

    Utils:EnsureTable(_GLL.PoseValues, characterUuid, varName)
    if not _GLL.PoseValues[characterUuid][varName]['HumanValue'] then
        if varName:find('_Scale') then
            _GLL.PoseValues[characterUuid][varName]['HumanValue'] = {1, 1, 1}
        else
            _GLL.PoseValues[characterUuid][varName]['HumanValue'] = {0, 0, 0}
        end
    end
end



local Postfixes = {'_Trans', '_Rot', '_Scale'}

function ResetAllBones()
    local uuid = getSelectedDummyOwnerUuid()
    if uuid then
        for _, postfix in pairs(Postfixes) do
            for boneGroupName, BoneCategories in pairs(AllBones) do
                for boneCategory, Bones in pairs(BoneCategories) do
                    for _, boneName in pairs(Bones) do
                        BZCaptureOldValue(uuid, boneName .. postfix)
                    end
                end
            end
        end
    end

    local value
    for _, postfix in pairs(Postfixes) do
        for boneGroupName, BoneCategories in pairs(AllBones) do
            for boneCategory, Bones in pairs(BoneCategories) do
                for _, boneName in pairs(Bones) do
                    local varName = boneName .. postfix
                    value = varName:find('_Scale') and {1,1,1,0} or {0,0,0,0}
                    SetValueToVarAndTableIt(varName, value)
                end
            end
        end
    end
    SetVarValuesToSliders()
    if uuid then BZHistorySnapshotIK() end
end



function ResetBonesForCategory(boneGroupName, boneCategory)
    if not _GLL.States.inPhotoMode then return end
    local uuid = getSelectedDummyOwnerUuid()
    local BoneCategories = AllBones[boneGroupName]
    local Bones = BoneCategories[boneCategory]

    if uuid then
        for _, postfix in pairs(Postfixes) do
            for _, boneName in pairs(Bones) do
                BZCaptureOldValue(uuid, boneName .. postfix)
            end
        end
    end

    for _, postfix in pairs(Postfixes) do
        for _, boneName in pairs(Bones) do
            local varName = boneName .. postfix
            local value = varName:find('_Scale') and {1,1,1,0} or {0,0,0,0}
            SetValueToVarAndTableIt(varName, value)
        end
    end
    SetVarValuesToSliders()
    if uuid then BZHistorySnapshotIK() end
end



function ResetBonesForGroup(boneGroupName)
    if not _GLL.States.inPhotoMode then return end
    local uuid = getSelectedDummyOwnerUuid()
    local BoneCategories = AllBones[boneGroupName]

    if uuid then
        for _, postfix in pairs(Postfixes) do
            for boneCategory, Bones in pairs(BoneCategories) do
                for _, boneName in pairs(Bones) do
                    BZCaptureOldValue(uuid, boneName .. postfix)
                end
            end
        end
    end

    for _, postfix in pairs(Postfixes) do
        for boneCategory, Bones in pairs(BoneCategories) do
            for _, boneName in pairs(Bones) do
                local varName = boneName .. postfix
                local value = varName:find('_Scale') and {1,1,1,0} or {0,0,0,0}
                SetValueToVarAndTableIt(varName, value)
            end
        end
    end
    SetVarValuesToSliders()
    if uuid then BZHistorySnapshotIK() end
end



function TableBoneValues(entity)
    local entity = entity or getSelectedDummy()
    local characterUuid = getDummyOwnerUuid(entity)
    local varName

    for _, postfix in pairs(Postfixes) do
        for boneGroupName, BoneCategories in pairs(AllBones) do
            for boneCategory, Bones in pairs(BoneCategories) do
                for _, boneName in pairs(Bones) do
                    varName = boneName .. postfix
                    local value = GetValueFromGenomeVariable(entity, varName)
                    if value then
                        Utils:EnsureTable(_GLL.PoseValues, characterUuid, varName)

                        if value.Type == 'Rotator3' then
                            local HumanValue = Helpers.Math.QuatToEuler(value.Value)
                            _GLL.PoseValues[characterUuid][varName]['Quats'] = value.Value
                            _GLL.PoseValues[characterUuid][varName]['HumanValue'] = HumanValue
                        else
                            _GLL.PoseValues[characterUuid][varName]['HumanValue'] = value.Value
                        end
                    end
                end
            end
        end
    end
    return _GLL.PoseValues
end



MAX_TRANS = 1
MIN_TRANS = -MAX_TRANS

MAX_ROT = 180
MIN_ROT = -MAX_ROT

MAX_SCALE = 5
MIN_SCALE = 0


PRECISE_ROT = 0.1
PRECOSE_TRANS_SCALE = 0.001



function createStepButtons(parent, slider, fn)
    local btnMinus = parent:AddButton('<')
        UI:Config(btnMinus, {
            SameLine = true,
            OnClick = function()
                if not _GLL.States.inPhotoMode then return end
                fn(-1)
            end
        })

    local btnPlus = parent:AddButton('>')
        UI:Config(btnPlus, {
            SameLine = true,
            OnClick = function()
                if not _GLL.States.inPhotoMode then return end
                fn(1)
            end
        })
end



function createResetButton(parent, slider, fn)
    local btnReset = parent:AddButton('r')
        UI:Config(btnReset, {
            SameLine = true,
            OnClick = function()
                if not _GLL.States.inPhotoMode then return end
                fn()
            end
        })
end



local function getLipSymmetry(varName)
    local name, number, transformType = varName:match('([^_]+)_(%d+)_(.+)')
    number = tonumber(number)

    local newNumber = 12 - number
    local zeroedNumber = string.format('%02d', newNumber)

    return name .. '_' .. zeroedNumber .. '_' .. transformType
end



local function getBoneSide(boneName)
    if boneName:match('_L$') or boneName:match('_[Ll]$') or boneName:match('^.*_[Ll]_') or boneName:match('[_%-]l[_%-]') then
        return 'L'
    elseif boneName:match('_R$') or boneName:match('_[Rr]$') or boneName:match('^.*_[Rr]_') or boneName:match('[_%-]r[_%-]') then
        return 'R'
    end
    return nil
end



function getSymmetryVarName(varName)

    if varName:find('lip') then
        varName = getLipSymmetry(varName)
        return varName
    else
    ---slop
        local mirror = {R='L', L='R', r='l', l='r'}
        local varName, n = varName:gsub('_([RLrl])$', function(s) return '_'..mirror[s] end)

        if n == 0 then
            varName = (varName:gsub('_([RLrl])_', function(s) return '_'..mirror[s]..'_' end, 1))
        end

        return varName
    end
end



local Facial = {}

local function facialTable()
    for boneGroup, Bones in pairs(FacialBones) do
        for _, boneName in pairs(Bones) do
            table.insert(Facial, boneName)
        end
    end
end
facialTable()



function SetSymmetry(characterUuid, varName, axisIndex, value)
    local mirrorVar = getSymmetryVarName(varName)
    if mirrorVar == varName then return end
    PopulateWithDefaultValues(characterUuid, mirrorVar)

    ---I WANT TO CRY
    local invert
    local isPiercing  = mirrorVar:find('piercing') and true or false
    local isFacial    = table.find(Facial, stripToBoneName(varName)) and true or false
    local isCheek     = mirrorVar:find('cheek') and true or false
    local isSmile     = mirrorVar:find('smile') and true or false
    local isChin      = mirrorVar:find('chin') and true or false
    local isBrow      = mirrorVar:find('brow') and true or false
    local isLip       = mirrorVar:find('lip') and true or false
    local isEye       = (mirrorVar:find('eye_l') or mirrorVar:find('eye_r') and not (mirrorVar:find('lid') or mirrorVar:find('corner'))) and true or false
    local isLid       = (mirrorVar:find('lid') or mirrorVar:find('corner')) and true or false
    local isTongue    = mirrorVar:find('tongue') and true or false

    local isRot = mirrorVar:find('_Rot')

    if axisIndex == 1 then
        invert = isFacial and not (isEye or isBrow or isCheek or isChin or isPiercing or isLip or isTongue)
    elseif axisIndex == 2 then
        invert = isFacial and not isEye
    else --- axisIndex == 3
        invert = isFacial and not (isEye or isLid or isSmile)
    end

    if not isRot then invert = not invert end

    if invert then value = -value end

    -- DPrint('isFacial: %s, isEye: %s, invert: %s', isFacial, isEye, invert)

    _GLL.PoseValues[characterUuid][mirrorVar]['HumanValue'][axisIndex] = value
    SetValueToVarAndTableIt(mirrorVar, _GLL.PoseValues[characterUuid][mirrorVar]['HumanValue'])


    E.slBZ[mirrorVar .. '_' .. axisIndex].Value = {value, 0,0,0}
end



local SliderConfigs = {
    X  = {label = 'Up/Down',    type = 'Translate', postfix = '_Trans', index = 1, min = MIN_TRANS, max = MAX_TRANS, default = 0},
    Y  = {label = 'Forw/Backw', type = 'Translate', postfix = '_Trans', index = 2, min = MIN_TRANS, max = MAX_TRANS, default = 0},
    Z  = {label = 'Left/Right', type = 'Translate', postfix = '_Trans', index = 3, min = MIN_TRANS, max = MAX_TRANS, default = 0},

    RX = {label = 'Yaw',   type = 'Rotation',  postfix = '_Rot',   index = 1, min = MIN_ROT,   max = MAX_ROT,   default = 0},
    RY = {label = 'Roll',  type = 'Rotation',  postfix = '_Rot',   index = 2, min = MIN_ROT,   max = MAX_ROT,   default = 0},
    RZ = {label = 'Pitch', type = 'Rotation',  postfix = '_Rot',   index = 3, min = MIN_ROT,   max = MAX_ROT,   default = 0},

    SX = {label = 'Width',  type = 'Scale',     postfix = '_Scale', index = 1, min = MIN_SCALE, max = MAX_SCALE, default = 1},
    SY = {label = 'Length', type = 'Scale',     postfix = '_Scale', index = 2, min = MIN_SCALE, max = MAX_SCALE, default = 1},
    SZ = {label = 'Height', type = 'Scale',     postfix = '_Scale', index = 3, min = MIN_SCALE, max = MAX_SCALE, default = 1},
}



function createBoneSlider(parent, boneName, axis)
    local Config = SliderConfigs[axis]
    local slider = parent:AddDrag('', Config.default, Config.min, Config.max)
    local varName = boneName .. Config.postfix

    E.slBZ[boneName .. Config.postfix .. '_' .. Config.index] = slider
        UI:Config(slider, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then slider.Value = {0,0,0,0} return end

                local characterUuid = getSelectedDummyOwnerUuid()
                PopulateWithDefaultValues(characterUuid, varName)

                -- Capture old value before mutation (only on first OnChange of this drag)
                BZCaptureOldValue(characterUuid, varName)

                _GLL.PoseValues[characterUuid][varName]['HumanValue'][Config.index] = e.Value[1]
                SetValueToVarAndTableIt(varName, _GLL.PoseValues[characterUuid][varName]['HumanValue'])

                if _GLL.States.bzSymmetry then
                    SetSymmetry(characterUuid, varName, Config.index, e.Value[1])
                end

                Utils:AntiSpam(400, function()
                    DPrint('BONE SNAPSHOTTED')
                    BZHistorySnapshot(characterUuid, varName)
                end)
            end
        })

    return slider, varName, axis, Config.index
end



local AxesNames = {
    Translate = {'X','Y','Z'},
    Rotation  = {'RX','RY','RZ'},
    Scale     = {'SX','SY','SZ'},
}



function CreateControls2(boneGroupName, boneCategory, boneName)
    local catKey = boneGroupName .. '_' .. boneCategory


    if not E.collapseGroup[boneGroupName] then
        E.collapseGroup[boneGroupName] = bns:AddCollapsingHeader(boneGroupName)
    end

    if not E.treeCategory[catKey] then
        E.treeCategory[catKey] = E.collapseGroup[boneGroupName]:AddTree(boneCategory)
    end

    E.collapseBone[boneName] = E.treeCategory[catKey]:AddCollapsingHeader(boneName)

    for transformType, Axes in pairs(AxesNames) do
        local tree = E.collapseBone[boneName]:AddTree(transformType)
        if transformType == 'Rotation' or (transformType == 'Translate' and boneName:find('lip')) then tree.DefaultOpen = true end
        tree.IDContext = Ext.Math.Random(1,10000000)

        for _, axis in ipairs(Axes) do
            local slider, varName, axisName, axisIndex = createBoneSlider(tree, boneName, axis)
            local step = varName:find('_Rot') and PRECISE_ROT or PRECOSE_TRANS_SCALE
            local defaultValue = varName:find('_Scale') and 1 or 0

            -- createStepButtons(tree, slider, function(direction)
            --     local characterUuid = getSelectedDummyOwnerUuid()
            --     local Value = _GLL.PoseValues[characterUuid][varName]['HumanValue']

            --     Value[axisIndex] = Value[axisIndex] + step * direction
            --     slider.Value = {Value[axisIndex], 0, 0, 0}


            --     SetValueToVarAndTableIt(varName, {Value[1], Value[2], Value[3]})

            --     if _GLL.States.bzSymmetry then
            --         SetSymmetry(characterUuid, varName, axisIndex, Value[axisIndex])
            --     end
            -- end)

            createResetButton(tree, slider, function()
                local characterUuid = getSelectedDummyOwnerUuid()
                local Value = _GLL.PoseValues[characterUuid][varName]['HumanValue']

                BZCaptureOldValue(characterUuid, varName)

                Value[axisIndex] = defaultValue
                slider.Value = {defaultValue, 0, 0, 0}

                SetValueToVarAndTableIt(varName, {Value[1], Value[2], Value[3]})

                if _GLL.States.bzSymmetry then
                    SetSymmetry(characterUuid, varName, axisIndex, defaultValue)
                end

                BZHistorySnapshot(characterUuid, varName)
            end)

            tree:AddText(SliderConfigs[axis].label).SameLine = true
        end
    end
end



function ApplySplitColor(boneName, color, colorHovered)
    BoneState[boneName] = 0

    local xd = E.collapseBone[boneName]
    xd:SetColor('Header',        color)
    xd:SetColor('HeaderHovered', colorHovered)

    xd.OnRightClick = function(e)
        BoneState[boneName] = (BoneState[boneName] + 1) % 2
        if BoneState[boneName] == 0 then
            xd:SetColor('Header',        color)
            xd:SetColor('HeaderHovered', colorHovered)
        elseif BoneState[boneName] == 1 then
            xd:SetColor('Header',        Style.Colors.header)
            xd:SetColor('HeaderHovered', Style.Colors.headerHovered)
        end
    end
end



local function SplitColor(Bones)
    for _, boneName in ipairs(Bones) do
        local color
        local colorHovered
        local side = getBoneSide(boneName)

        if side == 'L' then
            color        = Vector.__mul(Style.Colors.special, {0.5, 0.5, 0.7, 1})
            colorHovered = Vector.__mul(Style.Colors.special, {0.6, 0.6, 0.8, 1})
        elseif side == 'R' then
            color        = Vector.__mul(Style.Colors.special, {0.7, 0.5, 0.4, 1})
            colorHovered = Vector.__mul(Style.Colors.special, {0.8, 0.6, 0.5, 1})
        else
            color        = Vector.__mul(Style.Colors.special, {0.5, 0.6, 0.5, 1})
            colorHovered = Vector.__mul(Style.Colors.special, {0.6, 0.7, 0.6, 1})
        end

        ApplySplitColor(boneName, color, colorHovered)
    end
end



local function GradientColor(Bones)
    local boneCnt = #Bones

    for k, boneName in ipairs(Bones) do
        local color, colorHovered = ActiveGradient(k, boneCnt)
        ApplySplitColor(boneName, color, colorHovered)
    end
end



local function GradientSplitColor(Bones)
    local LeftBones, RightBones, CenterBones = {}, {}, {}

    for _, boneName in ipairs(Bones) do
        local side = getBoneSide(boneName)
        if     side == 'L' then table.insert(LeftBones,   boneName)
        elseif side == 'R' then table.insert(RightBones,  boneName)
        else                    table.insert(CenterBones, boneName)
        end
    end

    for k, boneName in ipairs(LeftBones) do
        local color, colorHovered = ActiveGradient(k, #LeftBones)
        ApplySplitColor(boneName,
            Vector.__mul(color,        {0.8, 0.7, 1.0, 1}),
            Vector.__mul(colorHovered, {0.8, 0.7, 1.0, 1})
        )
    end

    for k, boneName in ipairs(RightBones) do
        local color, colorHovered = ActiveGradient(k, #RightBones)
        ApplySplitColor(boneName,
            Vector.__mul(color,        {1.0, 0.9, 0.9, 1}),
            Vector.__mul(colorHovered, {1.0, 0.9, 0.9, 1})
        )
    end

    for k, boneName in ipairs(CenterBones) do
        local color, colorHovered = ActiveGradient(k, #CenterBones)
        ApplySplitColor(boneName,
            Vector.__mul(color,        {0.7, 0.7, 0.7, 1}),
            Vector.__mul(colorHovered, {0.7, 0.7, 0.7, 1})
        )
    end
end



function ResetBoneZoneColors()
    Imgui.ClearChildren(E.boneZone)

    ---TBD: Should have put all elements to a sub table smhing my head
    E.btnPose          = nil
    E.btnX2            = nil
    E.btnUpd           = nil
    E.slBZ             = nil
    E.collapseGroup    = nil
    E.treeCategory     = nil
    E.collapseBone     = nil

    E.treeTrans        = nil
    E.treeRot          = nil
    E.treeScale        = nil

    E.btnX             = nil
    E.catTree          = nil

    Helpers.Timer:OnTicks(10, function ()
        BoneZoneTab(E.boneZone)
    end)

    Helpers.Timer:OnTicks(20, function()
        ActiveGradient = Style.Gradients[E.comboGradients.SelectedIndex + 1]
    end)
end



function CreateContolsForEachBoneGroupAndColorize()
    BoneState = {}
    BoneTreeColors = {}

    for _, boneGroupName in ipairs(GroupOrder) do
        local BoneCategories = AllBones[boneGroupName]

        if BoneCategories then
            for _, boneCategory in ipairs(CategoryOrder) do
                local Bones = BoneCategories[boneCategory]

                if Bones then
                    for _, boneName in ipairs(Bones) do
                        CreateControls2(boneGroupName, boneCategory, boneName)
                    end

                    -- GradientColor(Bones)
                    -- SplitColor(Bones)
                    GradientSplitColor(Bones)
                end

                local catKey = boneGroupName .. '_' .. boneCategory
                if E.treeCategory[catKey] then
                    E.treeCategory[catKey]:AddSeparator()

                    local catResetId
                    local catResetBtn = E.treeCategory[catKey]:AddButton('Reset ' .. boneCategory)
                    catResetId = UI:CreateConfirmButton(
                        E.treeCategory[catKey],
                        catResetBtn,
                        'Reset ' .. boneCategory,
                        function()
                            ResetBonesForCategory(boneGroupName, boneCategory)
                        end
                    )
                    UI:Config(catResetBtn, {
                        OnClick = function()
                            UI:Confirm(catResetBtn, catResetId, 1000)
                        end
                    })
                end
            end
        end

        if E.collapseGroup[boneGroupName] then
            E.collapseGroup[boneGroupName]:AddSeparator()

            local grpResetId
            local grpResetBtn = E.collapseGroup[boneGroupName]:AddButton('Reset ' .. boneGroupName)
            grpResetId = UI:CreateConfirmButton(
                E.collapseGroup[boneGroupName],
                grpResetBtn,
                'Reset ' .. boneGroupName,
                function()
                    ResetBonesForGroup(boneGroupName)
                end
            )
            UI:Config(grpResetBtn, {
                OnClick = function()
                    UI:Confirm(grpResetBtn, grpResetId, 1000)
                end
            })
        end
    end
end



function AddPoseToList(catName, poseName)
    for savedCatName, SavedPoseNames in pairs(_GLL.SavedPoses) do
        for _, savedPoseName in pairs(SavedPoseNames) do
            if poseName == savedPoseName then
                DPrint('Pose already added')
                return false
            end
        end
    end

    table.insert(_GLL.SavedPoses[catName], poseName)
    Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(_GLL.SavedPoses))
    return true
end



local function DeleteCategoryOrPose(typeThing, catName, poseName)
    if typeThing == 'Category' then
        _GLL.SavedPoses[catName] = nil
    else
        local index = table.find(_GLL.SavedPoses[catName], poseName)
        table.remove(_GLL.SavedPoses[catName], index)
    end
    Ext.IO.SaveFile('LightyLights/Poses/_POSE_LIST.json', Ext.Json.Stringify(_GLL.SavedPoses))
end



local SaveCategories = {}
local IDCat = {}
local IDPoses = {}

function CreateCategoryTree(catName)
    E.btnX = E.btnX or {}
    E.catTree = E.catTree or {}

    if E.catTree[catName] then return end

    E.btnX[catName] = E.savedPoseParent:AddButton('x')
    IDCat[catName] = UI:CreateConfirmButton(
        E.savedPoseParent,
        E.btnX[catName],
        'x',
        function()
            local index = table.find(SaveCategories, catName)
            table.remove(SaveCategories, index)
            E.comboCats.Options = SaveCategories

            if IDPoses[catName] then
                for poseName, _ in pairs(IDPoses[catName]) do
                    E.btnPose[poseName]:Destroy()
                    E.btnX2[poseName]:Destroy()
                    E.btnPose[poseName] = nil
                    E.btnX2[poseName] = nil
                end
                IDPoses[catName] = nil
            end

            DeleteCategoryOrPose('Category', catName)

            E.catTree[catName]:Destroy()
            E.btnX[catName]:Destroy()
            E.catTree[catName] = nil
            IDCat[catName] = nil
        end
    )

        UI:Config(E.btnX[catName], {
            OnClick = function(e)
                UI:Confirm(E.btnX[catName], IDCat[catName])
            end
        })

    E.catTree[catName] = E.savedPoseParent:AddTree(catName)
        UI:Config(E.catTree[catName], { SameLine = true })

    table.insert(SaveCategories, catName)
    E.comboCats.Options = SaveCategories
    return true
end



function CreatePoseButton(catName, poseName)
    if E.btnPose[poseName] then return false end
    if not E.catTree and not E.catTree[catName] then return fasle end

    E.btnX2[poseName] = E.catTree[catName]:AddButton('x')

    IDPoses[catName] = IDPoses[catName] or {}
    IDPoses[catName][poseName] = UI:CreateConfirmButton(
        E.catTree[catName],
        E.btnX2[poseName],
        'x',
        function()
            DeleteCategoryOrPose('Pose', catName, poseName)

            E.btnPose[poseName]:Destroy()
            E.btnX2[poseName]:Destroy()
            E.btnUpd[poseName]:Destroy()
            E.btnUpd[poseName]  = nil
            E.btnPose[poseName] = nil
            E.btnX2[poseName] = nil
            IDPoses[catName][poseName] = nil
        end
    )

        UI:Config(E.btnX2[poseName], {
            OnClick = function(e)
                UI:Confirm(E.btnX2[poseName], IDPoses[catName][poseName])
            end
        })

    E.btnUpd[poseName] = E.catTree[catName]:AddButton('o')
        UI:Config(E.btnUpd[poseName], {
            SameLine = true,
            OnClick = function(e)
                Ext.IO.SaveFile('LightyLights/Poses/' .. poseName .. '.json',
                    Ext.Json.Stringify(_GLL.PoseValues[getSelectedDummyOwnerUuid()]))
            end
        })


    E.btnPose[poseName] = E.catTree[catName]:AddButton(poseName)
        UI:Config(E.btnPose[poseName], {
            SameLine = true,
            Size = {-1, 39},
            OnClick = function(e)
                if not _GLL.States.inPhotoMode then return end

                ResetAllBones()

                local SavedPose = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Poses/' .. poseName .. '.json'))
                _GLL.PoseValues[getSelectedDummyOwnerUuid()] = SavedPose

                SetVarValuesToSliders()
                SetValuesToVars()
            end
        })
    return true
end



function FilterPoses(searchText)
    searchText = searchText:lower()

    for catName, _ in pairs(E.catTree) do
        local categoryMatch = catName:lower():find(searchText, 1, true) ~= nil
        local hasFilteredPose = false

        if IDPoses[catName] then
            for poseName, _ in pairs(IDPoses[catName]) do
                local poseMatch = poseName:lower():find(searchText, 1, true) ~= nil

                if E.btnPose[poseName] and E.btnX2[poseName] then
                    if searchText == '' or poseMatch then
                        E.btnPose[poseName].Visible = true
                        E.btnX2[poseName].Visible = true
                        hasFilteredPose = true
                    else
                        E.btnPose[poseName].Visible = false
                        E.btnX2[poseName].Visible = false
                    end
                end
            end
        end

        if E.catTree[catName] and type(E.catTree[catName]) == 'userdata' and E.btnX[catName] then
            if searchText == '' or hasFilteredPose then
                E.catTree[catName].Visible = true
                E.btnX[catName].Visible = true
            else
                E.catTree[catName].Visible = false
                E.btnX[catName].Visible = false
            end
        end
    end
end



IKChains = {
    {label = 'Arm R',            bones = {'Shoulder_R', 'Elbow_R'}},
    {label = 'Arm L',            bones = {'Shoulder_L', 'Elbow_L'}},
    {label = 'Leg R',            bones = {'Hip_R',      'Knee_R' }},
    {label = 'Leg L',            bones = {'Hip_L',      'Knee_L' }},

    {label = 'Thumb L',          bones = {'ThumbFinger1_L',  'ThumbFinger2_L',  'ThumbFinger3_L' }},
    {label = 'Thumb L Reduced',  bones = {'ThumbFinger1_L',  'ThumbFinger2_L'}},
    {label = 'Index L',          bones = {'IndexFinger1_L',  'IndexFinger2_L',  'IndexFinger3_L' }},
    {label = 'Middle L',         bones = {'MiddleFinger1_L', 'MiddleFinger2_L', 'MiddleFinger3_L'}},
    {label = 'Ring L',           bones = {'RingFinger1_L',   'RingFinger2_L',   'RingFinger3_L'  }},
    {label = 'Pinky L',          bones = {'PinkyFinger1_L',  'PinkyFinger2_L',  'PinkyFinger3_L' }},

    {label = 'Thumb R',          bones = {'ThumbFinger1_R',  'ThumbFinger2_R',  'ThumbFinger3_R' }},
    {label = 'Thumb R Reduced',  bones = {'ThumbFinger1_R',  'ThumbFinger2_R'}},
    {label = 'Index R',          bones = {'IndexFinger1_R',  'IndexFinger2_R',  'IndexFinger3_R' }},
    {label = 'Middle R',         bones = {'MiddleFinger1_R', 'MiddleFinger2_R', 'MiddleFinger3_R'}},
    {label = 'Ring R',           bones = {'RingFinger1_R',   'RingFinger2_R',   'RingFinger3_R'  }},
    {label = 'Pinky R',          bones = {'PinkyFinger1_R',  'PinkyFinger2_R',  'PinkyFinger3_R' }},

    {label = 'All Fingers L',    multiBones = {'Thumb L', 'Index L', 'Middle L', 'Ring L', 'Pinky L'}},
    {label = 'All Fingers R',    multiBones = {'Thumb R', 'Index R', 'Middle R', 'Ring R', 'Pinky R'}},
}



local function resolveMultiChains(multiBones)
    local result = {}
    for _, targetLabel in ipairs(multiBones) do
        for _, chain in ipairs(IKChains) do
            if chain.label == targetLabel then
                table.insert(result, chain.bones)
                break
            end
        end
    end
    return result
end



local IKFalloff = 0.4
local IKFalloffFingers = 1

function ApplyProportionalIK(chain, axisDelta, axisIndex)
    local n = #chain
    local characterUuid = getSelectedDummyOwnerUuid()

    for i = n, 1, -1 do
        local bone = chain[i]
        local falloff = bone:find('Finger') and IKFalloffFingers or IKFalloff

        local influence = falloff ^ (n - i) --- Thx Mr.Clanker, I'm still too uneducated Gladge
        local varName = bone .. '_Rot'

        Utils:EnsureTable(_GLL.PoseValues, characterUuid, varName)

        local CurrentValue = _GLL.PoseValues[characterUuid][varName]
        local Value = (CurrentValue and CurrentValue.HumanValue) and
                    {CurrentValue.HumanValue[1], CurrentValue.HumanValue[2], CurrentValue.HumanValue[3]} or {0, 0, 0}

        -- Capture old value before mutation
        BZCaptureOldValue(characterUuid, varName)

        Value[axisIndex] = Value[axisIndex] + axisDelta * influence
        SetValueToVarAndTableIt(varName, Value)

        if _GLL.States.bzSymmetry then
            SetSymmetry(characterUuid, varName, axisIndex, Value[axisIndex])
        end
    end
    SetVarValuesToSliders()
end



local function createIKSliders(parent, axisIndex, axisLabel, Value, fn)
    local slider = parent:AddSlider('', 0, MIN_ROT, MAX_ROT, 1)
    UI:Config(slider, {
        OnChange = function(e)
            if not _GLL.States.inPhotoMode then slider.Value = {0, 0, 0, 0} return end
            local newVal = e.Value[1]
            local delta  = newVal - Value[axisIndex]
            Value[axisIndex] = newVal
            fn(delta, axisIndex)

            Utils:AntiSpam(400, function()
                BZHistorySnapshotIK()
            end)
        end
    })
    createStepButtons(parent, slider, function(direction)
        Value[axisIndex] = Value[axisIndex] + PRECISE_ROT * direction
        slider.Value = {Value[axisIndex], 0, 0, 0}
        fn(direction + PRECISE_ROT, axisIndex)
    end)
    createResetButton(parent, slider, function()
        local delta = -Value[axisIndex]
        Value[axisIndex] = 0
        slider.Value = {0, 0, 0, 0}
        fn(delta, axisIndex)
    end)
    parent:AddText(axisLabel).SameLine = true
end



local function CreateIKSliders(parent, chain, axisIndex, axisLabel, Value)
    createIKSliders(parent, axisIndex, axisLabel, Value, function(delta, axis)
        ApplyProportionalIK(chain, delta, axis)
    end)
end



local function CreateIKSlidersMulti(parent, chains, axisIndex, axisLabel, Value)
    createIKSliders(parent, axisIndex, axisLabel, Value, function(delta, axis)
        for _, chain in ipairs(chains) do
            ApplyProportionalIK(chain, delta, axis)
        end
        -- local thumbValue = {Value[3] * 1, Value[2], Value[3]}
        -- SetValueToVarAndTableIt('ThumbFinger1_R_Rot', thumbValue)
    end)
end



function CreateIKControls(parent, IKChain)
    local label = parent:AddTree(IKChain.label)
    local Value = {0, 0, 0}

    if IKChain.multiBones then
        local chains = resolveMultiChains(IKChain.multiBones)
        CreateIKSlidersMulti(label, chains, 1, 'RX', Value)
        CreateIKSlidersMulti(label, chains, 2, 'RY', Value)
        CreateIKSlidersMulti(label, chains, 3, 'RZ', Value)
    else
        CreateIKSliders(label, IKChain.bones, 1, 'RX', Value)
        CreateIKSliders(label, IKChain.bones, 2, 'RY', Value)
        CreateIKSliders(label, IKChain.bones, 3, 'RZ', Value)
    end
end



_GLL.AttachedEntities = {}
_GLL.AttachState = {}


function AttachObjectToHand(hand, uuid, character)
    _GLL.AttachedEntities[character] = _GLL.AttachedEntities[character] or {}

    local s, err = pcall(function()
        _GLL.AttachedEntities[character][hand] = Ext.Entity.Get(uuid)
    end)

    if err then DPrint('No UUID or UUID is invalid') end

    if s then
        local eq = character.ClientEquipmentVisuals.Equipment
        if eq.MeleeMainHand and eq.MeleeMainHand.SubVisuals[1] then
            local DummyTransform
            if hand == 'Main' then
                DummyTransform = eq.MeleeMainHand.SubVisuals[1].Visual.Visual.WorldTransform
            elseif hand == 'Off' then
                DummyTransform = eq.MeleeOffHand.SubVisuals[1].Visual.Visual.WorldTransform
            end
            _GLL.AttachedEntities[character][hand].Visual.Visual:SetWorldTranslate(DummyTransform.Translate)
            _GLL.AttachedEntities[character][hand].Visual.Visual:SetWorldRotate(DummyTransform.RotationQuat)
        end
    end
end



function ScaleAttachment(hand, value)
        local character = getSelectedDummy()
        local entity = _GLL.AttachedEntities[character] and _GLL.AttachedEntities[character][hand]
        if entity and entity.Visual then
            entity.Visual.Visual:SetWorldScale({value, value, value})
        end
    end



function tickAttach(e, hand)
    local character = getSelectedDummy()
    local uuid = (hand == 'Main') and E.inputAttachItem.Text or E.inputAttachItemOff.Text
    local key  = 'LL_Attachies_' .. hand .. '_' .. tostring(character)

    if e.Checked then
        if not _GLL.States.inPhotoMode then e.Checked = false return end

        Utils:SubUnsubToTick(1, key, function()
            if _GLL.States.inPhotoMode then
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
    SaveAttachState(character)
end



function SaveAttachState(character)
    local uuid = getDummyOwnerUuid(character)
    _GLL.AttachState[uuid] = {
        mainChecked = E.checkAttachies.Checked,
        mainUuid    = E.inputAttachItem.Text,
        mainScale   = E.slAttachScale.Value[1],
        offChecked  = E.checkAttachiesOff.Checked,
        offUuid     = E.inputAttachItemOff.Text,
        offScale    = E.slAttachScaleOff.Value[1],
    }
end



function LoadAttachState(character)
    local uuid = getDummyOwnerUuid(character)
    local xd = _GLL.AttachState[uuid]

    if xd then
        E.checkAttachies.Checked     = xd.mainChecked
        E.inputAttachItem.Text       = xd.mainUuid
        E.slAttachScale.Value        = {xd.mainScale, 0, 0, 0}

        E.checkAttachiesOff.Checked  = xd.offChecked
        E.inputAttachItemOff.Text    = xd.offUuid
        E.slAttachScaleOff.Value     = {xd.offScale, 0, 0, 0}
    else
        E.checkAttachies.Checked     = false
        E.inputAttachItem.Text       = ''
        E.slAttachScale.Value        = {1, 0, 0, 0}

        E.checkAttachiesOff.Checked  = false
        E.inputAttachItemOff.Text    = ''
        E.slAttachScaleOff.Value     = {1, 0, 0, 0}
    end
end


--- 24fc6855-03e7-3b20-7a99-13d4d942ad26




--- I'm still to uneducated, for now I'll let it slop
local BZ_HISTORY_MAX = 100

_GLL.BZHistory      = _GLL.BZHistory      or {}
_GLL.BZHistoryIndex = _GLL.BZHistoryIndex or {}
_GLL.BZOldValues    = _GLL.BZOldValues    or {}



function BZCaptureOldValue(uuid, varName)
    _GLL.BZOldValues[uuid] = _GLL.BZOldValues[uuid] or {}
    if _GLL.BZOldValues[uuid][varName] then return end

    local cur = _GLL.PoseValues[uuid] and _GLL.PoseValues[uuid][varName]
    if cur and cur.HumanValue then
        _GLL.BZOldValues[uuid][varName] = {cur.HumanValue[1], cur.HumanValue[2], cur.HumanValue[3]}
    else
        local default = varName:find('_Scale') and {1,1,1} or {0,0,0}
        _GLL.BZOldValues[uuid][varName] = default
    end
end



function BZHistorySnapshot(uuid, varName)
    if not uuid or not varName then return end

    local oldValues = _GLL.BZOldValues[uuid]
    if not oldValues or not oldValues[varName] then return end

    local cur = _GLL.PoseValues[uuid] and _GLL.PoseValues[uuid][varName]
    if not cur or not cur.HumanValue then return end

    local old = oldValues[varName]
    local new = {cur.HumanValue[1], cur.HumanValue[2], cur.HumanValue[3]}

    if old[1] == new[1] and old[2] == new[2] and old[3] == new[3] then
        _GLL.BZOldValues[uuid][varName] = nil
        return
    end

    _GLL.BZHistory[uuid]      = _GLL.BZHistory[uuid]      or {}
    _GLL.BZHistoryIndex[uuid] = _GLL.BZHistoryIndex[uuid] or 0

    local history = _GLL.BZHistory[uuid]
    local index   = _GLL.BZHistoryIndex[uuid]

    while #history > index do
        table.remove(history)
    end

    if #history >= BZ_HISTORY_MAX then
        table.remove(history, 1)
        index = index - 1
    end

    table.insert(history, {varName = varName, old = old, new = new})
    _GLL.BZHistoryIndex[uuid] = #history

    _GLL.BZOldValues[uuid][varName] = nil
end




function BZHistorySnapshotIK()
    local uuid = getSelectedDummyOwnerUuid()
    if not uuid then return end

    local oldValues = _GLL.BZOldValues[uuid]
    if not oldValues then return end

    _GLL.BZHistory[uuid]      = _GLL.BZHistory[uuid]      or {}
    _GLL.BZHistoryIndex[uuid] = _GLL.BZHistoryIndex[uuid] or 0

    local history = _GLL.BZHistory[uuid]
    local index   = _GLL.BZHistoryIndex[uuid]

    local diffs = {}
    for varName, old in pairs(oldValues) do
        local cur = _GLL.PoseValues[uuid] and _GLL.PoseValues[uuid][varName]
        if cur and cur.HumanValue then
            local new = {cur.HumanValue[1], cur.HumanValue[2], cur.HumanValue[3]}
            if old[1] ~= new[1] or old[2] ~= new[2] or old[3] ~= new[3] then
                table.insert(diffs, {varName = varName, old = old, new = new})
            end
        end
    end

    if #diffs == 0 then return end

    while #history > index do table.remove(history) end
    if #history >= BZ_HISTORY_MAX then
        table.remove(history, 1)
        index = index - 1
    end

    table.insert(history, diffs)
    _GLL.BZHistoryIndex[uuid] = #history

    _GLL.BZOldValues[uuid] = {}
end



local function BZApplyDiff(uuid, entry, direction)
    local diffs = entry.varName and {entry} or entry

    for _, diff in ipairs(diffs) do
        local value = direction == 'undo' and diff.old or diff.new
        SetValueToVarAndTableIt(diff.varName, value)
    end

    SetVarValuesToSliders()
    SetValuesToVars()
end



function BZHistoryUndo()
    if not _GLL.States.inPhotoMode then return end
    if Utils.antiSpam then DPrint([[CAN'T DO, Wating for snapshot]]) return end

    local uuid = getSelectedDummyOwnerUuid()
    if not uuid then return end

    _GLL.BZHistory[uuid]      = _GLL.BZHistory[uuid]      or {}
    _GLL.BZHistoryIndex[uuid] = _GLL.BZHistoryIndex[uuid] or 0

    local index = _GLL.BZHistoryIndex[uuid]
    if index < 1 then DPrint('Nothing to undo') return end

    BZApplyDiff(uuid, _GLL.BZHistory[uuid][index], 'undo')
    _GLL.BZHistoryIndex[uuid] = index - 1
    DPrint('Undo (' .. _GLL.BZHistoryIndex[uuid] .. '/' .. #_GLL.BZHistory[uuid] .. ')')
end



function BZHistoryRedo()
    if not _GLL.States.inPhotoMode then return end
    if Utils.antiSpam then DPrint([[CAN'T DO, Wating for snapshot]]) return end

    local uuid = getSelectedDummyOwnerUuid()
    if not uuid then return end

    _GLL.BZHistory[uuid]      = _GLL.BZHistory[uuid]      or {}
    _GLL.BZHistoryIndex[uuid] = _GLL.BZHistoryIndex[uuid] or 0

    local history = _GLL.BZHistory[uuid]
    local index   = _GLL.BZHistoryIndex[uuid]

    if index >= #history then DPrint('Nothing to redo') return end

    _GLL.BZHistoryIndex[uuid] = index + 1
    BZApplyDiff(uuid, history[_GLL.BZHistoryIndex[uuid]], 'redo')
    DPrint('Redo (' .. _GLL.BZHistoryIndex[uuid] .. '/' .. #history .. ')')
end