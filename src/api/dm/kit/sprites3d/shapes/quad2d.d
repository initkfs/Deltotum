module api.dm.kit.sprites3d.shapes.quad2d;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;
import api.dm.kit.sprites3d.textures.texture_gpu : TextureGPU;

/**
 * Authors: initkfs
 */

class Quad2d : Shape3d
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
