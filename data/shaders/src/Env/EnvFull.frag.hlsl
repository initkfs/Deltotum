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

//TODO one sampler for all
//SamplerState mainSampler : register(s0, space2);

// struct SimpleDataBuffer
// {
//      float4 value1;
// };

// RWStructuredBuffer<SimpleDataBuffer> sdataBuffer : register(u0, space2);

namespace LightType {
    static const uint Directional = 0;
    static const uint Point = 1;
    static const uint Spot = 2;
};

struct Material
{
    float4 albedo;
    float4 ambient;
    float4 diffuse;
    float4 specular;
    float shininess;
    float intensity;
    float reserve1;
    float reserve2;
};

struct Light {
    float3 position;
    uint lightType;
    float3 direction;
    float linearCoeff;
    float3 lightDirection;
    float constantCoeff;
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
    Light lights[4];
    Material material;
    //TODO replace with lamp pipeline
    uint isLamp;
};

cbuffer UBO : register(b0, space3)
{
    SceneConfig config;
};

#include "Com/ComTypes.hlsli"
#include "Com/ComDepth.hlsli"

float3 palette(float t) {
    float3 a = float3(0.5, 0.5, 0.5);
    float3 b = float3(0.5, 0.5, 0.5);
    float3 c = float3(1.0, 1.0, 1.0);
    float3 d = float3(0.26, 0.41, 0.55); // Сине-голубая гамма (можно менять)
    return a + b * cos(6.28318 * (c * t + d));
}

float3 calcDir(float3 diffuseColor, float3 specularColor, Light light, FragInput input, Material material, float3 viewDir){
    float3 lightDir = normalize(-light.direction);
    float diff = max(dot(input.normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(input.normal, halfwayDir), 0.0), material.shininess);
    //float spec = pow(max(dot(viewDir, halfwayDir), 0.0), material.shininess);
    float specMask = diff > 0.0 ? 1.0 : 0.0;
    float3 ambient  = light.ambient  * diffuseColor;
    float3 diffuse  = light.diffuse  * diff * diffuseColor;
    float3 specular = light.specular * spec * specMask  * specularColor;

    return ambient + diffuse + specular;
}

float3 calcPoint(float3 diffuseColor, float3 specularColor, Light light, FragInput input, Material material, float3 viewDir){
    float3 lightDir = normalize(light.position - input.worldPos);
    float diff = max(dot(input.normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(input.normal, halfwayDir), 0.0), material.shininess);
    
    float distance = length(light.position - input.worldPos);
    
    float attenuation = 1.0 / (light.constantCoeff + light.linearCoeff * distance + 
  			     light.quadraticCoeff * (distance * distance));   
    float specMask = diff > 0.0 ? 1.0 : 0.0;

    float3 ambient = light.ambient  * diffuseColor;
    float3 diffuse = light.diffuse  * diff * diffuseColor;
    float3 specular = light.specular * spec * specMask * specularColor;

    //return ambient + (diffuse * attenuation) + (specular * attenuation);
    return (ambient + diffuse + specular) * attenuation;
}

float3 calcSpot(float3 diffuseColor, float3 specularColor, Light light, FragInput input, Material material, float3 viewDir)
{
    float3 lightDir = normalize(light.position - input.worldPos);
    float diff = max(dot(input.normal, lightDir), 0.0);
    //float3 reflectDir = reflect(-lightDir, input.normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    
    float spec = pow(max(dot(input.normal, halfwayDir), 0.0), material.shininess);
    float specMask = diff > 0.0 ? 1.0 : 0.0;

    float distance = length(light.position - input.worldPos);
    float attenuation = 1.0 / (light.constantCoeff + light.linearCoeff * distance + light.quadraticCoeff * (distance * distance));    
    float theta = dot(lightDir, normalize(-light.lightDirection)); 
    
    //float epsilon = light.cutoff - light.outerCutoff;
    float epsilon = max(light.cutoff - light.outerCutoff, 0.0001);
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);
    
    float3 ambient = light.ambient * diffuseColor;
    float3 diffuse = light.diffuse * diff * diffuseColor;
    float3 specular = light.specular * spec * specMask * specularColor;

    float combinedFactor = attenuation * intensity;

    float3 finalAmbient = ambient * attenuation;
    float3 finalDiffuse = diffuse * combinedFactor;
    float3 finalSpecular = specular * combinedFactor;
    
    return finalAmbient + finalDiffuse + finalSpecular;
}

FragOutput main(FragInput input)
{
    FragOutput result;

    result.depth = linearizeDepthReversedDX(input.outPosition.z, config.nearPlane, config.farPlane);

    //SimpleDataBuffer dbuff;
    //dbuff.value1 = float4(0, lights[1].position);
    //sdataBuffer[0] = dbuff;

    //float ao = aoMap.Sample(sampler, texcoord).r;
    //float3 ambient = lightAmbientColor * materialDiffuse * ao;

    //float3 emissive = emissionMap.Sample(sampler, texcoord).rgb * emissionStrength;
    //finalColor.rgb += emissive;

    float3 resultColor = config.material.albedo.rgb;

    if(config.isLamp == 1){
        result.color = float4(resultColor, 1);
        return result;
    }

    float3 p = input.localPos; 
    float t = config.time * 0.4;

    // // 3D Domain Warping
    p.x += 0.15 * sin(t + p.y * 4.0);
    p.y += 0.15 * cos(t + p.z * 4.0);
    p.z += 0.15 * sin(t + p.x * 4.0);
    
    // // Wave summation
    float v = 0.0;
    v += cos(p.x * 8.0 + t);
    v += cos(p.y * 7.0 + t * 1.1);
    v += cos(p.z * 9.0 + t * 1.3);
    v += cos(length(p.xyz) * 12.0 - t);
    
    // v = saturate(v * 0.25 + 0.5);
    float3 effectColor = palette(v + t * 0.1);
    resultColor += effectColor;

    float3 viewDir = normalize(config.cameraPos - input.worldPos);
    float3 diffuseColor = diffuseMap.Sample(diffuseSampler, input.texcoord).rgb;
    float3 specularColor = specularMap.Sample(specularSampler, input.texcoord).rgb;

    for (int li = 0; li < config.lightCount; li++) {
         Light light = config.lights[li];

         if(light.lightType == LightType::Directional){
            resultColor += calcDir(diffuseColor, specularColor, light, input, config.material, viewDir);
         }else if(light.lightType == LightType::Point){
            resultColor += calcPoint(diffuseColor, specularColor, light, input, config.material, viewDir);
         }else if(light.lightType == LightType::Spot){
            resultColor += calcSpot(diffuseColor, specularColor, light, input, config.material, viewDir);
         }
    }

    result.color = float4(resultColor, 1);

    // result.color = float4(config.albedo.rgb * color, 1.0);
    return result;
}





