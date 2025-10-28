module api.dm.kit.sprites3d.shapes.shape3d;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.com.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.lightings.lighting_material : LightingMaterial;

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

    LightingMaterial lightingMaterial;
    bool isCreateLightingMaterial;

    string diffuseMapPath;
    string specularMapPath;

    protected
    {
        SDL_GPUTransferBuffer* transferBuffer;
    }

    this(ComVertex[] vertices, ushort[] indices = null, string diffuseMapPath = null, string specularMapPath = null)
    {
        this.vertices = vertices;
        this.indices = indices;
        this.diffuseMapPath = diffuseMapPath;
        this.specularMapPath = specularMapPath;

        if (diffuseMapPath.length > 0 || specularMapPath.length > 0)
        {
            isCreateLightingMaterial = true;
        }
    }

    this()
    {
        id = "Shape3d";
        isPushUniformVertexMatrix = true;
        isCreateLightingMaterial = true;
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

        if (!lightingMaterial)
        {
            if (isCreateLightingMaterial)
            {
                import api.dm.kit.sprites3d.lightings.phongs.materials.phong_material : PhongMaterial;

                lightingMaterial = new PhongMaterial(diffuseMapPath, specularMapPath);
                addCreate(lightingMaterial);
            }
        }
        else
        {
            if (!lightingMaterial.isCreated)
            {
                addCreate(lightingMaterial);
            }
        }
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
        gpu.dev.bindVertexBuffer(vertexBuffer);
        gpu.dev.bindIndexBuffer(indexBuffer);
    }

    void drawIndexed()
    {
        gpu.dev.drawIndexed(indices.length, 1, 0, 0, 0);
    }

    override void drawContent()
    {
        drawIndexed;
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
