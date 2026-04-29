module api.dm.kit.sprites3d.meshes.mesh3d_indexed;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.meshes.mesh3d : Mesh3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class Mesh3dHigh : Mesh3dIndexed!uint
{
    this(ComVertex[] vertices = null, uint[] indices = null)
    {
        super(vertices, indices);
    }
}

class Mesh3dLow : Mesh3dIndexed!ushort
{
    this(ComVertex[] vertices = null, ushort[] indices = null)
    {
        super(vertices, indices);
    }
}

class Mesh3dIndexed(IndexType) : Mesh3d
        if (is(IndexType == ushort) || is(IndexType == uint))
{

    IndexType[] indices;
    SDL_GPUBuffer* indexBuffer;
    bool isCreateIndexBuffer = true;

    this(ComVertex[] vertices = null, IndexType[] indices = null)
    {
        super(vertices);
        this.indices = indices;
        isCopyToBuffer = false;
    }

    override void create()
    {
        super.create;

        if (!indexBuffer && isCreateIndexBuffer)
        {
            indexBuffer = newIndexBuffer;
        }

        copyToBuffer;
    }

    SDL_GPUBuffer* newIndexBuffer()
    {
        const buffLen = indexBufferLen;
        if (buffLen == 0)
        {
            throw new Exception("Index buffer length must not be 0");
        }
        auto buff = gpu.dev.newGPUBufferIndex(buffLen);
        gpu.dev.setGPUBufferName(indexBuffer, "MeshIndexBuffer");
        return buff;
    }

    size_t indexBufferLen() => indices.length * IndexType.sizeof;
    override size_t transferBufferLen() => vertexBufferLen + indexBufferLen;

    override void copyToBuffer()
    {
        gpu.dev.copyToBuffer(transferBuffer, false, vertices, indices);
    }

    override void uploadStart()
    {
        super.uploadStart;

        if (transferBuffer && indexBuffer)
        {
            gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, indexBufferLen, vertexBufferLen, 0, false);
        }
    }

    override void bindAll()
    {
        super.bindAll;

        if (!indexBuffer)
        {
            return;
        }

        static if (IndexType.sizeof == 2)
        {
            gpu.dev.bindIndexBuffer16(indexBuffer);
        }
        else static if (IndexType.sizeof == 4)
        {
            gpu.dev.bindIndexBuffer32(indexBuffer);
        }
        else
        {
            static assert(false, "Unsupported index type: " ~ IndexType.stringof);
        }

        isBindBuffer = true;
    }

    void drawIndexed()
    {
        if (indices.length == 0)
        {
            throw new Exception("Not found index buffer");
        }

        if (!isBindBuffer)
        {
            throw new Exception("Buffers not bind");
        }

        gpu.dev.drawIndexed(indices.length, 1, 0, 0, 0);
    }

    override void drawContent()
    {
        drawIndexed;
        isBindBuffer = false;
    }

    override void dispose()
    {
        super.dispose;

        if (indexBuffer)
        {
            gpu.dev.deleteGPUBuffer(indexBuffer);
        }
    }
}
