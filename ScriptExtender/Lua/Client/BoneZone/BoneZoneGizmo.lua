local PHYS_FLAG         = Ext.Enums.PhysicsGroupFlags.Group08
local PHYS_TYPE         = Ext.Enums.PhysicsType.Dynamic
-- local PHYS_FLAG_EXCLUDE = Ext.Enums.PhysicsGroupFlags.Character
local PHYS_FLAG_EXCLUDE = 0



UnderEditing = {}

function isUnderEditing(boneName)
	if UnderEditing[boneName] then return true end
end



function RayCastAllColliders(entity)
	if entity and entity.Transform then
		local Translate = entity.Transform.Transform.Translate
		local Hit = Ext.Level.TestSphere(Translate, 1, PHYS_TYPE, PHYS_FLAG, PHYS_FLAG_EXCLUDE)
		return Hit
	end
end



function GetAllCollidersPosition(entity)
	local CollidersPos = {}
	local Hit = RayCastAllColliders(entity)

	if Hit then
		for k, v in pairs(Hit.Shapes) do
			local entity = v.PhysicsObject.Entity
			if entity.Dummy then
				local uuid = Entity:GetUuid(entity.Dummy.Entity)
				CollidersPos[uuid] = CollidersPos[uuid] or {}
				for d, a in pairs(v.PhysicsObject.Shapes) do
					local boneName = a.Name
					-- local NewRot = Ext.Math.QuatRotateAxisAngle(a.Rotation, {1,0,0}, math.rad(90))
					-- CollidersPos[uuid][boneName] = {RotationQuat = NewRot, Translate = a.Translate, Scale = a.Scale}
					CollidersPos[uuid][boneName] = {RotationQuat = a.Rotation, Translate = a.Translate, Scale = a.Scale}
				end
			end
		end
		return CollidersPos
	end
end


JointCharacterBoneMap = {}
AvailableJoint = {}
JointUuidBoneNameMap = {}
JointUuidEntityMap = {}


local JointTransformCache = {}

local function transformChanged(id, Transform)
    local Cached = JointTransformCache[id]
    if not Cached then return true end

    local t1, t2 = Cached.Translate, Transform.Translate
    local dx, dy, dz = t1[1]-t2[1], t1[2]-t2[2], t1[3]-t2[3]
    local posChanged = dx*dx + dy*dy + dz*dz > 0.0001

    local r1, r2 = Cached.RotationQuat, Transform.RotationQuat
    local rotChanged = false
    if r1 and r2 then
        rotChanged = r1[1] ~= r2[1] or r1[2] ~= r2[2] or
                     r1[3] ~= r2[3] or r1[4] ~= r2[4]
    end

    return posChanged or rotChanged
end



function JointLoop(entity)
    CreateJoints(entity)
    Helpers.Timer:OnTicks(20, function()
        Utils:SubUnsubToTick(1, 'JointLoop', function()
            local AllTransforms = GetAllCollidersPosition(entity)

            if not AllTransforms then return end
            for uuid, Bones in pairs(JointCharacterBoneMap) do
                for boneName, jointUuid in pairs(Bones) do
                    if not UnderEditing[boneName] then
                        local Transform = AllTransforms[uuid] and AllTransforms[uuid][boneName]

                        if Transform then
                            local id = uuid .. boneName

                            if transformChanged(id, Transform) then
                                JointTransformCache[id] = Transform
                                SetJointTransform(Transform, uuid, boneName, jointUuid)
                            end
                        end
                    end
                end
            end
        end)
    end)
end


function UpdateJoints(entity)
	local AllTransforms = GetAllCollidersPosition(entity)

	if not AllTransforms then return end
	for uuid, Bones in pairs(JointCharacterBoneMap) do
		for boneName, jointUuid in pairs(Bones) do
			if not UnderEditing[boneName] then
				local Transform = AllTransforms[uuid] and AllTransforms[uuid][boneName]

				if Transform then
					local id = uuid .. boneName

					if transformChanged(id, Transform) then
						JointTransformCache[id] = Transform
						SetJointTransform(Transform, uuid, boneName, jointUuid)
					end
				end
			end
		end
	end
end




function JointLoopOnce(entity)
    CreateJoints(entity)
    Helpers.Timer:OnTicks(20, function()
        UpdateJoints(entity)
    end)
end



function SetJointTransformForBone(boneName)
    local characterUuid = getSelectedDummyOwnerUuid()
    if not characterUuid then return end
    local boneMap = JointCharacterBoneMap[characterUuid]
    if not boneMap then return end
    local jointUuid = boneMap[boneName]
    if not jointUuid then return end

    local entity = getSelectedDummy()
    local AllTransforms = GetAllCollidersPosition(entity)
    if not AllTransforms or not AllTransforms[characterUuid] then return end

    local Transform = AllTransforms[characterUuid][boneName]
    if Transform then
        SetJointTransform(Transform, characterUuid, boneName, jointUuid)
    end
end



function JointLoopStop()
	Utils:SubUnsubToTick(0, 'JointLoop')
end



function CreateJoint()
	Ch.CreateJoint:RequestToServer(Data, function(Response)
		local jointUuid = Response
		AvailableJoint[jointUuid] = true
		PopulateJointUuidEntityMap(jointUuid)
	end)
end



function CreateJoints(entity)
	local CollidersPos = GetAllCollidersPosition(entity)
	for uuid, Colliders in pairs(CollidersPos) do
		for boneName, Transforms in pairs(Colliders) do
			Ch.CreateJoint:RequestToServer(Data, function(Response)
				local jointUuid = Response
				AvailableJoint[jointUuid] = true
				Helpers.Timer:OnTicks(5, function()
					AssignJointToBone(uuid, boneName, jointUuid)
					local Transform = CollidersPos[uuid][boneName]
					local entity = Ext.Entity.Get(jointUuid)

					SetJointTransform(Transform, uuid, boneName, jointUuid)

					JointUuidBoneNameMap[jointUuid] = boneName

					--- I don't really know if I need this. I think Ext.Entity.Get is basically the same thing
					JointUuidEntityMap[jointUuid] = entity
				end)
			end)
		end
	end
end



function SwitchJointAvailability(jointUuid)
	AvailableJoint[jointUuid] = not AvailableJoint[jointUuid]
end



function GetAvailableJoint()
	for k, v in pairs(AvailableJoint) do
		if AvailableJoint[k] then
			SwitchJointAvailability(k)
			return k
		end
	end
end



function AssignJointToBone(uuid, boneName, jointUuid)
	if AvailableJoint[jointUuid] then
		local boneName = boneName or 'Root_M'

		JointCharacterBoneMap                 = JointCharacterBoneMap or {}
		JointCharacterBoneMap[uuid]           = JointCharacterBoneMap[uuid] or {}
		JointCharacterBoneMap[uuid][boneName] = JointCharacterBoneMap[uuid][boneName] or {}

		JointCharacterBoneMap[uuid][boneName] = jointUuid
		SwitchJointAvailability(jointUuid)
		return uuid, boneName, jointUuid
	end
end



function SetJointTransform(Transform, uuid, boneName, jointUuid)
    local jointEnt = JointUuidEntityMap[jointUuid]
    if jointEnt and Transform then
    	local NewRot = Ext.Math.QuatRotateAxisAngle(Transform.RotationQuat, {0,1,0}, math.rad(90))
		local NewTransform = {Translate = Transform.Translate , RotationQuat = NewRot , Scale = Transform.Scale}
		jointEnt.Visual.Visual.ObjectDescs[1].Renderable.WorldTransform = NewTransform
		Ext.OnNextTick(function()
			ReplicateTransform(jointEnt, NewTransform)
		end)
	end
end


function GetJointTransform(jointUuid)
    local jointEnt = JointUuidEntityMap[jointUuid]
	if jointEnt then
		return jointEnt.Visual.Visual.ObjectDescs[1].Renderable.WorldTransform
	end
end


function ResetAllJoints()
	for jointUuid, _ in pairs(AvailableJoint) do
		AvailableJoint[jointUuid] = false
	end
	CollidersPos   = {}
	ShapeTemplates = {}
	JointCharacterBoneMap = {}
end



function DeleteJoint()
	Ch.DeleteJoints:SendToServer(action)
	ResetAllJoints()
end



function AssignSoftBody(entity)
	if Entity:hasVisual(entity) then
		-- entity.Visual.Visual.Attachments[1].Visual.VisualResource.SkeletonResource = '02adf183-8b3e-d80b-0f0a-8dae6c455622' -- BoneZone
		-- entity.Visual.Visual.Attachments[1].Visual.VisualResource.SoftbodyResourceID = '0c36a889-a3bd-6ebb-1137-e6ebb6acc6f2' -- BoneZone
		-- entity.Visual.Visual.Attachments[1].Visual.VisualResource.SoftbodyResourceID = 'abec7ca9-aa91-4a72-bee6-40a9474fa390' -- HUM_F_Ragdoll
	end
end



function RayCastCollider()
	local Ray = Screen:ScreenToWorldRay()
	local Hit = Ray:IntersectAll(_, PHYS_TYPE, PHYS_FLAG, PHYS_FLAG_EXCLUDE)
	return Hit
end



function FindCorrectCollider(Shapes, entity)
	local dummy = _C().HasDummy.Entity
	for k, v in ipairs(Shapes) do
		if v.PhysicsObject.Entity == dummy then
			return Shapes[k]
		end
	end
end



function GetSelectedColliderJointEntity()
	local Hit = RayCastCollider()
	local Shapes = Hit[1].Position[1].Shapes
	local CorrectShapes = FindCorrectCollider(Shapes, entity)
	local boneName = CorrectShapes.Name
	local uuid = Dummy:Owner(CorrectShapes.PhysicsObject.Entity).Uuid.EntityUuid
	local jointUuid = JointCharacterBoneMap[uuid][boneName]
	return jointUuid
end



function GizmoSelect()
	local jointUuid = GetSelectedColliderJointEntity()
	_GLL.boneGizmo:Select({jointUuid})
	_GLL.boneGizmo:SetMode('Rotate')
	DPrint(JointUuidBoneNameMap[jointUuid])
	return jointUuid
end



function GizmoCycleMode()
	_GLL.boneGizmo:CycleMode()
end



function AddBoneToSelection()
	local entity = GetSelectedColliderJointEntity()
	_GLL.boneGizmo:AddTarget(entity)
end



function ReplicateTransform(entity, Transform)
	local uuid = Entity:GetUuid(entity)
	local Data = {
		uuid = uuid,
		Transform = Transform
	}
	Ch.ReplicateTransform:SendToServer(Data)
end



function PopulateJointUuidEntityMap(jointUuid)
	local entity = Ext.Entity.Get(jointUuid)
	JointUuidEntityMap[jointUuid] = entity
end



function Garbo()
	local uuid = _C().Uuid.EntityUuid
	local jointUuid
	local boneName = 'Hip_R'
	local varName = boneName .. '_Rot'

	for boneName2, jointUuid2 in pairs(JointCharacterBoneMap[uuid]) do
		if boneName2 == boneName then jointUuid = jointUuid2 end
	end

	local entity = JointUuidEntityMap[jointUuid]
	UnderEditing[boneName] = true

	Utils:SubUnsubToTick(1, 'GARBO', function()
		local Transform = GetJointTransform(jointUuid)
		local value = Transform.RotationQuat
		SetValueToVarAndTableIt(varName, value, 'gizmo')
		DDump(value)
		-- DDump(value)
	end)
end