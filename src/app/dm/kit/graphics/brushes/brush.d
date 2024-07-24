module app.dm.kit.graphics.brushes.brush;

import app.dm.kit.graphics.colors.rgba : RGBA;
import app.dm.math.vector2 : Vector2;
import app.dm.math.rect2d : Rect2d;

import Math = app.dm.math;

import std.container.slist : SList;

private
{
    struct BrushState
    {
        Vector2 pos;
        double angleDeg = 0;
    }
}

/**
 * Authors: initkfs
 */
class Brush
{
    bool isBoundable;
    Rect2d bounds = Rect2d(0, 0, 100, 100);

    private
    {
        Vector2 _pos;
        Vector2 _initPos;

        double _angleDeg = 0;

        SList!BrushState _states;
    }

    void delegate(Vector2, Vector2) onDrawLineStartEnd;

    this(Vector2 initPos = Vector2(0, 0), double initAngleDeg = 0) pure @safe
    {
        _initPos = initPos;
        _pos = initPos;
        _angleDeg = initAngleDeg;
    }

    bool moveDraw(double distance)
    {
        const oldPos = _pos;

        move(distance);

        if (onDrawLineStartEnd)
        {
            onDrawLineStartEnd(oldPos, _pos);
        }

        return true;
    }

    bool move(double distance) @safe
    {
        const newPos = _pos + Vector2.fromPolarDeg(_angleDeg, distance);

        if (isBoundable && !bounds.contains(newPos))
        {
            return false;
        }

        _pos = newPos;

        return true;
    }

    void rotateRight(double angleDeg) @safe
    {
        _angleDeg += angleDeg;
    }

    void rotateLeft(double angleDeg) @safe
    {
        _angleDeg -= angleDeg;
    }

    void pos(double x, double y) @safe
    {
        _pos = Vector2(x, y);
    }

    void pos(Vector2 newPos) @safe
    {
        _pos = newPos;
    }

    Vector2 pos() @safe
    {
        return _pos;
    }

    void angleDeg(double value) @safe
    {
        _angleDeg = value;
    }

    double angleDeg() @safe
    {
        return _angleDeg;
    }

    void setState(Vector2 pos, double angleDeg) @safe
    {
        _pos = pos;
        _angleDeg = angleDeg;
    }

    void saveState() @safe
    {
        _states.insertFront(BrushState(_pos, angleDeg));
    }

    bool restoreState() @safe
    {
        if (_states.empty)
        {
            return false;
        }

        const lastState = _states.front;
        _states.removeFront;
        setState(lastState.pos, lastState.angleDeg);
        return true;
    }

}

unittest
{
    import app.dm.math.vector2 : Vector2;
    import app.dm.math.rect2d : Rect2d;

    const brushBounds = Rect2d(0, 0, 100, 100);
    auto brush = new Brush(Vector2(0, 0), 0);
    brush.bounds = brushBounds;

    assert(brush.move(10));
    assert(brush.pos.x == 10);
    assert(brush.pos.y == 0);

    brush.rotateRight(90);
    brush.move(10);

    assert(brush.pos.x == 10);
    assert(brush.pos.y == 10);
}
