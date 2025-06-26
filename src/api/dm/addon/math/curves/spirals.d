module api.dm.addon.math.curves.spirals;

import api.dm.addon.math.curves.plane_curves : onPointStep;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
void archimedean(scope bool delegate(Vec2d) onPointIsContinue, double innerRadius, double growthRate, size_t turnCount = 1, double step = 0.2)
{
    assert(onPointIsContinue);

    onPointStep(step, 0, Math.PI * 2 * turnCount, (double angleRad) {
        const polarR = innerRadius + growthRate * angleRad;
        return onPointIsContinue(Vec2d.fromPolarRad(angleRad, polarR));
    });
}

void lituus(scope bool delegate(Vec2d) onPointIsContinue, double k, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
{
    assert(onPointIsContinue);
    assert(k != 0);

    onPointStep(step, step, Math.PI * 2 * turnCount, (double angleRad) {
        const polarR = k / (Math.sqrt(angleRad)) * scale;
        return onPointIsContinue(Vec2d.fromPolarRad(angleRad, polarR));
    });
}

void cochleoid(scope bool delegate(Vec2d) onPointIsContinue, double a, size_t turnCount = 1, double scale = 1.0, double step = 0.2)
{
    assert(onPointIsContinue);
    assert(a != 0);

    onPointStep(step, step, Math.PI * 2 * turnCount, (double angleRad) {
        const polarR = ((a * Math.sin(angleRad)) / angleRad) * scale;
        return onPointIsContinue(Vec2d.fromPolarRad(angleRad, polarR));
    });
}
