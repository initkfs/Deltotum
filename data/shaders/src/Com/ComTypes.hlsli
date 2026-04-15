/**
* Author: initkfs
*/

struct VertInput
{
    float3 position : POSITION;
    float3 normal : NORMAL;
    float2 texcoord : TEXCOORD;
    float3 tangent  : TANGENT;
};

struct VertOutput
{
    float4 outPosition : SV_Position;
    float2 texcoord : TEXCOORD;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
    float3 worldPos : POSITION0;
    float3 localPos : POSITION1;
};

typedef VertOutput FragInput;

struct FragOutput
{
    float4 color : SV_Target0;
    float depth : SV_Depth;
};

struct FragOutputColor
{
    float4 color : SV_Target0;
};