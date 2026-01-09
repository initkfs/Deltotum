module api.math.umath;

import mathTrig = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import StdComp = std.algorithm.comparison;
import StdRound = std.math.rounding;
import StdAlgebraic = std.math.algebraic;

import api.math.geom2.vec2 : Vec2f;

/**
 * Authors: initkfs
 */
enum PI = mathConst.PI;
enum PI2 = PI * 2;
enum PIOver2 = mathConst.PI_2;
enum PIOver4 = mathConst.PI_4;

enum float goldUnitFrac = 0.62;
enum float goldRounded = 1.62;

alias Tau = PI2;

//2.718281...
enum E = mathConst.E;
//0.434294...
enum Log10E = mathConst.LOG10E;
//1.442695...
enum Log2E = mathConst.LOG2E;

enum angleFullDeg = 360.0;
enum angleHalfDeg = 180.0;

alias sin = mathTrig.sin;
alias cos = mathTrig.cos;
alias tan = mathTrig.tan;

//inverse hyperbolic cosin
alias acosh = mathTrig.acosh;

//return -π/2 to π/2
alias asin = mathTrig.asin;

//return  0 to π.
alias acos = mathTrig.acos;

//inverse hyperbolic sine
alias asinh = mathTrig.asinh;

//return -π/2 to π/2
alias atan = mathTrig.atan;

//-π to π
alias atan2 = mathTrig.atan2;

float atan2(Vec2f vec) => atan2(vec.y, vec.x);

//inverse hyperbolic tangent, -1..1
alias atanh = mathTrig.atanh;

//hyperbolic cosine
alias cosh = mathTrig.cosh;

//hyperbolic
alias sinh = mathTrig.sinh;
alias tanh = mathTrig.tanh;

alias tanHyp = tanh;
alias cosHyp = cosh;

float sinDeg(float valueDeg) nothrow pure @safe => sin(degToRad(valueDeg));
float cosDeg(float valueDeg) nothrow pure @safe => cos(degToRad(valueDeg));
float tanDeg(float valueDeg) nothrow pure @safe => tan(degToRad(valueDeg));

float csc(float x)
{
    immutable sinv = sin(x);
    if (sinv == 0)
    {
        return float.nan;
    }
    return 1.0 / sinv;
}

float csch(float x)
{
    immutable sinHyp = sinh(x);
    if (sinHyp == 0)
    {
        return float.nan;
    }
    return 1.0 / sinHyp;
}

float sec(float value) nothrow pure @safe
{
    auto cosv = cos(value);
    if (cosv == 0)
    {
        return float.nan;
    }
    return 1.0 / cosv;
}

float sech(float value) nothrow pure @safe
{
    auto cosHyp = cosh(value);
    if (cosHyp == 0)
    {
        return float.nan;
    }
    return 1.0 / cosHyp;
}

float acsc(float v) nothrow pure @safe => asin(1.0 / v);
float asec(float v) nothrow pure @safe => acos(1.0 / v);

alias cot = ctg;
alias acot = actg;
alias coth = ctgh;

pragma(inline, true);
float ctg(float x) nothrow pure @safe => 1.0 / tan(x);

pragma(inline, true);
float ctgh(float x) nothrow pure @safe => 1.0 / tanh(x);

pragma(inline, true);
float actg(float x) => atan(1.0 / x);

float actgs(float x)
{
    //actg(−x) = PI - actg(x)
    return x < 0 ? (PI - actg(-x)) : actg(x);
}

pragma(inline, true);
float arcctg(float x) nothrow pure @safe => PI / 2.0 - atan(x);

//alias sqrt = mathCore.sqrt;
float sqrt(float v) nothrow pure @safe => mathCore.sqrt(v);

alias pow = mathExp.pow;

float degToRad(float deg) nothrow pure @safe => deg * (PI / angleHalfDeg);
float radToDeg(float rad) nothrow pure @safe => rad * (angleHalfDeg / PI);

alias min = StdComp.min;
alias max = StdComp.max;

alias round = StdRound.round;
alias floor = StdRound.floor;
alias ceil = StdRound.ceil;
alias trunc = StdRound.trunc;

alias abs = StdAlgebraic.abs;

//TODO mixing numeric types
pragma(inline, true);
bool greater(T)(T oldValue, T newValue, T eps) nothrow pure @safe
{
    return (abs(newValue - oldValue) > eps);
}

T factorial(T)(T n)
{
    return (n == 0 || n == 1) ? 1 : n * factorial(n - 1);
}

float hypot(float a, float b) nothrow pure @safe
{
    float result = 0;
    if (abs(a) > abs(b))
    {
        result = b / a;
        result = abs(a) * sqrt(1 + result ^^ 2);
        return result;
    }

    if (b != 0.0)
    {
        result = a / b;
        result = abs(b) * sqrt(1 + result ^^ 2);
        return result;
    }

    return result;
}

import StdMathTraits = std.math.traits;

alias sign = StdMathTraits.sgn;

bool isSameSign(float a, float b) nothrow pure @safe
{
    return sign(a) == sign(b);
}

float toRange(float oldRangeValue, float oldMinInc, float oldMaxInc, float newMinInc, float newMaxInc) nothrow pure @safe
{
    return (((oldRangeValue - oldMinInc) * (newMaxInc - newMinInc)) / (oldMaxInc - oldMinInc)) + newMinInc;
}

float norm(float x, float minX = 0, float maxX = 1) nothrow pure @safe
{
    return (x - minX) / (maxX - minX);
}

T clamp(T)(T value, T min, T max)
{
    if (value < min)
    {
        return min;
    }

    if (value > max)
    {
        return max;
    }
    return value;
}

T clampAbs(T)(T value, T min, T max)
{
    if (value >= min)
    {
        return clamp(value, min, max);
    }
    return clamp(value, -max, min);
}

float clamp01(float value) nothrow pure @safe => clamp(value, 0.0, 1.0);

float wrap(float x, float min = 0.0, float max = 1.0)
{
    //or floor?
    if (min == 0 && max == 1.0)
    {
        //return ((x mod 1.0) + 1.0) mod 1.0;
        auto newX = x - trunc(x);
        if (newX < 0)
        {
            return newX + max;
        }
    }

    float newX = x - trunc((x - min) / (max - min)) * (max - min);
    if (newX < 0)
    {
        newX = newX + max - min;
    }
    return newX;
}

unittest
{
    auto minValue = 1;
    auto maxValue = 50;

    import std.math.operations: isClose;

    const eps = 0.01;

    assert(isClose(wrap(0.9, minValue, maxValue), 0.9, eps));
    assert(isClose(wrap(1, minValue, maxValue), 1, eps));
    assert(isClose(wrap(50, minValue, maxValue), 1, eps));
    assert(isClose(wrap(55, minValue, maxValue), 6, eps));
}

float roundEven(float v)
{
    return round(v * 0.5) * 2.0;
    //import std.math.rounding : nearbyint;
    //return nearbyint(v * 0.5) * 2.0;
}

float angleDegDiff(float startAngleDeg, float endAngleDeg) nothrow pure @safe
{
    if (startAngleDeg < endAngleDeg)
    {
        return endAngleDeg - startAngleDeg;
    }

    return angleFullDeg - (startAngleDeg - endAngleDeg);
}

float angleDegMiddle(float startAngleDeg, float endAngleDeg) nothrow pure @safe
{
    auto angleMiddle = angleDegDiff(startAngleDeg, endAngleDeg) / 2;
    return startAngleDeg + angleMiddle;
}

bool nearAngleDeg(float angleDeg, float targetAngle, float delta = 3) nothrow pure @safe
{
    const startAngle = targetAngle > delta ? (targetAngle - delta) : (
        angleFullDeg - (delta - targetAngle));
    const endAngle = targetAngle + delta;

    return angleDeg >= startAngle && angleDeg <= endAngle;
}

struct GoldenResult
{
    float longest = 0;
    float shortest = 0;
}

GoldenResult goldenDiv(float value) nothrow pure @safe
{
    if (value == 0)
    {
        return GoldenResult.init;
    }
    if (value < 0)
    {
        value = -value;
    }
    auto a = value * goldUnitFrac;
    auto b = value - a;
    return GoldenResult(a, b);
}

uint prevPower2(uint x)
{
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >> 16);
    return x - (x >> 1);
}

//https://stackoverflow.com/questions/364985/algorithm-for-finding-the-smallest-power-of-two-thats-greater-or-equal-to-a-giv
int pow2roundup(int x)
{
    if (x < 0)
        return 0;
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1;
}

//TODO negative values
T incmod(T)(T value, T inc, T mod) => (value + inc) % mod;
T decmod(T)(T value, T dec, T mod) => (value - dec + mod) % mod;

float wrapAngle(float angle, float minAngle = 0, float maxAngle = 360)
{
    assert(minAngle < maxAngle);

    import std.math.remainder : fmod;

    if (angle >= minAngle && angle <= maxAngle)
    {
        return angle;
    }

    float range = maxAngle - minAngle;

    float offset = angle - minAngle;

    float addRanges = floor(offset / range);
    float result = angle - addRanges * range;

    if (result < minAngle)
    {
        result += range;
    }

    else if (result > maxAngle)
    {
        result -= range;
    }

    return result;
}

unittest
{
    assert(cast(int)(wrapAngle(0, 0, 360)) == 0);
    assert(cast(int)(wrapAngle(1, 0, 360)) == 1);
    assert(cast(int)(wrapAngle(10, 0, 360)) == 10);
    assert(cast(int)(wrapAngle(359, 0, 360)) == 359);
    assert(cast(int)(wrapAngle(360, 0, 360)) == 360);
    assert(cast(int)(wrapAngle(370, 0, 360)) == 10);
    assert(cast(int)(wrapAngle(400, 0, 360)) == 40);

    assert(cast(int)(wrapAngle(-180, -180, 180)) == -180);
    assert(cast(int)(wrapAngle(180, -180, 180)) == 180);
    assert(cast(int)(wrapAngle(190, -180, 180)) == -170);
    assert(cast(int)(wrapAngle(-190, -180, 180)) == 170);
}

import std.math.remainder : fmod;

//[0, 360]
float wrapAngle360(float angle) => wrapAngle(angle, 0, 360.0);
