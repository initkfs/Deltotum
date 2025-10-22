module api.dm.kit.scenes.scene3d;

import api.math.matrices.matrix;

/**
 * Authors: initkfs
 */

struct SceneTransforms
{
    Matrix4x4f world;
    Matrix4x4f camera;
    Matrix4x4f projection;
    Matrix4x4f normal;
}