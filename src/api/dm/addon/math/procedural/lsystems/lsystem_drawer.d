module api.dm.addon.procedural.lsystems.lsystem_drawer;

import api.dm.kit.graphics.brushes.brush : Brush;
import api.dm.addon.procedural.lsystems.lsystem_parser : LSystemParser;

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

    bool isDrawFromCenter;
    bool isClosePath;

    void delegate(Vec2d, Vec2d) onLineStartEnd;

    this(bool isClosePath = false, bool isDrawFromCenter = true, LSystemParser parser = null, Brush newBrush = null)
    {
        this.isClosePath = isClosePath;
        this.isDrawFromCenter = isDrawFromCenter;
        this.lparser = !parser ? new LSystemParser : parser;
        this.brush = !newBrush ? new Brush : newBrush;

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

    void draw(dstring startAxiom, dstring[dchar] rules, size_t generations)
    {
        assert(lparser);
        lparser.parse(startAxiom, rules, generations);
    }

}
