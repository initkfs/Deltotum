module api.math.geom2.curves.superellipse;

import api.math.geom2.curves.plane_curves : onPointStep;
import api.math.geom2.vec2 : Vec2f;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
void superformula(scope bool delegate(Vec2f) onPointContinue, float a, float b, float m, float n1, float n2, float n3, float scale = 1.0, float step = 0.01)
{
    assert(onPointContinue);

    onPointStep(step, 0, Math.PI * 2, (angle) {
        auto x = Math.pow(Math.abs(Math.cos(m * angle / 4) / a), n2);
        auto y = Math.pow(Math.abs(Math.sin(m * angle / 4) / b), n3);
        auto r = Math.pow(x + y, -1 / n1);

        return onPointContinue(Vec2f.fromPolarRad(angle, r * scale));
    });
}

void superellipse(scope bool delegate(Vec2f) onPointContinue, float a, float b, float n, float scale = 1.0, float step = 0.1)
{
    assert(onPointContinue);

    onPointStep(step, 0, 1000, (angle) {
        const cosAngle = Math.cos(angle);
        const sinAngle = Math.sin(angle);
        auto x = a * (Math.abs(cosAngle) ^^ (2 / n)) * scale * Math.sign(cosAngle);
        auto y = b * (Math.abs(sinAngle) ^^ (2 / n)) * scale * Math.sign(sinAngle);

        return onPointContinue(Vec2f(x, y));
    });
}

void squircle(scope bool delegate(Vec2f) onPointContinue, float scale = 1.0, float step = 0.1)
{
    superellipse(onPointContinue, 1, 1, 4, scale, step);
}
