/**
* Author: initkfs
*/

struct VOutput {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
};

static float2 positions[6] = {
        float2(-1, -1), float2(1, -1), float2(-1, 1),
        float2(-1, 1), float2(1, -1), float2(1, 1)
};

VOutput main(uint vID : SV_VertexID)
{
    VOutput output;
    float2 pos = positions[vID];
    output.uv = pos * 0.5f + 0.5f; // UV from [-1, 1] to [0, 1]
    output.uv.y = 1.0f - output.uv.y; 
    //Z=0.5, W=1.0
    output.pos = float4(pos.x, pos.y, 0.00001f, 1.0f);
    return output;
}