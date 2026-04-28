module api.dm.kit.sprites3d.shapes.spring;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Spring : Shape3d
{
    float springRadius = 0;
    float tubeRadius = 0;
    float height = 0;
    int turns;

    this(float height = 1, float springRadius = 0.1, float tubeRadius = 0.01, int turns = 10)
    {
        this.springRadius = springRadius;
        this.tubeRadius = tubeRadius;
        this.height = height;
        this.turns = turns;
    }

    override void createMesh()
    {
        enum sectors = 16;
        enum stacks = 48;

        int totalStacks = stacks * turns;

        int totalVertices = (sectors + 1) * (totalStacks + 1);
        int totalIndices = sectors * totalStacks * 6;

        vertices = new ComVertex[totalVertices];
        indices = new ushort[totalIndices];

        size_t vertexIndex = 0;
        for (int i = 0; i <= totalStacks; i++)
        {
            float t = i / cast(float) totalStacks; // 0..1
            float y = (-height / 2) + t * height;
            float angle = t * 2 * Math.PI * turns;

            float centerX = springRadius * Math.cos(angle);
            float centerZ = springRadius * Math.sin(angle);

            Vec3f tangent = Vec3f(
                -springRadius * Math.sin(angle),
                height / (totalStacks),
                springRadius * Math.cos(angle)
            ).normalize;

            Vec3f radialDir = Vec3f(Math.cos(angle), 0, Math.sin(angle)).normalized;
            Vec3f binormal = tangent.cross(radialDir).normalized;

            for (int j = 0; j <= sectors; j++)
            {
                float sectorAngle = j * 2 * Math.PI / sectors;
                float u = j / cast(float) sectors;
                float v = t;

                Vec3f circlePoint;
                circlePoint.x = Math.cos(sectorAngle);
                circlePoint.y = Math.sin(sectorAngle);
                circlePoint.z = 0;

                float x = centerX + tubeRadius * (
                    circlePoint.x * radialDir.x + circlePoint.y * binormal.x);
                float z = centerZ + tubeRadius * (
                    circlePoint.x * radialDir.z + circlePoint.y * binormal.z);
                float yTube = y + tubeRadius * circlePoint.y * binormal.y;

                float localX = Math.cos(sectorAngle);
                float localY = Math.sin(sectorAngle);
                Vec3f normal = (radialDir * localX + binormal * localY).normalize;

                vertices[vertexIndex++] = ComVertex(x, yTube, z,
                    [normal.x, normal.y, normal.z], u, v, tangent.x, tangent.y, tangent.z);
            }
        }

        size_t index = 0;
        foreach (i; 0 .. totalStacks)
        {
            foreach (j; 0 .. sectors)
            {
                int k1 = i * (sectors + 1) + j;
                int k2 = k1 + 1;
                int k3 = (i + 1) * (sectors + 1) + j;
                int k4 = k3 + 1;

                // СW or CCW?
                indices[index++] = cast(ushort) k1;
                indices[index++] = cast(ushort) k2;
                indices[index++] = cast(ushort) k3;

                indices[index++] = cast(ushort) k2;
                indices[index++] = cast(ushort) k4;
                indices[index++] = cast(ushort) k3;
            }
        }

    }
}
