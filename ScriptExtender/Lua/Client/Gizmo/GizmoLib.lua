gizmoLibError = false


if Mods.GizmoLib then
    Utils:StripPrefixes(Mods.LL2, Mods.GizmoLib)

    --- IDK WHY IT CAN'T KEEP UP WITH INITIALIZATIONS FOR SOME PEOPLE T_T
    --- HOPEFULLY THIS WILL HELP
    -- GL_GLOBALS = GL_GLOBALS or {}
    GL_GLOBALS = Mods.GizmoLib.GL_GLOBALS

    function initGizmoLibColors()
        if GL_GLOBALS and Mods.GizmoLib.GL_GLOBALS then
            local tb = GL_GLOBALS.TransformToolbar
            tb.TopToolBar:SetColor("WindowBg", Style.Colors.windowBg)
            tb.TopToolBar:SetColor("Text", Style.Colors.textColor)
            tb.TopToolBar:SetColor("FrameBg", Style.Colors.frameBg)
            tb.TopToolBar:SetColor("TextDisabled", Style.Colors.textDisabled)
            tb.TopToolBar:SetColor("Button", Style.Colors.button)

            local special = Style.Colors.special or Style.Colors.button
            tb.CloseButton:SetColor("Button", special)
            tb.CloseButton:SetColor("ButtonActive", Style.Colors.buttonActive)
            tb.CloseButton:SetColor("ButtonHovered", Style.Colors.buttonHovered)
            Mods.GizmoLib.MCM.Set("boxsel_border_color", special)
        end
    end



    _GLL.gizmo = API.CreateManipulator()
    -- _GLL.gizmo.Config.IsSelectableEntity = function(info)
    --     return info.Type == "Unknown"
    -- end


    _GLL.boneGizmo = API.CreateManipulator()

    local function isBone(Guid)
        for k, v in pairs(JointUuidBoneNameMap) do
            if k == Guid then return true end
        end
    end



    local JointTransform = {
        Translate = {},
        RotationQuat = {},
        Scale = {},
    }


    local StartTransform = {
        Translate = {},
        RotationQuat = {},
        Scale = {},
        WorldPos     = {},
        WorldRot     = {},
    }


    -- First value is axes' order, second one is reversed or nay
    -- Move:   Xr = 1, Zb = 2, Yg = 3
    -- Rotate: Xr = 1, Zb = 3, Yg = 2
    local BoneAxisMap = {
        Default = {
            Translate = { {3, -1}, {1, 1}, {2, -1} },
            Rotate    = { {3, -1}, {1, 1}, {2, -1} },
            Scale     = { {1,  1}, {2, 1}, {3,  1} },
        },



        Scapula_L = {
            Translate = { {1, -1}, {3,  1}, {2,  1} },
            Rotate    = { {1,  1}, {3,  1}, {2,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Scapula_R = {
            Translate = { {1, -1}, {3, -1}, {2, -1} },
            Rotate    = { {1,  1}, {3, -1}, {2, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },



        Shoulder_L = {
            Translate = { {1, -1}, {3,  1}, {2,  1} },
            Rotate    = { {1,  1}, {3,  1}, {2,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Shoulder_R = {
            Translate = { {1, -1}, {3, -1}, {2, -1} },
            Rotate    = { {1,  1}, {3, -1}, {2, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },



        Elbow_L = {
            Translate = { {1, -1}, {3,  1}, {2,  1} },
            Rotate    = { {1,  1}, {3,  1}, {2,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Elbow_R = {
            Translate = { {1, -1}, {3, -1}, {2, -1} },
            Rotate    = { {1,  1}, {3, -1}, {2, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },


        Dummy_L_Hand_IK = {
            Translate = { {3,  1}, {2,  1}, {1, -1} },
            Rotate    = { {3, -1}, {2,  1}, {1,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },


        Dummy_R_Hand_IK = {
            Translate = { {3, -1}, {2, -1}, {1,  1} },
            Rotate    = { {3, -1}, {2,  1}, {1,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },


        Ankle_L = {
            Translate = { {3, -1}, {2,  1}, {1,  1} },
            Rotate    = { {3, -1}, {2,  1}, {1,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Ankle_R = {
            Translate = { {3, -1}, {2, -1}, {1, -1} },
            Rotate    = { {3, -1}, {2, -1}, {1, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Toes_L = {
            Translate = { {3, -1}, {2,  1}, {1,  1} },
            Rotate    = { {3, -1}, {2,  1}, {1,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Toes_R = {
            Translate = { {3, -1}, {2, -1}, {1, -1} },
            Rotate    = { {3, -1}, {2, -1}, {1, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Dummy_L_Foot_IK = {
            Translate = { {3,  1}, {2,  1}, {1, -1} },
            Rotate    = { {3, -1}, {2,  1}, {1,  1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

        Dummy_R_Foot_IK = {
            Translate = { {3,  1}, {2,  1}, {1, -1} },
            Rotate    = { {3, -1}, {2, -1}, {1, -1} },
            Scale     = { {2,  1}, {3,  1}, {1,  1} },
        },

    }

    local function remapTranslate(boneName, Delta)
        local Map = (BoneAxisMap[boneName] or BoneAxisMap.Default).Translate
        return {
            Delta[Map[1][1]] * Map[1][2],
            Delta[Map[2][1]] * Map[2][2],
            Delta[Map[3][1]] * Map[3][2],
        }
    end

    local function remapRotate(boneName, Delta)
        local Map = (BoneAxisMap[boneName] or BoneAxisMap.Default).Rotate
        return {
            Delta[Map[1][1]] * Map[1][2],
            Delta[Map[2][1]] * Map[2][2],
            Delta[Map[3][1]] * Map[3][2],
            Delta[4],
        }
    end

    local function remapScale(boneName, Delta)
        local Map = (BoneAxisMap[boneName] or BoneAxisMap.Default).Scale
        return {
            Delta[Map[1][1]] * Map[1][2],
            Delta[Map[2][1]] * Map[2][2],
            Delta[Map[3][1]] * Map[3][2],
        }
    end


    function getLocalTransforms(WorldTransform)
        local WT = WorldTransform
        local OriginTransfroms = _C().Transform.Transform
        local OT = OriginTransfroms
        local LTranslate = Vector.__sub(WT.Translate, OT.Translate)
        return LTranslate
    end


    API.Events.OnTransformStart:Subscribe(function(Data)
        _GLL.gizmo:SetActive(true) --- TBD: Tell Mazzle to  expose Toolbar for OnCommandExecuted

        if isBone(Data.Targets[1].Guid) then
            local jointUuid = Data.Targets[1].Guid
            local boneName  = JointUuidBoneNameMap[jointUuid]
            UnderEditing[boneName] = true
            StartTransform.WorldPos[jointUuid] = table.deepCopy(Data.StartTransforms[jointUuid].Translate)
            StartTransform.WorldRot[jointUuid] = table.deepCopy(Data.StartTransforms[jointUuid].RotationQuat)
            local characterUuid = getSelectedDummyOwnerUuid()
            local varTrans = boneName .. '_Trans'
            local varRot   = boneName .. '_Rot'
            local poseTrans = _GLL.PoseValues[characterUuid] and _GLL.PoseValues[characterUuid][varTrans]
            local poseRot   = _GLL.PoseValues[characterUuid] and _GLL.PoseValues[characterUuid][varRot]
            StartTransform.Translate[varTrans] = poseTrans and table.deepCopy(poseTrans.HumanValue) or {0,0,0}
            StartTransform.RotationQuat[varRot] = poseRot and table.deepCopy(poseRot.Quats) or {0,0,0,1}
        end
    end)



    API.Events.OnTransformApplied:Subscribe(function(Data)
        if not Data or not Data.Targets or #Data.Targets == 0 then return end

        if isBone(Data.Targets[1].Guid) then
            local uuid = _C().Uuid.EntityUuid
            local jointUuid = Data.Targets[1].Guid
            local boneName  = JointUuidBoneNameMap[jointUuid]
            if not boneName then return end

            UnderEditing[boneName] = true

            local JointTransform = GetJointTransform(jointUuid)

            local characterUuid = getSelectedDummyOwnerUuid()
            local varName, value

            if Data.Mode == 'Move' then
                varName = boneName .. '_Trans'
                local BoneQ    = StartTransform.WorldRot[jointUuid]
                local InvBoneQ = {-BoneQ[1], -BoneQ[2], -BoneQ[3], BoneQ[4]}
                local LocalDelta = Ext.Math.QuatRotate(InvBoneQ, Data.Delta)
                local Remap = remapTranslate(boneName, LocalDelta)
                -- value = {
                --     StartTransform.Translate[varName][1] + LocalDelta[1],
                --     StartTransform.Translate[varName][2] + LocalDelta[2],
                --     StartTransform.Translate[varName][3] + LocalDelta[3],
                -- }

                value = Vector.__add(StartTransform.Translate[varName], Remap)

            elseif Data.Mode == 'Rotate' then
                varName = boneName .. '_Rot'

                for boneName2, jointUuid2 in pairs(JointCharacterBoneMap[uuid]) do
                    if boneName2 == boneName then
                        local Transform = GetJointTransform(jointUuid2)

                        local NewRot = Ext.Math.QuatRotateAxisAngle(
                            Transform.RotationQuat,
                            {1,0,0},
                            math.rad(90)
                        )

                        local axis = {NewRot[1], NewRot[2], NewRot[3]}

                        value = {
                            axis[2],
                            -axis[3],
                            -axis[1],
                            NewRot[4]
                        }

                    end
                end

            elseif Data.Mode == 'Scale' then
                varName = boneName .. '_Scale'
                local Remap = remapScale(boneName, Data.Delta)
                value = Vector.__add(StartTransform.Scale[varName], Remap)
                JointTransform.Scale[varName] = value
            end

            if varName and value then
                CaptureOldValue(characterUuid, varName)
                SetValueToVarAndTableIt(varName, value, 'gizmo')
            end

        else
            for _, Target in pairs(Data.Targets) do
                if Target.Guid and Ext.Entity.Get(Target.Guid) and Ext.Entity.Get(Target.Guid).HasDummy then
                    local dummy = Ext.Entity.Get(Target.Guid).HasDummy.Entity
                    if dummy and dummy.Visual and dummy.Visual.Visual then
                        local Ser = Ext.Types.Serialize(dummy.Visual.Visual.WorldTransform)
                        Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, Ser)
                        _GLL.SavedDummyScale[E.comboDummies.Options[selectedCharacter]] = Ser.Scale
                    end
                end
            end
        end
    end)



    API.Events.OnTransformEnd:Subscribe(function(Data)
        if isBone(Data.Targets[1].Guid) then
            local varName
            local characterUuid = getSelectedDummyOwnerUuid()
            local boneName = JointUuidBoneNameMap[Data.Targets[1].Guid]
            UnderEditing[boneName] = false
            UpdateJoints(getSelectedDummy())
            --- Gizmo bones
            -- poggers = poggers + 1
            -- local boneName = stripToBoneName(varName)
            -- if boneName and poggers == 10 then
            --     poggers = 0
            --     SetJointTransformForBone(boneName)
            -- end

            -- Utils:AntiSpam(100, function()
            -- UpdateJoints(getSelectedDummy())
            -- end)

            if Data.Mode == 'Move' then
                varName = boneName .. '_Trans'
            elseif Data.Mode == 'Rotate' then
                varName = boneName .. '_Rot'
            elseif Data.Mode == 'Scale' then
                varName = boneName .. '_Scale'
            end

            HistorySnapshot(characterUuid, varName)
        end
    end)

-- SetValueToGenomeVariable(Mods.LL2.selectedDummy, 'Alpha', 1)

    API.Events.OnClearSelection:Subscribe(function(Data)
        if not _GLL.States.inPhotoMode then return end
        _GLL.GizmoDummySelections = {}
        for k, v in pairs(_GLL.DummyNames) do
            E.checkAddTarget[v].Checked = false
        end
    end)



    API.Events.OnMoveToCursor:Subscribe(function(Data)
        if not _GLL.States.inPhotoMode then return end
        local Dummies = Dummy:GetAll()
        for k, dummy in pairs(Dummies) do
            local Ser = Ext.Types.Serialize(dummy.Visual.Visual.WorldTransform)
            Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, Ser)
        end
    end)



    -- API.Events.OnSelectionChanged:Subscribe(function(Data)
    --     _GLL.gizmo:SetActive(true) --- TBD: Tell Mazzle to  expose Toolbar for OnCommandExecuted
    -- end)



    -- API.Events.OnCommandExecuted:Subscribe(function(payload)
    --     DPrint('awkmdal;kwndk')
    --     _DS(payload)
    --     if payload.Name == 'TransformToolbar' then
    --         DPrint('TransformToolbar executed')
    --     end
    -- end)

end