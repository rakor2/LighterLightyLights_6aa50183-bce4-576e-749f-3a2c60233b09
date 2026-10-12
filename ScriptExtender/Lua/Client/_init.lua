Ext.Require('Shared/LibLib/Style.lua')
Ext.Require('Client/Settings/_init.lua')
Ext.Require('Client/Main/_init.lua')
Ext.Require('Client/Anal/_init.lua')
Ext.Require('Client/Gizmo/_init.lua')
Ext.Require('Client/BoneZone/_init.lua')
Ext.Require('Client/OriginPoint/_init.lua')
Ext.Require('Client/Gobo/_init.lua')
Ext.Require('Client/PhotoMode/_init.lua')
Ext.Require('Client/Saver/_init.lua')
Ext.Require('Client/Useful/_init.lua')
Ext.Require('Client/QSAT/_init.lua')
Ext.Require('Client/BS/_init.lua')
Ext.Require('Client/ManualManual/_init.lua')



if Mods.Mazzle_Docs then
    Utils:StripPrefixes(Mods.LL2, Mods.Mazzle_Docs) --it's joever, my mod is Mazzled
    Ext.Require('Client/ManualManual/_init.lua')
end




--- RIGHT CLICK SHOULD SAVE ALL LIGHT POSITIONS
--- AND LOAD AS WELL
--- BUG WHEN CHANGING STYLES RESETS BONE ZONE COMBO