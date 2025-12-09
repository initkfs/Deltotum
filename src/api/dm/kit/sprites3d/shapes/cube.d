module api.dm.kit.sprites3d.shapes.cube;

import api.dm.kit.sprites3d.shapes.shape3d : Shape3d;
import api.dm.com.graphics.gpu.com_3d_types : ComVertex;

/**
 * Authors: initkfs
 */

class Cube : Shape3d
{
    float depth = 0;

    this()
    {

    }

    this(float width, float height, float depth)
    {
        this.initSize(width, height);
        this.depth = depth;
        id = "Cube3d";
    }

    override void createMesh()
    {
        const halfWidth = cast(float)(width / 2.0);
        const halfHeight = cast(float)(height / 2.0);
        const halfDepth = cast(float)(depth / 2.0);

        vertices = [
            // Front face (Z = +halfDepth), normal: (0, 0, 1)
            ComVertex(-halfWidth, -halfHeight, halfDepth, [0.0f, 0.0f, 1.0f], 0.0f, 1.0f), // 0: left bottom
            ComVertex(halfWidth, -halfHeight, halfDepth, [0.0f, 0.0f, 1.0f], 1.0f, 1.0f), // 1: bottom right
            ComVertex(halfWidth, halfHeight, halfDepth, [0.0f, 0.0f, 1.0f], 1.0f, 0.0f), // 2: top right
            ComVertex(-halfWidth, halfHeight, halfDepth, [0.0f, 0.0f, 1.0f], 0.0f, 0.0f), // 3: top left

            // Back face (Z = -halfDepth), normal: (0, 0, -1)
            ComVertex(halfWidth, -halfHeight, -halfDepth, [0.0f, 0.0f, -1.0f], 0.0f, 1.0f), // 4: bottom right
            ComVertex(-halfWidth, -halfHeight, -halfDepth, [0.0f, 0.0f, -1.0f], 1.0f, 1.0f), // 5: bottom left
            ComVertex(-halfWidth, halfHeight, -halfDepth, [0.0f, 0.0f, -1.0f], 1.0f, 0.0f), // 6: top left
            ComVertex(halfWidth, halfHeight, -halfDepth, [0.0f, 0.0f, -1.0f], 0.0f, 0.0f), // 7: top right

            // Left face (X = -halfWidth), normal: (-1, 0, 0)
            ComVertex(-halfWidth, -halfHeight, -halfDepth, [-1.0f, 0.0f, 0.0f], 0.0f, 1.0f), // 8: bottom back
            ComVertex(-halfWidth, -halfHeight, halfDepth, [-1.0f, 0.0f, 0.0f], 1.0f, 1.0f), // 9: bottom front
            ComVertex(-halfWidth, halfHeight, halfDepth, [-1.0f, 0.0f, 0.0f], 1.0f, 0.0f), // 10: top front
            ComVertex(-halfWidth, halfHeight, -halfDepth, [-1.0f, 0.0f, 0.0f], 0.0f, 0.0f), // 11: top back

            // Right face (X = halfWidth), normal: (1, 0, 0)
            ComVertex(halfWidth, -halfHeight, halfDepth, [1.0f, 0.0f, 0.0f], 0.0f, 1.0f), // 12: bottom front
            ComVertex(halfWidth, -halfHeight, -halfDepth, [1.0f, 0.0f, 0.0f], 1.0f, 1.0f), // 13: bottom back
            ComVertex(halfWidth, halfHeight, -halfDepth, [1.0f, 0.0f, 0.0f], 1.0f, 0.0f), // 14: top back
            ComVertex(halfWidth, halfHeight, halfDepth, [1.0f, 0.0f, 0.0f], 0.0f, 0.0f), // 15: top front

            // Top face (Y = halfHeight), normal: (0, 1, 0)
            ComVertex(-halfWidth, halfHeight, halfDepth, [0.0f, 1.0f, 0.0f], 0.0f, 1.0f), // 16: front left
            ComVertex(halfWidth, halfHeight, halfDepth, [0.0f, 1.0f, 0.0f], 1.0f, 1.0f), // 17: front right
            ComVertex(halfWidth, halfHeight, -halfDepth, [0.0f, 1.0f, 0.0f], 1.0f, 0.0f), // 18: back right
            ComVertex(-halfWidth, halfHeight, -halfDepth, [0.0f, 1.0f, 0.0f], 0.0f, 0.0f), // 19: back left

            // Bottom face (Y = -halfHeight), normal: (0, -1, 0)
            ComVertex(-halfWidth, -halfHeight, -halfDepth, [0.0f, -1.0f, 0.0f], 0.0f, 1.0f), // 20: back left
            ComVertex(halfWidth, -halfHeight, -halfDepth, [0.0f, -1.0f, 0.0f], 1.0f, 1.0f), // 21: back right
            ComVertex(halfWidth, -halfHeight, halfDepth, [0.0f, -1.0f, 0.0f], 1.0f, 0.0f), // 22: front right
            ComVertex(-halfWidth, -halfHeight, halfDepth, [0.0f, -1.0f, 0.0f], 0.0f, 0.0f), // 23: front left
        ];

        //ccw
        indices = [
            // front face
            0, 1, 2, 0, 2, 3,
            // back face
            4, 5, 6, 4, 6, 7,
            //left face
            8, 9, 10, 8, 10, 11,
            // right face
            12, 13, 14, 12, 14, 15,
            //top face
            16, 17, 18, 16, 18, 19,
            // bottom face
            20, 21, 22, 20, 22, 23
        ];
    }

    override bool isInCameraFrustum()
    {
        import Math = api.math;

        //d = √(a² + a² + a²) 
        //R = d / 2
        const float diag = Math.sqrt(width * width + height * height + depth * depth);
        const sphereR = diag / 2.0;
        if (camera.frustum.isSphereVisible(pos3, sphereR))
        {
            return true;
        }
        return false;
    }
}
