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
   float4 topColor;
   float4 horizonColor;
   float4 groundColor;
   
   float3 camForward;
   float  aspectRatio; // screenWidth / screenHeight
   float3 camRight;
   float  fovTan;      // tan(fov / 2)
   float3 camUp;
   float topBlend; //1.5
   
   float groundBlend; //1.0
};

float3 reconstructViewDir(float2 uv) {
    //UV to [-1, 1]
    float2 ndc = uv * 2.0 - 1.0;
    ndc.x *= aspectRatio;
    ndc.y *= -1.0;
    float3 viewDir = camForward + (camRight * ndc.x * fovTan) + (camUp * ndc.y * fovTan);
    return normalize(viewDir);
}

float4 calculateSky(float3 dir) {
    float y = dir.y;
    
    if (y > 0.0) {
        float blend = pow(y, topBlend); 
        return lerp(horizonColor, topColor, blend);
    } else {
        float blend = pow(-y, groundBlend); 
        return lerp(horizonColor, groundColor, blend);
    }
}

float4 main(VOutput input) : SV_Target0
{
    float3 viewDir = reconstructViewDir(input.uv);
    float4 skyColor = calculateSky(viewDir);
    return skyColor;
}