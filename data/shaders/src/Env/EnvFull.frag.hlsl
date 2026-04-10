/**
* Author: initkfs
*/

Texture2D<float4> diffuseMap : register(t0, space2);
SamplerState diffuseSampler : register(s0, space2);

Texture2D<float4> specularMap : register(t1, space2);
SamplerState specularSampler : register(s1, space2);

struct SimpleDataBuffer
{
     float4 value1;
};

//u2 for two textures
RWStructuredBuffer<SimpleDataBuffer> sdataBuffer : register(u1, space2);

struct Material
{
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float3 color;
    float shininess;
};

namespace LightType {
    static const uint Directional = 0;
    static const uint Point = 1;
    static const uint Spot = 2;
};

struct PlaneInfo {
    float nearPlane;
    float farPlane;
};

struct Light {
    float3 position;
    float3 direction;
    float3 lightDirection;
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float constantCoeff;
    float linearCoeff;
    float quadraticCoeff;
    float cutoff;
    float outerCutoff;
    uint lightType;
};

cbuffer UBO : register(b0, space3)
{
    PlaneInfo planes;
    float3 cameraPos;
    Material material;
    Light lights[6];
    uint lightCount; 
};

struct Input
{
    float4 position : SV_Position;
    float2 texcoord : TEXCOORD;
    float3 normal : NORMAL;
    float3 fragPos : POSITION;
};

struct Output
{
    float4 color : SV_Target0;
    float depth : SV_Depth;
};

float linearizeDepth(float depth, float near, float far)
{
    //OpenGL style
    //float z = depth * 2.0 - 1.0;
    //float linearDepth = ((2.0 * near * far) / (far + near - z * (far - near))) / far;
    //return linearDepth;
    float linearDepth = (near * far) / (far - depth * (far - near));
    return linearDepth / far;
}

float3 calcDir(Light light, Input input, Material material, float3 viewDir){
    //position not used
    float3 lightDir = normalize(-light.direction);
    float diff = max(dot(input.normal, lightDir), 0.0);
    float3 reflectDir = reflect(-lightDir, input.normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    
    float3 diffuseColor = diffuseMap.Sample(diffuseSampler, input.texcoord).rgb;
    float3 ambient  = light.ambient  * diffuseColor;
    float3 diffuse  = light.diffuse  * diff * diffuseColor;
    //float3 specular = light.specular * spec * specularMap.Sample(specularSampler, input.texcoord).rgb;
    return (ambient + diffuse);
}

float3 calcPoint(Light light, Input input, Material material, float3 viewDir){
    
    float3 lightDir = normalize(light.position - input.fragPos);
    float diff = max(dot(input.normal, lightDir), 0.0);
    float3 reflectDir = reflect(-lightDir, input.normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);

    float distance = length(light.position - input.fragPos);
    float attenuation = 1.0 / (light.constantCoeff + light.linearCoeff * distance + 
  			     light.quadraticCoeff * (distance * distance));    
    
    float3 diffuseColor = diffuseMap.Sample(diffuseSampler, input.texcoord).rgb;

    float3 ambient = light.ambient  * diffuseColor;
    float3 diffuse = light.diffuse  * diff * diffuseColor;
    //float3 specular = light.specular * spec * specularMap.Sample(specularSampler, input.texcoord).rgb;
    
    ambient  *= attenuation;
    diffuse  *= attenuation;
    //specular *= attenuation;

    return (ambient + diffuse);
}

float3 calcSpot(Light light, Input input, Material material, float3 viewDir)
{
    float3 lightDir = normalize(light.position - input.fragPos);
    float diff = max(dot(input.normal, lightDir), 0.0);
    float3 reflectDir = reflect(-lightDir, input.normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
   
    float distance = length(light.position - input.fragPos);
    float attenuation = 1.0 / (light.constantCoeff + light.linearCoeff * distance + light.quadraticCoeff * (distance * distance));    
    float theta = dot(lightDir, normalize(-light.lightDirection)); 
    float epsilon = light.cutoff - light.outerCutoff;
    float intensity = clamp((theta - light.outerCutoff) / epsilon, 0.0, 1.0);

    float3 diffuseColor = diffuseMap.Sample(diffuseSampler, input.texcoord).rgb;

    float3 ambient = light.ambient * diffuseColor;
    float3 diffuse = light.diffuse * diff * diffuseColor;
    //float3 specular = light.specular * spec * specularMap.Sample(specularSampler, input.texcoord).rgb;
    ambient *= attenuation * intensity;
    diffuse *= attenuation * intensity;
    //specular *= attenuation * intensity;
    return (ambient + diffuse);
}

Output main(Input input)
{
    Output result;

    //SimpleDataBuffer dbuff;
    //dbuff.value1 = float4(0, lights[1].position);
    //sdataBuffer[0] = dbuff;

    float3 resultColor = float3(0, 0, 0);

    float3 viewDir = normalize(cameraPos - input.fragPos);

    for (int li = 0; li < lightCount; li++) {
         Light light = lights[li];

         if(light.lightType == LightType::Directional){
            resultColor += calcDir(light, input, material, viewDir);
         }else if(light.lightType == LightType::Point){
            resultColor += calcPoint(light, input, material, viewDir);
         }else if(light.lightType == LightType::Spot){
            resultColor += calcSpot(light, input, material, viewDir);
         }
    }


    result.color = float4(resultColor, 1);
    result.depth = linearizeDepth(input.position.z, planes.nearPlane, planes.farPlane);
    return result;
}