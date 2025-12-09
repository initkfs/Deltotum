module api.dm.kit.graphics.brushes.brush;

import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.geom2.vec2 : Vec2d;
import api.math.geom2.rect2 : Rect2d;

import Math = api.dm.math;

import std.container.slist : SList;

private
{
    struct BrushState
    {
        Vec2d pos;
        float angleDeg = 0;
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
        Vec2d _pos;
        Vec2d _initPos;

        float _angleDeg = 0;

        SList!BrushState _states;
    }

    void delegate(Vec2d, Vec2d) onDrawLineStartEnd;

    this(Vec2d initPos = Vec2d(0, 0), float initAngleDeg = 0) pure @safe
    {
        _initPos = initPos;
        _pos = initPos;
        _angleDeg = initAngleDeg;
    }

    bool moveDraw(float distance)
    {
        const oldPos = _pos;

        move(distance);

        if (onDrawLineStartEnd)
        {
            onDrawLineStartEnd(oldPos, _pos);
        }

        return true;
    }

    bool move(float distance) @safe
    {
        const newPos = _pos + Vec2d.fromPolarDeg(_angleDeg, distance);

        if (isBoundable && !bounds.contains(newPos))
        {
            return false;
        }

        _pos = newPos;

        return true;
    }

    void rotateRight(float angleDeg) @safe
    {
        _angleDeg += angleDeg;
    }

    void rotateLeft(float angleDeg) @safe
    {
        _angleDeg -= angleDeg;
    }

    void pos(float x, float y) @safe
    {
        _pos = Vec2d(x, y);
    }

    void pos(Vec2d newPos) @safe
    {
        _pos = newPos;
    }

    Vec2d pos() @safe
    {
        return _pos;
    }

    void angleDeg(float value) @safe
    {
        _angleDeg = value;
    }

    float angleDeg() @safe
    {
        return _angleDeg;
    }

    void setState(Vec2d pos, float angleDeg) @safe
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
    import api.math.geom2.vec2 : Vec2d;
    import api.math.geom2.rect2 : Rect2d;

    const brushBounds = Rect2d(0, 0, 100, 100);
    auto brush = new Brush(Vec2d(0, 0), 0);
    brush.bounds = brushBounds;

    assert(brush.move(10));
    assert(brush.pos.x == 10);
    assert(brush.pos.y == 0);

    brush.rotateRight(90);
    brush.move(10);

    assert(brush.pos.x == 10);
    assert(brush.pos.y == 10);
}
