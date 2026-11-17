/**
 * Author: initkfs
 */
Texture2D<float2> OpticalDensity : register(t0, space0);
SamplerState LinearSampler : register(s0, space0);
RWTexture2D<float4> Output : register(u0, space1);

cbuffer Params : register(b0, space2)
{
    float3 camForward;
    float aspectRatio; // screenWidth / screenHeight
    float3 camRight;
    float fovTan; // tan(fov / 2)
    float3 camUp;
    float reserve1;
    float3 sunDir;       // normalized
    float planetRadius;  // 6371000.0
    float3 rayleighScat; // R, G, B, //(1/lambda^4), 0.0000058, 0.000010, 0.000033
    float atmHeight;     // 80000.0km
    float3 sunIntensity; // float3(20.0, 20.0, 19.0))
    float camHeight;     // 1meter
    float3 mieScat;      // float3(4e-6, 4e-6, 4e-6)
    float mieHeight;     // 1200.0m
    float mieG;          // 0.76 - 0.85, mieG = 0.0, all directrions, > 0 - forward, < 0 back .
    float reserve11;
    float reserve22;
    float reserve33;
};

float raySphereIntersect(float3 rayOrigin, float3 rayDir, float sphereRadius) {
    float b = dot(rayOrigin, rayDir);
    float c = dot(rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
    float discriminant = b * b - c;
    if (discriminant < 0.0) return -1.0;
    float t = -b + sqrt(discriminant);
    return t > 0.0 ? t : -1.0;
}

float densityAtHeight(float height, float scaleHeight) {
    return exp(-height / scaleHeight);
}

float2 GetLutUV(float height, float cosZenith, float maxAtmHeight)
{
    //float u = height / maxAtmHeight;
    //float v = cosZenith * 0.5 + 0.5;
    //return clamp(float2(u, v), 0.0, 1.0);

    float u = sqrt(saturate(height / atmHeight));
    float v = (1.0 - cosZenith) * 0.5;
    
    // if osZenith = v * 2.0 - 1.0:
    //float v = (cosZenith + 1.0) * 0.5;

    return float2(u, v);
}

void viewOpticalDepth(uint3 globalID, uint2 res){
    //left x, u = 0, camera earth, right x, u = 1, atmHeight. Red to black, density to 0
    float2 uvd = (float2(globalID.xy) + 0.5) / res;
    
    float2 opticalDepth = OpticalDensity.SampleLevel(LinearSampler, uvd, 0).rg;
    //float3 debugColorLin = float3(opticalDepth.r / 40000.0, opticalDepth.g / 8000.0, 0.0);
    float rayleighVis = 1.0 - exp(-opticalDepth.r / 8000.0);
    float mieVis      = 1.0 - exp(-opticalDepth.g / 1200.0);
    float3 debugColorExp = float3(rayleighVis, mieVis, 0.0);
    Output[globalID.xy] = float4(debugColorExp, 1.0);
}

[numthreads(16, 16, 1)] 
void main(uint3 globalID : SV_DispatchThreadID)
{
    //float3 rayleighScat = float3(0.0000058, 0.000013, 0.000033);
    //float3 rayleighScat = float3(0.0000078, 0.000030, 0.000053);
    //float3 rayleighScat = float3(0.0000068, 0.000023, 0.000053);
    
    // if(sunDir.y < -0.75){
    //     float twilightFade = exp(sunDir.y * 25.0); 
    //     float3 nightColor = float3(0, 0, 0);
    //     nightColor *= twilightFade;
    //     Output[globalID.xy] = float4(nightColor, 1.0);
    //     return;
    // }

    //float3 sunDir = normalize(float3(0.001, -0.05, 0));
    
    uint2 res;
    Output.GetDimensions(res.x, res.y);

    if (globalID.x >= res.x || globalID.y >= res.y)
        return;
    
    //viewOpticalDepth(globalID, res);
    //return;

    float2 uv = (float2(globalID.xy) + 0.5) / float2(res);

    //UV [0..1] to NDC [-1..1]
    float2 ndc = uv * 2.0 - 1.0;
    ndc.y = -ndc.y; // revert Y

    float3 viewDir = normalize(camForward + 
                               camRight * (ndc.x * fovTan * aspectRatio) + 
                               camUp * (ndc.y * fovTan));


    float Rplanet = planetRadius;
    float Ratmos = Rplanet + atmHeight;

    //float3 rayOrigin = worldCamPos; 
    float3 rayOrigin = float3(0.0, Rplanet + camHeight, 0.0);
    
    float tEarth = raySphereIntersect(rayOrigin, viewDir, Rplanet);
    float tAtmos = raySphereIntersect(rayOrigin, viewDir, Ratmos);
    float tEnd = (tEarth > 0.0) ? tEarth : tAtmos;
    
    if (tEarth > 0.0) {
        Output[globalID.xy] = float4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    const int SCATTER_SAMPLES = 16;
    float stepSize = tEnd / float(SCATTER_SAMPLES);
    
    float3 accumRayleigh = float3(0.0, 0.0, 0.0);
    float3 accumMie = float3(0.0, 0.0, 0.0);
    
    float3 optDepthCamRayleigh = float3(0.0, 0.0, 0.0);
    float3 optDepthCamMie = float3(0.0, 0.0, 0.0);
    
    const float H_R = 8000.0;
    float H_M = mieHeight;
    
    for (int i = 0; i < SCATTER_SAMPLES; i++) 
    //for(int i = SCATTER_SAMPLES - 1; i >= 0; i--)
    {
        float3 samplePoint = rayOrigin + viewDir * (stepSize * (float(i) + 0.5));
        float height = length(samplePoint) - Rplanet;

        float3 upDir = samplePoint / (Rplanet + height);
        
        float dR = densityAtHeight(height, H_R) * stepSize;
        float dM = densityAtHeight(height, H_M) * stepSize;
        
        optDepthCamRayleigh += dR * rayleighScat;
        optDepthCamMie += dM * mieScat;
        
        float cosZenithSun = dot(upDir, sunDir);
        float2 uvSun = GetLutUV(height, cosZenithSun, atmHeight);
        
        float2 optDepthSun = OpticalDensity.SampleLevel(LinearSampler, uvSun, 0).xy;
        
        float3 optDepthSunTotalRayleigh = optDepthSun.x * rayleighScat;
        float3 optDepthSunTotalMie = optDepthSun.y * mieScat;
        
        float3 attenuation = exp(-(optDepthCamRayleigh + optDepthSunTotalRayleigh + optDepthCamMie + optDepthSunTotalMie));
        
        accumRayleigh += dR * attenuation;
        accumMie += dM * attenuation;
    }
    
    float cosAngle = dot(viewDir, sunDir);
    
    float phaseRayleigh = 3.0 / (16.0 * 3.14159265) * (1.0 + cosAngle * cosAngle);
    
    float g = mieG;
    float g2 = g * g;
    float phaseMie = 1.0 / (4.0 * 3.14159265) * ((1.0 - g2) / pow(1.0 + g2 - 2.0 * g * cosAngle, 1.5));
    
    float3 accumRayTotal = accumRayleigh * rayleighScat * phaseRayleigh;
    float3 finalColor = (accumRayTotal + accumMie * mieScat * phaseMie) * sunIntensity;
    
    //finalColor = finalColor / (finalColor + float3(1.0, 1.0, 1.0));
    // float exposure = 0.3; 
    // finalColor = 1.0 - exp(-finalColor * exposure);
    // finalColor = pow(finalColor, 1.0 / 2.2);

    //if (sunDir.y < 0.0f)
    //{
        //finalColor = float3(1.0f, 0.0f, 0.0f);
    //}
    
    Output[globalID.xy] = float4(finalColor, 1.0);
}