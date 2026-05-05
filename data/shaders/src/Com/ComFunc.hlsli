/**
* Author: initkfs
*/

float period01(float v){
    //return abs(sin(time));
    return sin(v) * 0.5 + 0.5;// -1..1 to 0..1.
}

float goldNoise(float2 coords, float seed) {
    return frac(tan(distance(coords * 1.61803398875, coords) * seed) * coords.x);
}