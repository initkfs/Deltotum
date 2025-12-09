module api.dm.addon.procedural.lsystems.lsystem_drawer;

import api.dm.kit.graphics.brushes.brush : Brush;
import api.dm.addon.procedural.lsystems.lsystem_parser : LSystemParser;
import api.dm.addon.procedural.lsystems.lsystem: LSystemData;

import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
class LSystemDrawer
{
    LSystemParser lparser;
    Brush brush;

    LSystemData data;

    void delegate(Vec2f, Vec2f) onLineStartEnd;

    this(LSystemParser parser = null, Brush newBrush = null)
    {
        this.lparser = !parser ? new LSystemParser : parser;
        this.brush = !newBrush ? new Brush : newBrush;

        brush.onDrawLineStartEnd = (start, end) {
            if (onLineStartEnd)
            {
                onLineStartEnd(start, end);
            }
        };

        lparser.onMoveDraw = () { brush.moveDraw(data.step); };
        lparser.onMove = () { brush.move(data.step); };
        lparser.onSaveState = () => brush.saveState;
        lparser.onRestoreState = () => brush.restoreState;
        lparser.onRotateLeft = () => brush.rotateLeft(data.angleDeg);
        lparser.onRotateRight = () => brush.rotateRight(data.angleDeg);
    }

    void draw()
    {
        assert(lparser);
        lparser.parse(data.startAxiom, data.rules, data.generations);
    }

}
