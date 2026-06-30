module api.dm.kit.sprites3d.meshes.mesh3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class Mesh3d : MaterialSprite3d
{
    ComVertex[] vertices;
    SDL_GPUBuffer* vertexBuffer;
    bool isCreateVertexBuffer = true;

    SDL_GPUTransferBuffer* transferBuffer;
    bool isCreateTransferBuffer = true;
    bool isCopyToBuffer = true;

    protected
    {
        bool isBindBuffer;
    }

    this(ComVertex[] vertices = null)
    {
        id = "Mesh3d";
        isCalcInverseWorldMatrix = true;
        this.vertices = vertices;
    }

    void createMesh()
    {

    }

    override void create()
    {
        super.create;

        if (numId == 0)
        {
            numId = scene.nextUniqId;
        }

        createMesh;

        if (vertices.length == 0)
        {
            throw new Exception("Not found any vertex for mesh");
        }

        if (!vertexBuffer && isCreateVertexBuffer)
        {
            vertexBuffer = newVertexBuffer;
        }

        if (!transferBuffer && isCreateTransferBuffer)
        {
            transferBuffer = newTransferBuffer;
        }

        if (isCopyToBuffer)
        {
            copyToBuffer;
        }
    }

    size_t vertexBufferLen() => vertices.length * ComVertex.sizeof;
    size_t transferBufferLen() => vertexBufferLen;

    SDL_GPUBuffer* newVertexBuffer()
    {
        const buffLen = vertexBufferLen;
        if (buffLen == 0)
        {
            throw new Exception("Vertex buffer must not be 0");
        }
        auto buff = gpu.dev.newGPUBufferVertex(buffLen);
        gpu.dev.setGPUBufferName(vertexBuffer, "MeshVertexBuffer");
        return buff;
    }

    SDL_GPUTransferBuffer* newTransferBuffer()
    {
        const buffLen = transferBufferLen;
        if (buffLen == 0)
        {
            throw new Exception("Transfer buffer must not be 0");
        }
        auto buff = gpu.dev.newTransferUploadBuffer(transferBufferLen);
        return buff;
    }

    void copyToBuffer()
    {
        if (transferBuffer)
        {
            gpu.dev.copyToBuffer(transferBuffer, false, vertices);
        }
    }

    override void uploadStart()
    {
        super.uploadStart;

        if (transferBuffer && vertexBuffer)
        {
            gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, vertexBufferLen, 0, 0, false);
        }
    }

    override void uploadEnd()
    {
        super.uploadEnd;

        if (transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(transferBuffer);
            transferBuffer = null;
        }
    }

    override void bindAll()
    {
        super.bindAll;

        if (vertexBuffer)
        {
            gpu.dev.bindVertexBuffer(vertexBuffer);
            isBindBuffer = true;
        }
    }

    override void drawContent()
    {
        if (vertices.length > 0)
        {
            gpu.dev.draw(vertices.length, 1, 0, 0);
        }

        isBindBuffer = false;
    }

    override void dispose()
    {
        super.dispose;

        if (vertexBuffer)
        {
            gpu.dev.deleteGPUBuffer(vertexBuffer);
        }

        if (transferBuffer)
        {
            gpu.dev.deleteTransferBuffer(transferBuffer);
        }
    }
}
