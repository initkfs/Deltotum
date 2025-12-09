module api.dm.gui.controls.meters.scrolls.base_scroll;

import api.dm.gui.controls.meters.min_max_meter : MinMaxMeter;

/**
 * Authors: initkfs
 */
abstract class BaseScroll : MinMaxMeter!float
{
    this(float minValue = 0, float maxValue = 1.0)
    {
        super(minValue, maxValue);
    }
}
