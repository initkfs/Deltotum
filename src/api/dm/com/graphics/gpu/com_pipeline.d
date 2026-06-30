module api.dm.com.graphics.gpu.com_pipeline;

/**
 * Authors: initkfs
 */
struct ComPipelineBuffers
{
    uint numVertexSamples;
    uint numVertexStorageBuffers;
    uint numVertexUniformBuffers;
    uint numVertexStorageTextures;
    uint numFragSamples;
    uint numFragStorageBuffers;
    uint numFragUniformBuffers;
    uint numFragStorageTextures;

    string toString() const
    {
        import std.format : format;

        return format("VertexSample:%d, VertexStorage:%d, VertexUniform:%d, VertexStorageTexture:%d, FragSample:%d, FragStorage:%d, FragUniform:%d, FragStorageTexture:%d", numVertexSamples, numVertexStorageBuffers, numVertexUniformBuffers, numVertexStorageTextures, numFragSamples, numFragStorageBuffers, numFragUniformBuffers, numFragStorageTextures);
    }
}

struct ComComputeBuffers
{
    uint numSamplers = 0;
    uint numRTextures = 0;
    uint numRBuffers = 0;
    uint numRWTextures = 0;
    uint numRWBuffers = 0;
    uint numUniforms = 0;
}
