module api.dm.kit.sprites3d.sprite3d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : SceneTransforms;
import api.dm.kit.sprites3d.cameras.camera : Camera;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.kit.sprites3d.lightings.phongs.materials.lighting_material : LightingMaterial;
import api.math.geom3.vec3 : Vec3f;
import api.math.geom2.vec2 : Vec2f;
import api.math.matrices.matrix : Matrix4x4;
import api.math.quaternion : Quaternion;
import Math = api.math;

//TODO move to material
import api.dm.kit.graphics.colors.rgba : RGBA;

/**
 * Authors: initkfs
 */
class Sprite3d : Sprite2d
{
    bool isNoDrawOutOfFrustum;
    bool isNeedCamera = true;

    //bool isPushUniformVertexMatrix;

    protected
    {
        Camera _camera;

        float _z = 0;

        align(16)
        {
            Matrix4x4 _worldMatrix;
            Matrix4x4 _worldMatrixInverse;
        }

        float _angleX = 0;
        float _angleY = 0;
    }

    bool isManagedTransforms;

    bool isCalcInverseWorldMatrix = true;

    Vec3f _scale = Vec3f(1, 1, 1);

    Vec3f rotatePivot;
    Vec3f rotateLocalOffset;
    bool isRotateAroundPivot;
    bool isCalcPosFromRotation;

    bool isRoundEvenZ;
    bool isRoundEvenChildZ;

    Quaternion orientation = Quaternion.identity;
    bool isPermanentRotationMode;

    void delegate(float, float) onChangeZOldNew;

    float zChangeThreshold = defaultTreshold;

    bool isMatrixRecalc;

    bool isIgnoreAngleForChildX;
    bool isIgnoreAngleForChildY;

    //TODO move to materials
    RGBA albedo = RGBA.gray;
    float albedoIntensity = 1;

    LightingMaterial lightingMaterial;
    bool isCreateLightingMaterial;
    bool isShareMaterial;

    string diffuseMapPath;
    string specularMapPath;
    string normalMapPath;
    string dispMapPath;
    string aoMapPath;

    this()
    {
        //isManaged = false;
        isLayoutManaged = false;
        id = "Sprite3d";

        enum defaultTreshold = 0;

        xChangeThreshold = defaultTreshold;
        yChangeThreshold = defaultTreshold;
        widthChangeThreshold = defaultTreshold;
        heightChangeThreshold = defaultTreshold;
        zChangeThreshold = defaultTreshold;

        minWidth = 0;
        minHeight = 0;
    }

    override void create()
    {
        super.create;

        _worldMatrix = Matrix4x4.onesDiag;
        orientation = Quaternion(1.0f, Vec3f(0, 0, 0));

        calcWorldMatrix;

        if (!lightingMaterial)
        {
            if (isCreateLightingMaterial)
            {
                import api.dm.kit.sprites3d.lightings.phongs.materials.lighting_material : LightingMaterial;

                lightingMaterial = new LightingMaterial(diffuseMapPath, specularMapPath, normalMapPath, dispMapPath, aoMapPath);
                addCreate(lightingMaterial);
            }
        }
        else
        {
            addCreate(lightingMaterial);
        }
    }

    bool hasMaterial() => lightingMaterial !is null;

    void onMaterial(scope void delegate(LightingMaterial) onMaterialIfExists)
    {
        if (!lightingMaterial)
        {
            return;
        }

        onMaterialIfExists(lightingMaterial);
    }

    override bool isNeedDraw(Sprite2d sprite)
    {
        if (!super.isNeedDraw(sprite))
        {
            return false;
        }

        if (auto sprite3d = cast(Sprite3d) sprite)
        {
            if (sprite3d.isNoDrawOutOfFrustum && !sprite3d.isInCameraFrustum)
            {
                return false;
            }
        }

        return true;
    }

    bool isInCameraFrustum() => true;

    void calcWorldMatrix()
    {
        _worldMatrix = _worldMatrix.identity;

        //Scale -> Rotate -> Translate
        import api.math.matrices.affine3;

        _worldMatrix = _worldMatrix.mul(scaleMatrix(_scale));

        if (isRotateAroundPivot)
        {
            _worldMatrix = _worldMatrix.mul(translateMatrix(rotateLocalOffset));
        }

        Quaternion rotation = Quaternion.fromEuler(-angleX, -angleY, angle);

        if (!isPermanentRotationMode)
        {
            _worldMatrix = _worldMatrix.mul(rotation.normalize.toMatrix4x4RH);
        }
        else
        {
            orientation = orientation.mul(rotation).normalize;
            _worldMatrix = _worldMatrix.mul(orientation.toMatrix4x4RH);
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
            if (isCalcPosFromRotation)
            {
                auto newPos = posFromTransforms;
                super.x(newPos.x);
                super.y(newPos.y);
                z(newPos.z, false);
            }
        }

        if (parent && isManagedTransforms)
        {
            if (auto sprite3d = cast(Sprite3d) parent)
            {
                _worldMatrix = sprite3d.worldMatrix.mul(_worldMatrix);
            }
        }

        if (isCalcInverseWorldMatrix)
        {
            //left right block for row-order matrix
            import api.math.matrices.matrix : inverse;

            _worldMatrixInverse = Matrix4x4.onesDiag;

            //TODO more optimal, cache
            _worldMatrixInverse.eachRowRef((ri, ref scope float[4] row) {

                if (ri >= 3)
                {
                    return false;
                }

                //TODO row[3], xyz transforms
                row[0 .. 3] = _worldMatrix[ri][0 .. 3];

                return true;
            });

            bool isResult;

            Matrix4x4 result = inverse(_worldMatrixInverse, isResult);
            if (isResult)
            {
                _worldMatrixInverse = result;
            }
            else
            {
                logger.error("Inverse fail on matrix: ", _worldMatrixInverse.toString);
            }

            if (parent && isManagedTransforms)
            {
                if (auto sprite3d = cast(Sprite3d) parent)
                {
                    _worldMatrixInverse = sprite3d.worldMatrixInverse.mul(_worldMatrixInverse);
                }
            }
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

    ref Matrix4x4 worldMatrixInverse()
    {
        return _worldMatrixInverse;
    }

    Vec3f posFromTransforms() => Vec3f(_worldMatrix[3][0], _worldMatrix[3][1], _worldMatrix[3][2]);

    Vec3f translatePos()
    {
        if (!isRotateAroundPivot)
        {
            return Vec3f(x, y, z);
        }

        //TODO all axis
        //Vec3f local = Vec3f(rotateRadius, 0, 0);
        //Vec3f rotatedOffset = local.rotateAroundAxis(Vec3f(0, 1, 0), -angle);
        //Vec3f worldPos = rotatePivot.add(rotatedOffset);
        //return worldPos;
        return posFromTransforms;
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

    bool z(float newZ, bool isCalcMatrix = true)
    {
        if (isRoundEvenZ)
        {
            newZ = Math.roundEven(newZ);
        }

        if (zChangeThreshold != 0 && Math.abs(_z - newZ) < zChangeThreshold)
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

        if (isCalcMatrix)
        {
            isMatrixRecalc = true;
        }

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

    void bindAll()
    {
        foreach (ch; children)
        {
            if (auto sprite3d = cast(Sprite3d) ch)
            {
                sprite3d.bindAll;
            }
        }
    }

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

    override protected bool trySetParentProps(Sprite2d sprite)
    {
        bool isSet = super.trySetParentProps(sprite);
        if (auto sprite3d = cast(Sprite3d) sprite)
        {
            if (!sprite3d.hasCamera)
            {
                if (!_camera)
                {
                    if (sprite3d.isNeedCamera && isBuildOnAdd)
                    {
                        import std.format : format;

                        throw new Exception(format("Camera in parent sprite must not be null: %s", toString));
                    }
                }
                else
                {
                    sprite3d.camera = _camera;
                    isSet |= true;
                }
            }
        }

        return isSet;
    }

    void camera(Camera newCamera)
    {
        if (!newCamera)
        {
            throw new Exception("New camera must not be null.");
        }
        _camera = newCamera;
    }

    Camera camera()
    {
        assert(_camera, "Camera must not be null");
        return _camera;
    }

    bool hasCamera() => _camera !is null;

    float angleX() => _angleX;
    float angleY() => _angleY;
    alias angleZ = angle;

    bool angleX(float v)
    {
        if (_angleX == v)
        {
            return false;
        }

        _angleX = v;
        isMatrixRecalc = true;

        if (isAngleForChild)
        {
            foreach (ch; children)
            {
                if (auto sprite3d = cast(Sprite3d) ch)
                {
                    if (!sprite3d.isIgnoreAngleForChildX)
                    {
                        sprite3d.angleX = v;
                    }
                }
            }
        }

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

        if (isAngleForChild)
        {
            foreach (ch; children)
            {
                if (auto sprite3d = cast(Sprite3d) ch)
                {
                    if (!sprite3d.isIgnoreAngleForChildY)
                    {
                        sprite3d.angleY = v;
                    }
                }
            }
        }

        return true;
    }

    float scaleX() => _scale.x;
    void scaleX(float v)
    {
        _scale.x = v;
        isMatrixRecalc = true;
    }

    float scaleY() => _scale.y;
    void scaleY(float v)
    {
        _scale.y = v;
        isMatrixRecalc = true;
    }

    float scaleZ() => _scale.z;
    void scaleZ(float v)
    {
        _scale.z = v;
        isMatrixRecalc = true;
    }

    void scale(Vec3f vec)
    {
        _scale = vec;
        isMatrixRecalc = true;
    }

    void scale(float x, float y, float z)
    {
        _scale = Vec3f(x, y, z);
        isMatrixRecalc = true;
    }

    alias pos = typeof(super).pos;

    Vec3f pos3() @safe pure nothrow => Vec3f(_x, _y, _z);
    bool pos3(Vec3f p) => pos(p);
    bool pos3(float newX, float newY, float newZ) => pos(newX, newY, newZ);

    bool pos(Vec3f newPos) => pos(newPos.x, newPos.y, newPos.z);

    bool pos(float newX, float newY, float newZ)
    {
        bool isChangePos;
        isChangePos |= super.pos(newX, newY);
        isChangePos |= (z = newZ);
        return isChangePos;
    }

    override bool toCenterX(bool isUseParent = false)
    {
        float fullWidth = (isUseParent && parent) ? parent.width : 0;
        auto middleX = fullWidth / 2;
        return x = middleX;
    }

    override bool toCenterY(bool isUseParent = false)
    {
        float fullHeight = (isUseParent && parent) ? parent.height : 0;
        auto middleY = fullHeight / 2;
        return (y = middleY);
    }

    void rotateTowards(float targetX, float targetY, float targetZ, float smoothness = 0.1f)
    {
        import api.math.quaternion : Quaternion;

        //auto deltaQ = Quaternion.fromAngle(angularVelocity.length * dt, angularVelocity.normalize);
        //orientation = orientation.mul(deltaQ).normalize;
        Quaternion targetQ = Quaternion.fromEuler(targetX, targetY, targetZ);
        orientation = Quaternion.slerp(orientation, targetQ, smoothness);
        isMatrixRecalc = true;
    }

    Vec2f projectToScreen(Vec3f localPos = Vec3f.zero)
    {
        import api.math.geom3.vec3 : Vec3f;

        auto pm = worldMatrix.mul(scene3d.camera.view).mul(scene3d.camera.projection);

        float lx = localPos.x, ly = localPos.y, lz = localPos.z, lw = 1.0f;
        float cx = lx * pm[0][0] + ly * pm[1][0] + lz * pm[2][0] + lw * pm[3][0];
        float cy = lx * pm[0][1] + ly * pm[1][1] + lz * pm[2][1] + lw * pm[3][1];
        float cz = lx * pm[0][2] + ly * pm[1][2] + lz * pm[2][2] + lw * pm[3][2];
        float cw = lx * pm[0][3] + ly * pm[1][3] + lz * pm[2][3] + lw * pm[3][3];

        if (cw != 0.0f)
        {
            float ndcX = cx / cw;
            float ndcY = cy / cw;

            float guiX = (ndcX + 1.0f) * 0.5f * window.width;
            float guiY = (1.0f - ndcY) * 0.5f * window.height;

            return Vec2f(guiX, guiY);
        }

        return Vec2f.init;
    }

    Scene3d scene3d()
    {
        if (auto sc = cast(Scene3d) scene)
        {
            return sc;
        }

        throw new Exception("Not found 3D scene in sprite");
    }

    override void dispose()
    {
        if (lightingMaterial && isShareMaterial)
        {
            remove(lightingMaterial);
            lightingMaterial = null;
        }

        super.dispose;
    }

}
