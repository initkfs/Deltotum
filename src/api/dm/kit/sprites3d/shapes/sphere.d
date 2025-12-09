module api.dm.kit.sprites3d.shapes.sphere;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4f;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Sphere : Shape3d
{
    double radius = 0;

    this(double radius)
    {
        this.initSize(radius / 2, radius / 2);
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
        indices = new ushort[trianglesIndicesCount];

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

                vertices[index] = ComVertex(x, y, z, [nx, ny, nz], u, v);
                index++;
            }
        }

        index = 0;

        for (int i = 0; i < stacks; ++i)
        {
            for (int j = 0; j < sectors; ++j)
            {
                int k1 = i * (sectors + 1) + j; // top-left
                int k2 = k1 + 1; // top-right
                int k3 = k1 + (sectors + 1); // bottom-left
                int k4 = k3 + 1; // bottom-right

                // First triangle: top-left -> bottom-left -> top-right
                indices[index++] = cast(ushort) k1;
                indices[index++] = cast(ushort) k3;
                indices[index++] = cast(ushort) k2;

                // Second triangle: top-right -> bottom-left -> bottom-right
                indices[index++] = cast(ushort) k2;
                indices[index++] = cast(ushort) k3;
                indices[index++] = cast(ushort) k4;
            }
        }

    }

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
