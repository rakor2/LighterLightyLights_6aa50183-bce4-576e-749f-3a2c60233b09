ANL = {}
-- ANL = Ext.Require('Client/Anal/Anal.lua')

ANL.Blocked = {
	['Stash_PhinaCamp'] = true,
}

ANL.BlockedTriggers = {
	-- Lighting mirror and portraits
	['ac6e827d-4988-8365-2fc0-2335387bbaaa'] = true,
	['c91f161d-f938-8cd9-42fc-f7250adbad53'] = true,
	['00fd9f62-16d5-c800-b128-96fce29ebf00'] = true,
	['8a83e37d-b3fd-c0ce-f7a4-105e8692c5bb'] = true,
	['121d4caf-a43f-cd04-b78b-bade259a69f0'] = true,

	-- Atmosphere mirror and portraits
	['eeddb905-b403-8bd3-45a5-dfafe608a21a'] = true,
	['bb3a96a5-28d1-84e4-28b3-da06819ca637'] = true,
	['18210d12-510b-c0f9-dff1-c3edc664bd8a'] = true,
	['d47ca45f-c6e0-c4e7-e826-c6d1477f934b'] = true,
	['2a41ba5f-ef65-c5fd-d554-e7cf0960677a'] = true,
}

ANL.CurrentlyBlockedLevels = {}


local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')

local LightingTriggers = {}
local LightingAtmosphere = {}

local CurrentLighting
local CurrentAtmosphere


local Enum = {
	LTN = 1,
	ATM = 2,
}

-- _D(Ext.Entity.GetAllEntitiesWithComponent('ClientAtmosphereTrigger')[2].ClientAtmosphereTrigger.CurrentAtmosphereResourceID)
-- _D(Ext.Entity.GetAllEntitiesWithComponent('ClientAtmosphereTrigger')[2].ClientAtmosphereTrigger.AtmosphereResourceIDs)

local ComponentNames = {}

do --- Context based component names :mhm:
	if Ext.IsClient() then
		ComponentNames = {
			Lighting   = 'ClientLightingTrigger',
			Atmosphere = 'ClientAtmosphereTrigger'
		}
	else --- Server
		ComponentNames = {
			Lighting   = 'ServerLightingTrigger',
			Atmosphere = 'ServerAtmosphereTrigger'
		}
	end
end



function ANL.GetTriggers()
	local Triggers = {}
	local CLT = Ext.Entity.GetAllEntitiesWithComponent(ComponentNames.Lighting)
	local CAT = Ext.Entity.GetAllEntitiesWithComponent(ComponentNames.Atmosphere)

	for k, Trigger in pairs(CLT) do
		local levelName = Trigger.Level.LevelName
		local uuid = Trigger.Uuid.EntityUuid
		if ANL.Blocked[levelName]
			or (not Settings.allowMirror and ANL.BlockedTriggers[uuid])
		then
			CLT[k] = nil
			ANL.CurrentlyBlockedLevels[levelName] = true
		end
	end

	for k, Trigger in pairs(CAT) do
		local levelName = Trigger.Level.LevelName
		if ANL.Blocked[levelName]
			or (not Settings.allowMirror and ANL.BlockedTriggers[uuid])
		then

			CAT[k] = nil
			ANL.CurrentlyBlockedLevels[levelName] = true
		end
	end


	table.insert(Triggers, CLT)
	table.insert(Triggers, CAT)
	return Triggers
end



--- Don't really need this, since it's all client, just reloading save is fine
function ANL.SaveInitialResources(triggerType, Trigger)
	local Trigger = Trigger or ANL.GetTriggers()[Enum.LTN][1]
	local triggerUuid = Trigger.Uuid.EntityUuid --- Entity uuid matches template uuid, no worries
	local Initial = Initial or {}

	if not Initial[triggerUuid] then
		Initial[triggerUuid] = Trigger[ComponentNames[triggerType]]
	end
	return Initial
end



function ANL.AddResourceToTrigger(triggerType, resourceUuid, Trigger)
	local triggerType  = triggerType  or 'Lighting'
	local resourceUuid = resourceUuid or '2a6302ab-a80a-1219-d45b-b937e828b336'
	local Trigger      = Trigger      or ANL.GetTriggers()[Enum.LTN][1]

	if not triggerType  then DPrint('No template type provided') return false end
	if not resourceUuid then DPrint('No uuid provided')          return false end
	if not Trigger      then DPrint('No trigger provided')       return false end

	Trigger = Trigger[ComponentNames[triggerType]]

	if triggerType == 'Lighting' then
		local IDs = Trigger.LightingResourceIDs
		local SerIDs = Ext.Types.Serialize(IDs)

	--- A bit of jank, but I don't mind
	--- Adding new entries to the array causes crash
	--- Probably some memory bs, cuz the game doesn't allocate it for more entries????????? I don't know
	--- So the solution is to replace last entry
		SerIDs[#SerIDs] = resourceUuid

		Trigger.LightingResourceIDs = SerIDs
		return Trigger.LightingResourceIDs
	end

	if triggerType == 'Atmosphere' then
		local IDs = Trigger.AtmosphereResourceIDs
		local SerIDs = Ext.Types.Serialize(LR)
		SerIDs[#SerIDs] = resourceUuid
		Trigger.AtmosphereResourceIDs = SerIDs
		return Trigger.AtmosphereResourceIDs
	end

	return false
end



function ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
	local Camera = Camera:GetActiveCamera()

	if Camera.GameCameraBehavior and Camera.GameCameraBehavior.TargetCurrentLow then
		local T = Camera.GameCameraBehavior and Camera.GameCameraBehavior.TargetCurrentLow
		Camera.GameCameraBehavior.TargetCurrentLow = {T[1] + Settings.cameraOffset, T[2], T[3]}
		Camera.GameCameraBehavior.TargetCurrentLow = {T[1] - Settings.cameraOffset, T[2], T[3]}
	end
end



--- I don't mind duplications :mhm:

SavedLastLTNResource = {}
SavedLastATMResource = {}



function ANL.SetLigthing(ltnUuid, Trigger)
	local LTN_Triggers = LTN_Triggers or {}
	local Lighting = Ext.Resource.Get(ltnUuid, 'Lighting').Lighting

	if Settings.degenExtendedScriptExtender and _GLL.States.inPhotoMode then
		local CT = _C().Transform.Transform.Translate
		local Trigger = FindClosestTrigger(ComponentNames.Lighting, CT)
		Ext.GameRenderView.SetLighting(Lighting, 0, true)

		ANL.AddLightingToResourceIDs(ltnUuid, Trigger)
		Trigger[ComponentNames.Lighting].field_84 = 0
		Trigger[ComponentNames.Lighting].CurrentLightingResourceID = ltnUuid
		return
	end

	if not Trigger then
		if not next(LTN_Triggers) then
			LTN_Triggers = ANL.GetTriggers()[Enum.LTN]
		end

		for _, Trigger in pairs(LTN_Triggers) do
			ANL.AddLightingToResourceIDs(ltnUuid, Trigger)

			Trigger[ComponentNames.Lighting].field_84 = 0
			Trigger[ComponentNames.Lighting].CurrentLightingResourceID = ltnUuid
		end

	--- Should be before last end, but I'm not planning to set ligthing for specific triggers
	--- And since Reset calls SetLigthing multiple times the camera shift is huge
	--- I'll just add it here and in the Reset
		ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
	else
		ANL.AddLightingToResourceIDs(ltnUuid, Trigger)

		Trigger[ComponentNames.Lighting].field_84 = 0
		Trigger[ComponentNames.Lighting].CurrentLightingResourceID = ltnUuid
	end

	_GLL.CurrentLighting = UI:SelectedOpt(E.comboLighting)
	Anl.CurrentLighting = UI:SelectedOpt(E.comboLighting)
end



local dofFulAtmosphere

function ANL.SetAtmosphere(atmUuid, Trigger)
	local ATM_Triggers = ATM_Triggers or {}
	local Atmosphere = Ext.Resource.Get(atmUuid, 'Atmosphere').Atmosphere

	if Settings.degenExtendedScriptExtender and _GLL.States.inPhotoMode then
		local CT = _C().Transform.Transform.Translate
		local Trigger = FindClosestTrigger(ComponentNames.Atmosphere, CT)
		Ext.GameRenderView.SetAtmosphere(Atmosphere)

		ANL.AddAtmosphereToResourceIDs(atmUuid, Trigger)
		Trigger[ComponentNames.Atmosphere].field_84 = 0
		Trigger[ComponentNames.Atmosphere].CurrentAtmosphereResourceID = atmUuid
		return
	end

	--- TBD: Probably separate it in a function
	do  --- Disables dof, cuz if it's enabled, it will break photo mode dof controls xd
		if dofFulAtmosphere then
			-- DPrint('dofFulAtmosphere')
			-- DPrint(dofFulAtmosphere)
			local PrevAtmosphere = Resource:GetResource(dofFulAtmosphere, 'Atmosphere')
			PrevAtmosphere.PostProcess.Camera.DOF.DOF = true
			-- DDump(Resource:GetResource(dofFulAtmosphere, 'Atmosphere'))
		end


		local Atmosphere = Resource:GetResource(atmUuid, 'Atmosphere')
		local dofState = Atmosphere.PostProcess.Camera.DOF.DOF
		if dofState then
			-- DPrint('dofState')
			dofFulAtmosphere = atmUuid
			Atmosphere.PostProcess.Camera.DOF.DOF = false
			-- DDump(Resource:GetResource(Atmosphere, 'Atmosphere'))
		end
	end


	if not Trigger then
		if not next(ATM_Triggers) then
			ATM_Triggers = ANL.GetTriggers()[Enum.ATM]
		end

		for _, Trigger in pairs(ATM_Triggers) do
			ANL.AddAtmosphereToResourceIDs(atmUuid, Trigger)

			Trigger[ComponentNames.Atmosphere].field_84 = 0
			Trigger[ComponentNames.Atmosphere].CurrentAtmosphereResourceID = atmUuid
		end

		ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
	else
		ANL.AddAtmosphereToResourceIDs(atmUuid, Trigger)
		Trigger[ComponentNames.Atmosphere].field_84 = 0
		Trigger[ComponentNames.Atmosphere].CurrentAtmosphereResourceID = atmUuid
	end

	_GLL.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)
	Anl.CurrentAtmosphere = UI:SelectedOpt(E.comboAtmosphere)
end



function ANL.AddLightingToResourceIDs(ltnUuid, Trigger)
	local LR = Trigger[ComponentNames.Lighting].LightingResourceIDs
	local triggetUuid = Trigger.Uuid.EntityUuid

	if not SavedLastLTNResource[triggetUuid] then
		SavedLastLTNResource[triggetUuid] = SavedLastLTNResource[triggetUuid] or {}
		SavedLastLTNResource[triggetUuid] = LR[#LR]
	end
	LR[#LR] = ltnUuid
end



function ANL.AddAtmosphereToResourceIDs(atmUuid, Trigger)
	local AR = Trigger[ComponentNames.Atmosphere].AtmosphereResourceIDs
	local triggetUuid = Trigger.Uuid.EntityUuid

	if not SavedLastATMResource[triggetUuid] then
		SavedLastATMResource[triggetUuid] = SavedLastATMResource[triggetUuid] or {}
		SavedLastATMResource[triggetUuid] = AR[#AR]
	end
	AR[#AR] = atmUuid
end



function ANL.ResetLightingToResourceIDs()
	local LTN_Triggers = {}

	if not next(LTN_Triggers) then
		LTN_Triggers = ANL.GetTriggers()[Enum.LTN]
	end

	for _, Trigger in pairs(LTN_Triggers) do
		local LR = Trigger[ComponentNames.Lighting].LightingResourceIDs
		local lastIndex = #LR
		local triggetUuid = Trigger.Uuid.EntityUuid

		if SavedLastLTNResource[triggetUuid] then
			Trigger[ComponentNames.Lighting].LightingResourceIDs[lastIndex] = SavedLastLTNResource[triggetUuid]

			if lastIndex == 1 then
				--- If triggers has one resource reset normally
				ANL.SetLigthing(SavedLastLTNResource[triggetUuid], Trigger)
			else
				--- If triggers has more resources reset to the first one
				ANL.SetLigthing(LR[1], Trigger)
			end
		end
		ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
	end
end



function ANL.ResetAtmosphereToResourceIDs()
	local ATM_Triggers = {}

	if not next(ATM_Triggers) then
		ATM_Triggers = ANL.GetTriggers()[Enum.ATM]
	end

	for _, Trigger in pairs(ATM_Triggers) do
		local AR = Trigger[ComponentNames.Atmosphere].AtmosphereResourceIDs
		local lastIndex = #AR
		local triggetUuid = Trigger.Uuid.EntityUuid

		if SavedLastATMResource[triggetUuid] then
			Trigger[ComponentNames.Atmosphere].AtmosphereResourceIDs[lastIndex] = SavedLastATMResource[triggetUuid]

			if lastIndex == 1 then
				ANL.SetAtmosphere(SavedLastATMResource[triggetUuid], Trigger)
			else
				ANL.SetAtmosphere(AR[1], Trigger)
			end
		end
		ANL.MoveCameraToChangeANLBecauseThisGameIsWeird()
	end
end



function ANL.ApplyLighting()
	local switherLighting  = '3a7102a7-4818-185a-9060-d72318c181f4'
	local currentLighitng  = LTN_Templates[_GLL.CurrentLighting]
	local fallbackSwithcer = '32d627ea-192c-4d45-7a07-f6b7f1c9d745' --- in case if user selected '3a7102a7...'
	local resetLighting    = switherLighting == currentLighitng and fallbackSwithcer or switherLighting
	local LTN_Triggers     = {}

	local Saved = Ext.Types.Serialize(Ext.Resource.Get(currentLighitng, 'Lighting').Lighting)
	Saved.ParentGUID = resetLighting
	Ext.Types.Unserialize(Ext.Resource.Get(resetLighting, 'Lighting').Lighting, Saved)


	if not next(LTN_Triggers) then
		LTN_Triggers = ANL.GetTriggers()[Enum.LTN]
	end

	for _, Trigger in pairs(LTN_Triggers) do
		ANL.SetLigthing(resetLighting, Trigger)
	end

	OnTicks(2, function ()
		for _, Trigger in pairs(LTN_Triggers) do
			ANL.SetLigthing(currentLighitng, Trigger)
		end
	end)
end



function ANL.ApplyAtmosphere()
	local switherAtmopshere  = 'f9862ce8-972f-d2b6-4bf9-c37746c9eaac'
	local currentAtmosphere  = ATM_Templates[_GLL.CurrentAtmosphere]
	local resetAtmosphere    = switherAtmopshere
	local ATM_Triggers       = {}

	if not next(ATM_Triggers) then
		ATM_Triggers = ANL.GetTriggers()[Enum.ATM]
	end

	for _, Trigger in pairs(ATM_Triggers) do
		ANL.SetAtmosphere(resetAtmosphere, Trigger)
	end

	OnTicks(2, function ()
		for _, Trigger in pairs(ATM_Triggers) do
			ANL.SetAtmosphere(currentAtmosphere, Trigger)
		end
	end)
end



function ANL.AppendResources()
	local CLT, CAT = ANL.GetTriggers()

	for _, Trigger in pairs(CLT) do
		local LR = Trigger[ComponentNames.Lighting].LightingResourceIDs
		local SerLR = Ext.Types.Serialize(LR)

		for _, uuid in pairs(LTN_Templates) do
			table.insert(SerLR, uuid)
		end

		Ext.Types.Unserialize(LR, SerLR)
	end

	for _, Trigger in pairs(CAT) do
		local AR = Trigger.ClientAtmosphereTrigger.AtmosphereResourceIDs
		local SerAR = Ext.Types.Serialize(AR)

		for _, uuid in pairs(ATM_Templates) do
			table.insert(SerAR, uui)
		end

		Ext.Types.Unserialize(AR, SerAR)
	end

end


-- Stash_PhinaCamp
-- AtmosphereTrigger_Basic_000_9aabc15b-f0ac-4884-ba35-dc996a401ab3
-- LightingTrigger_Basic_000_c0e073a6-a84f-4dc2-bc4f-ce35548e2847




--- Thx Mr.Clanker for math Gladge
local function isInPolygon(px, pz, points)
    local inside = false
    local n = #points
    local j = n
    for i = 1, n do
        local xi, zi = points[i][1], points[i][2]
        local xj, zj = points[j][1], points[j][2]
        if ((zi > pz) ~= (zj > pz)) and (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end



local function rotateByInv(point, rot)
    local qx, qy, qz, qw = rot[1], rot[2], rot[3], rot[4]
    local px, py, pz = point[1], point[2], point[3]
    local ix =  qw*px + qy*pz - qz*py
    local iy =  qw*py + qz*px - qx*pz
    local iz =  qw*pz + qx*py - qy*px
    local iw = -qx*px - qy*py - qz*pz
    return {
        ix*qw + iw*(-qx) + iy*(-qz) - iz*(-qy),
        iy*qw + iw*(-qy) + iz*(-qx) - ix*(-qz),
        iz*qw + iw*(-qz) + ix*(-qy) - iy*(-qx)
    }
end



local function isInTriggerArea(point, TriggerArea)
    local Bounds =  TriggerArea.Bounds
    local Physics = TriggerArea.Physics
    local Pos =     Bounds.Position
    local Rot =     TriggerArea.RotationInv

    local lp = {point[1] - Pos[1], point[2] - Pos[2], point[3] - Pos[3]}
    if Rot then lp = rotateByInv(lp, Rot) end

    local ok, extents = pcall(function() return Physics.Extents end)
    if ok and extents then
        return math.abs(lp[1]) <= extents[1]
           and math.abs(lp[2]) <= extents[2]
           and math.abs(lp[3]) <= extents[3]
    end

    local ok2, points = pcall(function() return Physics.Points end)
    if ok2 and points then
        local minY, maxY = Bounds.BoundsMin[2], Bounds.BoundsMax[2]
        if lp[2] < minY or lp[2] > maxY then return false end
        return isInPolygon(lp[1], lp[3], points)
    end

    return false
end



function FindClosestTrigger(component, CT)
    local triggers = Ext.Entity.GetAllEntitiesWithComponent(component)
    local minDist = math.huge
    local found

    for _, trigger in ipairs(triggers) do
        if trigger[component] and trigger.TriggerArea and isInTriggerArea(CT, trigger.TriggerArea) then
            local TT = trigger.Transform.Transform.Translate
            local dx = TT[1] - CT[1]
            local dy = TT[2] - CT[2]
            local dz = TT[3] - CT[3]
            local d = math.sqrt(dx*dx + dy*dy + dz*dz)
            if d < minDist then
                minDist = d
                found = trigger
            end
        end
    end

    return found
end



function GetCurrentAtmosphere()
	-- local start = Ext.Timer.MonotonicTime()
    local CT = _C().Transform.Transform.Translate
    local Trigger = FindClosestTrigger(ComponentNames.Atmosphere, CT)
    -- DPrint(Trigger.Uuid.EntityUuid)
    -- DPrint('GetCurrentAtmosphere took: %s', Ext.Timer.MonotonicTime() - start)
    return Trigger and Trigger[ComponentNames.Atmosphere].CurrentAtmosphereResourceID
end



function GetCurrentLighting()
    local CT = _C().Transform.Transform.Translate
    local Trigger = FindClosestTrigger(ComponentNames.Lighting, CT)
    -- DPrint(Trigger.Uuid.EntityUuid)
    return Trigger and Trigger[ComponentNames.Lighting].CurrentLightingResourceID
end



function GetAtmosphereAndLightingInCurrentTrigger()
    local atmUuid = GetCurrentAtmosphere()
    local ltnUuid = GetCurrentLighting()
    return atmUuid, ltnUuid
end
