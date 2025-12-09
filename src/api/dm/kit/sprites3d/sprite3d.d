module api.dm.kit.sprites3d.sprite3d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : SceneTransforms;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
import api.math.geom3.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4;
import api.math.quaternion : Quaternion;
import Math = api.math;

/**
 * Authors: initkfs
 */
class Sprite3d : Sprite2d
{
    bool isNoDrawOutOfFrustum;

    protected
    {
        PerspectiveCamera _camera;

        float _z = 0;

        align(16)
        {
            Matrix4x4 _worldMatrix;
            Matrix4x4 _worldMatrixInverse;
        }

        float _angleX = 0;
        float _angleY = 0;
    }

    bool isCalcInverseWorldMatrix = true;

    Vec3f scale = Vec3f(1, 1, 1);

    Vec3f rotatePivot;
    float rotateRadius = 1;
    bool isRotateAroundPivot;

    bool isRoundEvenZ;
    bool isRoundEvenChildZ;

    bool isPushUniformVertexMatrix;

    void delegate(float, float) onChangeZOldNew;

    float zChangeThreshold = defaultTrashold;

    bool isMatrixRecalc;

    this()
    {
        isManaged = false;
        isLayoutManaged = false;
        id = "Sprite3d";
    }

    override void create()
    {
        super.create;

        _worldMatrix = Matrix4x4.onesDiag;

        calcWorldMatrix;
    }

    override bool draw()
    {
        if (!isVisible)
        {
            return false;
        }

        bindAll;
        pushUniforms;

        if (isNoDrawOutOfFrustum && !isInCameraFrustum)
        {
            return false;
        }

        bool redraw;

        foreach (Sprite2d obj; children)
        {
            if (!obj.isDrawByParent)
            {
                continue;
            }

            if (!obj.isDrawAfterParent && obj.isVisible)
            {
                obj.draw;
            }
        }

        if (isRedraw)
        {
            drawContent;
            redraw = true;
        }

        foreach (Sprite2d obj; children)
        {
            if (!obj.isDrawByParent)
            {
                continue;
            }

            if (obj.isDrawAfterParent && obj.isVisible)
            {
                obj.draw;
            }
        }

        return redraw;
    }

    bool isInCameraFrustum() => true;

    override void add(Sprite2d object, long index = -1)
    {
        super.add(object, index);

        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                if (!_camera)
                {
                    import std.format : format;

                    throw new Exception(format("Camera in parent sprite must not be null: %s", toString));
                }
                sprite3d.camera = _camera;
            }
        }
    }

    override void addCreate(Sprite2d object, long index = -1)
    {
        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                if (!_camera)
                {
                    import std.format : format;

                    throw new Exception(format("Camera in parent sprite must not be null: %s", toString));
                }
                sprite3d.camera = _camera;
            }
        }

        super.addCreate(object, index);
    }

    void pushUniforms()
    {
        foreach (child; children)
        {
            if (auto sprite3d = cast(Sprite3d) child)
            {
                sprite3d.pushUniforms;
            }
        }

        if (isPushUniformVertexMatrix)
        {
            SceneTransforms transforms;
            transforms.world = worldMatrix;
            transforms.camera = camera.view;
            transforms.projection = camera.projection;
            transforms.normal = worldMatrixInverse;

            gpu.dev.pushUniformVertexData(0, &transforms, SceneTransforms.sizeof);
        }
    }

    void calcWorldMatrix()
    {
        _worldMatrix = _worldMatrix.identity;

        //Scale -> Rotate -> Translate
        import api.math.matrices.affine3;

        _worldMatrix = _worldMatrix.mul(scaleMatrix(scale));

        if (isRotateAroundPivot)
        {
            _worldMatrix = _worldMatrix.mul(translateMatrix(rotateRadius, 0, 0));
        }

        if (angleY != 0 || angleX != 0 || angle != 0)
        {
            Quaternion rotation = Quaternion.fromEuler(angleX, angleY, angle);
            _worldMatrix = _worldMatrix.mul(rotation.toMatrix4x4LH);
        }

        //TODO all set to 0, pos = 0
        if (!isRotateAroundPivot)
        {
            if (x != 0 || y != 0 || z != 0)
            {
                _worldMatrix = _worldMatrix.mul(translateMatrix(Vec3f(x, y, z)));
            }
        }
        else
        {
            _worldMatrix = _worldMatrix.mul(translateMatrix(rotatePivot));
        }

        if (isCalcInverseWorldMatrix)
        {
            //left right block for row-order matrix
            import api.math.matrices.decompose.lup : decompose, invert;

            _worldMatrixInverse = Matrix4x4.onesDiag;

            //TODO more optimal
            _worldMatrixInverse.eachRowRef((ri, ref scope float[4] row) {

                if (ri >= 3)
                {
                    return false;
                }

                row[0 .. 3] = _worldMatrix[ri][0 .. 3];

                return true;
            });

            auto decomposeModel = decompose!(_worldMatrix.Type, 4, 4)(_worldMatrix);
            _worldMatrixInverse = invert(decomposeModel);
        }

        isMatrixRecalc = false;
    }

    ref Matrix4x4 worldMatrix()
    {
        if (isMatrixRecalc)
        {
            calcWorldMatrix;
            isMatrixRecalc = false;
        }

        return _worldMatrix;
    }

    ref Matrix4x4 worldMatrixInverse() => _worldMatrixInverse;

    Vec3f translatePos()
    {
        if (!isRotateAroundPivot)
        {
            return Vec3f(x, y, z);
        }

        //TODO all axis
        Vec3f local = Vec3f(rotateRadius, 0, 0);
        Vec3f rotatedOffset = local.rotateAroundAxis(Vec3f(0, 1, 0), -angle);
        Vec3f worldPos = rotatePivot.add(rotatedOffset);
        return worldPos;
    }

    override float x() @safe pure nothrow => super.x;

    override bool x(float newX)
    {
        if (super.x(newX))
        {
            isMatrixRecalc = true;
            return true;
        }

        return false;
    }

    override float y() @safe pure nothrow => super.y;

    override bool y(float newY)
    {
        if (super.y(newY))
        {
            isMatrixRecalc = true;
            return true;
        }
        return false;
    }

    float z() @safe pure nothrow => _z;

    bool z(float newZ)
    {
        if (isRoundEvenZ)
        {
            newZ = Math.roundEven(newZ);
        }

        if (!Math.greater(_z, newZ, zChangeThreshold))
        {
            return false;
        }

        foreach (Sprite2d child; children)
        {
            if (child.isManaged)
            {
                if (auto castchild3d = cast(Sprite3d) child)
                {
                    float dz = newZ - _z;
                    float newChildZ = castchild3d.z + dz;
                    castchild3d.z = !isRoundEvenChildZ ? newChildZ : Math.roundEven(newChildZ);
                }

            }
        }

        if (isCreated && onChangeZOldNew)
        {
            onChangeZOldNew(_z, newZ);
        }

        _z = newZ;

        if (!isInvalidationProcess)
        {
            setInvalid;
            invalidationState.z = true;
        }

        return true;
    }

    override bool angle(float value)
    {
        if (super.angle(value))
        {
            isMatrixRecalc = true;
            return true;
        }
        return false;
    }

    override float angle() => _angle;

    void uploadStart()
    {
        foreach (child; children)
        {
            if (auto sprite3d = cast(Sprite3d) child)
            {
                sprite3d.uploadStart;
            }
        }
    }

    void uploadEnd()
    {
        foreach (child; children)
        {
            if (auto sprite3d = cast(Sprite3d) child)
            {
                sprite3d.uploadEnd;
            }
        }
    }

    void bindAll()
    {
        foreach (sprite; children)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.bindAll;
            }
        }
    }

    void camera(PerspectiveCamera newCamera)
    {
        if (!newCamera)
        {
            throw new Exception("New camera must not be null.");
        }
        _camera = newCamera;
    }

    PerspectiveCamera camera()
    {
        assert(_camera, "Camera must not be null");
        return _camera;
    }

    bool hasCamera() => _camera !is null;

    float angleX() => _angleX;
    float angleY() => _angleY;

    bool angleX(float v)
    {

        if (_angleX == v)
        {
            return false;
        }

        _angleX = v;
        isMatrixRecalc = true;
        return true;
    }

    bool angleY(float v)
    {
        if (_angleY == v)
        {
            return false;
        }

        _angleY = v;
        isMatrixRecalc = true;
        return true;
    }

    Vec3f pos3() @safe pure nothrow => Vec3f(_x, _y, _z);

    bool pos(Vec3f newPos) => pos(newPos.x, newPos.y, newPos.z);

    bool pos(float newX, float newY, float newZ)
    {
        bool isChangePos;
        isChangePos |= super.pos(newX, newY);
        isChangePos |= (z = newZ);
        return isChangePos;
    }

}
