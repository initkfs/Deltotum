module api.dm.kit.sprites3d.textures.depth_tex;

import api.dm.kit.sprites3d.textures.tex3d : Tex3d;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class DepthTex : Tex3d
{
    SDL_GPUSampleCount sampleCount = SDL_GPU_SAMPLECOUNT_1;
    bool isMultiSampler;

    this()
    {
        id = "DepthTex";
    }

    override void create()
    {
        super.create;

        SDL_GPUTextureCreateInfo depthInfo;
        depthInfo.type = SDL_GPU_TEXTURETYPE_2D;
        depthInfo.width = cast(int) window.width;

        depthInfo.height = cast(int) window.height;
        depthInfo.layer_count_or_depth = 1;
        depthInfo.num_levels = 1;
        depthInfo.sample_count = sampleCount;
        depthInfo.format = gpu.dev.depthTextureFormat;
        if (isMultiSampler)
        {
            depthInfo.usage = SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET;
        }else {
            depthInfo.usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET;
        }

        _texture = gpu.dev.newTexture(&depthInfo);
        if (!_texture)
        {
            throw new Exception("Depth texture is null");
        }
    }

}
