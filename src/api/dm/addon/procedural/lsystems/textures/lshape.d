module api.dm.addon.procedural.lsystems.textures.lshape;

import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import api.dm.kit.sprites2d.shapes.shape2d : Shape2d;
import api.dm.kit.sprites2d.textures.vectors.shapes.vshape2d : VShape;
import api.dm.kit.graphics.brushes.brush : Brush;
import api.math.geom2.vec2 : Vec2d;
import api.dm.addon.procedural.lsystems.lsystem_drawer : LSystemDrawer;
import api.dm.addon.procedural.lsystems.lsystem: LSystemData;

import std.stdio;

/**
 * Authors: initkfs
 */
class LShape : VShape
{
    protected
    {
        LSystemDrawer drawer;
        bool _firstPoint;
        Vec2d firstPoint;
    }

    LSystemData data;

    this(double width = 100, double height = 100, GraphicStyle style = GraphicStyle
            .simple, bool isClosePath = false, bool isDrawFromCenter = true)
    {
        super(width, height, style);

        this.isDrawFromCenter = isDrawFromCenter;
        this.isClosePath = isClosePath;
    }

    override void initialize()
    {
        super.initialize;
        if (!drawer)
        {
            drawer = new LSystemDrawer;
        }

        drawer.onLineStartEnd = (start, end) {
            auto ctx = canvas;

            if (!_firstPoint)
            {
                firstPoint = start;
                ctx.moveTo(firstPoint);
                _firstPoint = true;
                return;
            }

            ctx.lineTo(start);
            ctx.lineTo(end);
        };
    }

    void parse()
    {
        assert(drawer);
        drawer.data = data;
        drawer.draw;
    }

    override void createTextureContent()
    {
        super.createTextureContent;

        parse;

        auto ctx = canvas;

        if (isClosePath)
        {
            ctx.lineTo(firstPoint);
        }

        ctx.lineWidth = style.lineWidth;
        ctx.color = style.lineColor;

        ctx.stroke;
    }
}
