module app.dm.math.affine2d;

import app.dm.math.vector2 : Vector2;

/**
 * Authors: initkfs
 */
struct Affine2d
{
    private
    {
        double m00 = 1;
        double m01 = 0;
        double m02 = 0;
        double m10 = 0;
        double m11 = 1;
        double m12 = 0;
    }

    static Affine2d identity() @nogc nothrow pure @safe
    {
        return Affine2d(1, 0, 0, 0, 1, 0);
    }

    Affine2d setTranslation(double x, double y) const @nogc nothrow pure @safe
    {
        return Affine2d(
            1, 0, x,
            0, 1, y
        );
    }

    Affine2d setScaling(double scaleX, double scaleY) const @nogc nothrow pure @safe
    {
        return Affine2d(
            scaleX, 0, 0,
            0, scaleY, 0
        );
    }

    Affine2d setRotation(double angleDeg) const @nogc nothrow pure @safe
    {
        import math = app.dm.math;

        immutable cos = math.cosDeg(angleDeg);
        immutable sin = math.sinDeg(angleDeg);

        return Affine2d(
            cos, -sin, 0,
            sin, cos, 0
        );
    }

    Affine2d setShearing(double shearX, double shearY) @nogc nothrow pure @safe
    {
        return Affine2d(
            1, shearX, 0,
            shearY, 1, 0
        );
    }

    static Affine2d valueOf(double translateX, double translateY, double angleDeg, double scaleX, double scaleY) @nogc nothrow pure @safe
    {

        if (angleDeg == 0)
        {
            return Affine2d(
                scaleX, 0, translateX,
                0, scaleX, translateY
            );
        }

        import math = app.dm.math;

        immutable sin = math.sinDeg(angleDeg);
        immutable cos = math.cosDeg(angleDeg);

        return Affine2d(
            cos * scaleX, -sin * scaleY, translateX,
            sin * scaleX, cos * scaleY, translateY
        );
    }

    static Affine2d valueOf(double translateX, double translateY, double scaleX, double scaleY) @nogc nothrow pure @safe
    {
        return Affine2d(
            scaleX, 0, translateX,
            0, scaleY, translateY
        );
    }

    Affine2d product(Affine2d l, Affine2d r) const @nogc nothrow pure @safe
    {
        immutable pm00 = l.m00 * r.m00 + l.m01 * r.m10;
        immutable pm01 = l.m00 * r.m01 + l.m01 * r.m11;
        immutable pm02 = l.m00 * r.m02 + l.m01 * r.m12 + l.m02;
        immutable pm10 = l.m10 * r.m00 + l.m11 * r.m10;
        immutable pm11 = l.m10 * r.m01 + l.m11 * r.m11;
        immutable pm12 = l.m10 * r.m02 + l.m11 * r.m12 + l.m12;
        return Affine2d(pm00, pm01, pm02, pm10, pm11, pm12);
    }

    Affine2d invert() const @nogc nothrow pure @safe
    {
        immutable matrixDet = det;
        if (matrixDet == 0)
        {
            //TODO exception, error?
        }

        double invDet = 1.0 / matrixDet;

        return Affine2d(
            m11 * invDet, -m01 * invDet, (m01 * m12 - m11 * m02) * invDet,
            -m10 * invDet, m00 * invDet, (m10 * m02 - m00 * m12) * invDet
        );
    }

    Affine2d mul(Affine2d other) const @nogc nothrow pure @safe
    {
        return Affine2d(
            m00 * other.m00 + m01 * other.m10,
            m00 * other.m01 + m01 * other.m11,
            m00 * other.m02 + m01 * other.m12 + m02,
            m10 * other.m00 + m11 * other.m10,
            m10 * other.m01 + m11 * other.m11,
            m10 * other.m02 + m11 * other.m12 + m12
        );
    }

    Affine2d translate(double x, double y) const @nogc nothrow pure @safe
    {
        return Affine2d(
            m00, m01, m02 + (m00 * x + m01 * y),
            m10, m11, m12 + (m10 * x + m11 * y)
        );
    }

    Affine2d scale(double scaleX, double scaleY) const @nogc nothrow pure @safe
    {
        return Affine2d(
            m00 * scaleX, m01 * scaleY, m02,
            m10 * scaleX, m11 * scaleY, m12
        );
    }

    Affine2d rotate(double angleDeg) const @nogc nothrow pure @safe
    {
        if (angleDeg == 0)
        {
            return Affine2d(m00, m01, m02, m10, m11, m12);
        }

        import math = app.dm.math;

        immutable cos = math.cosDeg(angleDeg);
        immutable sin = math.sinDeg(angleDeg);

        return Affine2d(
            m00 * cos + m01 * sin,
            m00 * -sin + m01 * cos,
            m02,
            m10 * cos + m11 * sin,
            m10 * -sin + m11 * cos,
            m12
        );
    }

    Affine2d shear(double shearX, double shearY) const @nogc nothrow pure @safe
    {
        return Affine2d(
            m00 + shearY * m01,
            m01 + shearX * m00,
            m02,
            m10 + shearY * m11,
            m11 + shearX * m10,
            m12
        );
    }

    double det() const @nogc nothrow pure @safe
    {
        return m00 * m11 - m01 * m10;
    }

    void getTranslation(out double x, out double y) const @nogc nothrow pure @safe
    {
        x = m02;
        y = m12;
    }

    bool isTranslation() const @nogc nothrow pure @safe
    {
        return (m00 == 1 && m01 == 0 && m10 == 0 && m11 == 1);
    }

    Vector2 transform(Vector2 point) const @nogc nothrow pure @safe
    {
        immutable newX = m00 * point.x + m01 * point.y + m02;
        immutable newY = m10 * point.x + m11 * point.y + m12;
        return Vector2(newX, newY);
    }

    string toString() const
    {
        import std.format : format;

        return format("[%s %s %s\n%s %s %s]", m00, m01, m02, m10, m11, m12);
    }
}
