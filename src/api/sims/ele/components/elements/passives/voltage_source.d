module api.sims.ele.components.elements.passives.voltage_source;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;

import api.sims.ele.components.elements.base_two_pin_element: BaseTwoPinElement;
import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 */

 class VoltageSource : BaseTwoPinElement
{
    double voltage = 0;

    this(double V, string label = "V1", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
        this.voltage = V;
    }

    override void update(float dt)
    {
        super.update(dt);
        p.pin.voltage = voltage;
        n.pin.voltage = 0; // Ground

        // const Rinternal = 0.1;
        // double current = p.pin.voltage / Rinternal;
        // p.pin.current(0, current);
        // n.pin.current(0, 0);
        // double I = p.current;
        // double terminalVoltage = V - current * R_internal;
        // p.voltage = terminalVoltage;
        // n.voltage = 0;
        // n.current = -p.current;
    }

    override Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto style = createFillStyle;

        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        const w = width;
        const h = height;

        auto shape = new class VectorTexture
        {
            this()
            {
                super(w, h);
            }

            import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

            override void createTextureContent(GraphicCanvas ctx)
            {
                super.createTextureContent;

                ctx.color = style.fillColor;
                ctx.lineWidth = style.lineWidth;

                const padding = height / 10;

                ctx.translate(width / 2, height / 2);

                ctx.moveTo(0, -height);
                ctx.lineTo(0, -padding);

                ctx.moveTo(-width / 2, -padding);
                ctx.lineTo(width / 2, -padding);

                ctx.moveTo(-width / 4, padding);
                ctx.lineTo(width / 4, padding);

                ctx.moveTo(0, padding);
                ctx.lineTo(0, height / 2);

                ctx.stroke;
            }
        };

        return shape;
    }

    override string toString() const
    {
        import std.format : format;

        return format("Voltage Source: %.2f V", voltage);
    }
}