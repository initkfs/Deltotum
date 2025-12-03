module api.sims.ele.components.elements.passives.resistor;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;

import api.sims.ele.components.elements.base_two_pin_element: BaseTwoPinElement;
import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 */

class Resistor : BaseTwoPinElement
{
    double resistance = 0;
    double eqvResistance = 0;
    double eqvVoltage = 0;
    double dU = 0;

    this(double R, string label = "R1", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
        this.resistance = R;
    }

    override void update(double dt)
    {
        super.update(dt);

        //I = (Vp - Vn) / R
        double voltageDiff = eqvVoltage == 0 ? p.pin.voltage - n.pin.voltage : eqvVoltage;
        double targetR = eqvResistance == 0 ? resistance : eqvResistance;
        double current = voltageDiff / targetR;

        //Current flows into p, flows out of n (Kirchhoff's Law)
        p.pin.current(current, 0);
        n.pin.current(0, current);
        dU = current * resistance;
        n.pin.voltage = p.pin.voltage - dU;

        //p.voltage > n.voltage, p --> n
        //p.voltage < n.voltage, p <-- n
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

            import api.dm.kit.graphics.canvases.graphic_canvas : GraphicCanvas;

            override void createTextureContent(GraphicCanvas ctx)
            {
                super.createTextureContent;

                ctx.color = style.fillColor;
                ctx.lineWidth = style.lineWidth;

                const paddingPin = height / 5;

                const halfW = width / 2;
                const halfH = height / 2;
                const halfLine = style.lineWidth / 2;

                ctx.translate(width / 2, height / 2);

                ctx.moveTo(0, -halfH);
                ctx.lineTo(0, -halfH + paddingPin);

                ctx.rect(-halfW + halfLine, -halfH + paddingPin, width - halfLine * 2, height - paddingPin * 2);

                ctx.moveTo(0, halfH - paddingPin);
                ctx.lineTo(0, halfH);

                ctx.stroke;
            }
        };

        return shape;
    }

    override string formatTooltip()
    {
        import std.format : format;

        string text = super.formatTooltip;
        text ~= format("\neqR=%0.2f(Om),eqV=%0.2fV\ndU=%0.2fV", eqvResistance, eqvVoltage, dU);
        return text;
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s: %.2f Ω | I=%s A", label.text, resistance, p.pin);
    }

}
