module dm.addon.fractals.lshape;

import dm.kit.graphics.styles.graphic_style : GraphicStyle;

import dm.kit.sprites.shapes.shape : Shape;
import dm.kit.sprites.textures.vectors.shapes.vpoints_shape : VPointsShape;
import dm.kit.graphics.brushes.brush : Brush;
import dm.math.vector2 : Vector2;
import dm.addon.fractals.lsystems.lsystem_parser : LSystemParser;

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
            brush = new Brush(Vector2(0, 0));
            brush.onDrawLineStartEnd = (start, end) {
                Vector2[2] pp = [start, end];
                points.insert(pp[]);
            };

            lparser.onMoveDraw = () { brush.moveDraw(step); };
            lparser.onMove = () { brush.move(step); };
            lparser.onSaveState = () => brush.saveState;
            lparser.onRestoreState = () => brush.restoreState;
            lparser.onRotateLeft = () => brush.rotateLeft(angleDeg);
            lparser.onRotateRight = () => brush.rotateRight(angleDeg);
        }
    }

    void parse()
    {
        assert(lparser);
        lparser.parse(startAxiom, rules, generations);
    }

    override void createTextureContent()
    {
        parse;
        super.createTextureContent;
    }
}
