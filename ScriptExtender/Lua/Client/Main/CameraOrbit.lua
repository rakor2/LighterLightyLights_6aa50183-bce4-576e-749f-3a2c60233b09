
--- Just a curiosity, a slop, using RingoIp/Realm Builder raycast and math
--- Enter photo mode, hold shift, hold middle mouse, rotate the camera

Vector = {}
Vec3 = {}
Vec4 = {}
Vec2 = {}

AxisIndexMap = { X = 1, Y = 2, Z = 3, W = 4, x = 1, y = 2, z = 3, w = 4 }
IndexAxisMap = { [1] = "X", [2] = "Y", [3] = "Z", [4] = "W" }


Vector.__index = Vector
function Vector.__add(a, b) return Vector.new(Ext.Math.Add(a, b)) end
function Vector.__sub(a, b) return Vector.new(Ext.Math.Sub(a, b)) end
function Vector.__mul(a, b) return Vector.new(Ext.Math.Mul(a, b)) end
function Vector.__div(a, b) return Vector.new(Ext.Math.Div(a, b)) end
function Vector.__unm(a) return Vector.new(Ext.Math.Mul(a, -1)) end
function Vector.__eq(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do if a[i] ~= b[i] then return false end end
    return true
end
function Vector.__tostring(a) return string.format("Vec(%s)", table.concat(a, ", ")) end
function Vector:Length() return Ext.Math.Length(self) end
function Vector:Normalize() return Vector.new(Ext.Math.Normalize(self)) end
function Vector:Dot(b) return Ext.Math.Dot(self, b) end
function Vector:Cross(b) return Vector.new(Ext.Math.Cross(self, b)) end
function Vector:Inverse() return Vector.new(Ext.Math.Inverse(self)) end
function Vector:IsSanitized(limit)
    limit = limit or 1e5
    for i = 1, #self do
        local v = self[i]
        if Ext.Math.IsNaN(v) or Ext.Math.IsInf(v) or math.abs(v) > limit then return false end
    end
    return true
end
function Vector:Sanitize(defaultVec, limit)
    limit = limit or 1e5
    defaultVec = Vector.new(defaultVec or { 0, 0, 0 }, #self)
    for i = 1, #self do
        local v = self[i]
        if Ext.Math.IsNaN(v) or Ext.Math.IsInf(v) or math.abs(v) > limit then self[i] = defaultVec[i] end
    end
    return self
end

Vec2.__index = Vec2
function Vec2.__add(a, b) return Vector.new(Ext.Math.Add(a, b)) end
function Vec2.__sub(a, b) return Vector.new(Ext.Math.Sub(a, b)) end
function Vec2.__mul(a, b) return Vector.new(Ext.Math.Mul(a, b)) end
function Vec2.__div(a, b) return Vector.new(Ext.Math.Div(a, b)) end
function Vec2.__unm(a) local r = {} for i=1,#a do r[i]=-a[i] end return Vector.new(r) end
function Vec2.__tostring(a) return string.format("Vec2(%s)", table.concat(a, ", ")) end

function Vector.new(tbl, dim)
    dim = dim or #tbl
    for i = 1, dim do tbl[i] = tbl[i] or 0 end
    for i = dim + 1, #tbl do tbl[i] = nil end
    if dim == 2 then return setmetatable(tbl, Vec2) end
    return setmetatable(tbl, Vector)
end
function Vec3.new(...)
    local args = {...}
    local tbl = (#args == 1 and type(args[1]) == "table") and args[1] or args
    return Vector.new(tbl, 3)
end
function Vec4.new(...)
    local args = {...}
    local tbl = (#args == 1 and type(args[1]) == "table") and args[1] or args
    return Vector.new(tbl, 4)
end
function Vec2.new(...)
    local args = {...}
    local tbl = (#args == 1 and type(args[1]) == "table") and args[1] or args
    return setmetatable(Vector.new(tbl, 2), Vec2)
end


Quat = Quat or {}
Quat.__index = Quat
Quat.__mul = function(a, b)
    if type(b) == "table" and #b == 4 then return Quat.new(Ext.Math.QuatMul(a, b))
    elseif type(b) == "table" and #b == 3 then return Vec3.new(Ext.Math.QuatRotate(a, b))
    else return Quat.Identity() end
end
Quat.__tostring = function(a) return string.format("Quat(%s)", table.concat(a, ", ")) end
function Quat.Identity() return Quat.new(0, 0, 0, 1) end
function Quat:Inverse() return Quat.new(Ext.Math.QuatInverse(self)) end
function Quat:Normalize() return Quat.new(Ext.Math.QuatNormalize(self)) end
function Quat:Rotate(v) return Vec3.new(Ext.Math.QuatRotate(self, v)) end
function Quat.new(...)
    local args = {...}
    local t
    if #args == 1 then
        local v = args[1]
        if type(v) == "table" and #v == 4 then t = {v[1], v[2], v[3], v[4]} end
    elseif #args == 4 then
        t = {args[1], args[2], args[3], args[4]}
    end
    if not t then t = {0, 0, 0, 1} end
    return setmetatable(t, Quat)
end
function Quat.FromTo(fromVec, toVec)
    return Quat.new(Ext.Math.QuatFromToRotation(fromVec, toVec))
end
Quat.IsQuat = true


Matrix = {}
Matrix.__index = Matrix
function Matrix:Transpose() return Matrix.new(Ext.Math.Transpose(self)) end
function Matrix:Inverse() return Matrix.new(Ext.Math.Inverse(self)) end
function Matrix.__mul(a, b)
    if type(b) == "table" and #b == 3 then return Vec3.new(Ext.Math.Mul(a, b))
    elseif type(b) == "table" and #b == 4 then return Vec4.new(Ext.Math.Mul(a, b))
    else return Matrix.new(Ext.Math.Mul(a, b)) end
end
function Matrix.__add(a, b) return Matrix.new(Ext.Math.Add(a, b)) end
function Matrix.__sub(a, b) return Matrix.new(Ext.Math.Sub(a, b)) end
function Matrix.new(tbl) return setmetatable(tbl or {}, Matrix) end
function Matrix.Identity(num)
    num = num or 4
    local mat = {}
    for i = 1, num do for j = 1, num do table.insert(mat, i == j and 1 or 0) end end
    return Matrix.new(mat)
end


local function _ClassSimple(name)
    local cls = {}
    cls.__index = cls
    cls.__name = name
    cls.new = function(...) 
        local inst = setmetatable({}, cls)
        if inst.__init then inst:__init(...) end
        return inst
    end
    return cls
end

Hit = _ClassSimple("Hit")
function Hit:__init(position, normal, distance, target)
    self.Position = position and Vec3.new(position) or nil
    self.Normal   = normal and Vec3.new(normal) or nil
    self.Distance = distance or math.huge
    self.Target   = target
end
function Hit.None() return Hit.new(nil, nil, math.huge, nil) end
function Hit:IsCloserThan(other)
    if not other then return true end
    return self.Distance < (other.Distance or math.huge)
end


local PhysicsGroupFlags = Ext.Enums.PhysicsGroupFlags
local PhysicsType = Ext.Enums.PhysicsType

local allInclude = 0
for _, flag in pairs(PhysicsGroupFlags) do allInclude = allInclude | flag end
local allPhyType = PhysicsType.Dynamic | PhysicsType.Static

Ray = _ClassSimple("Ray")
function Ray:__init(origin, direction)
    self.Origin    = Vec3.new(origin)
    self.Direction = Vec3.new(direction):Normalize()
end
function Ray:At(t) return self.Origin + self.Direction * t end

function Ray:IntersectCloseat(dis)
    dis = dis or 1000.0
    local hit = Ext.Level.RaycastClosest(self.Origin, self:At(dis), allPhyType, allInclude, 0, 1)
    if hit and hit.Distance >= 0 then
        return Hit.new(Vec3.new(hit.Position), Vec3.new(hit.Normal), hit.Distance, hit.Shape.PhysicsObject.Entity)
    end
    return nil
end


MathUtils = MathUtils or {}
setmetatable(MathUtils, { __index = Ext.Math })

local LHCS_AXES = { X={1,0,0}, Y={0,1,0}, Z={0,0,1}, x={1,0,0}, y={0,1,0}, z={0,0,1} }
local LHCS = setmetatable({}, {
    __index = function(t, k) return LHCS_AXES[k] and Vec3.new(LHCS_AXES[k]) or nil end,
    __newindex = function() end
})
GLOBAL_COORDINATE = LHCS
EPSILON = EPSILON or 1e-6

--- @param pivot vec3
--- @param targetTransform Transform
--- @param rotationQuat quat
--- @return Transform newTransform
function MathUtils.RotateAroundPivotQuat(pivot, targetTransform, rotationQuat)
    local toTarget = Ext.Math.Sub(targetTransform.Translate, pivot)
    local rotatedOffset = Ext.Math.QuatRotate(rotationQuat, toTarget)
    local newPos = Ext.Math.Add(pivot, rotatedOffset)
    local newRotQuat = Ext.Math.QuatNormalize(Ext.Math.QuatMul(rotationQuat, targetTransform.RotationQuat))
    return {
        Translate    = { newPos[1], newPos[2], newPos[3] },
        RotationQuat = { newRotQuat[1], newRotQuat[2], newRotQuat[3], newRotQuat[4] },
    }
end


local function _ScreenToWorldRay()
    local picker = Ext.ClientUI.GetPickingHelper(1)
    if not picker then return nil end
    local screenW, screenH = 2560, 1440
    if not screenW or screenW == 0 then return nil end
    local pos = picker.WindowCursorPos
    if not pos then return nil end
    local mouseX, mouseY = pos[1], pos[2]

    local cam = Camera:GetActiveCamera()
    if not cam or not cam.Camera then return nil end
    local controller = cam.Camera.Controller
    if not controller then return nil end

    local ndcX = (2.0 * mouseX) / screenW - 1.0
    local ndcY = 1.0 - (2.0 * mouseY) / screenH
    local clipNear = { ndcX, ndcY, 1.0, 1.0 }
    local clipFar  = { ndcX, ndcY, 0.0, 1.0 }

    local invProj = controller.Camera.InvProjectionMatrix
    local invView = controller.Camera.InvViewMatrix
    local inverse = Ext.Math.Mul(invView, invProj)

    local wn4 = Ext.Math.Mul(inverse, clipNear)
    local wf4 = Ext.Math.Mul(inverse, clipFar)
    local wn = { wn4[1]/wn4[4], wn4[2]/wn4[4], wn4[3]/wn4[4] }
    local wf = { wf4[1]/wf4[4], wf4[2]/wf4[4], wf4[3]/wf4[4] }
    local dir = { wf[1]-wn[1], wf[2]-wn[2], wf[3]-wn[3] }

    local origin = Vec3.new(cam.Transform.Transform.Translate)
    return Ray.new(origin, dir)
end


local SENSITIVITY_H = 0.005
local SENSITIVITY_V = 0.005

local isOrbiting = false
local orbitPoint  = nil
local shiftHeld   = false
local lastMouseX  = nil
local lastMouseY  = nil

local function GetCursorPos()
    local picker = Ext.ClientUI.GetPickingHelper(1)
    if not picker then return nil, nil end
    local pos = picker.WindowCursorPos
    if not pos then return nil, nil end
    return pos[1], pos[2]
end

local function GetCamera() return Camera:GetActiveCamera() end

local function GetCameraTransform()
    local cam = GetCamera()
    if not cam or not cam.Transform then return nil end
    local t = cam.Transform.Transform
    return {
        Translate    = { t.Translate[1],    t.Translate[2],    t.Translate[3] },
        RotationQuat = { t.RotationQuat[1], t.RotationQuat[2], t.RotationQuat[3], t.RotationQuat[4] },
        Scale        = { 1, 1, 1 },
    }
end

local function ApplyCameraTransform(transform)
    local cam = GetCamera()
    if not cam or not cam.PhotoModeCameraSavedTransform then return end
    cam.PhotoModeCameraSavedTransform.Transform.Translate    = transform.Translate
    cam.PhotoModeCameraSavedTransform.Transform.RotationQuat = transform.RotationQuat
    cam.PhotoModeCameraSavedTransform.Transform.Scale        = { 1, 1, 1 }
    Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.RecallCameraTransform:Execute()
end

local function RaycastUnderCursor()
    local ray = _ScreenToWorldRay()
    if ray then
        local hit = ray:IntersectCloseat(1000)
        if hit and hit.Position then
            return { hit.Position[1], hit.Position[2], hit.Position[3] }
        end
    end

    local t = GetCameraTransform()
    if not t then return nil end
    local fwd = Ext.Math.QuatRotate(t.RotationQuat, {0, 0, 1})
    return Ext.Math.Add(t.Translate, Ext.Math.Mul(fwd, 10))
end

Ext.Events.KeyInput:Subscribe(function(e)
    if e.Key == "LSHIFT" or e.Key == "RSHIFT" then
        shiftHeld = (e.Event == "KeyDown")
        if not shiftHeld then
            isOrbiting = false
            orbitPoint = nil
            lastMouseX = nil
            lastMouseY = nil
        end
    end
end)

Ext.Events.MouseButtonInput:Subscribe(function(e)
    if e.Button ~= 2 then return end
    if e.Pressed and shiftHeld then
        local point = RaycastUnderCursor()
        if not point then return end
        orbitPoint = point
        isOrbiting = true
        lastMouseX, lastMouseY = GetCursorPos()
        Ext.Utils.Print(string.format("[OrbitCam] START orbitPoint=%.2f %.2f %.2f", point[1], point[2], point[3]))
        if e.CanPreventAction then e:PreventAction() end
    else
        isOrbiting = false
        orbitPoint = nil
        lastMouseX = nil
        lastMouseY = nil
    end
end)

Ext.Events.Tick:Subscribe(function()
    if not isOrbiting or not orbitPoint then return end
    if not shiftHeld then
        isOrbiting = false
        orbitPoint = nil
        return
    end

    local mx, my = GetCursorPos()
    if not mx or not my then return end

    local dx, dy = 0, 0
    if lastMouseX ~= nil then
        dx = mx - lastMouseX
        dy = my - lastMouseY
    end
    lastMouseX = mx
    lastMouseY = my

    if math.abs(dx) < 0.5 and math.abs(dy) < 0.5 then return end

    local camTransform = GetCameraTransform()
    if not camTransform then return end

    local yawQ = Ext.Math.QuatNormalize(
        Ext.Math.QuatRotateAxisAngle(Quat.Identity(), {0, 1, 0}, -dx * SENSITIVITY_H)
    )
    local rightVec = Ext.Math.QuatRotate(camTransform.RotationQuat, {1, 0, 0})
    local pitchQ = Ext.Math.QuatNormalize(
        Ext.Math.QuatRotateAxisAngle(Quat.Identity(), rightVec, -dy * SENSITIVITY_V)
    )
    local combinedQ = Ext.Math.QuatNormalize(Ext.Math.QuatMul(yawQ, pitchQ))

    local newTransform = MathUtils.RotateAroundPivotQuat(orbitPoint, camTransform, combinedQ)
    ApplyCameraTransform(newTransform)
end)