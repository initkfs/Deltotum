module api.sims.ele.components.elements.base_two_pin_element;

import api.sims.ele.components.elements.base_one_pin_element : BaseOnePinElement;
import api.sims.ele.components.connects.connection : Connection;

import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 */

abstract class BaseTwoPinElement : BaseOnePinElement
{
    Connection n;

    this(string id, Orientation orientation = Orientation.vertical)
    {
        super(id, orientation);
    }

    override string formatTooltip()
    {
        import std.format : format;

        string text = format("P(%s).in:%.2fmA,out:%.2fmA,v:%.2fV\nN(%s).in:%.2fmA,out:%.2fmA,v:%.2fV", p.id, p.pin.currentInMa, p
                .pin.currentOutMa, p.pin.voltage, n.id, n
                .pin.currentInMa, n.pin.currentOutMa, n.pin.voltage);
        return text;
    }

    override void create()
    {
        super.create;

        n = new Connection;
        n.isNeg = true;
        addCreate(n);

        createTooltip;
    }
}
