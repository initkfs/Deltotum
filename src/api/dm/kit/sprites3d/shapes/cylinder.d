module api.dm.kit.sprites3d.shapes.cylinder;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.matrices.matrix : Matrix4x4;
import api.dm.back.sdl3.externs.csdl3;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Cylinder : Shape3d
{
    float bottomRadius = 0;
    float topRadius = 0;
    float height = 0;

    enum CylinderID = "Cylinder";
    enum DefaultHeight = 0.5;
    enum DefaultRadius = 0.5;

    this(float height = DefaultHeight, float radius = DefaultRadius, string id = CylinderID)
    {
        this(height, radius, radius, id);
    }

    this(float height = DefaultHeight, float bottomRadius = DefaultRadius, float topRadius = DefaultRadius, string id = CylinderID)
    {
        this.bottomRadius = bottomRadius;
        this.topRadius = topRadius;
        this.height = height;
        this.id = id;

        initSize(Math.max(bottomRadius, topRadius), height);
    }

    override void createMesh()
    {
        enum sectors = 16; // Number of sides
        enum stacks = 8; // Number of subdivisions along height

        enum cylinderVerticesCount = (sectors + 1) * (stacks + 1) + 2; // +2 for caps centers
        enum cylinderIndicesCount = sectors * stacks * 6 + sectors * 6; // sides + caps

        vertices = new ComVertex[cylinderVerticesCount];
        indices = new uint[cylinderIndicesCount];

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

                float tx = -Math.sin(sectorAngle);
                float ty = 0.0f;
                float tz = Math.cos(sectorAngle);

                vertices[vertexIndex++] = ComVertex(x, y, z, [
                        nx, ny, nz
                    ], u, v, tx, ty, tz);
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
        for (uint i = 0; i < stacks; ++i)
        {
            for (uint j = 0; j < sectors; ++j)
            {
                uint k1 = i * (sectors + 1) + j; // current stack, current sector
                uint k2 = k1 + 1; // current stack, next sector
                uint k3 = k1 + (sectors + 1); // next stack, current sector
                uint k4 = k3 + 1; // next stack, next sector

                // First triangle: k1 -> k3 -> k2
                indices[index++] = k1;
                indices[index++] = k3;
                indices[index++] = k2;

                // Second triangle: k2 -> k3 -> k4
                indices[index++] = k2;
                indices[index++] = k3;
                indices[index++] = k4;
            }
        }

        int sideIndexCount = index;
        int bottomCenterIndex = (sectors + 1) * (stacks + 1);
        int topCenterIndex = bottomCenterIndex + 1;

        // Generate indices for bottom cap
        for (uint j = 0; j < sectors; ++j)
        {
            uint k1 = j; // first stack, current sector
            //int k2 = (j + 1) % (sectors + 1); // first stack, next sector
            uint k2 = j + 1;

            // Triangle: bottomCenter -> k2 -> k1 (CCW winding)
            indices[index++] = bottomCenterIndex;
            indices[index++] = k1;
            indices[index++] = k2;
        }

        // Generate indices for top cap
        for (uint j = 0; j < sectors; ++j)
        {
            uint k1 = stacks * (sectors + 1) + j; // last stack, current sector
            uint k2 = k1 + 1; // last stack, next sector
            //if (j == sectors - 1)
            //    k2 = stacks * (sectors + 1); // wrap around

            if (j == sectors - 1)
                k2 = stacks * (sectors + 1);

            // Triangle: topCenter -> k1 -> k2 (CCW winding)
            indices[index++] = topCenterIndex;
            indices[index++] = k2;
            indices[index++] = k1;
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
