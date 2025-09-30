
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()

    -- DWarn('LL AnL triggers:------')
    -- DDump(Globals.LightingTriggers)
    -- DDump(Globals.AtmosphereTriggers)
    -- DPrint('-------------------')

    Ext.Net.BroadcastMessage('LL_WhenLevelGameplayStarted', Ext.Json.Stringify(data))
end)


Ext.Entity.OnCreate('Transform', function (entity)
    if entity and entity.Effect then
        Helpers.Timer:OnTicks(10, function ()
            D(entity.Effect.EffectName)        
        end)
    end
end)