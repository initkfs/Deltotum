module api.subs.ele.components.elements.passives.capacitor;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

import api.subs.ele.components.elements.base_two_pin_element : BaseTwoPinElement;
import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 * i = C * dv/dt
 * dv/dt ≈ (vₙ - vₙ₋₁) / Δt
 * iₙ = C * (vₙ - vₙ₋₁) / Δt
 * iₙ = (C / Δt) * vₙ - (C / Δt) * vₙ₋₁
 * iₙ = g_eff * vₙ + i_eff
 */

class Capacitor : BaseTwoPinElement
{
    double capacitance = 0;
    double prevVoltage = 0;
    double current = 0;

    double eqvVoltage = 0;

    this(double capMf, string label = "С1", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
        this.capacitance = capMf / 1_000_000;
    }

    override void update(double dt)
    {
        //TODO dt < R * C
        super.update(dt);

        double voltageDiff = eqvVoltage == 0 ? p.pin.voltage - n.pin.voltage : eqvVoltage;
        //i_curr = C * (v_curr - v_prev) / dt
        current = capacitance * (voltageDiff - prevVoltage) / dt;

        p.pin.current(current, 0);
        n.pin.current(0, current);

        if(current > 0){
            import std: writeln;
            writeln("C: ", current, " ", voltageDiff, " ", dt, " pp: ", p.pin.voltage, "  nn: ", n.pin.voltage);
        }

        prevVoltage = voltageDiff;

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

                ctx.moveTo(-width / 2, padding);
                ctx.lineTo(width / 2, padding);

                ctx.moveTo(0, padding);
                ctx.lineTo(0, height / 2);

                ctx.stroke;
            }
        };

        return shape;
    }

    override string formatTooltip()
    {
        import std.format : format;

        string text = super.formatTooltip;
        // text ~= format("\neqR=%0.2f(Om),eqV=%0.2fV\ndU=%0.2fV", eqvResistance, eqvVoltage, dU);
        return text;
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s: %.2f Ω | I=%s A", label.text, capacitance, p.pin);
    }

}
