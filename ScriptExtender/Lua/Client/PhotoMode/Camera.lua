function CameraSaveLoadPosition(index)
    local CameraPositions = CameraPositions or {}
    local CameraXd = CameraXd or {}

    if not _GLL.States.inPhotoMode then return end
    local PmCamera = Camera:GetPhotoModeCamera()
    local ActiveCam = Camera:GetActiveCamera()

    if PmCamera then
        CameraPositions[tostring(index)] = Ext.Types.Serialize(ActiveCam.Transform.Transform)
        cameraFov = ActiveCam.Camera.Controller.FOV

        -- {
        --     Translate = activeCam.Transform.Transform.Translate,
        --     RotationQuat = activeCam.Transform.Transform.RotationQuat,
        --     Scale = activeCam.Transform.Transform.Scale,
        -- }
    end
    return CameraPositions, cameraFov
end



local btnCounter = 0
local savedButtons = {}

function CreateSelectableForSavedCameraPos()
    if not _GLL.States.inPhotoMode then return end

    btnCounter = btnCounter + 1
    local currentIndex = btnCounter
    local size = 0

    local CameraPositions, cameraFov = CameraSaveLoadPosition(currentIndex)

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
            local ActiveCamera = Camera:GetActiveCamera()
            local PmCamera = Camera:GetPhotoModeCamera()
            local Translate = CameraPositions[index].Translate
            local RotationQuat = CameraPositions[index].RotationQuat

            Ext.Types.Unserialize(ActiveCamera.PhotoModeCameraSavedTransform.Transform, CameraPositions[index])

            OnTicks(5, function()
                -- local Rotation = Helpers.Math.QuatToEuler(RotationQuat)
                -- DDump(CameraXd)
                -- Ext.System.PhotoModeMovementSystem:UpdateCameraController(ActiveCamera.Camera, CameraXd[index].LookAt, CameraXd[index].field_58)
                -- Ext.System.PhotoModeMovementSystem.field_30 = 1
                -- Ext.UI.Defer(function ()
                -- ActiveCamera.Camera.Controller.FOV = cameraFov
                E.camFov.Value = {cameraFov, 0,0,0}

                Ext.UI.Defer(function ()
                    Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.FieldOfView = cameraFov
                end)

                Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.RecallCameraTransform:Execute()
                -- end)
            end)
        end
    end
end



function CameraControlls(type, value)
    local camera = Camera:GetActiveCamera()

    if camera then
        if type == 'FarPlane' then
            camera.Camera.Controller.FarPlane = value
        elseif type == 'NearPlane' then
            camera.Camera.Controller.NearPlane = value
        elseif type == 'FOV' then
            Ext.UI.Defer(function ()
                Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.FieldOfView = value
            end)
        end
    end
end
