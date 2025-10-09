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
                                                                                       

Channels.OriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'OriginPoint')


Channels.StickToCamera = Ext.Net.CreateChannel(ModuleUUID, 'StickToCamera')

Channels.MarkerHandler = Ext.Net.CreateChannel(ModuleUUID, 'MarkerHandler')       


Channels.EntityLookAt = Ext.Net.CreateChannel(ModuleUUID, 'EntityLookAt') --UNUSED