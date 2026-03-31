module api.dm.kit.scenes.antialiasings.msaa;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class MSAA : GraphicComponent
{

    SDL_GPUSampleCount aliasingSampleCount = SDL_GPU_SAMPLECOUNT_4;

    SDL_GPUTexture* msaaTexture;
    SDL_GPUTextureFormat textureFormat = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;

    override void create()
    {
        super.create;

        if (!SDL_GPUTextureSupportsSampleCount(gpu.dev.ptr, textureFormat, aliasingSampleCount))
        {
            debug
            {
                import std.conv : to;

                throw new Exception("Unsupported msaa format: " ~ textureFormat.to!string);
            }
        }

        gpu.dev.isUseSampleCount = true;
        gpu.dev.sampleCount = aliasingSampleCount;
        gpu.dev.pipeLineTargetFormat = textureFormat;

        SDL_GPUTextureCreateInfo msaTextureInfo;
        msaTextureInfo.type = SDL_GPU_TEXTURETYPE_2D;
        msaTextureInfo.width = window.widthu;
        msaTextureInfo.height = window.heightu;
        msaTextureInfo.layer_count_or_depth = 1;
        msaTextureInfo.num_levels = 1;
        msaTextureInfo.format = textureFormat;
        msaTextureInfo.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET;
        msaTextureInfo.sample_count = aliasingSampleCount;

        if (aliasingSampleCount == SDL_GPU_SAMPLECOUNT_1)
        {
            msaTextureInfo.usage |= SDL_GPU_TEXTUREUSAGE_SAMPLER;
        }

        msaaTexture = SDL_CreateGPUTexture(gpu.dev.ptr, &msaTextureInfo);
        if (!msaaTexture)
        {
            throw new Exception("MSAA texture is null");
        }
    }

    override void dispose()
    {
        super.dispose;
        if (msaaTexture)
        {
            gpu.dev.deleteTexture(msaaTexture);
        }
    }

}
