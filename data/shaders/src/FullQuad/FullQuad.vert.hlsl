/**
* Author: initkfs
*/

struct VOutput {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
};

VOutput main(uint vID : SV_VertexID)
{
    VOutput output;
    // [-1, 1] UV [0, 1]
    output.uv = float2((vID << 1) & 2, vID & 2);
    output.pos = float4(output.uv * 2.0f - 1.0f, 0.0f, 1.0f);
    
    // DirectX/SDL_GPU Y inversion
    output.uv.y = 1.0f - output.uv.y; 
    
    return output;
}