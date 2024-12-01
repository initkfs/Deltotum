module api.dm.gui.controls.scrolls.base_scroll;

import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
abstract class BaseScroll : Control
{
    double minValue;
    double maxValue;

    this(double minValue = 0, double maxValue = 1.0)
    {
        this.minValue = minValue;
        this.maxValue = maxValue;

        import api.dm.kit.sprites.sprites2d.layouts.managed_layout: ManagedLayout;

        this.layout = new ManagedLayout;
    }

    double valueRange()
    {
        import Math = api.math;

        if (minValue == maxValue)
        {
            return 0;
        }

        const double range = minValue < maxValue ? (maxValue - minValue) : (minValue - maxValue);
        return range;
    }
}
