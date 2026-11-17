/**
 * Author: initkfs
 */
RWTexture2D<float2> OpticalDepth : register(u0, space1);

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

float raySphereIntersect(float3 rayOrigin, float3 rayDir, float sphereRadius)
{
    // float b = dot(rayOrigin, rayDir);
    // float c = dot(rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
    // float discriminant = b * b - c;
    // if (discriminant < 0.0)
    //     return -1.0;
    // float t = -b + sqrt(discriminant);
    // return t > 0.0 ? t : -1.0;

    float b = dot(rayOrigin, rayDir);
    float c = dot(rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
    float discriminant = b * b - c;
    
    if (discriminant < 0.0)
        return -1.0;
        
    float sqrtDisc = sqrt(discriminant);
    float t0 = -b - sqrtDisc; // near\enter
    float t1 = -b + sqrtDisc; // far\exit
    
    if (t0 > 0.0) return t0;
    if (t1 > 0.0) return t1;
    
    return -1.0;
}

float densityAtHeight(float height, float scaleHeight)
{
    return exp(-height / scaleHeight);
}

[numthreads(16, 16, 1)] 
void main(uint3 globalID : SV_DispatchThreadID)
{
    uint2 res;
    OpticalDepth.GetDimensions(res.x, res.y);

    if (globalID.x >= res.x || globalID.y >= res.y)
        return;

    //[0.0, 1.0], +.5 to center 
    float u = (float(globalID.x) + 0.5) / float(res.x);
    float v = (float(globalID.y) + 0.5) / float(res.y);

    // X (U) -> 0 .. atmHeight)
    //float height = u * atmHeight;
    float height = (u * u) * atmHeight; 
    //float height = pow(u, 4) * atmHeight;

    // Y (V) ->  -1.0 to ground, 1.0 to sky
    //float cosZenith = v * 2.0 - 1.0;
    float cosZenith = 1.0 - v * 2.0;
    float sinZenith = sqrt(max(0.0, 1.0 - cosZenith * cosZenith));

    float Rplanet = planetRadius;
    float Ratmos = Rplanet + atmHeight;

    float3 rayOrigin = float3(0.0, Rplanet + height, 0.0);
    float3 rayDir = float3(sinZenith, cosZenith, 0.0);

    float tAtmos = raySphereIntersect(rayOrigin, rayDir, Ratmos);
    float tEarth = raySphereIntersect(rayOrigin, rayDir, Rplanet);

    float totalRayleigh = 0.0;
    float totalMie = 0.0;

    float maxDist = tAtmos;
    if (tEarth > 0.0 && tEarth < tAtmos)
    {
        maxDist = tEarth;
        float totalRayleighEarth = 100000.0; 
        float totalMieEarth = 100000.0;
        OpticalDepth[globalID.xy] = float2(totalRayleighEarth, totalMieEarth);
        return;
    }

    const int SAMPLE_COUNT = 32;
    float stepSize = maxDist / float(SAMPLE_COUNT);

    const float H_R = 8000.0;
    float H_M = mieHeight;

    for (int i = 0; i < SAMPLE_COUNT; i++)
    {
        float3 samplePoint = rayOrigin + rayDir * (stepSize * (float(i) + 0.5));
        float sampleHeight = length(samplePoint) - Rplanet;

        totalRayleigh += densityAtHeight(sampleHeight, H_R) * stepSize;
        totalMie += densityAtHeight(sampleHeight, H_M) * stepSize;
    }

    // Rayleigh -> R, Mie -> G
    OpticalDepth[globalID.xy] = float2(totalRayleigh, totalMie);
}