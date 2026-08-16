module api.dm.sim3d.diffusions.textures.diffusion_texture_array;

import api.dm.kit.sprites3d.textures.tex3d : Tex3d;

/**
 * Authors: initkfs
 */

import api.dm.back.sdl3.externs.csdl3;
import core.stdc.stdlib : malloc, free, realloc;

class DiffusionTextureArray : Tex3d
{
    size_t count;

    bool isKeepBuffer = true;

    protected
    {
        float[] dataBuffer;
    }

    this(float w = 32, float h = 32, size_t count = 256)
    {
        initSize(w, h);
        id = "DiffusionTextureArray";
        assert(count > 0);
        this.count = count;

        isMipMaps = false;
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

    size_t dataBufferSize()
    {
        uint depth = cast(uint) count;
        size_t bufferSize = widthu * heightu * depth;
        return bufferSize;
    }

    size_t dataBufferSizeBytes(size_t bufferSize) => bufferSize * float.sizeof;

    void createDataBuffer()
    {
        size_t bufferSize = dataBufferSize;
        if (bufferSize == 0)
        {
            throw new Exception("Buffer size must not be 0");
        }

        if (dataBuffer.length == bufferSize)
        {
            dataBuffer[] = 0;
            return;
        }

        size_t bufferSizeBytes = dataBufferSizeBytes(bufferSize);

        float* cpuDataPtr;
        if (dataBuffer.length == 0)
        {
            cpuDataPtr = cast(float*) malloc(bufferSizeBytes);
        }
        else
        {
            cpuDataPtr = cast(float*) realloc(dataBuffer.ptr, bufferSizeBytes);
        }

        if (!cpuDataPtr)
        {
            throw new Exception("Data buffer allocation fail");
        }

        dataBuffer = cpuDataPtr[0 .. bufferSize];
    }

    void deleteDataBuffer()
    {
        //TODO is null?
        if (dataBuffer.length == 0)
        {
            return;
        }

        free(dataBuffer.ptr);
        dataBuffer = null;
    }

    override void uploadStart()
    {
        createDataBuffer;

        if (!isKeepBuffer)
        {
            scope (exit)
            {
                deleteDataBuffer;
            }
        }

        const bufferSize = dataBufferSize;
        const buffSizeBytes = dataBufferSizeBytes(bufferSize);

        createTransferBuffer(buffSizeBytes);

        auto transBuffMap = gpu.dev.mapTransferBuffer(transferBuffer, false);
        float[] transBuffSlize = (cast(float*) transBuffMap)[0 .. bufferSize];
        transBuffSlize[0 .. bufferSize] = dataBuffer[0 .. bufferSize];

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
        destRegion.d = cast(uint) count;

        gpu.dev.uploadTexture(&sourceInfo, &destRegion, false);
        _upload = true;
    }

    // void setIndex(float value = 0, float u0to1 = 0, uint v0to1 = 0, size_t heatZ = 0)
    // {
    //     uint heatX = cast(uint)(u0to1 * width);
    //     uint heatY = cast(uint)(v0to1 * height);

    //     if (heatX >= width)
    //         heatX = widthi - 1;
    //     if (heatY >= height)
    //         heatY = heighti - 1;

    //     size_t pixelIndex = heatX + (heatZ * heatY * widthu);
    //     if (pixelIndex >= dataBuffer.length)
    //     {
    //         import std.format : format;

    //         throw new Exception(format("Data buffer overflow with index %d, but length %d", pixelIndex, dataBuffer
    //                 .length));
    //     }
    //     dataBuffer[pixelIndex] = value;
    // }

    // SDL_GPUTransferBuffer* updateUV(float value = 0, float u0to1 = 0, uint v0to1 = 0, size_t heatZ = 0)
    // {
    //     uint heatX = cast(uint)(u0to1 * width);
    //     uint heatY = cast(uint)(v0to1 * height);

    //     if (heatX >= width)
    //         heatX = widthi - 1;
    //     if (heatY >= height)
    //         heatY = heighti - 1;

    //     //size_t pixelIndex = heatX + (heatZ * heatY * widthu);

    //     SDL_GPUTransferBuffer* tbuff = gpu.dev.newTransferBuffer(float.sizeof);
    //     auto transBuffMap = gpu.dev.mapTransferBuffer(tbuff, false);
    //     *(cast(float*) transBuffMap) = value;      
    //     gpu.dev.unmapTransferBuffer(transBuffMap);  

    //     SDL_GPUTextureTransferInfo source;
    //     //Direct3D 12
    //     //pixels_per_row align 256, offset align 512
    //     source.transfer_buffer = tbuff;
    //     source.offset = 0;

    //     SDL_GPUTextureRegion dest;
    //     dest.texture = _texture;
    //     dest.mip_level = 0;
    //     dest.x = heatX;
    //     dest.y = heatY;
    //     dest.z = 0;
    //     dest.w = 1;
    //     dest.h = 1;
    //     dest.d = 1;
    //     dest.layer = heatZ;

    //     gpu.dev.uploadTexture(&source, &dest, true);

    //     return tbuff;
    // }

}
