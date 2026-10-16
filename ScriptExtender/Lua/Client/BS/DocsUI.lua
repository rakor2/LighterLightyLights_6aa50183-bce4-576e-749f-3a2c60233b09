function Docs2Tab(p)
    p:AddText([[For the documentation download MazzleDocs
and place it above Lighty Lights in your load order.
Then you can acces it by opening MazzleDocs' UI]])


end



function Todo2App(p)
    p:AddSeparatorText('Todo app')

    local n = p:AddInputText('Patreon (copy me)')
    n.Text = 'patreon.com/cw/rakor1'
    n.ReadOnly = true

    local b = p:AddCheckbox('Add patreon link')
    b.Checked = true

    local x = p:AddCheckbox('Add effects and texture browsers')
    x.Checked = false

    local xd = p:AddCheckbox('Crowd remover seems broken I think')
    xd.Checked = false

    local y = p:AddCheckbox('Add Scene saver')
    y.Checked = false

    local z = p:AddCheckbox('Love Dani for ever!')
    z.Checked = true
    z.Disabled = true

    local ddytdx = p:AddCheckbox('Add Symmetry indicator for zone bone')
    ddytdx.Checked = false

    local yty = p:AddCheckbox('Add more surfaces to remove, not only blood')
    yty.Checked = false

    local ytd = p:AddCheckbox('Add gizmo to lights')
    ytd.Checked = false

    local ytdd = p:AddCheckbox('Add gizmo to origin point')
    ytdd.Checked = false

    local yt = p:AddCheckbox('Add gizmo to bones')
    yt.Checked = false

    local ytx = p:AddCheckbox('Add "timeline" to QSAT')
    ytx.Checked = false

    local dytdx = p:AddCheckbox('Make gobos less annoying to use and make them invisible')
    dytdx.Checked = false

    local ytdx = p:AddCheckbox('Rename AnL2 to AnL')
    ytdx.Checked = false

    local ytddx = p:AddCheckbox('Be a bigger person')
    ytddx.Checked = false
end