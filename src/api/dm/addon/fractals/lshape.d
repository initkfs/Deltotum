module api.dm.addon.fractals.lshape;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vpoints_shape : VPointsShape;
import api.dm.kit.graphics.brushes.brush : Brush;
import api.math.geom2.vec2 : Vec2d;
import api.dm.addon.fractals.lsystems.lsystem_parser : LSystemParser;

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
            brush = new Brush(Vec2d(0, 0));
            brush.onDrawLineStartEnd = (start, end) {
                Vec2d[2] pp = [start, end];
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
