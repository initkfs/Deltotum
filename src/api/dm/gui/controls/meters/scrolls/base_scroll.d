module api.dm.gui.controls.meters.scrolls.base_scroll;

import api.dm.gui.controls.meters.min_max_value_meter : MinMaxValueMeter;

/**
 * Authors: initkfs
 */
abstract class BaseScroll : MinMaxValueMeter!double
{
    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }
}
