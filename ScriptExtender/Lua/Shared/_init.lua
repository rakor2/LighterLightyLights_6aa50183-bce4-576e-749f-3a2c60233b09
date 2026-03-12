-- Ext.Require("Shared/_Libs.lua")
Ext.Require("Shared/LibLib/_init.lua")
Ext.Require("Shared/Channels.lua")
Ext.Require("Shared/Tables.lua")
Ext.Require("Shared/GUIDs.lua")
Ext.Require("Shared/ATM_Triggers.lua")
Ext.Require("Shared/LTN_Triggers.lua")
Ext.Require("Shared/ATM_Templates.lua")
Ext.Require("Shared/LTN_Templates.lua")



function _DD(fileName, entity, getAll)
	if not getAll then
		Ext.IO.SaveFile(fileName .. '.json', Ext.DumpExport(entity))
	else
		Ext.IO.SaveFile(fileName .. '.json', Ext.DumpExport(entity:GetAllComponents()))
	end
end
