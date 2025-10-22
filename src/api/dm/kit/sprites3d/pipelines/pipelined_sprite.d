module api.dm.kit.sprites3d.pipelines.pipelined_sprite;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.back.sdl3.gpu.sdl_gpu_pipeline : SdlGPUPipeline;

/**
 * Authors: initkfs
 */

class PipelinedSprite : Sprite3d
{
    protected
    {
        SdlGPUPipeline _pipeline;
    }

    string vertexShaderName;
    string fragmentShaderName;

    override void bindAll()
    {
        bindPipeline;
        super.bindAll;
    }

    void bindPipeline()
    {
        assert(_pipeline);
        gpu.dev.bindPipeline(_pipeline);
    }

    override void dispose()
    {
        super.dispose;

        if (_pipeline)
        {
            gpu.dev.deletePipeline(_pipeline);
        }
    }

    void createPipeline(
        uint numVertexSamples = 0,
        uint numVertexStorageBuffers = 0,
        uint numVertexUniformBuffers = 0,
        uint numVertexStorageTextures = 0,
        uint numFragSamples = 0,
        uint numFragStorageBuffers = 0,
        uint numFragUniformBuffers = 0,
        uint numFragStorageTextures = 0)
    {

        assert(vertexShaderName.length > 0);
        assert(fragmentShaderName.length > 0);

        auto vertShaderPath = gpu.shaderDefaultPath(vertexShaderName);
        auto fragShaderPath = gpu.shaderDefaultPath(fragmentShaderName);

        _pipeline = gpu.newPipeline(
            vertShaderPath, 
            fragShaderPath, 
            numVertexSamples,
            numVertexStorageBuffers,
            numVertexUniformBuffers,
            numVertexStorageTextures,
            numFragSamples,
            numFragStorageBuffers,
            numFragUniformBuffers,
            numFragStorageTextures);

        if (!_pipeline)
        {
            throw new Exception("Pipeline is null");
        }

    }

    SdlGPUPipeline pipeline()
    {
        assert(_pipeline);
        return _pipeline;
    }

    void pipeline(SdlGPUPipeline npipeline)
    {
        assert(npipeline, "New pipeline must not be null");
        _pipeline = npipeline;
    }

}
