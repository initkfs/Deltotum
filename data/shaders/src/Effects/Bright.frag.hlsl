/**
* Author: initkfs
*/

Texture2D<float4> resultTexture : register(t0, space2);
SamplerState resultSampler : register(s0, space2);

struct Config
{
    float threshold; //1.0
    float intensity; //0.2
};

cbuffer UBO : register(b0, space3)
{
    Config config;
};

struct Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD0;
};

struct Output
{
    float4 color : SV_Target0;
};


Output main(Input input)
{
    Output result;

    float4 sceneColor = resultTexture.Sample(resultSampler, input.uv);
    float3 bright = max(sceneColor.rgb - config.threshold, 0.0f);
    result.color = float4(bright * config.intensity, 1.0f);
    return result;
}





