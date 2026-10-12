function CameraSaveLoadPosition(index)
    local CameraPositions = CameraPositions or {}

    if not _GLL.States.inPhotoMode then return end
    local pmCamera = Camera:GetPhotoModeCamera()
    local activeCam = Camera:GetActiveCamera()

    if pmCamera then
        CameraPositions[tostring(index)] = Ext.Types.Serialize(activeCam.Transform.Transform)
        -- {
        --     Translate = activeCam.Transform.Transform.Translate,
        --     RotationQuat = activeCam.Transform.Transform.RotationQuat,
        --     Scale = activeCam.Transform.Transform.Scale,
        -- }
    end
    return CameraPositions
end



local btnCounter = 0
local savedButtons = {}

function CreateSelectableForSavedCameraPos()
    if not _GLL.States.inPhotoMode then return end

    btnCounter = btnCounter + 1
    local currentIndex = btnCounter
    local size = 0

    local CameraPositions = CameraSaveLoadPosition(currentIndex)

    E.windowLoadPos.Size = {
        E.windowLoadPos.Size[1],
        E.windowLoadPos.Size[2] + size
    }

    local btnDelete = E.windowLoadPos:AddButton('X')
        UI:Config(btnDelete, {IDContext = 'delete_' .. currentIndex})

    local btnLoad = E.windowLoadPos:AddButton('')
        UI:Config(btnLoad, {
            IDContext = 'load_' .. currentIndex,
            SameLine  = true,
            Label     = tostring(currentIndex)
        })

    savedButtons[currentIndex] = {
        load   = btnLoad,
        delete = btnDelete
    }

    btnDelete.OnClick = function()
        if savedButtons[currentIndex] then
            savedButtons[currentIndex].load:Destroy()
            savedButtons[currentIndex].delete:Destroy()
            savedButtons[currentIndex] = nil
            CameraPositions[tostring(currentIndex)] = nil

            E.windowLoadPos.Size = {
                E.windowLoadPos.Size[1],
                E.windowLoadPos.Size[2] - size
            }
        end
    end

    btnLoad.OnClick = function()
        local index = tostring(currentIndex)
        if CameraPositions[index] then
            local Camera = Camera:GetActiveCamera()
            Ext.Types.Unserialize(Camera.PhotoModeCameraSavedTransform.Transform, CameraPositions[index])
            -- Camera.PhotoModeCameraSavedTransform.Transform.Translate    = CameraPositions[index].Translate
            -- Camera.PhotoModeCameraSavedTransform.Transform.RotationQuat = CameraPositions[index].RotationQuat
            -- Camera.PhotoModeCameraSavedTransform.Transform.Scale        = CameraPositions[index].Scale

            Helpers.Timer:OnTicks(5, function()
                Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.RecallCameraTransform:Execute()
            end)
        end
    end
end



function CameraControlls(type, value)
    local camera = Camera:GetActiveCamera()

    if camera then
        if type == 'FarPlane' then
            camera.Camera.Controller.FarPlane = value
        else --- type == 'NearPlane'
            camera.Camera.Controller.NearPlane = value
        end
    end
end
