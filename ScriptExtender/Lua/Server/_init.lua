Ext.Require("Server/Main/_init.lua")



function CacheLTNServer()
    Ext.Net.BroadcastMessage("ManualCache", "")
end



Ext.RegisterConsoleCommand("cacheltn", CacheLTNServer)


-- Ext.Events.GameStateChanged:Subscribe(function()
    -- local Materials = Ext.Resource.GetAll('Material')
    -- for _, v in pairs(Materials) do
    --     local mt = Ext.Resource.Get(v ,'Material')
    --     if mt.Instance then
    --         for _, y in pairs(mt.Instance.Parameters.ScalarParameters) do
    --             if y.ParameterName == 'SeeThroughEnabled' then
    --                 print(y.Value)
    --                 y.Value = 0
    --             end
    --         end
    --     end
    -- end
-- end)

-- Ext.Events.SessionLoaded:Subscribe(function()
--     local Materials = Ext.Resource.GetAll('Material')
--     for _, v in pairs(Materials) do
--         local mt = Ext.Resource.Get(v ,'Material')
--         if mt.Instance then
--             for _, y in pairs(mt.Instance.Parameters.ScalarParameters) do
--                 if y.ParameterName == 'SeeThroughEnabled' then
--                     print(y.Value)
--                     y.Value = 0
--                 end
--             end
--         end
--     end
-- end)


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    Ext.Net.BroadcastMessage("LLL_LevelStarted", "")
end)







-- _GLL.States.isLtalpInstalled = false

-- Ext.OnNextTick(function(e)
--     if Mods.LTALP then
--         DPrint('Level Triggers and Light Probes')
--         _GLL.States.isLtalpInstalled = true
--     else
--         _GLL.States.isLtalpInstalled = false
--     end
-- end)
