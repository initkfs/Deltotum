module api.dm.gui.controls.meters.clocks.analogs.analog_clock;

import api.dm.gui.controls.meters.clocks.base_clock : BaseClock;
import api.dm.gui.controls.meters.clocks.analogs.faces.analog_clock_face : AnalogClockFace;

import std.conv : to;

/**
 * Authors: initkfs
 */
class AnalogClock : BaseClock!AnalogClockFace
{
    float handWidth = 0;
    float diameter = 0;

    protected
    {

    }

    this(float diameter = 0)
    {
        this.diameter = diameter;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadAnalogClockTheme;
    }

    void loadAnalogClockTheme()
    {
        if (handWidth == 0)
        {
            handWidth = theme.meterHandWidth * 2;
            assert(handWidth > 0);
        }

        if (diameter == 0)
        {
            diameter = theme.meterThumbDiameter * 2;
            initSize(diameter, diameter);
        }
    }

    override AnalogClockFace newClockFace()
    {
        auto face = new AnalogClockFace(diameter);
        return face;
    }

}
