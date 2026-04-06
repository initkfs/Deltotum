/**
* Author: initkfs
*/

TextureCube<float4> skyboxTexture : register(t0, space2);
SamplerState skyboxSampler : register(s0, space2);

float4 main(float3 texcoords : TEXCOORD0) : SV_Target0
{
    return skyboxTexture.Sample(skyboxSampler, texcoords);
}