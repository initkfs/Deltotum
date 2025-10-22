module api.dm.kit.sprites3d.textures.depth_texture;

import api.dm.kit.sprites3d.textures.texture3d : Texture3d;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class DepthTexture : Texture3d
{

    this()
    {
        id = "DepthTexture";
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
        depthInfo.sample_count = SDL_GPU_SAMPLECOUNT_1;
        depthInfo.format = SDL_GPU_TEXTUREFORMAT_D16_UNORM;
        depthInfo.usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET;

        _texture = gpu.dev.newTexture(&depthInfo);
        if (!_texture)
        {
            throw new Exception("Depth texture is null");
        }
    }

}
