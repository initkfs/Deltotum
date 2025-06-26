module api.dm.addon.procedural.fractals.lshape;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vpoints_shape : VPointsShape;
import api.dm.kit.graphics.brushes.brush : Brush;
import api.math.geom2.vec2 : Vec2d;
import api.dm.addon.procedural.lsystems.lsystem_drawer : LSystemDrawer;

import std.stdio;

/**
 * Authors: initkfs
 */
class LShape : VPointsShape
{
    protected
    {
        LSystemDrawer drawer;
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
        if (!drawer)
        {
            drawer = new LSystemDrawer;
        }

        drawer.onLineStartEnd = (start, end) {
            Vec2d[2] pp = [start, end];
            points.insert(pp[]);
        };
    }

    void parse()
    {
        assert(drawer);
        drawer.step = step;
        drawer.angleDeg = angleDeg;
        drawer.draw(startAxiom, rules, generations);
    }

    override void createTextureContent()
    {
        parse;
        super.createTextureContent;
    }
}
