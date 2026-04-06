/**
* Author: initkfs
*/

float circle(float2 coords, float radius, float blur) {
    float d = length(coords - 0.5);
    return 1.0 - smoothstep(radius - blur, radius + blur, d);
}

float circle(float2 coords, float radius) {
    float d = length(coords - 0.5);
    float edge = fwidth(d);
    return 1.0 - smoothstep(radius - edge, radius + edge, d);
}