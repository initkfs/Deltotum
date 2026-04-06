struct SimpleDataBuffer
{
     float4 value1;
};

RWStructuredBuffer<SimpleDataBuffer> sdataBuffer : register(u0, space2);

struct Config {
    float4 albedo;
    float intensity;
    float reserve;
    float nearPlane;
    float farPlane;
    float iTime;
    float iResolutionX;
    float iResolutionY;
};

cbuffer UBO : register(b0, space3)
{
    Config config;
};

#include "Com/ComTypes.hlsli"
#include "Com/ComDepth.hlsli"

float3 palette(float t) {
    float3 a = float3(0.5, 0.5, 0.5);
    float3 b = float3(0.5, 0.5, 0.5);
    float3 c = float3(1.0, 1.0, 1.0);
    float3 d = float3(0.26, 0.41, 0.55); // Сине-голубая гамма (можно менять)
    return a + b * cos(6.28318 * (c * t + d));
}

FragOutput main(FragInput input)
{
    FragOutput result;

    //SimpleDataBuffer dbuff;
    //dbuff.value1 = float4(0, lights[1].position);
    //sdataBuffer[0] = dbuff;

    result.depth = linearizeDepthReversedDX(input.outPosition.z, config.nearPlane, config.farPlane);

    float3 p = input.localPos; 
    float t = config.iTime * 0.4;

    // 3D Domain Warping
    p.x += 0.15 * sin(t + p.y * 4.0);
    p.y += 0.15 * cos(t + p.z * 4.0);
    p.z += 0.15 * sin(t + p.x * 4.0);
    
    // Wave summation
    float v = 0.0;
    v += cos(p.x * 8.0 + t);
    v += cos(p.y * 7.0 + t * 1.1);
    v += cos(p.z * 9.0 + t * 1.3);
    v += cos(length(p.xyz) * 12.0 - t);
    
    v = saturate(v * 0.25 + 0.5);
    float3 color = palette(v + t * 0.1);
    result.color = float4(config.albedo.rgb * color, 1.0);
    return result;
}





