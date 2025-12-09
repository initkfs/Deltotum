module api.math.lowdisc;

import api.math.geom2.vec2 : Vec2d;
import api.math.geom3.vec3: Vec3d;


import Math = api.math;

/**
 * Authors: initkfs
 */

/*
* Low discrepancy sequences.
* https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
* https://habr.com/ru/articles/440892/
*/

//enum goldenRatio = (Math.sqrt(5.0) + 1) / 2;
enum goldenRatio = 1.618033988749895;
enum plasticRatio = 1.32471795724474602596090885447809;

protected
{
    //enum a1 = 1.0 / plasticRatio;
    //enum a2 = 1.0 / (plasticRatio * plasticRatio);
    enum a1 = 0.7548776662466927;
    enum a2 = 0.5698402909980532;
}

protected double seqValue(double v, size_t nn, double seed = 0.5) => (seed + v * nn) % 1;

Vec2d lds2d(size_t n, double seed = 0.5)
{
    const x = seqValue(a1, n, seed);
    const y = seqValue(a2, n, seed);
    return Vec2d(x, y);
}

Vec3d lds3d(size_t n, double seed = 0.5)
{
    enum ratio = 1.22074408460575947536;
    const x = seqValue(1.0 / ratio, n, seed);
    const y = seqValue(1.0 / (ratio * ratio), n, seed);
    const z = seqValue(1.0 / (ratio * ratio * ratio), n, seed);
    return Vec3d(x, y, z);
}
