Channels = {}

Channels.SelectedLight = Ext.Net.CreateChannel(ModuleUUID, 'SelectedLight')
Channels.CreateLight = Ext.Net.CreateChannel(ModuleUUID, 'CreateLight')
Channels.DeleteLight = Ext.Net.CreateChannel(ModuleUUID, 'DeleteLight')

Channels.EntityTransform = Ext.Net.CreateChannel(ModuleUUID, 'EntityTransform') --tbd: remove Translate/Rotation
Channels.EntityTranslate = Ext.Net.CreateChannel(ModuleUUID, 'EntityTranslate')
Channels.EntityRotation = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotation')
Channels.EntityRotationOrbit = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotationOrbit')

Channels.EntityLookAt = Ext.Net.CreateChannel(ModuleUUID, 'EntityLookAt')

Channels.StickToCamera = Ext.Net.CreateChannel(ModuleUUID, 'StickToCamera')



