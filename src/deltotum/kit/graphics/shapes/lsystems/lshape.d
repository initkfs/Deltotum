module deltotum.kit.graphics.shapes.lsystems.lshape;

import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

import deltotum.kit.graphics.shapes.shape : Shape;
import deltotum.kit.graphics.shapes.vectors.vpoints_shape : VPointsShape;
import deltotum.kit.graphics.brushes.brush : Brush;
import deltotum.math.vector2d : Vector2d;
import deltotum.math.geom.fractals.lsystems.lsystem_parser : LSystemParser;

import std.stdio;

/**
 * Authors: initkfs
 */
class LShape : VPointsShape
{
    protected
    {
        LSystemParser lparser;
        Brush brush;
    }

    double step = 2;
    double angleDeg = 90;
    dstring startAxiom = "X";
    dstring[dchar] rules;
    size_t generations = 10;

    this(double width = 100, double height = 100, GraphicStyle style = GraphicStyle
            .simple, dstring[dchar] rules = null, bool isClosePath = false, bool isDrawFromCenter = true)
    {
        super(null, width, height, style, isClosePath, isDrawFromCenter);

        this.rules = rules;
    }

    override void initialize()
    {
        super.initialize;
        if (!lparser)
        {
            lparser = new LSystemParser;
        }

        if (!brush)
        {
            brush = new Brush(Vector2d(0, 0));
            brush.onDrawLineStartEnd = (start, end) {
                points ~= start;
                points ~= end;
            };

            lparser.onMoveDraw = () { brush.moveDraw(step); };
            lparser.onMove = () { brush.move(step); };
            lparser.onSaveState = () => brush.saveState;
            lparser.onRestoreState = () => brush.restoreState;
            lparser.onRotateLeft = () => brush.rotateLeft(angleDeg);
            lparser.onRotateRight = () => brush.rotateRight(angleDeg);
        }
    }

    override void createTextureContent()
    {
        lparser.parse(startAxiom, rules, generations);
        super.createTextureContent;
    }
}
