module api.subs.ele.components;

/**
 * Authors: initkfs
 */

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.math.graphs.vertex : Vertex;
import api.math.graphs.edge : Edge;
import api.math.pos2.orientation : Orientation;
import api.math.geom2.vec2 : Vec2d;

import Math = api.math;

struct Pin
{
    double voltage = 0;
    double current = 0;
}

class Connection : Control
{
    Pin pin;

    this()
    {
        initSize(10);
    }
}

abstract class Component : Control
{

}

abstract class Element : Component
{
    import api.dm.gui.controls.texts.text : Text;
    import api.math.geom2.vec3;
    import api.dm.kit.graphics.colors.processings.processing;

    Text label;
    Vertex vertex;

    Orientation orientation;

    this(dstring text, Orientation orientation = Orientation.vertical)
    {
        label = new Text(text);
        vertex = new Vertex;
        isDraggable = true;

        this.orientation = orientation;

        if (orientation == Orientation.vertical)
        {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout;
            layout.isAlignX = true;
        }
        else
        {
            //TODO other
            import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

            layout = new HLayout;
            layout.isAlignY = true;
        }

        layout.isAutoResize = true;
    }

    override void loadTheme()
    {
        super.loadTheme;
        enum size = 50;
        if (width == 0)
        {
            width = size;
        }
        if (height == 0)
        {
            height = size;
        }
    }

    override void create()
    {
        super.create;

        assert(label);
        label.isLayoutManaged = false;
        addCreate(label);
    }
}

abstract class TwoPinElement : Element
{
    Connection p;
    Connection n;

    Sprite2d content;

    this(dstring text, Orientation orientation = Orientation.vertical)
    {
        super(text, orientation);
    }

    override void create()
    {
        super.create;

        p = new Connection;
        addCreate(p);

        content = createContent;
        addCreate(content);

        n = new Connection;
        addCreate(n);
    }

    Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto style = createDefaultStyle;
        return theme.rectShape(width, height, angle, style);
    }
}

abstract class ConnectorTwoPin : Component
{
    Edge edge;

    TwoPinElement src;
    TwoPinElement dst;

    Connection fromPin;
    Connection toPin;

    Vec2d[1] points;

    double spacing = 5;

    this(Connection fromPin, Connection toPin, TwoPinElement src, TwoPinElement dst)
    {
        assert(fromPin);
        this.fromPin = fromPin;
        this.toPin = toPin;

        assert(src);
        assert(dst);

        this.src = src;
        this.dst = dst;
        edge = new Edge(src.vertex, dst.vertex);
    }

    override void drawContent()
    {
        super.drawContent;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.line(fromPin.pos, toPin.pos, RGBA.green);

        graphic.color = RGBA.red;
        scope (exit)
        {
            graphic.restoreColor;
        }

        auto start = fromPin.pos;

        foreach (ref p; points)
        {
            graphic.fillRect(start.add(p), 5, 5);
        }
    }

    override void update(double dt)
    {
        super.update(dt);

        toPin.pin.voltage = fromPin.pin.voltage;
        if (cast(Ground) dst)
        {
            fromPin.pin.voltage = 0;
        }

        import api.dm.kit.graphics.colors.rgba : RGBA;

        double current = 0;

        //RGBA color = (I > 0) ? RGBA.red : RGBA.blue;

        Vec2d direction;
        double currentFlow = 0;

        if (fromPin.pin.current > 0 && toPin.pin.current < 0)
        {
            //from -> to
            direction = (toPin.pos - fromPin.pos).normalize;
            currentFlow = Math.min(fromPin.pin.current, -toPin.pin.current);
        }
        else if (fromPin.pin.current < 0 && toPin.pin.current > 0)
        {
            //to -> from
            direction = (fromPin.pos - toPin.pos).normalize;
            currentFlow = Math.min(-fromPin.pin.current, toPin.pin.current);
        }
        else if (fromPin.pin.current != 0 || toPin.pin.current != 0)
        {
            if (Math.abs(fromPin.pin.current) > Math.abs(toPin.pin.current))
            {
                direction = (toPin.pos - fromPin.pos).normalize;
                currentFlow = Math.abs(fromPin.pin.current);
            }
            else
            {
                direction = (fromPin.pos - toPin.pos).normalize;
                currentFlow = Math.abs(fromPin.pin.current);
            }

            if ((fromPin.pin.current > 0 && toPin.pin.current == 0) || (fromPin.pin.current == 0 && toPin.pin.current < 0))
            {

            }
            else
            {
                direction = direction.reflect;
            }
        }

        double minSpeed = 5;
        double scale = 50;
        double speed = minSpeed + currentFlow * scale;

        double moveDist = speed * dt;

        Vec2d start = fromPin.pos;

        foreach (ref point; points)
        {
            if ((start.add(point) - fromPin.pos)
                .dotProduct(direction) > (toPin.pos - fromPin.pos).length)
            {
                point = Vec2d(0, 0);
                continue;
            }
            //auto dp = (I * dt * scale) / (length * 1e-9); // q = 1e-9
            point = point.add(direction.scale(moveDist));
        }
    }
}

class Wire : ConnectorTwoPin
{
    this(Connection fromPin, Connection toPin, TwoPinElement src, TwoPinElement dst)
    {
        super(fromPin, toPin, src, dst);
    }
}

class Resistor : TwoPinElement
{
    double resistance = 0;

    this(double R, dstring label = "R1", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
        this.resistance = R;
    }

    override void update(double dt)
    {
        super.update(dt);

        //I = (Vp - Vn) / R
        double voltageDiff = p.pin.voltage - n.pin.voltage;
        double current = voltageDiff / resistance;

        //Current flows into p, flows out of n (Kirchhoff's Law)
        p.pin.current = current;
        n.pin.current = -current;

        //p.voltage > n.voltage, p --> n
        //p.voltage < n.voltage, p <-- n
    }

    override Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        double w = 20;
        double h = 50;
        if (orientation == Orientation.horizontal)
        {
            import std.algorithm.mutation : swap;

            swap(w, h);
        }

        auto style = createDefaultStyle;
        style.isFill = false;
        return theme.rectShape(w, h, angle, style);
    }

    override string toString() const
    {
        import std.format : format;

        return format("%s: %.2f Ω | I=%.2f A", label.text, resistance, p.pin.current);
    }

}

class VoltageSource : TwoPinElement
{
    double voltage = 0;

    this(double V, dstring label = "V1", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
        this.voltage = V;
    }

    override void update(double dt)
    {
        super.update(dt);
        p.pin.voltage = voltage;
        n.pin.voltage = 0; // Ground

        //const Rinternal = 0.1;
        // double current = (p.voltage - n.voltage) / Rinternal;
        // double I = p.current;
        // double terminalVoltage = V - current * R_internal;
        // p.voltage = terminalVoltage;
        // n.voltage = 0;
        // n.current = -p.current;
    }

    override Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        double size = 50;

        auto style = createDefaultStyle;
        style.isFill = true;
        return theme.rectShape(size, size, angle, style);
    }

    override string toString() const
    {
        import std.format : format;

        return format("Voltage Source: %.2f V", voltage);
    }
}

class Ground : TwoPinElement
{
    double conductance = 1e9;

    this(dstring label = "Gnd", Orientation orientation = Orientation.vertical)
    {
        super(label, orientation);
    }

    override void create()
    {
        super.create;
        p.pin.voltage = 0;
        n.pin.voltage = 0;
    }

    override void update(double dt)
    {
        super.update(dt);
        p.pin.current = (p.pin.voltage - n.pin.voltage) * conductance;
        n.pin.current = -p.pin.current;
    }
}
