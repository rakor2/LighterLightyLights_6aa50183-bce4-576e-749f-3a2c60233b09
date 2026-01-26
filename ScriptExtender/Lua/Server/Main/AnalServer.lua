function getLevelAvailableLTNTriggers()
    LLGlobals.LightingTriggers = Ext.Entity.GetAllEntitiesWithComponent('ServerLightingTrigger')
    return LLGlobals.LightingTriggers
end



function getLevelAvailableATMTriggers()
    LLGlobals.AtmosphereTriggers = Ext.Entity.GetAllEntitiesWithComponent('ServerAtmosphereTrigger')
    return LLGlobals.AtmosphereTriggers
end



Ext.RegisterNetListener('LL_GetLTNTriggers', function(channel, payload, user)
    getLevelAvailableLTNTriggers()
end)



Ext.RegisterNetListener('LL_GetATMTriggers', function(channel, payload, user)
    getLevelAvailableATMTriggers()
end)



Ch.GetTriggers:SetHandler(function(Data)
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
end)



Ext.RegisterNetListener('LL_LightingApply', function(channel, payload, user)
    for _, trigger in pairs(LLGlobals.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, ltn_templates2[payload])
    end
    LLGlobals.SelectedLighting = ltn_templates2[payload]
end)



Ext.RegisterNetListener('LL_AtmosphereApply', function(channel, payload, user)
    for _, trigger in pairs(LLGlobals.AtmosphereTriggers) do
        Osi.TriggerSetAtmosphere(trigger.Uuid.EntityUuid, atm_templates2[payload])
    end
    LLGlobals.SelectedAtmosphere = atm_templates2[payload]
end)



Ch.ApplyANL:SetRequestHandler(function(Data)
    local uuid = '6e3f3623-5c84-a681-6131-2da753fa2c8f'

    for _, trigger in pairs(LLGlobals.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
    end

    local uuid = LLGlobals.SelectedLighting or '6e3f3623-5c84-a681-6131-2da753fa2c8f'

    Helpers.Timer:OnTicks(3, function ()
        for _, trigger in pairs(LLGlobals.LightingTriggers) do
            Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
        end
    end)
    return true
end)



Ch.ResetANL:SetHandler(function(Data)
    if Data == 'Lighting' then
        for _, trigger in pairs(LLGlobals.LightingTriggers) do
            Osi.TriggerResetLighting(trigger.Uuid.EntityUuid)
        end
    else
        for _, trigger in pairs(LLGlobals.AtmosphereTriggers) do
            Osi.TriggerResetAtmosphere(trigger.Uuid.EntityUuid)
        end
    end
end)


-- local function deepcopy(tbl, tbl2) --accidentally made deepcopy wtf
--     tbl2 = tbl2 or {}
--     for k, v in pairs(tbl) do
--         if type(v) == 'table' or type(v) == 'userdata' then
--             tbl2[k] = {}
--             deepcopy(v, tbl2[k])
--         else
--             tbl2[k] = v
--         end
--     end
--     -- DDump(tbl2)
--     return tbl2
-- end