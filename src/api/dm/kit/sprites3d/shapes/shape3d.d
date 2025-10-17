module api.dm.kit.sprites3d.shapes.shape3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.com.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4f;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class Shape3d : Sprite3d
{
    ComVertex[] vertices;
    ushort[] indices;

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUBuffer* indexBuffer;

    protected
    {
        SDL_GPUTransferBuffer* transferBuffer;
    }

    void createMesh()
    {

    }

    override void create()
    {
        super.create;

        createMesh;

        assert(vertices.length > 0, "Vertices not found");

        const vertexCount = vertices.length;
        const indexCount = indices.length;

        const vertexBuffLen = vertexCount * ComVertex.sizeof;

        if (!vertexBuffer)
        {
            vertexBuffer = gpu.dev.newGPUBufferVertex(vertexBuffLen);
        }

        const indexBuffLen = indexCount * ushort.sizeof;

        if (!indexBuffer)
        {
            indexBuffer = gpu.dev.newGPUBufferIndex(indexBuffLen);
        }

        if (!transferBuffer)
        {
            transferBuffer = gpu.dev.newTransferUploadBuffer(vertexBuffLen + indexBuffLen);
        }

        copyToBuffer;
    }

    void copyToBuffer()
    {
        gpu.dev.copyToBuffer(transferBuffer, false, vertices, indices);
    }

    void uploadStart()
    {
        assert(transferBuffer);
        assert(vertexBuffer);
        assert(indexBuffer);
        gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, ComVertex.sizeof * vertices.length, 0, 0, false);
        gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, ushort.sizeof * indices.length, ComVertex.sizeof * vertices
                .length, 0, false);
    }

    void uploadEnd()
    {
        assert(transferBuffer);
        gpu.dev.deleteTransferBuffer(transferBuffer);
        transferBuffer = null;
    }

    void bindBuffers()
    {
        gpu.dev.bindVertexBuffer(vertexBuffer);
        gpu.dev.bindIndexBuffer(indexBuffer);
    }

    void drawIndexed()
    {
        gpu.dev.drawIndexed(indices.length, 1, 0, 0, 0);
    }

    override void update(double dt)
    {
        super.update(dt);
    }

    override void dispose()
    {
        super.dispose;

        if (vertexBuffer)
        {
            gpu.dev.deleteGPUBuffer(vertexBuffer);
        }

        if (indexBuffer)
        {
            gpu.dev.deleteGPUBuffer(indexBuffer);
        }

        if (transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(transferBuffer);
        }
    }
}
