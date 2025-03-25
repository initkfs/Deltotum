module api.math.lsystems.lsystem_drawer;

import api.dm.kit.graphics.brushes.brush : Brush;
import api.math.lsystems.lsystem_parser : LSystemParser;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class LSystemDrawer
{

    LSystemParser lparser;
    Brush brush;

    double step = 2;
    double angleDeg = 90;
    dstring startAxiom = "X";
    dstring[dchar] rules;
    size_t generations = 10;

    bool isDrawFromCenter;
    bool isClosePath;

    void delegate(Vec2d, Vec2d) onLineStartEnd;

    this(dstring[dchar] rules = null, bool isClosePath = false, bool isDrawFromCenter = true)
    {
        this.rules = rules;
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
    }

    void create()
    {
        if (!lparser)
        {
            lparser = new LSystemParser;
        }

        if (!brush)
        {
            brush = new Brush(Vec2d(0, 0));
            brush.onDrawLineStartEnd = (start, end) {
                if (onLineStartEnd)
                {
                    onLineStartEnd(start, end);
                }
            };

            lparser.onMoveDraw = () { brush.moveDraw(step); };
            lparser.onMove = () { brush.move(step); };
            lparser.onSaveState = () => brush.saveState;
            lparser.onRestoreState = () => brush.restoreState;
            lparser.onRotateLeft = () => brush.rotateLeft(angleDeg);
            lparser.onRotateRight = () => brush.rotateRight(angleDeg);
        }
    }

    void draw()
    {
        assert(lparser);
        lparser.parse(startAxiom, rules, generations);
    }

}
