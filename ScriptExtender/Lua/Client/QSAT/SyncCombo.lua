SC = {}

function SC.SyncSelectedDummuToQSAT(SelectedIndex)
	if Mods.QSAT then
		if Mods.QSAT.Settings and Mods.QSAT.Settings.syncDummies then
			Mods.QSAT.E.comboCharacters.SelectedIndex = SelectedIndex
			if Mods.QSAT.E.comboCharacters.Options[1] then
				Mods.QSAT.CharComboOnChange(Mods.QSAT.E.comboCharacters)
			end
		end
	end
end