module api.dm.kit.sprites3d.primitives.cube;

import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.com.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4f;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom2.vec3 : Vec3f;

/**
 * Authors: initkfs
 */

class Cube : Sprite3d
{
    ComVertex[24] vertices;

    Vec3f rotation;
    Vec3f scale = Vec3f(1, 1, 1);

    float posZ = 0;

    protected
    {
        align(16)
        {
            Matrix4x4f localMatrix;
        }
    }

    //ccw
    ushort[] indices = [
        // front face
        0, 1, 2, 0, 2, 3,
        // back face
        4, 5, 6, 4, 6, 7,
        //left face
        8, 9, 10, 8, 10, 11,
        // right face
        12, 13, 14, 12, 14, 15,
        //top face
        16, 17, 18, 16, 18, 19,
        // bottom face
        20, 21, 22, 20, 22, 23
    ];

    double depth = 0;

    SDL_GPUBuffer* vertexBuffer;
    SDL_GPUBuffer* indexBuffer;

    protected
    {
        SDL_GPUTransferBuffer* transferBuffer;
    }

    this(double width, double height, double depth)
    {
        this.initSize(width, height);
        this.depth = depth;
    }

    override void create()
    {
        super.create;

        localMatrix = Matrix4x4f.onesDiag;

        const halfWidth = cast(float)(width / 2.0);
        const halfHeight = cast(float)(height / 2.0);
        const halfDepth = cast(float)(depth / 2.0);

        vertices = [
            // Front face (Z = +halfDepth)
            ComVertex(-halfWidth, -halfHeight, halfDepth, 0.0f, 1.0f), // 0: left bottom
            ComVertex(halfWidth, -halfHeight, halfDepth, 1.0f, 1.0f), // 1: bottom right
            ComVertex(halfWidth, halfHeight, halfDepth, 1.0f, 0.0f), // 2: top right
            ComVertex(-halfWidth, halfHeight, halfDepth, 0.0f, 0.0f), // 3: top left

            // Back face (Z = -halfDepth)
            ComVertex(halfWidth, -halfHeight, -halfDepth, 0.0f, 1.0f), // 4: bottom right
            ComVertex(-halfWidth, -halfHeight, -halfDepth, 1.0f, 1.0f), // 5: bottom left
            ComVertex(-halfWidth, halfHeight, -halfDepth, 1.0f, 0.0f), // 6: top left
            ComVertex(halfWidth, halfHeight, -halfDepth, 0.0f, 0.0f), // 7: top right

            // Left face (X = -halfWidth)
            ComVertex(-halfWidth, -halfHeight, -halfDepth, 0.0f, 1.0f), // 8: bottom back
            ComVertex(-halfWidth, -halfHeight, halfDepth, 1.0f, 1.0f), // 9: bottom front
            ComVertex(-halfWidth, halfHeight, halfDepth, 1.0f, 0.0f), // 10: top front
            ComVertex(-halfWidth, halfHeight, -halfDepth, 0.0f, 0.0f), // 11: top back

            // Right face (X = halfWidth)
            ComVertex(halfWidth, -halfHeight, halfDepth, 0.0f, 1.0f), // 12: bottom front
            ComVertex(halfWidth, -halfHeight, -halfDepth, 1.0f, 1.0f), // 13: bottom back
            ComVertex(halfWidth, halfHeight, -halfDepth, 1.0f, 0.0f), // 14: top back
            ComVertex(halfWidth, halfHeight, halfDepth, 0.0f, 0.0f), // 15: top front

            // Top face (Y = halfHeight)
            ComVertex(-halfWidth, halfHeight, halfDepth, 0.0f, 1.0f), // 16: front left
            ComVertex(halfWidth, halfHeight, halfDepth, 1.0f, 1.0f), // 17: front right
            ComVertex(halfWidth, halfHeight, -halfDepth, 1.0f, 0.0f), // 18: back right
            ComVertex(-halfWidth, halfHeight, -halfDepth, 0.0f, 0.0f), // 19: back left

            // Bottom face (Y = -halfHeight)
            ComVertex(-halfWidth, -halfHeight, -halfDepth, 0.0f, 1.0f), // 20: back left
            ComVertex(halfWidth, -halfHeight, -halfDepth, 1.0f, 1.0f), // 21: back right
            ComVertex(halfWidth, -halfHeight, halfDepth, 1.0f, 0.0f), // 22: front right
            ComVertex(-halfWidth, -halfHeight, halfDepth, 0.0f, 0.0f), // 23: front left
        ];

        uint len = cast(uint)(vertices.length * ComVertex.sizeof + ushort.sizeof * indices.length);

        vertexBuffer = gpu.dev.newGPUBufferVertex(vertices.length * ComVertex.sizeof);
        transferBuffer = gpu.dev.newTransferUploadBuffer(len);

        gpu.dev.copyToBuffer(transferBuffer, false, vertices, indices);

        indexBuffer = gpu.dev.newGPUBufferIndex(ushort.sizeof * indices.length);
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

    ref Matrix4x4f worldMatrix()
    {
        //TODO lazy
        localMatrix = localMatrix.identity;

        //Scale -> Rotate -> Translate
        import api.math.matrices.affine3;

        //TODO dirty flag
        if(scale.x != 1 || scale.y != 1 || scale.z != 1){
            localMatrix = localMatrix.mul(scaleMatrix(scale));
        }

        if (angle != 0 && (rotation.x != 0 || rotation.y != 0 || rotation.z != 0))
        {
            localMatrix = localMatrix.mul(rotateMatrix(angle, rotation));
        }

        if(pos.x != 0 || pos.y != 0 || posZ != 0){
            localMatrix = localMatrix.mul(translateMatrix(Vec3f(pos.x, pos.y, posZ)));
        }

        return localMatrix;
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
