module api.dm.sims.phys.lightings.lights.spot_light;

import api.dm.sims.phys.lightings.lights.base_light : BaseLight;

import Math = api.math;

/**
 * Authors: initkfs
 */
class SpotLight : BaseLight
{
    float cutoff = Math.cosDeg(12.5);
    float outerCutoff = Math.cosDeg(17.5);

    this()
    {
        id = "SpotLight";
    }
}
