module api.dm.kit.sprites3d.textures.cubemap;

import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class CubeMap : TextureGPU
{
    alias create = TextureGPU.create;

    string[6] faces;
    string basePath;

    this(string basePath, string ext = "jpg")
    {
        this.basePath = basePath;

        faces = [
            "right." ~ ext,
            "left." ~ ext,
            "top." ~ ext,
            "bottom." ~ ext,
            "front." ~ ext,
            "back." ~ ext
        ];
    }

    override void create()
    {
        super.create;
        createSampler;
    }

    override void uploadStart()
    {
        // assert w == 0, not super.uploadStart;

        import api.dm.com.graphics.com_surface : ComSurface;

        ComSurface imageLoader = graphic.comSurfaceProvider.getNew();

        foreach (fi, faceName; faces)
        {
            auto facePath = basePath ~ faceName;

            foreach (codec; graphic.comImageCodecs)
            {
                if (codec.isSupport(facePath))
                {
                    if (const err = codec.load(facePath, imageLoader))
                    {
                        throw new Exception(err.toString);
                    }
                    break;
                }
                //TODO not found codec
            }

            if (imageLoader.getFormat != SDL_PIXELFORMAT_ABGR8888)
            {
                if (const err = imageLoader.convert(SDL_PIXELFORMAT_ABGR8888))
                {
                    throw new Exception(err.toString);
                }
            }

            //TODO check size oldW == w, oldH == h
            int w = imageLoader.getWidth;
            int h = imageLoader.getHeight;

            assert(w > 0);
            assert(h > 0);

            void* rawImagePtr;
            if (const err = imageLoader.getPixelsRGBA(rawImagePtr))
            {
                throw new Exception(err.toString);
            }

            size_t imageLen = w * h * 4;

            if (!_texture)
            {
                SDL_GPUTextureCreateInfo info;
                info.type = SDL_GPU_TEXTURETYPE_CUBE;
                info.format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM;
                info.width = w;
                info.height = h;
                info.layer_count_or_depth = 6;
                info.num_levels = 1;
                info.usage = SDL_GPU_TEXTUREUSAGE_COLOR_TARGET | SDL_GPU_TEXTUREUSAGE_SAMPLER;

                _texture = SDL_CreateGPUTexture(gpu.dev.ptr, &info);
                if (!texture)
                {
                    throw new Exception("Cubemap texture is empty");
                }
            }

            if (!_transferBuffer)
            {
                _transferBuffer = gpu.dev.newTransferUploadBuffer(cast(uint) imageLen);
            }

            ubyte[] imagePtr = (cast(ubyte*) rawImagePtr)[0 .. imageLen];

            auto transBuffMap = gpu.dev.mapTransferBuffer(_transferBuffer, cycle:
                true);
            ubyte[] transBuffSlice = (cast(ubyte*) transBuffMap)[0 .. imageLen];
            transBuffSlice[0 .. imageLen] = imagePtr[];
            gpu.dev.uploadTexture(_transferBuffer, texture, cast(uint) w, cast(uint) h, 0, false, cast(
                    uint) fi);

            imageLoader.dispose;
        }
    }

    override void uploadEnd()
    {
        super.uploadEnd;
    }

    override void bindAll()
    {
        super.bindAll;
        gpu.dev.bindFragmentSamplers(this);
    }

    override void createSampler()
    {
        SDL_GPUSamplerCreateInfo samplerInfo = gpu.dev.nearestClampToEdge;
        _sampler = gpu.dev.newSampler(&samplerInfo);
        assert(_sampler);
    }
}
