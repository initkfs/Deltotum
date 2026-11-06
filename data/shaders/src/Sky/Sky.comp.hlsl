/**
 * Author: initkfs
 */
RWTexture2D<float2> Output : register(u0, space1);

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
    float b = dot(rayOrigin, rayDir);
    float c = dot(rayOrigin, rayOrigin) - sphereRadius * sphereRadius;
    float discriminant = b * b - c;
    if (discriminant < 0.0)
        return -1.0;
    float t = -b + sqrt(discriminant);
    return t > 0.0 ? t : -1.0;
}

float densityAtHeight(float height, float scaleHeight)
{
    return exp(-height / scaleHeight);
}

[numthreads(16, 16, 1)] 
void main(uint3 globalID : SV_DispatchThreadID)
{
    uint2 res;
    Output.GetDimensions(res.x, res.y);

    if (globalID.x >= res.x || globalID.y >= res.y)
        return;

    float u = (float(globalID.x) + 0.5) / float(res.x);
    float v = (float(globalID.y) + 0.5) / float(res.y);

    // X (U) -> 0 .. atmHeight)
    float height = u * atmHeight;

    // Y (V) ->  -1.0 до 1.0
    float cosZenith = v * 2.0 - 1.0;
    float sinZenith = sqrt(max(0.0, 1.0 - cosZenith * cosZenith));

    float Rplanet = planetRadius;
    float Ratmos = Rplanet + atmHeight;

    float3 rayOrigin = float3(0.0, Rplanet + height, 0.0);
    float3 rayDir = float3(sinZenith, cosZenith, 0.0);

    float tAtmos = raySphereIntersect(rayOrigin, rayDir, Ratmos);
    float tEarth = raySphereIntersect(rayOrigin, rayDir, Rplanet);

    float maxDist = tAtmos;
    if (tEarth > 0.0 && tEarth < tAtmos)
    {
        maxDist = tEarth;
    }

    const int SAMPLE_COUNT = 32;
    float stepSize = maxDist / float(SAMPLE_COUNT);

    float totalRayleigh = 0.0;
    float totalMie = 0.0;

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
    Output[globalID.xy] = float2(totalRayleigh, totalMie);
}