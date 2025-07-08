module api.subs.ele.components;

/**
 * Authors: initkfs
 */

import api.dm.gui.controls.control : Control;

abstract class Component : Control
{
    import api.dm.gui.controls.texts.text : Text;

    Text label;

    this(dstring text)
    {
        initSize(50);
        isDrawBounds = true;

        label = new Text(text);
    }

    override void create()
    {
        super.create;

        assert(label);
        addCreate(label);
    }

    override void drawContent()
    {
        super.drawContent;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.fillRect(boundsRect, RGBA.red);
    }

}

struct Pin
{
    double voltage = 0;
    double current = 0;
}

class Wire : Component
{
    Pin start, end;
    double length; //pixels
    double[] points; //normalization

    this(Pin p1, Pin p2, dstring label = "Wire")
    {
        super(label);
        start = p1;
        end = p2;
        //length = distance(p1, p2);
        points = new double[cast(size_t)(length / 10)]; // pixels
        points[] = 0;
    }

    override void update(double dt)
    {
        super.update(dt);

        //Color color = (I > 0) ? COLOR_RED : COLOR_BLUE;
        enum scale = 1.0;
        //AC if (I < 0) pos -=

        double I = start.current;
        foreach (ref pos; points)
        {
            pos += (I * dt * scale) / (length * 1e-9); // q = 1e-9
            if (pos > 1)
                pos = 0;
        }
        //pos = lerp(oldPos, newPos, 0.2);
    }
}

class Resistor : Component
{
    Pin p, n;
    double resistance = 0;

    this(double R, dstring label = "R")
    {
        super(label);
        this.resistance = R;
    }

    override void update(double dt)
    {
        super.update(dt);

        //I = (Vp - Vn) / R
        double voltageDiff = p.voltage - n.voltage;
        double current = voltageDiff / resistance;

        //Current flows into p, flows out of n (Kirchhoff's Law)
        p.current = current;
        n.current = -current;

        //p.voltage > n.voltage, p --> n
        //p.voltage < n.voltage, p <-- n
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s: %.2f Ω | I=%.2f A", label.text, resistance, p.current);
    }

}

class VoltageSource : Component
{
    Pin p, n;
    double voltage;

    this(double V, dstring label = "V")
    {
        super(label);
        this.voltage = V;
    }

    override void update(double dt)
    {
        super.update(dt);
        p.voltage = voltage;
        n.voltage = 0; // Ground
    }

    override string toString() const
    {
        import std.format : format;

        return format("Voltage Source: %.2f V", voltage);
    }
}
