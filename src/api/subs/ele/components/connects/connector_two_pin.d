module api.subs.ele.components.connects.connector_two_pin;

import api.subs.ele.components.base_component : BaseComponent;
import api.subs.ele.components.connects.connection: Connection;
import api.subs.ele.components.elements.base_two_pin_element: BaseTwoPinElement;
import api.math.pos2.orientation : Orientation;
import api.math.graphs.edge : Edge;

import api.math.geom2.vec2: Vec2d;

import api.subs.ele.components.elements.passives.voltage_source: VoltageSource;
import api.subs.ele.components.elements.passives.resistor: Resistor;
import api.subs.ele.components.elements.passives.ground: Ground;

import Math = api.math;

/**
 * Authors: initkfs
 */

abstract class ConnectorTwoPin : BaseComponent
{
    Edge edge;

    BaseTwoPinElement src;
    BaseTwoPinElement dst;

    Connection fromPin;
    Connection toPin;

    Vec2d[1] points;

    double spacing = 5;

    double eqvCurrent = 0;

    double horizontalThreshold = 2.0; // dx/dy > 2 == horizontal
    double verticalThreshold = 0.5; // dx/dy < 0.5 == vertical

    Vec2d startLine;
    Vec2d endLine;

    this(Connection fromPin, Connection toPin, BaseTwoPinElement src, BaseTwoPinElement dst)
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

        // foreach (ref p; points)
        // {
        //     graphic.fillRect(start.add(p), 5, 5);
        // }
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
