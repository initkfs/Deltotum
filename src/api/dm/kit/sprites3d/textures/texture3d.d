module api.dm.kit.sprites3d.textures.texture3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class Texture3d : Sprite3d
{
    string name = "Texture3D";

    protected
    {
        SDL_GPUTexture* _texture;
        SDL_GPUSampler* _sampler;
        SDL_GPUTransferBuffer* _transferBuffer;
    }

    void createSampler()
    {
        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestRepeat;
        _sampler = gpu.dev.newSampler(&samplerInfo);
        assert(_sampler);
    }

    void create(string path)
    {
        import api.dm.back.sdl3.images.sdl_image : SdlImage;

        scope image = new SdlImage();
        scope(exit){
            image.dispose;
        }

        if (const err = image.create(path))
        {
            throw new Exception(err.toString);
        }

        if (image.getFormat != SDL_PIXELFORMAT_ABGR8888)
        {
            if (const err = image.convert(SDL_PIXELFORMAT_ABGR8888))
            {
                throw new Exception(err.toString);
            }
        }

        int w = image.getWidth;
        int h = image.getHeight;

        void* rawImagePtr;
        if (const err = image.getPixels(rawImagePtr))
        {
            throw new Exception(err.toString);
        }

        size_t imageLen = w * h * 4;

        ubyte[] imagePtr = (cast(ubyte*) rawImagePtr)[0 .. imageLen];

        auto newTexture = gpu.dev.newTexture(w, h, SDL_GPU_TEXTURETYPE_2D, SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM, SDL_GPU_TEXTUREUSAGE_SAMPLER, 1, 1);
        assert(newTexture);

        _texture = newTexture;

        _transferBuffer = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);

        auto transBuffMap = gpu.dev.mapTransferBuffer(_transferBuffer, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        width = w;
        height = h;

        gpu.dev.unmapTransferBuffer(_transferBuffer);

        createSampler;

        import std.string : toStringz;

        SDL_SetGPUTextureName(gpu.dev.getObject, _texture, name.toStringz);
    }

    override void create()
    {
        super.create();
    }

    void uploadStart()
    {
        assert(width > 0);
        assert(height > 0);
        assert(_transferBuffer);
        assert(_texture);
        gpu.dev.uploadTexture(_transferBuffer, _texture, cast(uint) width, cast(uint) height);
    }

    void uploadEnd()
    {
        if (_transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(_transferBuffer);
        }
    }

    SDL_GPUTexture* texture()
    {
        assert(_texture);
        return _texture;
    }

    SDL_GPUSampler* sampler()
    {
        assert(_sampler);
        return _sampler;
    }

    SDL_GPUTransferBuffer* transferBuffer()
    {
        assert(_transferBuffer);
        return _transferBuffer;
    }

    override void dispose()
    {
        super.dispose;

        if (_texture)
        {
            gpu.dev.deleteTexture(_texture);
        }

        if (_sampler)
        {
            SDL_ReleaseGPUSampler(gpu.dev.getObject, _sampler);
        }
    }
}
