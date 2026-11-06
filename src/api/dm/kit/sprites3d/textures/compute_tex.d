module api.dm.kit.sprites3d.textures.compute_tex;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.kit.sprites3d.textures.tex3d : Tex3d;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class ComputeTex : Tex3d
{

    this()
    {
        id = "ComputeTex3d";
        isAutoMipMapLevels = false;
        isCreateSampler = false;
    }

    void createCompute(int width, int height, uint levels = 1)
    {
        uint flags = SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE |
            SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ |
            SDL_GPU_TEXTUREUSAGE_SAMPLER;

        auto newTexture = gpu.dev.newTexture(width, height, SDL_GPU_TEXTURETYPE_2D, gpu.dev.pipelineTextureFormat, flags, 1, levels);

        if (!newTexture)
        {
            throw new Exception("GPU texture is null");
        }

        _texture = newTexture;

        initSize(width, height);
    }

}
