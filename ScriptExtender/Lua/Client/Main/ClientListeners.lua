---@diagnostic disable: param-type-mismatch





---Gets selected characters index in the Fill combo
function getSelectedFillCharacter()
    if visTemComob then
        local selectedOptionName = visTemComob.Options[visTemComob.SelectedIndex + 1]
        selectedCharacter = NamedOptions[selectedOptionName]
    end
end


function matchDummyAndCharacter(entity, dummy)
    local e = Ext.Entity.Get(entity)
    if e and e.Transform
        and e.Transform.Transform.Translate[1] == dummy.Transform.Transform.Translate[1]
        and e.Transform.Transform.Translate[2] == dummy.Transform.Transform.Translate[2] 
        and e.Transform.Transform.Translate[3] == dummy.Transform.Transform.Translate[3] then
        return dummy
    end
end


function dumpDummies()
    local v = Ext.Entity.GetAllEntitiesWithComponent("Visual")
    for _, entity in pairs(v) do 
        for _, component in pairs(entity:GetAllComponentNames(false)) do
            if component:lower():find('dummy') then
                DPrint(entity)
                break
            end
        end
    end
end



Ext.Entity.OnCreate('PhotoModeSession', function ()
    --DPrint('PhotoModeSession OnCreate')
    Helpers.Timer:OnTicks(30, function ()
        Globals.DummyNameMap = {}
        local dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')
        for _, dummy in pairs(dummies) do
            Globals.DummyNameMap[Dummy:Name(dummy) .. '##' .. Ext.Math.Random(1,10000)] = dummy
            -- DDebug('-----------------------------------------')
            -- DDebugDump(Dummy:Name(dummy))
            -- DDebugDump(dummy:GetAllComponentNames(true))
        end
        Globals.DummyNames = Utils:MapToArray(Globals.DummyNameMap)
        visTemComob.Options = Globals.DummyNames
        UpdateCharacterInfo(visTemComob.SelectedIndex + 1)
        -- DDebug('Map---------------------------------------')
        -- DDebugDump(Globals.DummyNameMap)
        -- DDebug('Vis---------------------------------------')
        -- DDebugDump(visTemComob.Options)
    end)
end)



Ext.Entity.OnDestroy('PhotoModeSession', function ()
    --DPrint('PhotoModeSession OnDestroy')
    Globals.DummyNameMap = nil
    Globals.DummyNames = nil
    visTemComob.Options = {'Not in Photo Mode'}
    visTemComob.SelectedIndex = 0
    UpdateCharacterInfo(nil)
end)



-- Ext.Entity.OnCreate('Effect', function (entity)
--     if entity.Effect then
--         Helpers.Timer:OnTicks(10, function ()
--             D(entity.Effect.EffectName)  
--         end)
--     end
-- end)
