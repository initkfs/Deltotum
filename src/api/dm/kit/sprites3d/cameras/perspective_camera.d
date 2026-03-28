module api.dm.kit.sprites3d.cameras.perspective_camera;

import api.dm.kit.sprites3d.cameras.camera: Camera;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.math.geom3.frustum3 : Frustum3f;

import Math = api.math;
import api.math.geom3.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4;
import api.math.matrices.affine3;

/**
 * Authors: initkfs
 */
class PerspectiveCamera : Camera
{

    float fov = 45;

    this(Scene3d targetScene)
    {
        super(targetScene);
    }

    override void create()
    {
        super.create;

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        targetScene.onPointerWheel ~= (ref e) {
            auto dy = e.y;

            if (fov >= 1.0f && fov <= 45.0f)
                fov -= dy;
            if (fov <= 1.0f)
                fov = 1.0f;
            if (fov >= 45.0f)
                fov = 45.0f;
        };

        float w = window.width;
        float h = window.height;
        assert(w > 0);
        assert(h > 0);

        projection = perspectiveMatrixGL(fov, w / h, nearPlane, farPlane);

        recalcView;
    }

    override void recalcFrustum()
    {
        float ratio = window.width / window.height;
        _frustum = Frustum3f(cameraPos, cameraFront, cameraUp, cameraRight, Math.degToRad(fov), ratio, nearPlane, farPlane);
    }
}
