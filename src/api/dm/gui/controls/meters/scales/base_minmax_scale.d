module api.dm.gui.controls.meters.scales.base_minmax_scale;

import api.dm.gui.controls.meters.scales.base_scale : BaseScale;

import Math = api.math;

/**
 * Authors: initkfs
 */
abstract class BaseMinMaxScale : BaseScale
{
    float minValue = 0;
    float maxValue = 1;

    float valueStep = 0.05;

    float range()
    {
        assert(minValue < maxValue);
        return maxValue - minValue;
    }

    size_t tickCount()
    {
        import std.conv: to;
        
        size_t ticksCount = Math.round(range / valueStep).to!size_t;
        return ticksCount + 1;
    }

}
