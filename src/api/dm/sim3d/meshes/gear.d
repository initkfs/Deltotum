module api.dm.sim3d.meshes.gear;

import api.dm.sim3d.meshes.mesh3d_indexed : Mesh3dHigh;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Gear : Mesh3dHigh
{
    int toothCount;
    float innerRadius;
    float outerRadius;
    float thickness;

    this(int toothCount = 12, float innerRadius = 0.04, float outerRadius = 0.05, float thickness = 0.01, string id = "Gear3d")
    {
        this.toothCount = toothCount;
        this.innerRadius = innerRadius;
        this.outerRadius = outerRadius;
        this.thickness = thickness;
        this.id = id;
    }

    override void createMesh()
    {
        int sectors = toothCount * 4;
        int totalVertices = (sectors + 1) * 2;

        int totalIndices = (sectors * 6) + (sectors * 3) * 2;

        vertices = new ComVertex[totalVertices];
        indices = new uint[totalIndices];

        float halfH = thickness / 2;
        size_t vertexIndex;

        foreach (layer; 0 .. 2)
        {
            float y = (layer == 0) ? -halfH : halfH;
            float v = (layer == 0) ? 1.0f : 0.0f;

            for (int j = 0; j <= sectors; j++)
            {
                float u = j / cast(float) sectors;
                float angle = u * 2 * Math.PI;

                int step = j % 4;
                float r = (step == 1 || step == 2) ? outerRadius : innerRadius;

                if (j == sectors)
                {
                    r = innerRadius;
                }

                float x = r * Math.cos(angle);
                float z = r * Math.sin(angle);

                Vec3f normal = Vec3f(Math.cos(angle), 0.0f, Math.sin(angle)).normalize;
                Vec3f tangent = Vec3f(-Math.sin(angle), 0.0f, Math.cos(angle)).normalize;

                vertices[vertexIndex++] = ComVertex(
                    x, y, z,
                    [normal.x, normal.y, normal.z],
                    u, v,
                    tangent.x, tangent.y, tangent.z
                );
            }
        }

        size_t idx;
        foreach (uint j; 0 .. sectors)
        {
            uint k1 = j; // low ring
            uint k2 = k1 + 1;
            uint k3 = (sectors + 1) + j; // upper ring
            uint k4 = k3 + 1;

            // COUNTER_CLOCKWISE
            indices[idx++] = k1;
            indices[idx++] = k3;
            indices[idx++] = k2;

            indices[idx++] = k2;
            indices[idx++] = k3;
            indices[idx++] = k4;
        }

        vertices ~= ComVertex(0.0f, -halfH, 0.0f, [0.0f, -1.0f, 0.0f], 0.5f, 0.5f); // center bottom
        uint centerBottomIdx = cast(uint)(vertices.length - 1);

        vertices ~= ComVertex(0.0f, halfH, 0.0f, [0.0f, 1.0f, 0.0f], 0.5f, 0.5f); //center upper
        uint centerTopIdx = cast(uint)(vertices.length - 1);

        foreach (uint j; 0 .. sectors)
        {
            // normal [0, -1, 0]
            // CCW
            uint b1 = j;
            uint b2 = j + 1;
            indices[idx++] = centerBottomIdx;
            indices[idx++] = b1;
            indices[idx++] = b2;

            uint t1 = (sectors + 1) + j;
            uint t2 = t1 + 1;
            indices[idx++] = centerTopIdx;
            indices[idx++] = t2;
            indices[idx++] = t1;
        }
    }
}
