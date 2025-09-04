module api.subs.ele.components.elements.passives.ground;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;

import api.subs.ele.components.elements.base_two_pin_element: BaseTwoPinElement;
import api.math.pos2.orientation : Orientation;


/**
 * Authors: initkfs
 */
 class Ground : BaseTwoPinElement
{
    double conductance = 1e9;

    this(string label = "Gnd", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
    }

    override void create()
    {
        super.create;
        p.pin.voltage = 0;
        n.pin.voltage = 0;

        n.isVisible = false;
    }

    override void update(double dt)
    {
        super.update(dt);
        p.pin.currentOut = 0;
        n.pin.currentOut = 0;
    }

    override Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto style = createFillStyle;

        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        double w = 20;
        double h = 50;
        if (orientation == Orientation.horizontal)
        {
            import std.algorithm.mutation : swap;

            swap(w, h);
        }

        auto shape = new class VectorTexture
        {
            this()
            {
                super(w, h);
            }

            override void createTextureContent()
            {
                super.createTextureContent;

                auto ctx = canvas;
                ctx.color = style.fillColor;
                ctx.lineWidth = style.lineWidth;

                ctx.translate(width / 2, height / 2);

                ctx.moveTo(0, -height / 2);
                ctx.lineTo(0, 0);

                auto lineSize = height / 2 / 3;

                ctx.moveTo(-width / 2, 0);
                ctx.lineTo(width / 2, 0);

                ctx.moveTo(-width / 2 / 2, lineSize);
                ctx.lineTo(width / 2 / 2, lineSize);

                ctx.moveTo(-width / 2 / 4, lineSize * 2);
                ctx.lineTo(width / 2 / 4, lineSize * 2);

                ctx.stroke;
            }
        };

        return shape;
    }
}