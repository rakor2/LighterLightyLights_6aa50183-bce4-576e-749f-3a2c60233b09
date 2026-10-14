local Res = {}
Res.Coverage = {}
Res.Effect = {}



function Res.RNGCover()
	local start = Ext.Timer.MonotonicTime()
	local Texs = Ext.Resource.GetAll('Texture')
	for k, v in pairs(Texs) do
		local TExture = Ext.Resource.Get(v, 'Texture')
		if TExture.SourceFile:find('CloudCoverage') then
			table.insert(Res.Coverage, TExture.Guid)
		end
	end
    DPrint('Res.RNGCover() took: %s', Ext.Timer.MonotonicTime() - start)
end



function Res.RNGEffect()
	local start = Ext.Timer.MonotonicTime()
	local Efex = Ext.Resource.GetAll('Effect')
	for k, v in pairs(Efex) do
		local Efec = Ext.Resource.Get(v, 'Effect')
		if Efec.SourceFile:find('Environment') then
			local name = GetFileNameFromPath(Efec.SourceFile)
			table.insert(Res.Effect, name)
		end
	end
    DPrint('Res.RNGEffect() took: %s', Ext.Timer.MonotonicTime() - start)
end



Res.RNGCover()
Res.RNGEffect()



return Res