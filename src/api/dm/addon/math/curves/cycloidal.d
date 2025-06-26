module api.dm.addon.math.curves.cycloidal;

import api.dm.addon.math.curves.plane_curves : onPointStep;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
void hypotrochoid(scope bool delegate(Vec2d) onPointIsContinue, double radius1, double theta1, double radius2, double theta2, double dots = 500, double scale = 1.0)
{
    assert(onPointIsContinue);

    auto initTheta = Math.PI * 2 / dots;
    double theta = 0;

    foreach (i; 0 .. dots)
    {
        theta = i * initTheta;
        const x = (radius1 * Math.cos(
                theta1 * theta) + radius2 * Math.cos(
                theta2 * theta)) * scale;
        const y = (radius1 * Math.sin(
                theta1 * theta) - radius2 * Math.sin(
                theta2 * theta)) * scale;
        if (!onPointIsContinue(Vec2d(x, y)))
        {
            break;
        }
    }
}

void cycloid(scope bool delegate(Vec2d) onPointIsContinue, double radius = 10, size_t dots = 100, double step = 0.5)
{
    assert(onPointIsContinue);

    //TODO check is -PI<=theta<=PI
    onPointStep(step, 0, dots, (dt) {
        const x = (radius * dt) - radius * Math.sin(dt);
        const y = radius - radius * Math.cos(dt);
        return onPointIsContinue(Vec2d(x, y));
    });
}
