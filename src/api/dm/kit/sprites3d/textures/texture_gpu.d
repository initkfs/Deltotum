module api.dm.kit.sprites3d.textures.texture_gpu;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.com.graphics.com_surface : ComSurface;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class TextureGPU : Sprite3d
{
    bool isCreateSampler;

    protected
    {
        SDL_GPUTexture* _texture;
        SDL_GPUTransferBuffer* _transferBuffer;

        SDL_GPUSampler* _sampler;
        bool isDisposeSampler;

        bool _upload;
    }

    this()
    {
        id = "TextureGPU";
    }

    void createSampler()
    {
        if (!isCreateSampler)
        {
            _sampler = gpu.defaultSampler;
            isDisposeSampler = false;
        }

        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestRepeat;
        _sampler = gpu.dev.newSampler(&samplerInfo);
        isDisposeSampler = true;
    }

    void create(int width, int height, RGBA color = RGBA.red)
    {
        auto image = graphic.comSurfaceProvider.getNew();
        scope (exit)
        {
            image.dispose;
        }

        auto textureFormat = gpu.dev.textureFormat;

        if (const err = image.create(width, height, textureFormat))
        {
            throw new Exception(err.toString);
        }

        if (const err = image.fill(color.r, color.g, color.b, color.aByte))
        {
            throw new Exception(err.toString);
        }

        create(image);
    }

    void create(string path)
    {
        ComSurface comSurf;

        foreach (codec; graphic.comImageCodecs)
        {
            if (codec.isSupport(path))
            {
                comSurf = graphic.comSurfaceProvider.getNew();
                if (const err = codec.load(path, comSurf))
                {
                    throw new Exception(err.toString);
                }
                break;
            }
        }

        if (!comSurf)
        {
            throw new Exception("Not supported path: " ~ path);
        }

        scope (exit)
        {
            comSurf.dispose;
        }

        create(comSurf);
    }

    void create(ComSurface image)
    {
        auto imagePixelFormat = gpu.dev.textureFormat;
        if (image.getFormat != imagePixelFormat)
        {
            if (const err = image.convert(imagePixelFormat))
            {
                throw new Exception(err.toString);
            }
        }

        int w = image.getWidth;
        int h = image.getHeight;

        if (w == 0 || h == 0)
        {
            throw new Exception("Texture buffer size must be positive");
        }

        void* rawImagePtr;
        if (const err = image.getPixelsRGBA(rawImagePtr))
        {
            throw new Exception(err.toString);
        }

        int bpp = SDL_GetPixelFormatDetails(imagePixelFormat).bytes_per_pixel;

        size_t imageLen = w * h * bpp;

        ubyte[] imagePtr = (cast(ubyte*) rawImagePtr)[0 .. imageLen];

        auto newTexture = gpu.dev.newTexture(w, h, SDL_GPU_TEXTURETYPE_2D, gpu.dev.pipeLineTargetFormat, SDL_GPU_TEXTUREUSAGE_SAMPLER, 1, 1);

        if (!newTexture)
        {
            throw new Exception("GPU texture is null");
        }

        _texture = newTexture;

        _transferBuffer = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);
        auto transBuffMap = gpu.dev.mapTransferBuffer(_transferBuffer, false);
        ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
        transBuffSlice[0 .. imageLen] = imagePtr[];

        width = w;
        height = h;

        gpu.dev.unmapTransferBuffer(_transferBuffer);

        createSampler;

        if (id.length > 0)
        {
            import std.string : toStringz;

            SDL_SetGPUTextureName(gpu.dev.ptr, _texture, id.toStringz);
        }
    }

    override void create()
    {
        super.create();
    }

    override void uploadStart()
    {
        super.uploadStart;

        assert(width > 0);
        assert(height > 0);
        assert(_transferBuffer);
        assert(_texture);
        gpu.dev.uploadTexture(_transferBuffer, _texture, cast(uint) width, cast(uint) height);
        _upload = true;
    }

    bool isUpload() => _upload;

    override void uploadEnd()
    {
        super.uploadEnd;
        if (_transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(_transferBuffer);
            _transferBuffer = null;
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

        if (_sampler && isDisposeSampler)
        {
            SDL_ReleaseGPUSampler(gpu.dev.ptr, _sampler);
        }

        if (_transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(_transferBuffer);
        }
    }
}
