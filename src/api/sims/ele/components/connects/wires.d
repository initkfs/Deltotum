module api.sims.ele.components.connects.wires;

import api.sims.ele.components.connects.connector_two_pin: ConnectorTwoPin;
import api.sims.ele.components.elements.base_two_pin_element: BaseTwoPinElement;
import api.sims.ele.components.connects.connection: Connection;

/**
 * Authors: initkfs
 */

 class Wire : ConnectorTwoPin
{
    this(Connection fromPin, Connection toPin, BaseTwoPinElement src, BaseTwoPinElement dst)
    {
        super(fromPin, toPin, src, dst);
    }
}

class WirePP : Wire
{
    this(BaseTwoPinElement src, BaseTwoPinElement dst)
    {
        super(src.p, dst.p, src, dst);
    }
}

class WirePN : Wire
{
    this(BaseTwoPinElement src, BaseTwoPinElement dst)
    {
        super(src.p, dst.n, src, dst);
    }
}

class WireNP : Wire
{
    this(BaseTwoPinElement src, BaseTwoPinElement dst)
    {
        super(src.n, dst.p, src, dst);
    }
}

class WireNN : Wire
{
    this(BaseTwoPinElement src, BaseTwoPinElement dst)
    {
        super(src.n, dst.n, src, dst);
    }
}