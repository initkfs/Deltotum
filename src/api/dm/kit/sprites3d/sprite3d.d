module api.dm.kit.sprites3d.sprite3d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.math.geom2.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4f;
import Math = api.math;

/**
 * Authors: initkfs
 */
class Sprite3d : Sprite2d
{
    protected
    {
        double _z = 0;

        align(16)
        {
            Matrix4x4f _worldMatrix;
            Matrix4x4f _worldMatrixInverse;
        }
    }

    bool isCalcInverseWorldMatrix = true;

    Vec3f rotation;
    Vec3f scale = Vec3f(1, 1, 1);

    Vec3f rotatePivot;
    float rotateRadius = 1;
    bool isRotateAroundPivot;

    bool isRoundEvenZ;
    bool isRoundEvenChildZ;

    void delegate(double, double) onChangeZOldNew;

    double zChangeThreshold = defaultTrashold;

    bool isMatrixRecalc;

    this()
    {
        isManaged = false;
        isLayoutManaged = false;
    }

    override void create()
    {
        super.create;

        _worldMatrix = Matrix4x4f.onesDiag;

        calcWorldMatrix;
    }

    protected void calcWorldMatrix()
    {
        _worldMatrix = _worldMatrix.identity;

        //Scale -> Rotate -> Translate
        import api.math.matrices.affine3;

        _worldMatrix = _worldMatrix.mul(scaleMatrix(scale));

        if (isRotateAroundPivot)
        {
            _worldMatrix = _worldMatrix.mul(translateMatrix(rotateRadius, 0, 0));
        }

        if ((rotation.x != 0) || (rotation.y != 0) || (rotation.z != 0))
        {
            _worldMatrix = _worldMatrix.mul(rotateMatrix(angle, rotation));
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

            _worldMatrixInverse = Matrix4x4f.onesDiag;

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
    }

    ref Matrix4x4f worldMatrix()
    {
        if (isMatrixRecalc)
        {
            calcWorldMatrix;
            isMatrixRecalc = false;
        }

        return _worldMatrix;
    }

    ref Matrix4x4f worldMatrixInverse()
    {
        return _worldMatrixInverse;
    }

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

    override double x() @safe pure nothrow => super.x;

    override bool x(double newX)
    {
        if (super.x(newX))
        {
            isMatrixRecalc = true;
            return true;
        }

        return false;
    }

    override double y() @safe pure nothrow => super.y;

    override bool y(double newY)
    {
        if (super.y(newY))
        {
            isMatrixRecalc = true;
            return true;
        }
        return false;
    }

    double z() @safe pure nothrow => _z;

    bool z(double newZ)
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
                    double dz = newZ - _z;
                    double newChildZ = castchild3d.z + dz;
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

    override bool angle(double value)
    {
        if (super.angle(value))
        {
            isMatrixRecalc = true;
            return true;
        }
        return false;
    }

    override double angle() => _angle;

}
