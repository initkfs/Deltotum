module api.math.geom2.curves.spirals;

import api.math.geom2.curves.plane_curves : onPointStep;
import api.math.geom2.vec2 : Vec2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
void archimedean(scope bool delegate(Vec2f) onPointContinue, float innerRadius, float growthRate, size_t turnCount = 1, float step = 0.2)
{
    assert(onPointContinue);

    onPointStep(step, 0, Math.PI * 2 * turnCount, (float angleRad) {
        const polarR = innerRadius + growthRate * angleRad;
        return onPointContinue(Vec2f.fromPolarRad(angleRad, polarR));
    });
}

void lituus(scope bool delegate(Vec2f) onPointContinue, float k, size_t turnCount = 1, float scale = 1.0, float step = 0.2)
{
    assert(onPointContinue);
    assert(k != 0);

    onPointStep(step, step, Math.PI * 2 * turnCount, (float angleRad) {
        const polarR = k / (Math.sqrt(angleRad)) * scale;
        return onPointContinue(Vec2f.fromPolarRad(angleRad, polarR));
    });
}

void cochleoid(scope bool delegate(Vec2f) onPointContinue, float a, size_t turnCount = 1, float scale = 1.0, float step = 0.2)
{
    assert(onPointContinue);
    assert(a != 0);

    onPointStep(step, step, Math.PI * 2 * turnCount, (float angleRad) {
        const polarR = ((a * Math.sin(angleRad)) / angleRad) * scale;
        return onPointContinue(Vec2f.fromPolarRad(angleRad, polarR));
    });
}
