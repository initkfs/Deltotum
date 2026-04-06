/**
* Author: initkfs
*/

cbuffer UniformBlock : register(b0, space1)
{
    row_major float4x4 model;
    row_major float4x4 view;
    row_major float4x4 projection;
    row_major float4x4 normal;
};

#include "Com/ComTypes.hlsli"

VertOutput main(VertInput input)
{
    VertOutput output;

    float4 pos = float4(input.position, 1.0f);
    pos = mul(pos, model);
    pos = mul(pos, view);
    pos = mul(pos, projection);
    output.outPosition = pos;

    output.texcoord = float2(input.texcoord.x, 1.0 - input.texcoord.y);
    
    output.normal = normalize(mul((float3x3) normal, input.normal));
    output.localPos = input.position;
    output.worldPos = (mul(float4(input.position, 1.0f), model)).xyz;
    
    return output;
}