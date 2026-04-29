module api.dm.kit.sprites3d.meshes.sphere;

import api.dm.kit.sprites3d.meshes.mesh3d_indexed : Mesh3dHigh;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;
import api.math.geom3.sphere3 : Sphere3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Sphere : Mesh3dHigh
{
    float radius = 0;

    this(float radius = 0.5)
    {
        this.initSize(radius, radius);
        this.radius = radius;
    }

    override void createMesh()
    {
        enum sectors = 32;
        enum stacks = 16;
        enum sphereVerticesCount = (stacks + 1) * (
                sectors + 1);
        enum trianglesIndicesCount = stacks * sectors * 6;

        vertices = new ComVertex[sphereVerticesCount];
        indices = new uint[trianglesIndicesCount];

        float sectorStep = 2.0f * Math.PI / sectors;
        float stackStep = Math.PI / stacks;

        int index = 0;

        for (int i = 0; i <= stacks; ++i)
        {
            float stackAngle = Math.PI / 2 - i * stackStep; // from π/2 to -π/2
            float xy = radius * Math.cos(stackAngle); // radius on XZ plane
            float y = radius * Math.sin(stackAngle); // Y coordinate

            for (int j = 0; j <= sectors; ++j)
            {
                float sectorAngle = j * sectorStep; // from 0 to 2π

                // Vertex position
                float x = xy * Math.cos(sectorAngle); // X = r * cos(φ) * cos(θ)
                float z = xy * Math.sin(sectorAngle); // Z = r * cos(φ) * sin(θ)

                // Normal (normalized vector from center to vertex)
                float nx = x / radius;
                float ny = y / radius;
                float nz = z / radius;

                // UV coordinates
                float u = cast(float) j / sectors; // U: 0.0 to 1.0
                float v = cast(float) i / stacks; // V: 0.0 to 1.0

                float tx = -Math.sin(sectorAngle);
                float ty = 0.0f;
                float tz = Math.cos(sectorAngle);

                vertices[index] = ComVertex(x, y, z, [nx, ny, nz], u, v, tx, ty, tz);
                index++;
            }
        }

        index = 0;

        for (uint i = 0; i < stacks; ++i)
        {
            for (uint j = 0; j < sectors; ++j)
            {
                uint k1 = i * (sectors + 1) + j; // top-left
                uint k2 = k1 + 1; // top-right
                uint k3 = k1 + (sectors + 1); // bottom-left
                uint k4 = k3 + 1; // bottom-right

                // top-left -> bottom-left -> bottom-right
                indices[index++] = k1;
                indices[index++] = k2;
                indices[index++] = k4;

                // top-left -> bottom-right -> top-right
                indices[index++] = k1;
                indices[index++] = k4;
                indices[index++] = k3;
            }
        }

    }

    override Sphere3f sphereBounds() => Sphere3f(pos3, radius);

    override bool isInCameraFrustum()
    {
        if (camera.frustum.isSphereVisible(pos3, radius))
        {
            return true;
        }
        return false;
    }

    override void create()
    {
        super.create;
    }

    override void dispose()
    {
        super.dispose;
    }
}
