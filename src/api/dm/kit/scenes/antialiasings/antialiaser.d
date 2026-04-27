module api.dm.kit.scenes.antialiasings.antialiaser;

import api.dm.kit.components.graphic_component : GraphicComponent;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */

class AntiAliaser : GraphicComponent
{

    SDL_GPUTexture* texture;
    SDL_GPUSampler* sampler;
    SDL_GPUTextureFormat textureFormat = SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT;

    abstract void process(SDL_GPUTexture* inTexture, SDL_GPUTexture* outTexture, bool isMix2d3dMode);

    override void dispose()
    {
        super.dispose;

        if (texture)
        {
            gpu.dev.deleteTexture(texture);
        }

        if (sampler)
        {
            gpu.dev.deleteSampler(sampler);
        }
    }
}
