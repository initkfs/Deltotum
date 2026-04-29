module api.dm.kit.sprites3d.meshes.quad2d;

import api.dm.kit.sprites3d.meshes.mesh3d_indexed : Mesh3dLow;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

/**
 * Authors: initkfs
 */

class Quad2d : Mesh3dLow
{
    this(float width = 0.5, float height = 0.5)
    {
        this.initSize(width, height);
        id = "Quad2d";
    }

    override void createMesh()
    {
        vertices = [
            ComVertex(-0.5, -0.5, 0, [0.0f, 0.0f, 1.0f], 0.0f, 1.0f),
            ComVertex(0.5, -0.5, 0, [0.0f, 0.0f, 1.0f], 1.0f, 1.0f),
            ComVertex(0.5, 0.5, 0, [0.0f, 0.0f, 1.0f], 1.0f, 0.0f),
            ComVertex(-0.5, 0.5, 0, [0.0f, 0.0f, 1.0f], 0.0f, 0.0f)
        ];

        indices = [
            0, 1, 2, 2, 3, 0
        ];
    }
}
