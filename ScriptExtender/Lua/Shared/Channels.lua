Channels = {}


-- NO HIGLIGHTS
-- local ChannelsToCreate = {
--     'SelectedLight',
--     'CreateLight',
--     'DeleteLight',

--     'CurrentEntityTransform',

--     'EntityTranslate',
--     'EntityRotation',
--     'EntityRotationOrbit',
--     'StickToCamera',

--     'MarkerHandler',

--     'EntityLookAt',
-- }

-- for _, channel in ipairs(ChannelsToCreate) do
--     Channels[channel] = Ext.Net.CreateChannel(ModuleUUID, channel)
-- end
            


Channels.SelectedLight = Ext.Net.CreateChannel(ModuleUUID, 'SelectedLight')
Channels.CreateLight = Ext.Net.CreateChannel(ModuleUUID, 'CreateLight')
Channels.DeleteLight = Ext.Net.CreateChannel(ModuleUUID, 'DeleteLight')
Channels.DuplicateLight = Ext.Net.CreateChannel(ModuleUUID, 'DuplicateLight')

Channels.CurrentEntityTransform = Ext.Net.CreateChannel(ModuleUUID, 'CurrentEntityTransform')
Channels.EntityTranslate = Ext.Net.CreateChannel(ModuleUUID, 'EntityTranslate')
Channels.EntityRotation = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotation')
Channels.EntityRotationOrbit = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotationOrbit')

Channels.SaveLoadLightPos = Ext.Net.CreateChannel(ModuleUUID, 'SaveLoadLightPos')


Channels.StickToCamera = Ext.Net.CreateChannel(ModuleUUID, 'StickToCamera')

Channels.MarkerHandler = Ext.Net.CreateChannel(ModuleUUID, 'MarkerHandler')  




Channels.CreateOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'CreateOriginPoint')
Channels.DeleteOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'DeleteOriginPoint')
Channels.MoveOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'MoveOriginPoint')
Channels.ToCamOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'ToCamOriginPoint')




Channels.SelectedGobo = Ext.Net.CreateChannel(ModuleUUID, 'SelectedGobo')
Channels.CreateGobo = Ext.Net.CreateChannel(ModuleUUID, 'CreateGobo')
Channels.DeleteGobo = Ext.Net.CreateChannel(ModuleUUID, 'DeleteGobo')
Channels.GoboTranslate = Ext.Net.CreateChannel(ModuleUUID, 'GoboTranslate')
Channels.GoboRotation = Ext.Net.CreateChannel(ModuleUUID, 'GoboRotation')

Channels.MazzleBeam = Ext.Net.CreateChannel(ModuleUUID, 'MazzleBeam')


Channels.DeleteEverything = Ext.Net.CreateChannel(ModuleUUID, 'DeleteEverything')


Channels.SceneSave = Ext.Net.CreateChannel(ModuleUUID, 'SceneSave')
Channels.SceneLoad = Ext.Net.CreateChannel(ModuleUUID, 'SceneLoad')


Channels.GetTriggers = Ext.Net.CreateChannel(ModuleUUID, 'GetTriggers')

Channels.ResetANL = Ext.Net.CreateChannel(ModuleUUID, 'ResetANL')
