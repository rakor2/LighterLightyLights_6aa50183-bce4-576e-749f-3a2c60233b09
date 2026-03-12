Ext.Require("_Libs/_InitLibs.lua")
-- Ext.Require("Shared/_Libs.lua")
Ext.Require("Shared/_init.lua")
Ext.Require("Server/_init.lua")

if Mods.GizmoLib then
    Utils:StripPrefixes(Mods.LL2, Mods.GizmoLib)
end