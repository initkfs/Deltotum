
#define FXAA_PC 1     
#define FXAA_HLSL_5 1
//#define FXAA_GREEN_AS_LUMA 1

#include "AA/Fxaa_nvidia.hlsli"

Texture2D screenTexture : register(t0, space2);
SamplerState screenSampler : register(s0, space2);

struct Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD0;
};

cbuffer FXAAConfig : register(b0, space3) {
    float4 rcpFrame; // x = 1.0/width, y = 1.0/height
};

struct VSOutput {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
};

float4 main(Input input) : SV_Target {

    FxaaTex t;
    t.tex = screenTexture;
    t.smpl = screenSampler;

    //before fxaa
    //float alpha = dot(color.rgb, float3(0.299, 0.587, 0.114));

    float4 color = FxaaPixelShader(
        input.uv,
        0,                       // Consoles
        t,
        t,
        t,
        rcpFrame.xy,             // (1/W, 1/H)
        0, 0, 0,                 // consoles
        0.1,                     // subpix -  (0.0 - 1.0)
        0.166,                   // edgeThreshold - (0.166)
        0.0833,                  // edgeThresholdMin - darks
        0, 0, 0, 0               // consoles
    );

    color.a = 1;
    return color;
}