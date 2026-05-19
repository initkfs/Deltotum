module api.dm.kit.sprites3d.textures.heat_texture_array;

import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class HeatTextureArray : TextureGPU
{
    size_t count;

    this(float w = 256, float h = 256, size_t count = 1024)
    {
        initSize(w, h);
        id = "HeatTextureArray";
        assert(count > 0);
        this.count = count;
    }

    override void create()
    {
        super.create;

        SDL_GPUTextureCreateInfo texInfo;
        texInfo.type = SDL_GPU_TEXTURETYPE_2D_ARRAY;
        texInfo.width = widthi;
        texInfo.height = heighti;
        texInfo.layer_count_or_depth = cast(int) count;
        texInfo.num_levels = 1;
        texInfo.sample_count = SDL_GPU_SAMPLECOUNT_1;
        texInfo.format = SDL_GPU_TEXTUREFORMAT_R16_FLOAT;

        texInfo.usage = SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE |
            SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ |
            SDL_GPU_TEXTUREUSAGE_SAMPLER;

        _texture = gpu.dev.newTexture(&texInfo);
        if (!_texture)
        {
            throw new Exception("Heat texture array is null");
        }
    }

}
