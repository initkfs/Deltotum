module api.dm.kit.sprites3d.pipelines.pipeline_group;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material : Material;
import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;
import api.dm.com.graphics.gpu.com_pipeline : ComPipelineBuffers;

import api.dm.back.sdl3.externs.csdl3;

struct SimpleDataBuffer
{
    float[4] value1;
}

struct SharedMaterials
{
    Material material;
    MaterialSprite3d[] sprites;
}

/**
 * Authors: initkfs
 */

class PipelineGroup : Sprite3d
{
    bool isBlend;

    protected
    {
        SdlGPUPipeline _comPipeline;

        PipelineGroup[] childPipelines;

        bool _hasSprites;

        SharedMaterials[string] sharedMaterials;
    }

    bool isPushUniformVertexMatrix;

    string vertexShaderName;
    string fragmentShaderName;

    bool isDepth = true;
    bool isCreateDataBuffer;
    bool isBindForEmptyChildren;

    SDL_GPUBuffer* dataBufferPtr;
    SDL_GPUTransferBuffer* dataTransferBufferPtr;

    this()
    {
        isPushUniformVertexMatrix = false;
        isForPipeLine = false;
    }

    override void create()
    {
        super.create;

        if (isCreateDataBuffer)
        {
            dataBufferPtr = gpu.dev.newGPUBuffer(SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ, SimpleDataBuffer
                    .sizeof);
            gpu.dev.setGPUBufferName(dataBufferPtr, "DataBuffer");
            dataTransferBufferPtr = gpu.dev.newTransferDownloadBuffer(SimpleDataBuffer.sizeof);
        }

        // import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;

        // if (auto sprite3d = cast(MaterialSprite3d) sprite)
        // {
        //     if (sprite3d.hasMaterial && sprite3d.material.isSharedMaterial)
        //     {
        //     }
        // }
    }

    override bool isNeedDraw(Sprite2d sprite)
    {
        if (!super.isNeedDraw(sprite))
        {
            return false;
        }

        import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;

        if (auto sprite3d = cast(MaterialSprite3d) sprite)
        {
            if (sprite3d.hasMaterial && sprite3d.material.isSharedMaterial)
            {
                return false;
            }
        }

        return true;
    }

    override bool draw(float alpha)
    {
        foreach (pipe; childPipelines)
        {
            if (pipe.bindPipeline)
            {
                if (pipe.isCreateDataBuffer)
                {
                    pipe.bindDataBuffer;
                }
                pipe.draw(alpha);
            }

        }

        if (bindPipeline)
        {
            if (isCreateDataBuffer)
            {
                bindDataBuffer;
            }

            if (sharedMaterials.length > 0)
            {
                foreach (ref sm; sharedMaterials)
                {
                    if (sm.sprites.length == 0)
                    {
                        continue;
                    }

                    Material m = sm.material;
                    bindMaterialSafe(m);
                    foreach (sp; sm.sprites)
                    {
                        sp.bindAll;
                        pushSpriteUniforms(sp);
                        //TODO check prev flag
                        sp.isCanDrawSelf = true;
                        sp.draw(alpha);
                        sp.isCanDrawSelf = false;
                    }
                }
            }

            return super.draw(alpha);
        }

        return false;
    }

    void bindSpriteData(Sprite3d sprite)
    {

    }

    void bindMaterialSafe(Material mat)
    {

    }

    void pushSpriteUniforms(Sprite3d sprite)
    {

    }

    void bindDataBuffer()
    {
        gpu.dev.bindFragmentStorageBuffer(dataBufferPtr);
    }

    bool bindPipeline()
    {
        //assert(_comPipeline);
        if (!_comPipeline)
        {
            return false;
        }

        if (((!_hasSprites) || children.length == 0) && !isBindForEmptyChildren)
        {
            return false;
        }

        gpu.dev.bindPipeline(_comPipeline);

        //import api.math.geom2.rect2 : Rect2f;

        //TODO extract to scene?
        //gpu.dev.setViewport(Rect2f(-1, -1, 1, 1));

        return true;
    }

    override bool add(Sprite2d object, long index = -1)
    {
        if (!super.add(object, index))
        {
            return false;
        }

        if (auto pipeline = cast(PipelineGroup) object)
        {
            //TODO check exists
            childPipelines ~= pipeline;
            pipeline.isDrawByParent = false;
        }
        else
        {
            if (!_hasSprites)
            {
                //TODO on remove
                _hasSprites = true;
            }
        }

        return true;
    }

    ComPipelineBuffers pipeBuffers()
    {
        ComPipelineBuffers buffers;
        if (isCreateDataBuffer)
        {
            buffers.numFragStorageBuffers = 1;
        }
        return buffers;
    }

    void createPipeline(
        in ComPipelineBuffers buffers,
        SDL_GPUGraphicsPipelineTargetInfo* colorDesc = null,
        SDL_GPURasterizerState* rasterState = null,
        SDL_GPUDepthStencilState* stencilState = null,
        scope void delegate(
            ref SDL_GPUGraphicsPipelineCreateInfo) onPipeSettings = null
    )
    {
        assert(!_comPipeline, "Found old pipeline");

        assert(vertexShaderName.length > 0);
        assert(
            fragmentShaderName.length > 0);

        auto vertShaderPath = gpu.shaderDefaultPath(
            vertexShaderName);
        auto fragShaderPath = gpu.shaderDefaultPath(
            fragmentShaderName);

        _comPipeline = gpu.newPipeline(
            vertShaderPath,
            fragShaderPath,
            buffers,
            colorDesc,
            rasterState,
            stencilState,
            id,
            onPipeSettings
        );
        if (!_comPipeline)
        {
            throw new Exception("Pipeline is null");
        }
    }

    void createPipeline(ComPipelineBuffers buffers, scope void delegate(
            ref SDL_GPUGraphicsPipelineCreateInfo) onPipeSettings = null)
    {
        SDL_GPUGraphicsPipelineTargetInfo targetInfo;

        SDL_GPUColorTargetDescription[1] targetDesc;
        targetDesc[0].format = gpu.dev.pipelineTextureFormat;
        targetInfo.num_color_targets = 1;
        targetInfo.color_target_descriptions = targetDesc
            .ptr;
        if (isDepth)
        {
            targetInfo.has_depth_stencil_target = true;
            targetInfo.depth_stencil_format = gpu.dev.depthTextureFormat;
        }

        if (isBlend)
        {
            SDL_GPUColorTargetBlendState blendState;
            if (!gpu.dev.isA2C)
            {
                blendState.enable_blend = true;
            }

            blendState.src_color_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA,
            blendState.dst_color_blendfactor = SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
            blendState.color_blend_op = SDL_GPU_BLENDOP_ADD,
            blendState.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE,
            blendState.dst_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ZERO,
            blendState.alpha_blend_op = SDL_GPU_BLENDOP_ADD;

            // blendState.color_write_mask = cast(ubyte) (SDL_GPU_COLORCOMPONENT_R |
            //     SDL_GPU_COLORCOMPONENT_G |
            //     SDL_GPU_COLORCOMPONENT_B |
            //     SDL_GPU_COLORCOMPONENT_A);

            targetDesc[0].blend_state = blendState;
        }

        auto stencilState = gpu.dev.depthStencilState;
        if (isBlend)
        {
            stencilState.enable_depth_write = false;
        }

        auto rastState = createRasterizerState;

        createPipeline(
            buffers,
            &targetInfo,
            &rastState,
            &stencilState,
            onPipeSettings);
    }

    SDL_GPURasterizerState createRasterizerState()
    {
        import KitConfig = api.dm.kit.kit_config_keys;

        bool isLineMode = config.getBoolIfHas(KitConfig.backendGPUShowLines);
        bool isCullDisable = config.getBoolIfHas(KitConfig.backendGPUDisableCull);

        auto fillMode = !isLineMode ? SDL_GPU_FILLMODE_FILL : SDL_GPU_FILLMODE_LINE;
        auto cullMode = !isCullDisable ? SDL_GPU_CULLMODE_BACK : SDL_GPU_CULLMODE_NONE;

        return gpu.dev.rasterizerState(fillMode, cullMode);
    }

    SdlGPUPipeline comPipeline()
    {
        assert(_comPipeline);
        return _comPipeline;
    }

    void comPipeline(SdlGPUPipeline npipeline)
    {
        assert(npipeline, "New pipeline must not be null");
        _comPipeline = npipeline;
    }

    SimpleDataBuffer downloadData()
    {
        gpu.dev.startCopyPass;
        gpu.dev.downloadBuffer(dataBufferPtr, dataTransferBufferPtr, SimpleDataBuffer.sizeof);
        gpu.dev.endCopyPass(true, true);

        SimpleDataBuffer dataBuffer;
        auto dataBuffPtr = cast(SimpleDataBuffer*) gpu.dev.mapTransferBuffer(dataTransferBufferPtr);
        dataBuffer.value1 = (*dataBuffPtr).value1;
        gpu.dev.unmapTransferBuffer(dataTransferBufferPtr);
        return dataBuffer;
    }

    Material newSharedMaterial(string id = "Material")
    {
        auto m = new Material;
        m.id = id;
        build(m);
        m.isSharedMaterial = true;

        auto mId = m.id;
        foreach (ref sm; sharedMaterials)
        {
            if (sm.material.id == mId)
            {
                throw new Exception("Shared material already exists with id: " ~ mId);
            }
        }

        sharedMaterials[mId] = SharedMaterials(m);
        return m;
    }

    void addSharedMaterialSprite(MaterialSprite3d sprite)
    {
        if (!sprite.hasMaterial)
        {
            throw new Exception("Material is null");
        }

        foreach (ref sm; sharedMaterials)
        {
            if (sm.material.id == sprite.material.id)
            {
                foreach (sp; sm.sprites)
                {
                    if (sp is sprite)
                    {
                        return;
                    }
                }

                sm.sprites ~= sprite;
            }
        }
    }

    bool removeSharedMatSprite(MaterialSprite3d sprite)
    {
        foreach (ref sm; sharedMaterials)
        {
            if (sm.material.id == sprite.material.id)
            {
                foreach (sp; sm.sprites)
                {
                    if (sp is sprite)
                    {
                        import api.core.utils.arrays : drop;

                        return drop(sm.sprites, sp);
                    }
                }
            }
        }

        return false;
    }

    override PipelineGroup pipelineForChild() => this;

    override void dispose()
    {
        super.dispose;

        _pipeline = null;

        if (sharedMaterials.length > 0)
        {
            foreach (mdata; sharedMaterials)
            {
                mdata.material.dispose;
            }

            sharedMaterials = null;
        }

        if (_comPipeline)
        {
            gpu.dev.deletePipeline(_comPipeline);
        }

        if (dataBufferPtr)
        {
            gpu.dev.deleteGPUBuffer(dataBufferPtr);
            dataBufferPtr = null;
        }

        if (dataTransferBufferPtr)
        {
            gpu.dev.deleteTransferBuffer(dataTransferBufferPtr);
            dataTransferBufferPtr = null;
        }
    }

}
