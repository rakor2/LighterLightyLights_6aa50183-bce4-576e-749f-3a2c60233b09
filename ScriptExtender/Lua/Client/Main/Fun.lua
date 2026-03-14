local WINDOW_IS_OPENED = true
local WINDOW_SIZE = {400,400}

-- local w = Ext.IMGUI.NewWindow('DVD')
-- w.Open = WINDOW_IS_OPENED
-- w.NoDecoration = true
-- w:SetPos({500, 500})
-- w:SetSize(WINDOW_SIZE)


Fun = {}
Fun.Windows = {}



local function AttachWindowToEntity(w, TargetTranslate, WinSize)
    local Pos = Screen.WorldToScreenPoint(TargetTranslate)
    if not Pos then w.Visible = false return end
    if not WinSize then WinSize = {0,0} end

    local WindowCenter = {WinSize[1]*0.5, WinSize[2]*0.5}
    w:SetPos(Vec2.__sub({Pos[1], Pos[2]}, WindowCenter))
end


local HEIGHT_OFFSET = 2
local MAX_DISTANCE = 11


Ext.Entity.OnCreate('PhotoModeSession', function()
	Helpers.Timer:OnTicks(30, function ()
		local Dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')

		for k, dummy in pairs(Dummies) do
			local dummyName = Dummy:Name(dummy)

			local wn =  Ext.IMGUI.NewWindow(Ext.Math.Random(1, 100))
			wn.Visible = true
			ApplyStyle(wn, StyleSettings.selectedStyle)
			wn.NoDecoration = true
			wn.AlwaysAutoResize = true

			local x, y, z = table.unpack(dummy.DummyOriginalTransform.Transform.Translate)
			local TargetTranslate = {x, y + HEIGHT_OFFSET, z}

			AttachWindowToEntity(wn, TargetTranslate)

			local selectedLightNotification = wn:AddText(dummyName)
			Fun.Windows[k] = {Window = wn, Size = wn.LastSize, Dummy = dummy, Name = dummyName}
		end

	end)
end)



Ext.Entity.OnDestroy('PhotoModeSession', function()
	for _, v in pairs(Fun.Windows) do
		v.Window:Destroy()
	end
end)



Utils:SubUnsubToTick(1, 'FUN', function()
    if not _GLL.States.inPhotoMode then return end
    local Dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')

    for k, _ in ipairs(Dummies) do
        local tbl = Fun.Windows[k]
        local x, y, z = table.unpack(tbl.Dummy.DummyOriginalTransform.Transform.Translate)
        local TargetTranslate = {x, y + HEIGHT_OFFSET, z}
        local CamTranslate = Camera:GetActiveCamera().Transform.Transform.Translate
        local distanceToTarget = Ext.Math.Distance(TargetTranslate, CamTranslate)

        tbl.Window.Visible = distanceToTarget < MAX_DISTANCE
        AttachWindowToEntity(tbl.Window, TargetTranslate, tbl.Size)
    end


    -- local Quat = MathUtils.DirectionToQuat(Ray.Direction, _, 'Y')
    -- local Pos, Rot = PickingUtils.GetPickingHitPosAndRot()
	-- SetValueToGenomeVariable(d, 'eye_r_Rot', Quat)
	-- SetValueToGenomeVariable(d, 'eye_l_Rot', Quat)


    -- local Ray = Screen.ScreenToWorldRay(Camera:GetActiveCamera())
    -- local Hit = Ray:IntersectAll(3000)

    -- local d = Dummy:Get(_C())
    -- local Dtranslta = d.Visual.Visual.WorldTransform
    -- local Pos = Hit[1].Position
    -- local Quat = MathUtils.LookAtParent(Dtranslta, Pos)

    -- d.Visual.Visual.WorldTransform.RotationQuat = Quat
end)