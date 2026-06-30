module api.dm.kit.sprites3d.textures.heat_texture_array;

import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;

class HeatTextureArray : TextureGPU
{
    size_t count;

    this(float w = 16, float h = 16, size_t count = 256)
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
        texInfo.type = SDL_GPU_TEXTURETYPE_3D;
        texInfo.width = widthi;
        texInfo.height = heighti;
        texInfo.layer_count_or_depth = cast(int) count;
        texInfo.num_levels = 1;
        texInfo.sample_count = SDL_GPU_SAMPLECOUNT_1;
        texInfo.format = SDL_GPU_TEXTUREFORMAT_R32_FLOAT; //SDL_GPU_TEXTUREFORMAT_R16_FLOAT;

        texInfo.usage = SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE |
            SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ |
            SDL_GPU_TEXTUREUSAGE_SAMPLER;

        _texture = gpu.dev.newTexture(&texInfo);
        if (!_texture)
        {
            throw new Exception("Heat texture array is null");
        }

        //createSampler;
        SDL_GPUSamplerCreateInfo samplerInfo;
        samplerInfo.min_filter = SDL_GPU_FILTER_NEAREST;
        samplerInfo.mag_filter = SDL_GPU_FILTER_NEAREST;
        samplerInfo.mipmap_mode = SDL_GPU_SAMPLERMIPMAPMODE_NEAREST;
        samplerInfo.address_mode_u = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;
        samplerInfo.address_mode_v = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;
        samplerInfo.address_mode_w = SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE;

        _sampler = gpu.dev.newSampler(&samplerInfo);
        isDisposeSampler = true;
    }

    override void uploadStart()
    {
        import core.stdc.stdlib : malloc, free;

        uint width = widthu;
        uint height = heightu;
        uint depth = cast(uint) count;

        size_t bufferSize = width * height * depth;
        size_t bufferSizeBytes = bufferSize * float.sizeof;
        float* cpuDataPtr = cast(float*) malloc(bufferSizeBytes);
        if (!cpuDataPtr)
        {
            throw new Exception("cpu data is null");
        }

        scope (exit)
        {
            free(cpuDataPtr);
        }

        float[] cpuData = cpuDataPtr[0 .. bufferSize];
        cpuData[] = 20;

        uint centerX = widthu / 2;
        uint centerY = heightu / 2;
        uint centerZ = 1;
        size_t pixelIndex = centerX + (centerY * width) + (centerZ * width * height);
        cpuData[0 .. 10] = 50000.0f;

        SDL_GPUTransferBuffer* transferBuffer = gpu.dev.newTransferUploadBuffer(
            cast(uint) bufferSizeBytes);
        // scope (exit)
        // {
        //     gpu.dev.deleteTransferBuffer(transferBuffer);
        // }
        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer, false);
        float[] transBuffSlize = (cast(float*) transBuffMap)[0 .. bufferSize];
        transBuffSlize[0 .. bufferSize] = cpuData[0 .. bufferSize];

        gpu.dev.unmapTransferBuffer(transferBuffer);

        SDL_GPUTextureTransferInfo sourceInfo;
        sourceInfo.transfer_buffer = transferBuffer;
        sourceInfo.offset = 0;
        sourceInfo.pixels_per_row = widthu;
        sourceInfo.rows_per_layer = heightu;

        SDL_GPUTextureRegion destRegion;
        destRegion.texture = texture;
        destRegion.mip_level = 0;
        destRegion.x = 0;
        destRegion.y = 0;
        destRegion.z = 0;
        destRegion.w = widthu;
        destRegion.h = heightu;
        destRegion.d = depth;

        gpu.dev.uploadTexture(&sourceInfo, &destRegion, false);
    }

}
