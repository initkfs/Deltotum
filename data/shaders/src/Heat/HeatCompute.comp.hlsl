/**
* Author: initkfs
*/

//Texture2DArray<float> InputThermalArray : register(t0, space0);
//RWTexture2D<float> OutputThermalArray[] : register(u0, space1);

Texture3D<float> InputThermalVolume : register(t0, space0);
RWTexture3D<float> OutputThermalVolume : register(u0, space1);

cbuffer ThermalParams : register(b0, space2)
{
    float deltaTime;      // 0.016 for 60 FPS
    float conductivity;   // (0.0 - 1.0)
    float coolingRate;
    float ambientTemp;    // 20.0)
};

static const float EPSILON = 1e-5f;

[numthreads(16, 16, 1)]
void main(uint3 globalID : SV_DispatchThreadID)
{
    //float3 uv = float3(input.texcoord, 0.0f);
    //float blurredTemp = thermalMap.Sample(linearSampler, uv).r; 
    //float currentTemp = thermalMap.Sample(pointSampler, uv).r;
    //float newTemp = lerp(currentTemp, blurredTemp, speed * deltaTime);

    // uint layerID = globalID.z;
    // uint2 pixelCoord = globalID.xy;
    // float currentTemp = InputThermalArray.Load(int4(pixelCoord, layerID, 0)).r;
    // float newTemp = currentTemp + 10.0f;
    // OutputThermalArray[layerID][pixelCoord] = newTemp;

    //uint2 pixelCoord = globalID.xy;
    //float currentTemp = InputThermalArray.Load(int3(pixelCoord, 0)).r;
    //OutputThermalArray[pixelCoord] = currentTemp + 10.0f;

    // globalID.x = X (0...511)
    // globalID.y = Y (0...511)
    // globalID.z = index / Z (0...1023)
    
    //uint3 texCoord = globalID; 
    //float currentTemp = InputThermalVolume.Load(int4(texCoord, 0)).r;
    //float newTemp = currentTemp + 10.0f;
    //OutputThermalVolume[texCoord] = newTemp;

    uint3 texCoord = globalID;
    
    uint3 textureDims;
    InputThermalVolume.GetDimensions(textureDims.x, textureDims.y, textureDims.z);

    if (texCoord.x >= textureDims.x || texCoord.y >= textureDims.y || texCoord.z >= textureDims.z)
        return;

    int4 loadCoords = int4((int3)globalID, 0);

    float currentTemp = InputThermalVolume.Load(loadCoords).r;

    float tempLeft  = (texCoord.x > 0) ? InputThermalVolume.Load(int4(texCoord.x - 1, texCoord.y, texCoord.z, 0)).r : currentTemp;
    float tempRight = (texCoord.x < textureDims.x - 1) ? InputThermalVolume.Load(int4(texCoord.x + 1, texCoord.y, texCoord.z, 0)).r : currentTemp;
    float tempUp    = (texCoord.y > 0) ? InputThermalVolume.Load(int4(texCoord.x, texCoord.y - 1, texCoord.z, 0)).r : currentTemp;
    float tempDown  = (texCoord.y < textureDims.y - 1) ? InputThermalVolume.Load(int4(texCoord.x, texCoord.y + 1, texCoord.z, 0)).r : currentTemp;

    float laplacian = (tempLeft + tempRight + tempUp + tempDown) - (4.0f * currentTemp);
    //not more 0.25
    float newTemp = currentTemp + (laplacian * conductivity * deltaTime);
    
    //float d2dx2 = (tempLeft + tempRight) - (2.0f * currentTemp);
    //float d2dy2 = (tempUp + tempDown) - (2.0f * currentTemp);
    //float K_X = 1.0f;
    //float K_Y = 0.5f;
    //float anisotropicLaplacian = (K_X * d2dx2) + (K_Y * d2dy2);
    // alpha <= 0.25
    //float alpha = min(conductivity * deltaTime, 0.22f);
    //float newTemp = currentTemp + (anisotropicLaplacian * alpha);

    //Convenction
    newTemp -= (newTemp - ambientTemp) * coolingRate * deltaTime;
    newTemp = clamp(newTemp, ambientTemp, 1000000);
    OutputThermalVolume[texCoord] = newTemp;
}