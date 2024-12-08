module api.dm.gui.controls.meters.range_bars.color_range_bar;

import api.dm.gui.controls.meters.min_value_meter: MinValueMeter;
import api.dm.kit.graphics.colors.rgba: RGBA;

/**
 * Authors: initkfs
 */
struct RangeInfo
{
    RGBA color;
    double range;
}

class ColorRangeBar : MinValueMeter!double {

    this(double minValue, double maxValue)
    {
        super(minValue, maxValue);
    }

    override void create(){
        super.create;
    }

}