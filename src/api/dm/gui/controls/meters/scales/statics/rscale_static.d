module api.dm.gui.controls.meters.scales.statics.rscale_static;

import api.dm.gui.controls.meters.scales.statics.base_radial_scale_static: BaseRadialScaleStatic;

/**
 * Authors: initkfs
 */
class RScaleStatic : BaseRadialScaleStatic
{
    this(double diameter = 0, double minAngleDeg = 0, double maxAngleDeg = 90)
    {
        super(diameter, minAngleDeg, maxAngleDeg);
    }
}
