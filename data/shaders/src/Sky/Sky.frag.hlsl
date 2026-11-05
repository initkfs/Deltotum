/**
* Author: initkfs
*/

struct VOutput
{
    float4 pos : SV_Position;
    float2 uv  : TEXCOORD0;
};

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
   float3 rayleighScat;    // R, G, B, float3(5.8e-6, 1.35e-5, 3.31e-5)), sun day Vec3f(1e-6, 1e-6, 1e-6), fog  4e-4
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

float raySphereIntersect(float3 rayOrigin, float3 rayDir, float sphereRadius) {
    float b = dot(rayOrigin, rayDir);
    float c = dot(rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
    float discriminant = b * b - c;
    if (discriminant < 0.0) return -1.0;
    float t = -b + sqrt(discriminant);
    return t > 0.0 ? t : -1.0;
}

// float densityAtHeight(float height) {
//     const float H_R = 8000.0;  //meters
//     return exp(-height / H_R);
// }

float densityAtHeight(float height, float scaleHeight) {
    return exp(-height / scaleHeight);
}

float2 integrateOpticalDepth(float3 start, float3 end, float Rplanet, float Ratmos, float H_R, float H_M) {
    float3 stepVec = end - start;
    float dist = length(stepVec);
    float3 dir = stepVec / dist; //normalized direction
    
    const int SAMPLE_COUNT = 5; //4..8
    float stepSize = dist / float(SAMPLE_COUNT);
    float totalRayleigh = 0.0;
    float totalMie = 0.0;

    for (int i = 0; i < SAMPLE_COUNT; i++) {
        float3 samplePoint = start + dir * (stepSize * (float(i) + 0.5));
        float height = length(samplePoint) - Rplanet;
        
        totalRayleigh += densityAtHeight(height, H_R) * stepSize;
        totalMie += densityAtHeight(height, H_M) * stepSize;
    }
    
    return float2(totalRayleigh, totalMie);
   
   
    // float stepSize = dist / float(SAMPLE_COUNT);
    // float totalDensity = 0.0;
    // for (int i = 0; i < SAMPLE_COUNT; i++) {
    //     float3 samplePoint = start + dir * (stepSize * (float(i) + 0.5));
    //     float height = length(samplePoint) - Rplanet;
    //     totalDensity += densityAtHeight(height) * stepSize;
    // }
    
    //return totalDensity;
}

float3 reconstructViewDir(float2 uv) {
    float2 ndc = uv * 2.0 - 1.0;
    ndc.x *= aspectRatio;
    ndc.y *= -1.0;
    return normalize(camForward + (camRight * ndc.x * fovTan) + (camUp * ndc.y * fovTan));
}

float4 main(VOutput input) : SV_Target0
{
    float3 viewDir = reconstructViewDir(input.uv);
    
    float Rplanet = planetRadius;
    float Ratmos = Rplanet + atmHeight;
    
    float3 rayOrigin = float3(0.0, Rplanet + camHeight, 0.0);
    
    float tEarth = raySphereIntersect(rayOrigin, viewDir, Rplanet);
    float tAtmos = raySphereIntersect(rayOrigin, viewDir, Ratmos);
    float tEnd = (tEarth > 0.0) ? tEarth : tAtmos;
    
    if (tEarth > 0.0) {
        return float4(0.0, 0.0, 0.0, 1.0);
    }

    const int SCATTER_SAMPLES = 8;
    float stepSize = tEnd / float(SCATTER_SAMPLES);
    
    float3 accumRayleigh = float3(0.0, 0.0, 0.0);
    float3 accumMie = float3(0.0, 0.0, 0.0);
    
    float3 optDepthCamRayleigh = float3(0.0, 0.0, 0.0);
    float3 optDepthCamMie = float3(0.0, 0.0, 0.0);
    
    const float H_R = 8000.0;
    float H_M = mieHeight;
    
    for (int i = 0; i < SCATTER_SAMPLES; i++) {
        float3 samplePoint = rayOrigin + viewDir * (stepSize * (float(i) + 0.5));
        float height = length(samplePoint) - Rplanet;
        
        float dR = densityAtHeight(height, H_R) * stepSize;
        float dM = densityAtHeight(height, H_M) * stepSize;
        
        optDepthCamRayleigh += dR * rayleighScat;
        optDepthCamMie += dM * mieScat;
        
        float tSun = raySphereIntersect(samplePoint, sunDir, Ratmos);
        float3 sunEnd = samplePoint + sunDir * tSun;
        float2 optDepthSun = integrateOpticalDepth(samplePoint, sunEnd, Rplanet, Ratmos, H_R, H_M);
        
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
    
    float3 finalColor = (accumRayleigh * rayleighScat * phaseRayleigh + accumMie * mieScat * phaseMie) * sunIntensity;
    
    if (tEarth > 0.0) {
        float3 groundColor = float3(0.2, 0.15, 0.1); 
        finalColor += groundColor * exp(-(optDepthCamRayleigh + optDepthCamMie));
    }
    
    // Tone mapping
    //finalColor = 1.0 - exp(-finalColor * 0.05); 
    finalColor = finalColor / (finalColor + float3(1.0, 1.0, 1.0));
    
    return float4(finalColor, 1.0);
    
//     const int SCATTER_SAMPLES = 6;
//     float stepSize = tEnd / float(SCATTER_SAMPLES);
    
//     float3 totalRayleigh = float3(0.0, 0.0, 0.0);
//     float3 opticalDepthToCam = float3(0.0, 0.0, 0.0);
    
//     for (int i = 0; i < SCATTER_SAMPLES; i++) {
//         float3 samplePoint = rayOrigin + viewDir * (stepSize * (float(i) + 0.5));
//         float height = length(samplePoint) - Rplanet;
        
//         float localDensity = densityAtHeight(height) * stepSize;
        
//         opticalDepthToCam += localDensity * rayleighScat;
        
//         float tSun = raySphereIntersect(samplePoint, sunDir, Ratmos);
//         float3 sunEnd = samplePoint + sunDir * tSun;
//         float opticalDepthToSun = integrateOpticalDepth(samplePoint, sunEnd, Rplanet, Ratmos);
        
//         float3 attenuation = exp(-(opticalDepthToCam + opticalDepthToSun * rayleighScat));
        
//         totalRayleigh += localDensity * attenuation;
//     }
    
//     float cosAngle = dot(viewDir, sunDir);
//     float phaseRayleigh = 3.0 / (16.0 * 3.14159265) * (1.0 + cosAngle * cosAngle);
    
//     float3 finalColor = totalRayleigh * rayleighScat * phaseRayleigh * sunIntensity;
    
//     if (tEarth > 0.0) {
//         float3 groundColor = float3(0.2, 0.15, 0.1);
//         finalColor += groundColor * exp(-opticalDepthToCam);
//     }
    
//     //float sunDisk = smoothstep(0.998, 0.999, cosAngle);
//    // finalColor += sunDisk * sunIntensity * exp(-opticalDepthToCam);
    
//     return float4(finalColor, 1.0);
}
