/**
* Author: initkfs
*/

struct VOutput
{
    float4 pos : SV_Position;
    float2 uv  : TEXCOORD0;
};


Texture2D<float4> SkyViewLUT : register(t0, space2);
SamplerState LinearSampler   : register(s0, space2);

/*
Mercury, Moon:
rayleighScat = Vec3f(0.0f, 0.0f, 0.0f);
mieScat = Vec3f(0.0f, 0.0f, 0.0f);
not works for Venus\Jupiter\etc
*/
cbuffer SceneUBO : register(b0, space3)
{
   float3 camForward;
   float  aspectRatio; // screenWidth / screenHeight
   float3 camRight;
   float  fovTan;      // tan(fov / 2)
   float3 camUp;
   float reserve1;
   float3 sunDir; //normalized
   float  planetRadius;     // 6371000.0
   float3 rayleighScat;    // R, G, B, //(1/lambda^4), 0.0000058, 0.000010, 0.000033
   float  atmHeight;       // 80000.0km
   float3 sunIntensity;    // float3(20.0, 20.0, 19.0))
   float  camHeight;       // 1meter
   float3 mieScat;          // float3(4e-6, 4e-6, 4e-6)
   float  mieHeight;        //1200.0m
   float  mieG;             // 0.76 - 0.85, mieG = 0.0, all directrions, > 0 - forward, < 0 back .
   float  reserve11;
   float  reserve22;
   float  reserve33;
};

float3 reconstructViewDir(float2 uv) {
    float2 ndc = uv * 2.0 - 1.0;
    ndc.x *= aspectRatio;
    ndc.y *= -1.0;
    return normalize(camForward + (camRight * ndc.x * fovTan) + (camUp * ndc.y * fovTan));
}

float2 GetLutUV(float height, float cosZenith, float atmHeight)
{
    float u = height / atmHeight;
    //float v = cosZenith * 0.5 + 0.5;
    float v = (1.0 - cosZenith) * 0.5; 
    return clamp(float2(u, v), 0.0, 1.0);
}

float PhaseRayleigh(float cosTheta)
{
    return (3.0 / (16.0 * 3.14159265)) * (1.0 + cosTheta * cosTheta);
}

float PhaseMie(float cosTheta, float g)
{
    float g2 = g * g;
    float denom = 1.0 + g2 - 2.0 * g * cosTheta;
    return (3.0 / (8.0 * 3.14159265)) * ((1.0 - g2) * (1.0 + cosTheta * cosTheta)) / ((2.0 + g2) * pow(denom, 1.5));
}

float4 main(VOutput input) : SV_Target0
{
    //float3 sunDir = normalize(float3(0.001, -0.001, 0));

    // if(sunDir.y < -0.4){
    //     float twilightFade = exp(sunDir.y * 25.0); 
    //     float3 nightColor = float3(0, 0, 0);
    //     nightColor *= twilightFade;
    //     return float4(nightColor, 1.0);
    // }

    const float SUN_SIZE_DEGREES = 6.0; 
    const float SUN_RADIUS_COS = cos(radians(SUN_SIZE_DEGREES * 0.5));
    const float SUN_EDGE_SMOOTH = 0.001; 

    // UV (0..1) to NDC (Normalized Device Coordinates) -1.. 1
    float2 ndc = input.uv * 2.0 - 1.0;
    ndc.y = -ndc.y; 
    
    float3 viewDir = camForward + (ndc.x * aspectRatio * fovTan * camRight) + (ndc.y * fovTan * camUp);
    viewDir = normalize(viewDir);
    
    float3 skyAtmColor = SkyViewLUT.Sample(LinearSampler, input.uv).rgb;
    //return float4(skyAtmColor, 1.0);

    float cosTheta = dot(viewDir, sunDir);

    //cos(20grad) ≈ 0.94.
    const float SUN_INFLUENCE_THRESHOLD = 0.94; 
    if (cosTheta < SUN_INFLUENCE_THRESHOLD)
    {
        skyAtmColor = pow(skyAtmColor, 1.0 / 1.2); 
        //skyAtmColor = skyAtmColor / (skyAtmColor + float3(1.0, 1.0, 1.0));
        //skyAtmColor= pow(skyAtmColor, 1.0 / 2.2);
        //skyAtmColor = pow(skyAtmColor, 1.0 / 1.5); 
        return float4(skyAtmColor, 1.0);
    }

    float pixelHorizonMask = smoothstep(0.0, 0.002, viewDir.y);
    float sunDiskMask = smoothstep(SUN_RADIUS_COS, SUN_RADIUS_COS + SUN_EDGE_SMOOTH, cosTheta);
    
    float activeY = max(viewDir.y, 0.0);
    float3 transmittance = exp(-float3(0.05, 0.15, 0.4) * (1.0 / (activeY + 0.04)));
    
    float3 directSunDisk = sunDiskMask * sunIntensity * transmittance * pixelHorizonMask;
    
    float phaseM = PhaseMie(cosTheta, mieG);
    float haloHorizonMask = smoothstep(-0.05, 0.05, viewDir.y);
    float3 sunHalo = mieScat * phaseM * sunIntensity * transmittance * haloHorizonMask * 0.02;
    
    float3 finalColor = skyAtmColor + sunHalo + directSunDisk;

    //corona
    // float angleToSun = acos(cosTheta);
    // float ringPattern = sin(angleToSun * 150.0);
    // float3 coronaColor = float3(
    // smoothstep(-0.2, 0.2, sin(angleToSun * 120.0 - 0.5)), // Red
    // smoothstep(-0.2, 0.2, sin(angleToSun * 135.0)),       // Green
    // smoothstep(-0.2, 0.2, sin(angleToSun * 150.0 + 0.5))  // Blue
    // );
    // coronaColor *= exp(-angleToSun * 25.0) * sunIntensity * 0.15;
    // finalColor += coronaColor;

    // Halo
    // float angleToSunHalo = acos(cosTheta);
    
    // // 18..26 grad = 0.31 .. 0.45 rad
    // if (angleToSunHalo > 0.31 && angleToSunHalo < 0.45)
    // {
    // float rCenter = 0.375; 
    // float gCenter = 0.384;
    // float bCenter = 0.393;
    
    // float haloWidth = 0.015;
    
    // float rRing = saturate(1.0 - abs(angleToSunHalo - rCenter) / haloWidth);
    // float gRing = saturate(1.0 - abs(angleToSunHalo - gCenter) / haloWidth);
    // float bRing = saturate(1.0 - abs(angleToSunHalo - bCenter) / haloWidth);
    
    // float tail = smoothstep(0.45, 0.384, angleToSunHalo) * 0.3;
    // float3 haloColor = float3(rRing, gRing, bRing) + float3(tail, tail, tail);
    // haloColor *= sunIntensity * 0.002; 
    // finalColor += haloColor;
    // }

    //finalColor = finalColor / (finalColor + float3(1.0, 1.0, 1.0));
    //finalColor = pow(finalColor, 1.0 / 2.2);
    finalColor = pow(finalColor, 1.0 / 1.2);

    return float4(finalColor, 1.0);
}

float3 calcGlory(float3 viewDir, float3 sunDir, float3 color){
    
    float cosGloriaTheta = dot(viewDir, -sunDir);
    // cos(10 grad) ≈ 0.985.
    if (cosGloriaTheta < 0.985)
    {
        return color;
    }

    float angleToAntisolar = acos(cosGloriaTheta);
    float3 gloriaColor = float3(
        smoothstep(-0.3, 0.3, sin(angleToAntisolar * 240.0 - 0.6)), // Red
        smoothstep(-0.3, 0.3, sin(angleToAntisolar * 270.0)),       // Green
        smoothstep(-0.3, 0.3, sin(angleToAntisolar * 300.0 + 0.6))  // Blue
    );
    
    float attenuation = exp(-angleToAntisolar * 12.0);
    //TODO cloud\fog
    gloriaColor *= attenuation * sunIntensity * 0.005; 
    return color + gloriaColor;
}
