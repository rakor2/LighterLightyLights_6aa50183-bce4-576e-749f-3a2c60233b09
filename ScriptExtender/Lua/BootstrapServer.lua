if Mods.Realm_Builder then
    setmetatable(Mods.LL2, {__index = Mods.Realm_Builder})
end



if Mods.GizmoLib then
    setmetatable(Mods.LL2, {__index = Mods.GizmoLib})
end



Ext.Require("Shared/_init.lua")
Ext.Require("Server/_init.lua")
