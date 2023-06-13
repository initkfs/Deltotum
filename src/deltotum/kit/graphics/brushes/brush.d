module deltotum.kit.graphics.brushes.brush;

import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.shapes.rect2d : Rect2d;

import Math = deltotum.math;

import std.container.slist : SList;

private
{
    struct BrushState
    {
        Vector2d pos;
        double angleDeg = 0;
    }
}

/**
 * Authors: initkfs
 */
class Brush
{
    //TODO bounds
    Rect2d bounds = Rect2d(0, 0, 100, 100);

    protected
    {
        Vector2d _pos;
        Vector2d _initPos;

        double _angleDeg = 0;

        SList!BrushState _states;
    }

    void delegate(Vector2d, Vector2d) onDrawLineStartEnd;

    this(Vector2d initPos = Vector2d(0, 0), double initAngleDeg = 0)
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

    bool move(double distance)
    {
        const newPos = _pos + Vector2d.fromPolarDeg(_angleDeg, distance);

        //TODO check bounds
        _pos = newPos;

        return true;
    }

    void rotateRight(double angleDeg)
    {
        _angleDeg += angleDeg;
    }

    void rotateLeft(double angleDeg)
    {
        _angleDeg -= angleDeg;
    }

    Vector2d pos()
    {
        return _pos;
    }

    double angleDeg()
    {
        return _angleDeg;
    }

    void setState(Vector2d pos, double angleDeg)
    {
        _pos = pos;
        _angleDeg = angleDeg;
    }

    void saveState()
    {
        _states.insertFront(BrushState(_pos, angleDeg));
    }

    void restoreState()
    {
        if (_states.empty)
        {
            return;
        }

        const lastState = _states.front;
        _states.removeFront;
        setState(lastState.pos, lastState.angleDeg);
    }

}

unittest
{
    import deltotum.math.vector2d : Vector2d;
    import deltotum.math.shapes.rect2d : Rect2d;

    const brushBounds = Rect2d(0, 0, 100, 100);
    auto brush = new Brush(Vector2d(0, 0), 0);
    brush.bounds = brushBounds;

    assert(brush.move(10));
    assert(brush.pos.x == 10);
    assert(brush.pos.y == 0);

    brush.angleDeg = 90;
    brush.move(10);

    assert(brush.pos.x == 10);
    assert(brush.pos.y == 10);
}
