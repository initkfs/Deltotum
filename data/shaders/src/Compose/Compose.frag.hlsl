/**
* Author: initkfs
*/

Texture2D sceneTexture : register(t0, space2);
Texture2D bloomTexture : register(t1, space2);
SamplerState defaultSampler : register(s0, space2);

struct Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD0;
};

struct ShaderFlags {
    uint isColorTint       : 1;
    uint isColorEffects        : 1;
    uint unused1 : 1;
    uint isVignette     : 1;
    uint unused         : 28;
};

struct Config
{
    float3 filterColor; //[1, 1, 1, 0] for mul
    float filterIntensity; // 0-1

    float3 flashColor; //[0, 0, 0, 0] for add
    float flashIntensity; // 0-1

    float baseIntensity; // 2, 1.5–2.0 Base cube strength
    float bloomIntensity; //1, Halo density
    float exposure; //0.9 Overall brightness (ACES)
    float threshold; //50 At what brightness the cube begins to whiten
    
    float contrast;  //1
    float saturation; //1, 0 -2
    float vignetteIntensity; //0- 2;
    ShaderFlags flags;
}; 

cbuffer UBO : register(b0, space3)
{
    Config config;
};

float3 acesTonemap(float3 x) {
    // Narkowicz
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

float screenNoise(float2 uv) {
    return frac(dot(uv, float2(12.9898, 78.233)) * 43758.5453);
}

float4 main(Input input) : SV_Target {
    
    float3 base = sceneTexture.Sample(defaultSampler, input.uv).rgb;
    float3 bloom = bloomTexture.Sample(defaultSampler, input.uv).rgb;

    float3 hdrColor = base * config.baseIntensity + bloom * config.bloomIntensity;
    float luma = dot(hdrColor, float3(0.2126, 0.7152, 0.0722));
    
    float3 mappedColor = acesTonemap(hdrColor * config.exposure); 

    if(config.flags.isColorTint){
        float3 filter = lerp(float3(1.0f, 1.0f, 1.0f), config.filterColor.rgb, config.filterIntensity);        
        float3 flash = config.flashColor.rgb * config.flashIntensity; 
        mappedColor = mappedColor * filter + flash;
        mappedColor = saturate(mappedColor);
    }

    if(config.flags.isColorEffects){
        //S-curve
        // >= 1.0
        float contrast = config.contrast; 
        // 0.5 - curve middle
        mappedColor = (mappedColor - 0.5f) * contrast + 0.5f;
        mappedColor = saturate(mappedColor); // 0.0-1.0

        //Saturation
        float grey = dot(mappedColor, float3(0.2126f, 0.7152f, 0.0722f));
        mappedColor = lerp(float3(grey, grey, grey), mappedColor, config.saturation);

        //white-out effect
        //float threshold = 0.8; 
        float smoothness = 10.0; 
        float luma = dot(hdrColor, float3(0.2126, 0.7152, 0.0722));
        //float smoothness = 0.01; // How quickly it becomes whiten
        float whiteMask = pow(saturate((luma - config.threshold) * smoothness), 2.0);
        mappedColor = lerp(mappedColor, float3(1.0, 1.0, 1.0), whiteMask);
    }

    if(config.flags.isVignette){
        //Vignette
        //float pulse = (sin(config.time * 2.0f) * 0.5f + 0.5f) * config.pulseIntensity, config.vignetteIntensity + pulse
        float dist = distance(input.uv, float2(0.5f, 0.5f));
        mappedColor *= smoothstep(0.8f, 0.2f, dist * config.vignetteIntensity);
    }

    //Simple Dithering
    //finalColor += (screenNoise(input.uv) - 0.5) * (1.0 / 255.0);
    
    return float4(mappedColor, 1.0);
    //float4(pow(finalColor, 1.0/2.2), 1.0);
}







