module api.math.umath;

import mathTrig = std.math.trigonometry;
import mathConst = std.math.constants;
import mathCore = core.math;
import mathExp = std.math.exponential;
import StdComp = std.algorithm.comparison;
import StdRound = std.math.rounding;
import StdAlgebraic = std.math.algebraic;

import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
enum PI = mathConst.PI;
enum PI2 = PI * 2;
enum PIOver2 = mathConst.PI_2;
enum PIOver4 = mathConst.PI_4;

enum double goldUnitFrac = 0.62;
enum double goldRounded = 1.62;

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

//inverse hyperbolic tangent, -1..1
alias atanh = mathTrig.atanh;

//hyperbolic cosine
alias cosh = mathTrig.cosh;

//hyperbolic
alias sinh = mathTrig.sinh;
alias tanh = mathTrig.tanh;

alias tanHyp = tanh;
alias cosHyp = cosh;

double sinDeg(double valueDeg)  nothrow pure @safe => sin(degToRad(valueDeg));
double cosDeg(double valueDeg)  nothrow pure @safe => cos(degToRad(valueDeg));
double tanDeg(double valueDeg)  nothrow pure @safe => tan(degToRad(valueDeg));

double csc(double x)
{
    immutable sinv = sin(x);
    if (sinv == 0)
    {
        return double.nan;
    }
    return 1.0 / sinv;
}

double csch(double x)
{
    immutable sinHyp = sinh(x);
    if (sinHyp == 0)
    {
        return double.nan;
    }
    return 1.0 / sinHyp;
}

double sec(double value)  nothrow pure @safe
{
    auto cosv = cos(value);
    if (cosv == 0)
    {
        return double.nan;
    }
    return 1.0 / cosv;
}

double sech(double value)  nothrow pure @safe
{
    auto cosHyp = cosh(value);
    if (cosHyp == 0)
    {
        return double.nan;
    }
    return 1.0 / cosHyp;
}

double acsc(double v)  nothrow pure @safe => asin(1.0 / v);
double asec(double v)  nothrow pure @safe => acos(1.0 / v);

alias cot = ctg;
alias acot = actg;
alias coth = ctgh;

pragma(inline, true);
double ctg(double x)  nothrow pure @safe => 1.0 / tan(x);

pragma(inline, true);
double ctgh(double x)  nothrow pure @safe => 1.0 / tanh(x);

pragma(inline, true);
double actg(double x) => atan(1.0 / x);

double actgs(double x)
{
    //actg(−x) = PI - actg(x)
    return x < 0 ? (PI - actg(-x)) : actg(x);
}

pragma(inline, true);
double arcctg(double x)  nothrow pure @safe => PI / 2.0 - atan(x);

//alias sqrt = mathCore.sqrt;
double sqrt(double v)  nothrow pure @safe => mathCore.sqrt(v);

alias pow = mathExp.pow;

double degToRad(double deg)  nothrow pure @safe => deg * (PI / angleHalfDeg);
double radToDeg(double rad)  nothrow pure @safe => rad * (angleHalfDeg / PI);

alias min = StdComp.min;
alias max = StdComp.max;

alias round = StdRound.round;
alias floor = StdRound.floor;
alias ceil = StdRound.ceil;
alias trunc = StdRound.trunc;

alias abs = StdAlgebraic.abs;

//TODO mixing numeric types
pragma(inline, true);
bool greater(T)(T oldValue, T newValue, T eps)  nothrow pure @safe
{
    return (abs(newValue - oldValue) > eps);
}

T factorial(T)(T n)
{
    return (n == 0 || n == 1) ? 1 : n * factorial(n - 1);
}

double hypot(double a, double b)  nothrow pure @safe
{
    double result = 0;
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

bool isSameSign(double a, double b)  nothrow pure @safe
{
    return sign(a) == sign(b);
}

double toRange(double oldRangeValue, double oldMinInc, double oldMaxInc, double newMinInc, double newMaxInc)  nothrow pure @safe
{
    return (((oldRangeValue - oldMinInc) * (newMaxInc - newMinInc)) / (oldMaxInc - oldMinInc)) + newMinInc;
}

double norm(double x, double minX = 0, double maxX = 1)  nothrow pure @safe
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

double clamp01(double value)  nothrow pure @safe => clamp(value, 0.0, 1.0);

double wrap(double x, double min = 0.0, double max = 1.0)
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

    double newX = x - trunc((x - min) / (max - min)) * (max - min);
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

    assert(wrap(0.9, minValue, maxValue) == 0.9);
    assert(wrap(1, minValue, maxValue) == 1);
    assert(wrap(50, minValue, maxValue) == 1);
    assert(wrap(55, minValue, maxValue) == 6);
}

double roundEven(double v)
{
    return round(v * 0.5) * 2.0;
    //import std.math.rounding : nearbyint;
    //return nearbyint(v * 0.5) * 2.0;
}

double angleDegDiff(double startAngleDeg, double endAngleDeg)  nothrow pure @safe
{
    if (startAngleDeg < endAngleDeg)
    {
        return endAngleDeg - startAngleDeg;
    }

    return angleFullDeg - (startAngleDeg - endAngleDeg);
}

double angleDegMiddle(double startAngleDeg, double endAngleDeg)  nothrow pure @safe
{
    auto angleMiddle = angleDegDiff(startAngleDeg, endAngleDeg) / 2;
    return startAngleDeg + angleMiddle;
}

bool nearAngleDeg(double angleDeg, double targetAngle, double delta = 3)  nothrow pure @safe
{
    const startAngle = targetAngle > delta ? (targetAngle - delta) : (
        angleFullDeg - (delta - targetAngle));
    const endAngle = targetAngle + delta;

    return angleDeg >= startAngle && angleDeg <= endAngle;
}

struct GoldenResult
{
    double longest = 0;
    double shortest = 0;
}

GoldenResult goldenDiv(double value)  nothrow pure @safe
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
