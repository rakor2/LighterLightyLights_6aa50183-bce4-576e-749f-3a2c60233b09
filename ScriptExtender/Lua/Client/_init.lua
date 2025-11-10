Ext.Require('Shared/LibLib/Style.lua')
Ext.Require('Client/UI/_init.lua')
Ext.Require('Client/Main/_init.lua')
if Mods.Mazzle_Docs then
    setmetatable(Mods.LL2, { __index = Mods.Mazzle_Docs }) --it's joever, my mod is Mazzled
    Ext.Require('Client/ManualManual/_init.lua')
end

