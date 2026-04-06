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

struct Input
{
    float3 texcoords : TEXCOORD0;
};

struct Output
{
    float3 texcoords : TEXCOORD0;
    float4 position : SV_Position;
};

Output main(float3 texcoords : TEXCOORD0)
{
    Output output;

    output.texcoords = texcoords;

    float4 pos = float4(texcoords, 1.0);
    pos = mul(pos, model);
    pos = mul(pos, view);
    pos = mul(pos, projection);
    output.position = pos;
    
    return output;
}