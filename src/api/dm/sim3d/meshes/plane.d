module api.dm.sim3d.meshes.plane;

import api.dm.sim3d.meshes.mesh3d_indexed : Mesh3dLow;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.textures.tex3d : Tex3d;

/**
 * Authors: initkfs
 */

class Plane : Mesh3dLow
{
    this(float width = 0.5, float height = 0.5, string id = "Plane3d")
    {
        this.initSize(width, height);
        this.id = id;
    }

    override void createMesh()
    {
        const halfWidth = width / 2.0;
        const halfHeight = height / 2.0;

        vertices = [
            ComVertex(-halfWidth, 0.0f, halfHeight, [0.0f, 1.0f, 0.0f], 0.0f, 1.0f, 1.0f, 0.0f, 0.0f),
            ComVertex(halfWidth, 0.0f, halfHeight, [0.0f, 1.0f, 0.0f], 1.0f, 1.0f, 1.0f, 0.0f, 0.0f),
            ComVertex(halfWidth, 0.0f, -halfHeight, [0.0f, 1.0f, 0.0f], 1.0f, 0.0f, 1.0f, 0.0f, 0.0f),
            ComVertex(-halfWidth, 0.0f, -halfHeight, [0.0f, 1.0f, 0.0f], 0.0f, 0.0f, 1.0f, 0.0f, 0.0f)
        ];

        indices = [
            0, 1, 2, 2, 3, 0
        ];
    }
}
