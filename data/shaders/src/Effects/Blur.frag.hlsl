/**
* Author: initkfs
*/

Texture2D<float4> inputTexture : register(t0, space2);
SamplerState inputSampler : register(s0, space2);

cbuffer BlurData : register(b0, space3)
{
    float2 direction;
    float2 texelSize;
    float  blurScale; // radius,  1.0
    float  intensity; // luma 1.0
};

struct Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD0;
};

float4 main(Input input) : SV_Target {
    float2 uv = input.uv;
    float2 offset = direction * texelSize * blurScale;

    float3 color = inputTexture.Sample(inputSampler, uv).rgb * 0.227;
    color += inputTexture.Sample(inputSampler, uv + offset * 1.38).rgb * 0.316;
    color += inputTexture.Sample(inputSampler, uv - offset * 1.38).rgb * 0.316;
    color += inputTexture.Sample(inputSampler, uv + offset * 3.23).rgb * 0.070;
    color += inputTexture.Sample(inputSampler, uv - offset * 3.23).rgb * 0.070;

    return float4(color * intensity, 1.0);
}





