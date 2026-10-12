Ext.Events.ResetCompleted:Subscribe(function()
    -- getLevelAvailableLTNTriggers()
    -- getLevelAvailableATMTriggers()
end)



Ext.Entity.OnDestroyDeferred('JumpFollow', function()
    Ch.JumpFollow:Broadcast({})
end)



Ch.DisableCrowd:SetHandler(function(data)
    Settings.disableCrowd = data
end)

Ext.Events.GameStateChanged:Subscribe(function(e)
    if Settings.disableCrowd then
            if e.FromState == 'LoadLevel' then
                local Entities = Ext.Entity.GetAllEntitiesWithComponent('ServerCrowdCharacterTrigger')
                for k, v in pairs(Entities) do
                    if v.ServerCrowdCharacterTrigger then
                    v.ServerCrowdCharacterTrigger.MaxCharacters = 0
                end
            end
        end
    end
end)



Ch.RemoveAllCombat:SetHandler(function()
    local Entities = Ext.Entity.GetAllEntities()
    for _, v in pairs(Entities) do
        if v.CombatParticipant and v.Uuid then
            --- idk how to remove flags with SE :PepeLaugh:
            Osi.SetCanJoinCombat(v.Uuid.EntityUuid, 0)
        end
    end
end)


--- Thank you Mazzle for pointing to the right place
-- Ext.Osiris.RegisterListener('EnteredTrigger', 2, "after", function(character, trigger)
--     DDump({character, trigger})
--     DPrint('DOESNT WORK NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO')
-- end)



