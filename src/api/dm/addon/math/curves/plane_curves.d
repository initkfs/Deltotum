module api.dm.addon.math.curves.plane_curves;

import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */

//FIXME default argument expected for `onNextStepIsContinue`
void onPointStep(scope bool delegate(
        double) onNextStepIsContinue, double points = 100, double step = 0.001, bool isReverse = false)
{
    return onPointStep(step, 0, points, onNextStepIsContinue, isReverse);
}

void onPointStep(double step, double minValueInclusive, double maxValueInclusive, scope bool delegate(
        double) onNextStepIsContinue, bool isReverse = false)
{
    assert(minValueInclusive < maxValueInclusive);
    assert(step > 0 && step < maxValueInclusive);

    for (double i = minValueInclusive; i <= maxValueInclusive; i += step)
    {
        const resultDt = isReverse ? -(i) : i;
        if (!onNextStepIsContinue(resultDt))
        {
            break;
        }
    }
}

void witchOfAgnesi(scope bool delegate(Vec2d) onPointIsContinue, double radius = 50, double step = 0.01)
{
    assert(onPointIsContinue);

    onPointStep(step, -(Math.PI / 2) + step, Math.PI / 2 - step, (dt) {
        const x = radius * Math.tan(dt);
        const y = radius * (Math.cos(dt) ^^ 2);
        return onPointIsContinue(Vec2d(x, y));
    });
}

void bicorn(scope bool delegate(Vec2d) onPointIsContinue, double radius = 50, double thetaRad = 0.01, size_t dots = 500, double step = 1.0)
{
    assert(onPointIsContinue);

    //TODO check is -PI<=theta<=PI
    onPointStep(step, 0, dots, (dt) {
        const x = radius * Math.sin(thetaRad * dt);
        const y = radius * (
            ((Math.cos(thetaRad * dt) ^^ 2) * (2 + Math.cos(thetaRad * dt)))
            /
            (3 + (Math.sin(thetaRad * dt) ^^ 2))
        );
        return onPointIsContinue(Vec2d(x, y));
    });
}

void cardioid(scope bool delegate(Vec2d) onPointIsContinue, double radius = 10, double step = 0.01)
{
    assert(onPointIsContinue);

    //TODO check is -PI<=theta<=PI
    onPointStep(step, 0, Math.PI * 2, (angle) {
        auto x = (2 * radius) * (1 - Math.cos(angle)) * Math.cos(angle);
        auto y = (2 * radius) * (1 - Math.cos(angle)) * Math.sin(angle);
        onPointIsContinue(Vec2d(x, y));
        return true;
    });
}

void lemniscateBernoulli(scope bool delegate(Vec2d) onPointIsContinue, double distance = 10, double step = 0.01)
{
    assert(onPointIsContinue);

    //TODO check is -PI<=theta<=PI
    import StdMath = std.math;

    onPointStep(step, 0, Math.PI * 2, (angle) {
        auto x = (distance * Math.sqrt(2.0) * Math.cos(angle)) / (1 + Math.pow(Math.sin(angle), 2));
        auto y = (distance * Math.sqrt(2.0) * Math.sin(angle) * Math.cos(angle)) / (
            1 + Math.pow(Math.sin(angle), 2));

        return onPointIsContinue(Vec2d(x, y));
        return true;
    });
}

void strophoid(scope bool delegate(Vec2d) onPointIsContinue, double phi, double step = 0.01, double scale = 1.0)
{
    assert(onPointIsContinue);

    onPointStep(step, 0, Math.PI * 2, (angle) {
        const r = -((phi * Math.cos(2 * angle)) / Math.cos(angle)) * scale;
        return onPointIsContinue(Vec2d.fromPolarRad(angle, r));
    });
}

void foliumOfDescartes(scope bool delegate(Vec2d) onPointIsContinue, double phi, double step = 0.01, double scale = 1.0)
{
    assert(onPointIsContinue);

    onPointStep(step, 0, Math.PI * 2, (angle) {
        const r = (3 * phi * Math.cos(angle) * Math.sin(angle)) / (
            (Math.cos(angle) ^^ 3) + (Math.sin(angle) ^^ 3)) * scale;
        return onPointIsContinue(Vec2d.fromPolarRad(angle, r));
    });
}

void tractrix(scope bool delegate(Vec2d) onPointIsContinue, double length, double step = 0.01)
{
    assert(onPointIsContinue);

    import std.math.exponential : log;

    onPointStep(step, 0, Math.PI, (angle) {
        const sign = Math.sign(angle);
        const x = sign * length * (
            (log(Math.tan(Math.abs(angle / 2)))) + Math.cos(Math.abs(angle)));
        const y = length * Math.sin(angle);
        return onPointIsContinue(Vec2d(x, y));
    });
}

void trisectrixMaclaurin(scope bool delegate(Vec2d) onPointIsContinue, double radius = 10, double step = 0.1)
{
    assert(onPointIsContinue);

    onPointStep(step, -step, Math.PI * 2, (angle) {
        auto r = (radius / 2) * (4 * Math.cos(angle) - Math.sec(angle));
        return onPointIsContinue(Vec2d.fromPolarRad(angle, r));
    });
}

void lissajous(scope bool delegate(Vec2d) onPointIsContinue, double amplitudeX = 50, double freqX = 1, double amplitudeY = 50, double freqY = 2, double phaseShift = (
        Math.PI / 2), double dots = 2000, double step = 0.01)
{
    assert(onPointIsContinue);

    double dt = 0;
    foreach (i; 0 .. dots)
    {
        dt += step;
        const x = amplitudeX * Math.sin(freqX * dt + phaseShift);
        const y = amplitudeY * Math.sin(freqY * dt);
        if (!onPointIsContinue(Vec2d(x, y)))
        {
            break;
        }
    }
}

void rose(scope bool delegate(Vec2d) onPointIsContinue, double roseSize, double n, double d, size_t curlsCount = 1, double step = 0.01)
{
    assert(onPointIsContinue);

    const petalsFactor = n / d;

    //For an integer k, the number of petals is k if k is odd and 2k if even
    onPointStep(step, 0, Math.PI * curlsCount - step, (angle) {
        auto r = roseSize * Math.sin(petalsFactor * angle);
        return onPointIsContinue(Vec2d.fromPolarRad(angle, r));
    });
}
