/**
* Author: initkfs
*/

struct VOutput
{
    float4 pos : SV_Position;
    float2 uv  : TEXCOORD0;
};

cbuffer SceneUBO : register(b0, space3)
{
   float3 camForward;
   float  aspectRatio; // screenWidth / screenHeight
   float3 camRight;
   float  fovTan;      // tan(fov / 2)
   float3 camUp;
};

float3 reconstructViewDir(float2 uv) {
    //UV to [-1, 1]
    float2 ndc = uv * 2.0 - 1.0;
    ndc.x *= aspectRatio;
    ndc.y *= -1.0;
    float3 viewDir = camForward + (camRight * ndc.x * fovTan) + (camUp * ndc.y * fovTan);
    return normalize(viewDir);
}

float3 calculateSky(float3 dir) {
    float y = dir.y;
    
    float3 skyTop = float3(1, 0, 0);
    float3 skyHorizon = float3(0.5, 0.7, 0.9);
    float3 ground = float3(0.1, 0.08, 0.05);

    if (y > 0.0) {
        float blend = pow(y, 1.5); 
        return lerp(skyHorizon, skyTop, blend);
    } else {
        float blend = pow(-y, 1.0); 
        return lerp(skyHorizon, ground, blend);
    }
}

float4 main(VOutput input) : SV_Target0
{
    float3 viewDir = reconstructViewDir(input.uv);
    float3 skyColor = calculateSky(viewDir);
    return float4(skyColor, 1.0);
}