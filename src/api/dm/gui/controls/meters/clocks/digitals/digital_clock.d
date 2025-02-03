module api.dm.gui.controls.meters.clocks.digitals.digital_clock;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.meters.clocks.digitals.faces.digital_clock_face : DigitalClockFace;
import api.dm.gui.controls.meters.clocks.base_clock : BaseClock;

/**
 * Authors: initkfs
 */
class DigitalClock : BaseClock!DigitalClockFace
{
    override DigitalClockFace newClockFace()
    {
        auto face = new DigitalClockFace(width, height);
        return face;
    }

    override void loadTheme()
    {
        super.loadTheme;
        loadControlSizeTheme;
    }

}
