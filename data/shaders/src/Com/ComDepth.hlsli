/**
* Author: initkfs
*/

float linearizeDepthGL(float depth, float near, float far)
{
    //convert to NDC
    float z = depth * 2.0 - 1.0;
    float linearDepth = ((2.0 * near * far) / (far + near - z * (far - near))) / far;
    return linearDepth;
}

float linearizeDepth(float depth, float near, float far)
{
    float linearDepth = (near * far) / (far + depth * (near - far));
    return linearDepth / far;
}

float linearizeDepthReversedDX(float depth, float near, float far)
{
    float linearDepth = (near * far) / (far + depth * (near - far));
    return (near * far) / (depth * (far - near) + near);
}