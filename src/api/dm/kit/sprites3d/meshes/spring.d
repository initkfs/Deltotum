module api.dm.kit.sprites3d.meshes.spring;

import api.dm.kit.sprites3d.meshes.mesh3d_indexed : Mesh3dHigh;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

import api.math.geom3.vec3 : Vec3f;
import Math = api.math;

/**
 * Authors: initkfs
 */

class Spring : Mesh3dHigh
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
        indices = new uint[totalIndices];

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
        foreach (uint i; 0 .. totalStacks)
        {
            foreach (uint j; 0 .. sectors)
            {
                uint k1 = i * (sectors + 1) + j;
                uint k2 = k1 + 1;
                uint k3 = (i + 1) * (sectors + 1) + j;
                uint k4 = k3 + 1;

                // СW or CCW?
                indices[index++] = k1;
                indices[index++] = k2;
                indices[index++] = k3;

                indices[index++] = k2;
                indices[index++] = k4;
                indices[index++] = k3;
            }
        }

    }
}
