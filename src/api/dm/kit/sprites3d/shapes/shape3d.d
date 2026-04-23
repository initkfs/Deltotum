module api.dm.kit.sprites3d.shapes.shape3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites3d.materials.material_sprite3d : MaterialSprite3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class Shape3d : MaterialSprite3d
{
    ComVertex[] vertices;
    ushort[] indices;

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUBuffer* indexBuffer;

    protected
    {
        SDL_GPUTransferBuffer* transferBuffer;

        bool isBindBuffer;
    }

    this(ComVertex[] vertices, ushort[] indices = null, string diffuseMapPath = null, string specularMapPath = null, string normalMapPath = null, string dispMapPath = null)
    {
        this();
        this.vertices = vertices;
        this.indices = indices;
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;
        this.normalMapPath = normalMapPath;
        this.dispMapPath = dispMapPath;

        if (diffuseMapPath.length > 0 || specularMapPath.length > 0)
        {
            isCreateMaterial = true;
        }
    }

    this()
    {
        id = "Shape3d";
        isCalcInverseWorldMatrix = true;
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
            gpu.dev.setGPUBufferName(vertexBuffer, "ShapeVertexBuffer");
        }

        const indexBuffLen = indexCount * ushort.sizeof;

        if (!indexBuffer)
        {
            indexBuffer = gpu.dev.newGPUBufferIndex(indexBuffLen);
            gpu.dev.setGPUBufferName(indexBuffer, "ShapeIndexBuffer");
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

    override void uploadStart()
    {
        super.uploadStart;

        assert(transferBuffer);
        assert(vertexBuffer);
        assert(indexBuffer);
        gpu.dev.unmapAndUpload(transferBuffer, vertexBuffer, ComVertex.sizeof * vertices.length, 0, 0, false);
        gpu.dev.unmapAndUpload(transferBuffer, indexBuffer, ushort.sizeof * indices.length, ComVertex.sizeof * vertices
                .length, 0, false);
    }

    override void uploadEnd()
    {
        super.uploadEnd;
        assert(transferBuffer);
        gpu.dev.deleteTransferBuffer(transferBuffer);
        transferBuffer = null;
    }

    override void bindAll()
    {
        super.bindAll;

        if (!vertexBuffer)
        {
            throw new Exception("Vertex buffer is null");
        }

        if (!indexBuffer)
        {
            throw new Exception("Index buffer is null");
        }

        gpu.dev.bindVertexBuffer(vertexBuffer);
        gpu.dev.bindIndexBuffer(indexBuffer);

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

    override void update(float dt)
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
