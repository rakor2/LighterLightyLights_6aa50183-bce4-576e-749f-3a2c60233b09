local Channels = {
	'SelectedLight',
	'CreateLight',
	'DeleteLight',
	'DuplicateLight',

	'CurrentEntityTransform',
	'EntityTranslate',
	'EntityRotation',
	'EntityRotationOrbit',

	'SaveLoadLightPos',

	'StickToCamera',

	'MarkerHandler',

	'CreateOriginPoint',
	'DeleteOriginPoint',
	'MoveOriginPoint',
	'ToCamOriginPoint',

	'SelectedGobo',
	'CreateGobo',
	'DeleteGobo',
	'HideGobo',
	'GoboTranslate',
	'GoboRotation',

	'MazzleBeam',

	'DeleteEverything',

	'SceneSave',
	'SceneLoad',

	'GetTriggers',

	'ApplyANL',
	'ResetANL',

	'CurrentResource',

	'PlayAnimation',

	'GetDaggers',
}

for _, channel in pairs(Channels) do
	Ch[channel] = Ext.Net.CreateChannel(ModuleUUID, channel)
end




-- Ch.SelectedLight = Ext.Net.CreateChannel(ModuleUUID, 'SelectedLight')
-- Ch.CreateLight = Ext.Net.CreateChannel(ModuleUUID, 'CreateLight')
-- Ch.DeleteLight = Ext.Net.CreateChannel(ModuleUUID, 'DeleteLight')
-- Ch.DuplicateLight = Ext.Net.CreateChannel(ModuleUUID, 'DuplicateLight')

-- Ch.CurrentEntityTransform = Ext.Net.CreateChannel(ModuleUUID, 'CurrentEntityTransform')
-- Ch.EntityTranslate = Ext.Net.CreateChannel(ModuleUUID, 'EntityTranslate')
-- Ch.EntityRotation = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotation')
-- Ch.EntityRotationOrbit = Ext.Net.CreateChannel(ModuleUUID, 'EntityRotationOrbit')

-- Ch.SaveLoadLightPos = Ext.Net.CreateChannel(ModuleUUID, 'SaveLoadLightPos')

-- Ch.StickToCamera = Ext.Net.CreateChannel(ModuleUUID, 'StickToCamera')

-- Ch.MarkerHandler = Ext.Net.CreateChannel(ModuleUUID, 'MarkerHandler')

-- Ch.CreateOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'CreateOriginPoint')
-- Ch.DeleteOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'DeleteOriginPoint')
-- Ch.MoveOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'MoveOriginPoint')
-- Ch.ToCamOriginPoint = Ext.Net.CreateChannel(ModuleUUID, 'ToCamOriginPoint')

-- Ch.SelectedGobo = Ext.Net.CreateChannel(ModuleUUID, 'SelectedGobo')
-- Ch.CreateGobo = Ext.Net.CreateChannel(ModuleUUID, 'CreateGobo')
-- Ch.DeleteGobo = Ext.Net.CreateChannel(ModuleUUID, 'DeleteGobo')
-- Ch.HideGobo = Ext.Net.CreateChannel(ModuleUUID, 'HideGobo')
-- Ch.GoboTranslate = Ext.Net.CreateChannel(ModuleUUID, 'GoboTranslate')
-- Ch.GoboRotation = Ext.Net.CreateChannel(ModuleUUID, 'GoboRotation')

-- Ch.MazzleBeam = Ext.Net.CreateChannel(ModuleUUID, 'MazzleBeam')

-- Ch.DeleteEverything = Ext.Net.CreateChannel(ModuleUUID, 'DeleteEverything')

-- Ch.SceneSave = Ext.Net.CreateChannel(ModuleUUID, 'SceneSave')
-- Ch.SceneLoad = Ext.Net.CreateChannel(ModuleUUID, 'SceneLoad')

-- Ch.GetTriggers = Ext.Net.CreateChannel(ModuleUUID, 'GetTriggers')

-- Ch.ApplyANL = Ext.Net.CreateChannel(ModuleUUID, 'ApplyANL')
-- Ch.ResetANL = Ext.Net.CreateChannel(ModuleUUID, 'ResetANL')
-- Ch.CurrentResource = Ext.Net.CreateChannel(ModuleUUID, 'CurrentResource')
