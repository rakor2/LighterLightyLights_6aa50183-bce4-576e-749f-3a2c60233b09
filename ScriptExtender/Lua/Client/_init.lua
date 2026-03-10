Ext.Require('Shared/LibLib/Style.lua')
Ext.Require('Client/Main/_init.lua')



if Mods.Mazzle_Docs then
    Utils:StripPrefixes(Mods.LL2, Mods.Mazzle_Docs) --it's joever, my mod is Mazzled
    Ext.Require('Client/ManualManual/_init.lua')
end