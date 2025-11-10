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


Channels.GetTriggers:SetHandler(function(Data)
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



Channels.ApplyANL:SetRequestHandler(function(Data)

    local uuid = '6e3f3623-5c84-a681-6131-2da753fa2c8f'

    for _, trigger in pairs(LLGlobals.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
    end

    local uuid = LLGlobals.SelectedLighting

    Helpers.Timer:OnTicks(3, function ()
        for _, trigger in pairs(LLGlobals.LightingTriggers) do
            Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
        end
    end)
    
    return true
end)



Channels.ResetANL:SetHandler(function(Data)
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



local testTbl = {
    level1_1 = {
        level2_1 = {
            'Apple',
            value = 228,
            level3_1 = {
                level4_1 = {
                    'Carrot',
                    value = 145
                }
            }
        }
    },
    level1_2 = {
        level2_2 = {
            'Orange',
            value = 1337,
        }
    }
}

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

-- local test = {}
-- Ext.RegisterConsoleCommand('trev', function (cmd, ...)
--     -- DDump(testTbl)
--     treverse(testTbl, test)
--     -- local uuid = '4ffe46ad-b46b-0a3a-c739-d71f1bf209d9'
--     -- local tbl = Resource:GetResource(uuid, 'Lighting')
-- end)


--this works, but useless
-- local function SetValue(parameterName, parameterValueName, value)
--     local uuid = '4ffe46ad-b46b-0a3a-c739-d71f1bf209d9'
--     local tbl = Resource:GetResource(uuid, 'Lighting')[parameterName]

--     local parameterSubName
--     local function set(tbl)
--         local tbl2 = tbl2 or {}
--         for k, v in pairs(tbl) do
--             if k == parameterValueName then
--                 Resource:GetResource(uuid, 'Lighting')[parameterName][parameterSubName][parameterValueName] = value
--                 DPrint('Found')
--                 return
--             end

--             if type(v) == 'table' or type(v) == 'userdata' then
--                 tbl2[k] = {}
--                 parameterSubName = k
--                 set(v, tbl2[k])
--             else
--                 tbl2[k] = v
--             end
--         end
--         return tbl2
--     end

--     set(tbl)

-- end


-- Ext.RegisterConsoleCommand('find', function (cmd, ...)
--     -- DDump(testTbl)
--     SetValue('Fog', 'Albedo', {0.5,0.5,0.5})
--     -- local uuid = '4ffe46ad-b46b-0a3a-c739-d71f1bf209d9'
--     -- local tbl = Resource:GetResource(uuid, 'Lighting')
-- end)



Ext.RegisterConsoleCommand('res', function(cmd, ...)
    local uuid1 = '4ffe46ad-b46b-0a3a-c739-d71f1bf209d9'
    local uuid2 = '73e03af9-7ab1-47a7-906b-a4e0362045ef'
    DDump(Resource:GetResource(uuid1, 'Lighting'))
    DDump(Resource:GetResource(uuid2, 'Atmosphere'))
end)
