module api.dm.gui.controls.meters.scales.statics.rscale_static;

import api.dm.gui.controls.meters.scales.statics.base_radial_scale_static: BaseRadialScaleStatic;

/**
 * Authors: initkfs
 */
class RScaleStatic : BaseRadialScaleStatic
{
    this(float diameter = 0, float minAngleDeg = 0, float maxAngleDeg = 90)
    {
        super(diameter, minAngleDeg, maxAngleDeg);
    }
}
