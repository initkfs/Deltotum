module api.dm.kit.sprites3d.shapes.cylinder;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4f;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom2.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Cylinder : Shape3d
{
    float bottomRadius = 0;
    float topRadius = 0;
    float height = 0;

    this(float bottomRadius, float topRadius, float height)
    {
        this.bottomRadius = bottomRadius;
        this.topRadius = topRadius;
        this.height = height;
    }

    override void createMesh()
    {
        enum sectors = 16; // Number of sides
        enum stacks = 8; // Number of subdivisions along height

        enum cylinderVerticesCount = (sectors + 1) * (stacks + 1) + 2; // +2 for caps centers
        enum cylinderIndicesCount = sectors * stacks * 6 + sectors * 6; // sides + caps

        vertices = new ComVertex[cylinderVerticesCount];
        indices = new ushort[cylinderIndicesCount];

        float halfHeight = height / 2.0f;
        float sectorStep = 2.0f * Math.PI / sectors;
        float stackStep = height / stacks;
        float radiusDiff = topRadius - bottomRadius;

        int vertexIndex = 0;

        // Generate side vertices with correct normals for conical shapes
        for (int i = 0; i <= stacks; ++i)
        {
            float y = -halfHeight + i * stackStep;
            float radius = bottomRadius + radiusDiff * (i / cast(float) stacks);

            for (int j = 0; j <= sectors; ++j)
            {
                float sectorAngle = j * sectorStep;
                float x = Math.cos(sectorAngle) * radius;
                float z = Math.sin(sectorAngle) * radius;

                // Calculate correct normal for conical surface
                float normalY = -radiusDiff / height; // Slope of the side
                float normalLength = Math.sqrt(1.0f + normalY * normalY);
                float nx = Math.cos(sectorAngle) / normalLength;
                float nz = Math.sin(sectorAngle) / normalLength;
                float ny = normalY / normalLength;

                float u = cast(float) j / sectors;
                float v = cast(float) i / stacks;

                vertices[vertexIndex++] = ComVertex(x, y, z, [
                    nx, ny, nz
                ], u, v);
            }
        }

        // Generate cap centers (same as before)
        vertices[vertexIndex++] = ComVertex(0, -halfHeight, 0, [
            0.0f, -1.0f, 0.0f
        ], 0.5f, 0.5f);
        vertices[vertexIndex++] = ComVertex(0, halfHeight, 0, [
            0.0f, 1.0f, 0.0f
        ], 0.5f, 0.5f);

        int index = 0;

        // Generate indices for sides (quads -> triangles)
        for (int i = 0; i < stacks; ++i)
        {
            for (int j = 0; j < sectors; ++j)
            {
                int k1 = i * (sectors + 1) + j; // current stack, current sector
                int k2 = k1 + 1; // current stack, next sector
                int k3 = k1 + (sectors + 1); // next stack, current sector
                int k4 = k3 + 1; // next stack, next sector

                // First triangle: k1 -> k3 -> k2
                indices[index++] = cast(ushort) k1;
                indices[index++] = cast(ushort) k3;
                indices[index++] = cast(ushort) k2;

                // Second triangle: k2 -> k3 -> k4
                indices[index++] = cast(ushort) k2;
                indices[index++] = cast(ushort) k3;
                indices[index++] = cast(ushort) k4;
            }
        }

        int sideIndexCount = index;
        int bottomCenterIndex = (sectors + 1) * (stacks + 1);
        int topCenterIndex = bottomCenterIndex + 1;

        // Generate indices for bottom cap
        for (int j = 0; j < sectors; ++j)
        {
            int k1 = j; // first stack, current sector
            int k2 = (j + 1) % (sectors + 1); // first stack, next sector

            // Triangle: bottomCenter -> k2 -> k1 (CCW winding)
            indices[index++] = cast(ushort) bottomCenterIndex;
            indices[index++] = cast(ushort) k2;
            indices[index++] = cast(ushort) k1;
        }

        // Generate indices for top cap
        for (int j = 0; j < sectors; ++j)
        {
            int k1 = stacks * (sectors + 1) + j; // last stack, current sector
            int k2 = k1 + 1; // last stack, next sector
            if (j == sectors - 1)
                k2 = stacks * (sectors + 1); // wrap around

            // Triangle: topCenter -> k1 -> k2 (CCW winding)
            indices[index++] = cast(ushort) topCenterIndex;
            indices[index++] = cast(ushort) k1;
            indices[index++] = cast(ushort) k2;
        }

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
