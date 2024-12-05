module api.dm.gui.controls.meters.scrolls.base_scroll;

import api.dm.gui.controls.meters.min_value_meter : MinValueMeter;

/**
 * Authors: initkfs
 */
abstract class BaseScroll : MinValueMeter!double
{
    this(double minValue = 0, double maxValue = 1.0)
    {
        super(minValue, maxValue);
    }
}
