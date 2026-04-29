module api.dm.kit.sprites3d.shapes.toroid;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Toroid : Shape3d
{
    float radius = 0.2f; 
    float tubeRadius = 0.01f;
    int sectors = 16;
    int rings = 48;

    this()
    {

    }

    override void createMesh()
    {
        enum sectors = 16;
        enum rings = 48;

        vertices = new ComVertex[(rings + 1) * (sectors + 1)];
        indices = new uint[rings * sectors * 6];

        size_t vIdx = 0;
        for (int i = 0; i <= rings; i++)
        {
            float u = cast(float) i / rings;
            float outerAngle = u * 2.0f * Math.PI;

            float centerX = radius * Math.cos(outerAngle);
            float centerZ = radius * Math.sin(outerAngle);

            Vec3f centerPos = Vec3f(centerX, 0, centerZ);
            Vec3f tangent = Vec3f(-Math.sin(outerAngle), 0, Math.cos(outerAngle));
            Vec3f normalToCenter = centerPos.normalize;

            for (int j = 0; j <= sectors; j++)
            {
                float v = cast(float) j / sectors;
                float innerAngle = v * 2.0f * Math.PI;

                float xOffset = Math.cos(innerAngle);
                float yOffset = Math.sin(innerAngle);

                float x = centerX + tubeRadius * xOffset * normalToCenter.x;
                float y = tubeRadius * yOffset;
                float z = centerZ + tubeRadius * xOffset * normalToCenter.z;

                Vec3f radialDir = Vec3f(xOffset * normalToCenter.x, yOffset, xOffset * normalToCenter.z);
                Vec3f normal = radialDir.normalize;

                vertices[vIdx++] = ComVertex(
                    x, y, z,
                    [normal.x, normal.y, normal.z],
                    u, v,
                    tangent.x, tangent.y, tangent.z
                );
            }
        }

        size_t iIdx = 0;
        for (uint i = 0; i < rings; i++)
        {
            for (uint j = 0; j < sectors; j++)
            {
                uint current = i * (sectors + 1) + j;
                uint next = current + 1;
                uint bottom = (i + 1) * (sectors + 1) + j;
                uint bottomNext = bottom + 1;

                indices[iIdx++] = current;
                indices[iIdx++] = next;
                indices[iIdx++] = bottom;

                indices[iIdx++] = next;
                indices[iIdx++] = bottomNext;
                indices[iIdx++] = bottom;
            }
        }

    }
}
