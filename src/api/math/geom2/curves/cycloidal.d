module api.math.geom2.curves.cycloidal;

import api.math.geom2.curves.plane_curves : onPointStep;
import api.math.geom2.vec2 : Vec2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
void hypotrochoid(scope bool delegate(Vec2f) onPointContinue, float radius1, float theta1, float radius2, float theta2, float dots = 500, float scale = 1.0)
{
    assert(onPointContinue);

    auto initTheta = Math.PI * 2 / dots;
    float theta = 0;

    foreach (i; 0 .. dots)
    {
        theta = i * initTheta;
        const x = (radius1 * Math.cos(
                theta1 * theta) + radius2 * Math.cos(
                theta2 * theta)) * scale;
        const y = (radius1 * Math.sin(
                theta1 * theta) - radius2 * Math.sin(
                theta2 * theta)) * scale;
        if (!onPointContinue(Vec2f(x, y)))
        {
            break;
        }
    }
}

void cycloid(scope bool delegate(Vec2f) onPointContinue, float radius = 10, size_t dots = 100, float step = 0.5)
{
    assert(onPointContinue);

    //TODO check is -PI<=theta<=PI
    onPointStep(step, 0, dots, (dt) {
        const x = (radius * dt) - radius * Math.sin(dt);
        const y = radius - radius * Math.cos(dt);
        return onPointContinue(Vec2f(x, y));
    });
}
