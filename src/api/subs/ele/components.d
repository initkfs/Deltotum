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
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

import Math = api.math;

struct Pin
{
    double voltage = 0;
    double currentIn = 0;
    double currentOut = 0;

    double eqvCurrentIn = 0;
    double eqvCurrentOut = 0;

    double currentInMa() => currentMa(currentIn);
    double currentOutMa() => currentMa(currentOut);
    double eqvCurrentInMa() => currentMa(eqvCurrentIn);

    void current(double inValue, double outValue)
    {
        currentIn = inValue;
        currentOut = outValue;
    }

    double currentMa(double currentA) => currentA * 1000;
}

class DrawableComponent : Control
{

}

class Connection : DrawableComponent
{
    Pin pin;
    bool isNeg;

    this()
    {
        initSize(10);
    }

    override void create()
    {
        super.create;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto style = createDefaultStyle;
        if (!isNeg)
        {
            style.color = RGBA.red;
        }
        else
        {
            style.color = RGBA.blue;
        }
        style.isFill = true;
        auto shape = theme.rectShape(width, height, angle, style);
        addCreate(shape);
    }
}

abstract class Component : DrawableComponent
{
    import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

    override GraphicStyle createDefaultStyle()
    {
        auto style = super.createDefaultStyle;
        style.isFill = false;
        style.lineWidth = theme.lineThickness * 2;
        return style;
    }
}

abstract class Element : Component
{
    import api.dm.gui.controls.texts.text : Text;
    import api.math.geom2.vec3;
    import api.dm.kit.graphics.colors.processings.processing;

    Text label;
    Vertex vertex;

    Orientation orientation;

    dstring elementId;

    this(dstring id, Orientation orientation = Orientation.vertical)
    {
        this.elementId = id;

        label = new Text(elementId);
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

    override void applyLayout()
    {
        super.applyLayout;

        if (label)
        {
            const labelPosX = boundsRect.right;
            const labelPosY = boundsRect.center.y - label
                .halfHeight;
            label.pos(labelPosX, labelPosY);
        }

    }
}

abstract class OnePinElement : Element
{
    Connection p;

    Sprite2d content;

    this(dstring id, Orientation orientation = Orientation.vertical)
    {
        super(id, orientation);
    }

    override void create()
    {
        super.create;

        p = new Connection;
        addCreate(p);

        content = createContent;
        addCreate(content);
    }

    Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto style = createDefaultStyle;
        return theme.rectShape(width, height, angle, style);
    }

    string createSVG()
    {
        import api.dm.kit.sprites2d.textures.vectors.vector_texture : VectorTexture;

        if (auto vtexture = cast(VectorTexture) content)
        {
            auto svg = vtexture.createSVG;
            return svg;
        }

        return "";
    }
}

abstract class TwoPinElement : OnePinElement
{
    Connection n;

    this(dstring id, Orientation orientation = Orientation.vertical)
    {
        super(id, orientation);
    }

    import api.dm.gui.controls.popups.tooltips.text_tooltip : TextTooltip;
    import api.math.geom2.points2;

    TextTooltip tooltip;

    override void create()
    {
        super.create;

        n = new Connection;
        n.isNeg = true;
        addCreate(n);

        tooltip = new TextTooltip;
        tooltip.onShow ~= () {
            import std.format : format;

            string text = format("P.in:%.2fmA,out:%.2fmA,v:%.2fV\nN.in:%.2fmA,out:%.2fmA,v:%.2fV", p.pin.currentInMa, p
                    .pin.currentOutMa, p.pin.voltage, n
                    .pin.currentInMa, n.pin.currentOutMa, n.pin.voltage);

            if (auto res = cast(Resistor) this)
            {
                text ~= format("\neqR=%0.2f(Om),eqV=%0.2fV\ndU=%0.2fV", res.eqvResistance, res.eqvVoltage, res
                        .dU);
            }

            assert(tooltip.label);
            tooltip.label.text = text;
        };
        installTooltip(tooltip);
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

    double eqvCurrent = 0;

    double horizontalThreshold = 2.0; // dx/dy > 2 == horizontal
    double verticalThreshold = 0.5; // dx/dy < 0.5 == vertical

    Vec2d startLine;
    Vec2d endLine;

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

    Vec2d direction() => toPin.pos - fromPin.pos;
    Vec2d directionAbs()
    {
        const dir = direction;
        double dx = Math.abs(dir.x);
        double dy = Math.abs(dir.y);
        return Vec2d(dx, dy);
    }

    double directionRatio()
    {
        const dir = directionAbs;
        double ratio = dir.x / dir.y;
        return ratio;
    }

    Orientation orientation()
    {
        const dirAbs = directionAbs;
        const dx = dirAbs.x;
        const dy = dirAbs.y;

        const ratio = dx / dy;

        if (dx < 1.0 && dy < 1.0)
        {
            return Orientation.point;
        }
        else if (ratio > horizontalThreshold)
        {
            return Orientation.horizontal;
        }
        else if (ratio < verticalThreshold)
        {
            return Orientation.vertical;
        }

        return Orientation.diagonal;
    }

    override void drawContent()
    {
        super.drawContent;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        graphic.color = RGBA.yellowgreen;

        const startCenter = fromPin.boundsRect.center;
        const endCenter = toPin.boundsRect.center;

        startLine = startCenter;
        endLine = endCenter;

        graphic.line(startCenter, endCenter);

        auto orient = orientation;
        if (orient == Orientation.vertical || orient == Orientation.diagonal)
        {
            graphic.line(startCenter.x - 1, startCenter.y, endCenter.x - 1, endCenter.y);
            graphic.line(startCenter.x + 1, startCenter.y, endCenter.x + 1, endCenter.y);
        }
        else if (orient == Orientation.horizontal)
        {
            graphic.line(startCenter.x, startCenter.y - 1, endCenter.x, endCenter.y - 1);
            graphic.line(startCenter.x, startCenter.y + 1, endCenter.x, endCenter.y + 1);
        }

        graphic.restoreColor;

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

        bool isUpdatePin = true;

        if (cast(VoltageSource) src)
        {
            fromPin.pin.currentOut = toPin.pin.currentIn;
        }

        if (cast(Resistor) src && cast(Resistor) dst)
        {
            auto srcR = cast(Resistor) src;
            auto dstR = cast(Resistor) dst;

            if (fromPin is srcR.n && toPin is dstR.p)
            {
                if (dstR.eqvResistance > 0)
                {
                    if (dstR.eqvResistance != srcR.eqvResistance)
                    {
                        srcR.eqvResistance = dstR.eqvResistance;
                    }
                }
                else
                {
                    double totalR = srcR.resistance + dstR.resistance;

                    if (srcR.eqvResistance != 0 && dstR.eqvResistance == 0)
                    {
                        totalR = srcR.eqvResistance + dstR.resistance;
                    }

                    dstR.eqvResistance = totalR;
                    //dstR.p.pin.voltage = srcR.n.pin.voltage;
                }

                if (dstR.eqvResistance > 0 && dstR.eqvVoltage == 0)
                {
                    dstR.eqvVoltage = srcR.eqvVoltage == 0 ? srcR.p.pin.voltage : srcR.eqvVoltage;
                }

                if (srcR.eqvResistance > 0 && srcR.eqvVoltage == 0 && dstR.eqvResistance > 0 && dstR.eqvVoltage > 0)
                {
                    srcR.eqvVoltage = dstR.eqvVoltage;
                }
            }
            else
            {
                //parallel
                if (srcR.eqvResistance > 0 && dstR.eqvResistance > 0)
                {
                    auto eqvR = 1 / srcR.eqvResistance + 1 / dstR.eqvResistance;
                    auto r = 1 / eqvR;
                    auto v = srcR.eqvVoltage > 0 ? srcR.eqvVoltage : fromPin.pin.voltage;
                    auto current = v / r;

                    if (fromPin is srcR.p)
                    {
                        fromPin.pin.eqvCurrentIn = current;
                    }
                    else
                    {
                        toPin.pin.eqvCurrentOut = current;
                    }

                }

            }

        }

        if (isUpdatePin)
        {
            toPin.pin.voltage = fromPin.pin.voltage;
        }

        if (cast(VoltageSource) dst && cast(Ground) src)
        {
            auto bat = cast(VoltageSource) dst;
            bat.n.pin.currentIn = src.p.pin.currentIn;
        }

        if (cast(Ground) dst)
        {
            toPin.pin.currentIn = fromPin.pin.currentOut;
        }

        if (toPin.pin.eqvCurrentIn > 0)
        {
            fromPin.pin.currentOut = toPin.pin.eqvCurrentIn;
        }

        if (toPin.pin.eqvCurrentOut > 0)
        {
            fromPin.pin.currentIn = toPin.pin.eqvCurrentOut;
        }

        //toPin.pin.currentIn = fromPin.pin.currentOut;

        //(Math.abs(fromPin.pin.currentOut - toPin.pin.currentIn) < 1e-9);

        import api.dm.kit.graphics.colors.rgba : RGBA;

        double current = 0;

        //RGBA color = (I > 0) ? RGBA.red : RGBA.blue;

        Vec2d direction;
        double currentFlow = 0;

        //fromPin > toPin
        if (fromPin.pin.currentOut > 0 && toPin.pin.currentIn > 0)
        {
            direction = (toPin.pos - fromPin.pos).normalize;
            current = Math.min(fromPin.pin.currentOut, toPin.pin.currentIn);
        }
        // toPin > fromPin
        else if (fromPin.pin.currentIn > 0 && toPin.pin.currentOut > 0)
        {
            direction = (fromPin.pos - toPin.pos).normalize;
            current = Math.min(fromPin.pin.currentIn, toPin.pin.currentOut);
        }
        //
        else if (fromPin.pin.currentOut > 0 || toPin.pin.currentIn > 0)
        {
            direction = (toPin.pos - fromPin.pos).normalize;
            current = Math.max(fromPin.pin.currentOut, toPin.pin.currentIn);
        }
        // revert
        else if (fromPin.pin.currentIn > 0 || toPin.pin.currentOut > 0)
        {
            direction = (fromPin.pos - toPin.pos).normalize;
            current = Math.max(fromPin.pin.currentIn, toPin.pin.currentOut);
        }
        else
        {
            direction = Vec2d.zero;
            current = 0;
        }

        double minSpeed = 70;
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

    override string toString()
    {
        import std.format : format;

        return format("Wire");
    }
}

class Wire : ConnectorTwoPin
{
    this(Connection fromPin, Connection toPin, TwoPinElement src, TwoPinElement dst)
    {
        super(fromPin, toPin, src, dst);
    }
}

class WirePP : Wire
{
    this(TwoPinElement src, TwoPinElement dst)
    {
        super(src.p, dst.p, src, dst);
    }
}

class WirePN : Wire
{
    this(TwoPinElement src, TwoPinElement dst)
    {
        super(src.p, dst.n, src, dst);
    }
}

class WireNP : Wire
{
    this(TwoPinElement src, TwoPinElement dst)
    {
        super(src.n, dst.p, src, dst);
    }
}

class WireNN : Wire
{
    this(TwoPinElement src, TwoPinElement dst)
    {
        super(src.n, dst.n, src, dst);
    }
}

class ConnectionNode : Component
{
    ConnectorTwoPin[] fromPins;
    ConnectorTwoPin[] toPins;
}

class Resistor : TwoPinElement
{
    double resistance = 0;
    double eqvResistance = 0;
    double eqvVoltage = 0;
    double dU = 0;

    this(double R, dstring label = "R1", Orientation orientation = Orientation.vertical)
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

    override string toString() const
    {
        import std.format : format;

        return format("%s: %.2f Ω | I=%s A", label.text, resistance, p.pin);
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

            override void createTextureContent()
            {
                super.createTextureContent;

                auto ctx = canvas;
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
