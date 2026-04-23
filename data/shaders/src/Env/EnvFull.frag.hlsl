/**
* Author: initkfs
*/
Texture2D<float4> diffuseMap : register(t0, space2);
SamplerState diffuseSampler : register(s0, space2);

Texture2D<float4> specularMap : register(t1, space2);
SamplerState specularSampler : register(s1, space2);

Texture2D<float4> normalMap : register(t2, space2);
SamplerState normalSampler : register(s2, space2);

Texture2D<float4> aoMap : register(t3, space2);
SamplerState aoSampler : register(s3, space2);

Texture2D<float4> emissionMap : register(t4, space2);
SamplerState emissionSampler : register(s4, space2);

Texture2D<float4> dispMap : register(t5, space2);
SamplerState dispMapSampler : register(s5, space2);

//TODO one sampler for all
//SamplerState mainSampler : register(s0, space2);

// struct SimpleDataBuffer
// {
//      float4 value1;
// };

// RWStructuredBuffer<SimpleDataBuffer> sdataBuffer : register(u0, space2);


struct Material
{
    float4 albedo;
    float4 ambient;
    float4 reserve0;
    float4 specular;
    float shininess;
    float intensity;
    float gloss;
    uint isLamp;
};

namespace LightType {
    static const uint Directional = 0;
    static const uint Point = 1;
    static const uint Spot = 2;
};

struct Light {
    float3 position;
    uint lightType;
    float3 direction;
    float linearCoeff;
    float3 reserve1;
    float radius;
    float3 ambient;
    float quadraticCoeff;
    float3 diffuse;
    float cutoff;
    float3 specular;
    float outerCutoff;   
};

struct SceneConfig {
    float3 cameraPos;
    float nearPlane;
    float farPlane;
    float time;
    uint lightCount;
    float reserved4;
    Light lights[4];
};

struct MaterialConfig {
    Material material;
};

cbuffer SceneUBO : register(b0, space3)
{
    SceneConfig sceneConfig;
};

cbuffer MaterialUBO : register(b1, space3)
{
    MaterialConfig matConfig;
};

#include "Com/ComTypes.hlsli"
#include "Com/ComDepth.hlsli"

float3 palette(float t) {
    float3 a = float3(0.5, 0.5, 0.5);
    float3 b = float3(0.5, 0.5, 0.5);
    float3 c = float3(1.0, 1.0, 1.0);

    float3 d = float3(0.5, 0.5, 0.5);
    //float3 d = float3(0.26, 0.41, 0.55);
    return a + b * cos(6.28318 * (c * t + d));
}

float3 calcDir(float3 diffuseColor, float4 specularColor, float3 normal, float ao, Light light, FragInput input, Material material, float3 viewDir){
    float3 lightDir = normalize(-light.direction);
    float diff = max(dot(normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), material.shininess);
    //float spec = pow(max(dot(viewDir, halfwayDir), 0.0), material.shininess);
    float specMask = diff > 0.0 ? 1.0 : 0.0;
    float3 ambient  = light.ambient  * diffuseColor * material.albedo.rgb * ao;
    float3 diffuse  = light.diffuse  * diff * diffuseColor * material.albedo.rgb;
    float3 specular = light.specular * spec * specMask  * specularColor.rgb;

    //hard shadow return (ambient + diffuse) * attenuation * ao + specular;
    return ambient + diffuse + specular;
}

float3 calcPoint(float3 diffuseColor, float4 specularColor, float3 normal, float ao, Light light, FragInput input, Material material, float3 viewDir){
    float3 lightDir = normalize(light.position - input.worldPos);
    float diff = max(dot(normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);

    float gloss = specularColor.a * material.gloss;
    
    //float shininess = pow(2.0, gloss * 8.0);  //0..1, 2..256
    //float shininess = exp2(10.0 * gloss + 1.0);
    float shininess = clamp(pow(2.0, gloss * 8.0), 1.0, 512.0);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), shininess);
    // float spec = pow(max(dot(normal, halfwayDir), 0.0), material.shininess);
    
    float distance = length(light.position - input.worldPos);
    float radius = light.radius;
    //if (distance > radius) return 0.0;

    float constantCoeff = 1;

    //too dark, need to adjust intensity
    //float d2 = distance * distance;
    //float attenuation = 1.0 / (d2, 0.01);
    
    float attenuation = 1.0 / (constantCoeff + light.linearCoeff * distance + 
  			     light.quadraticCoeff * (distance * distance));   
    float alpha = distance / radius;
    float damping = 1.0 - (alpha * alpha);  // smooth
    //or damping = 1.0 - pow(alpha, 4);
    attenuation = clamp(attenuation * damping, 0, 1);

    //float factor = distance / radius;
    
    //float smoothFactor = clamp(1.0 - factor * factor, 0.0, 1.0); //(1 - alpha^2)^2
    //float damping = smoothFactor * smoothFactor;
    //attenuation *= damping;
    //attenuation = clamp(attenuation, 0, 1);
    
    //float factor2 = factor * factor;
    //float factor4 = factor2 * factor2;
    //float windowing = clamp(1.0 - factor4, 0.0, 1.0);
    
    //attenuation = attenuation * (windowing * windowing);

    float3 ambient = light.ambient  * diffuseColor * material.albedo.rgb * ao;
    //float3 diffuse = light.diffuse  * diff * diffuseColor * material.albedo.rgb;
    
    float energyConservation = (shininess + 2.0) / 8.0; 
    float3 specular = light.specular * spec * specularColor.rgb * energyConservation * 0.04;
    //float3 specular = light.specular * spec * specularColor;

    float3 diffuse = light.diffuse  * diff * (1.0 - specular) * diffuseColor * material.albedo.rgb;

    //return ambient + (diffuse * attenuation) + (specular * attenuation);
    return (ambient + diffuse + specular) * attenuation;
}

float3 calcSpot(float3 diffuseColor, float4 specularColor, float3 normal, float ao, Light light, FragInput input, Material material, float3 viewDir)
{
    float3 lightDir = normalize(light.position - input.worldPos);
    float diff = max(dot(normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    
    float spec = pow(max(dot(normal, halfwayDir), 0.0), material.shininess);
    float specMask = diff > 0.0 ? 1.0 : 0.0;

    float distance = length(light.position - input.worldPos);
    float radius = light.radius;
    if (distance > radius) return 0.0;

    float constantCoeff = 1;

    float attenuation = 1.0 / (constantCoeff + light.linearCoeff * distance + light.quadraticCoeff * (distance * distance));  
    float alpha = distance / radius;
    float damping = 1.0 - (alpha * alpha);  // smooth
    //or damping = 1.0 - pow(alpha, 4);
    attenuation = clamp(attenuation * damping, 0, 1);  
    
    //float theta = dot(lightDir, normalize(-light.lightDirection)); 
    float theta = dot(lightDir, normalize(-light.direction));
    
    //float epsilon = light.cutoff - light.outerCutoff;
    float epsilon = max(light.cutoff - light.outerCutoff, 0.0001);
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);
    
    float3 ambient = light.ambient * diffuseColor * material.albedo.rgb * ao;
    float3 diffuse = light.diffuse * diff * diffuseColor  * material.albedo.rgb;
    float3 specular = light.specular * spec * specMask * specularColor.rgb;

    float combinedFactor = attenuation * intensity;

    float3 finalAmbient = ambient * attenuation;
    float3 finalDiffuse = diffuse * combinedFactor;
    float3 finalSpecular = specular * combinedFactor;
    
    return finalAmbient + finalDiffuse + finalSpecular;
}

FragOutputColor main(FragInput input, bool isFrontFace : SV_IsFrontFace)
{
    FragOutputColor result;

    if(matConfig.material.isLamp == 1){
        result.color = matConfig.material.albedo;
        return result;
    }

    //result.depth = linearizeDepthReversedDX(input.outPosition.z, config.nearPlane, config.farPlane);

    //SimpleDataBuffer dbuff;
    //dbuff.value1 = float4(0, lights[1].position);
    //sdataBuffer[0] = dbuff;

    //float ao = aoMap.Sample(sampler, texcoord).r;
    //float3 ambient = lightAmbientColor * materialDiffuse * ao;

    //float3 emissive = emissionMap.Sample(sampler, texcoord).rgb * emissionStrength;
    //finalColor.rgb += emissive;

    //light.ambient * material.albedo; 
    float3 resultColor = (float3) 0;

    float3 normalV = normalize(input.normal);
    float3 tangentV = normalize(input.tangent);
    
    //result.color = float4(input.tangent * 0.5 + 0.5, 1.0);
    //return result;

    // if (!isFrontFace) {
    //     normalV = -normalV;
    //     tangentV = -tangentV;
    // }

    //* 2.0 - 1.0 for SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM 
    float3 mapNormal = normalMap.Sample(normalSampler, input.texcoord).rgb;
    mapNormal = normalize(mapNormal);

    //OpenGL-style
    float3 bitangent = cross(normalV, tangentV);
    //result.color = float4(bitangent * 0.5 + 0.5, 1.0);
    //return result;
    
    float3x3 TBN = float3x3(tangentV, bitangent, normalV);
    //mapNormal.y = -mapNormal.y;
    float3 normal = normalize(mul(mapNormal, TBN)); 
    //result.color = float4(normal * 0.5 + 0.5, 1.0);
    //return result;

    float3 viewDir = normalize(sceneConfig.cameraPos - input.worldPos);

    //Disp map
    float3 viewDirTS = mul(viewDir, TBN); 
    float height = dispMap.Sample(dispMapSampler, input.texcoord).r;
    float scale = 0.03;
    float2 texUV = input.texcoord - (viewDirTS.xy / viewDirTS.z) * (height * scale);
    // if(texUV.x > 1.0 || texUV.y > 1.0 || texUV.x < 0.0 || texUV.y < 0.0){
    //     discard; 
    // }

    //diff = max(dot(N, lightDir), 0.0); 
    //Two side light
    //float diff = abs(dot(N, lightDir)); 

    // float3 p = input.localPos; 
    // float t = sceneConfig.time * 0.4;

    // // // 3D Domain Warping
    // p.x += 0.15 * sin(t + p.y * 4.0);
    // p.y += 0.15 * cos(t + p.z * 4.0);
    // p.z += 0.15 * sin(t + p.x * 4.0);
    
    // // // Wave summation
    // float v = 0.0;
    // v += cos(p.x * 8.0 + t);
    // v += cos(p.y * 7.0 + t * 1.1);
    // v += cos(p.z * 9.0 + t * 1.3);
    // v += cos(length(p.xyz) * 12.0 - t);
    
    // // v = saturate(v * 0.25 + 0.5);
    // float3 effectColor = palette(v + t * 0.1);
    // resultColor += effectColor;

    float ao = aoMap.Sample(aoSampler, input.texcoord).r;

    float4 fullDiffuseColor = diffuseMap.Sample(diffuseSampler, texUV);
    
    float3 diffuseColor = fullDiffuseColor.rgb;
    float4 specularColor = specularMap.Sample(specularSampler, texUV) * matConfig.material.specular;

    for (int li = 0; li < sceneConfig.lightCount; li++) {
         Light light = sceneConfig.lights[li];

         if(light.lightType == LightType::Directional){
            resultColor += calcDir(diffuseColor, specularColor, normal, ao, light, input, matConfig.material, viewDir);
         }else if(light.lightType == LightType::Point){
            resultColor += calcPoint(diffuseColor, specularColor, normal, ao, light, input, matConfig.material, viewDir);
         }else if(light.lightType == LightType::Spot){
            resultColor += calcSpot(diffuseColor, specularColor, normal, ao, light, input, matConfig.material, viewDir);
         }
    }

    //resultColor = clamp(resultColor, 0.0, 1.0);

    result.color = float4(resultColor, fullDiffuseColor.a);
    //output.a = max(texColor.a, luminance(specular));
    // result.color = float4(config.albedo.rgb * color, 1.0);
    //or if (texColor.a < 0.1) discard;
    return result;
}





