local JOINT_TEMPLATE         = '6506b2c7-7227-4122-a38e-ab5a40a55377'
local JOINT_TEMPLATE_CAPSULE = 'c8bf9d2a-533e-4531-b91c-fedda5972599'


Joints = {}

Ch.CreateJoint:SetRequestHandler(function(Data)
	local uuid = Data and Data.uuid or Entity:GetUuid(_C())
	local entity = Ext.Entity.Get(uuid)
	local x, y, z = table.unpack(entity.Transform.Transform.Translate)
	-- local joitUuid = Osi.CreateAt(JOINT_TEMPLATE, x, y, z, 0, 0, '')
	local joitUuid = Osi.CreateAt(JOINT_TEMPLATE_CAPSULE, x, y, z, 0, 0, '')
	table.insert(Joints, joitUuid)
	return joitUuid
end)



function DeleteAllJoints()
	for k, v in pairs(Joints) do
		Osi.RequestDelete(v)
	end
end



Ch.DeleteJoints:SetHandler(function()
	DeleteAllJoints()
end)



Ch.ReplicateTransform:SetHandler(function(Data)
	local Transform = Data.Transform
	local uuid = Data.uuid
	local entity = Ext.Entity.Get(uuid)
	entity.Transform.Transform.Translate    = Transform.Translate
	entity.Transform.Transform.RotationQuat = Transform.RotationQuat
	entity.Transform.Transform.Scale        = Transform.Scale
	local x, y, z = Osi.GetPosition(uuid)
	local rx, ry, rz = Osi.GetRotation(uuid)
	Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
end)
