module api.dm.kit.sprites3d.cameras.action_camera;

import api.dm.kit.sprites3d.cameras.persp_camera : PerspCamera;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.kit.sprites3d.cameras.frustums.base_frustum3 : BaseFrustum3f;

import Math = api.math;
import api.math.geom3.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4;
import api.math.geom3.quat3 : Quaternion;
import api.math.matrices.affine3;

/**
 * Authors: initkfs
 */
class ActionCamera : PerspCamera
{
    float mouseSensitivity = 0.05f;
    bool mouseCaptured = false;
    float lastMouseX = 0, lastMouseY = 0;
    bool firstMouse = true;

    this(Scene3d targetScene)
    {
        super(targetScene);
    }

    override void create()
    {
        super.create;

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        targetScene.onPointerMove ~= (ref e) {

            if (!input.keyboard.keyModifier.isCtrl)
            {
                handlePointerMove(e.x, e.y, false);
                return;
            }

            handlePointerMove(e.x, e.y, true);
        };
    }

    void processMouseMovement(float deltaX, float deltaY)
    {
        deltaX *= mouseSensitivity;
        deltaY *= mouseSensitivity;

        angleY += deltaX;
        angleX -= deltaY;

        const float MAX_PITCH = 89.0f;
        if (angleX > MAX_PITCH)
            angleX = MAX_PITCH;
        if (angleX < -MAX_PITCH)
            angleX = -MAX_PITCH;

        // Vec3f front;
        // front.x = Math.cosDeg(angleY) * Math.cosDeg(angleX);
        // front.y = Math.sinDeg(angleX);
        // front.z = Math.sinDeg(angleY) * Math.cosDeg(angleX);

        // cameraFront = front.normalize;

        // Vec3f worldUp = Vec3f(0.0f, 1.0f, 0.0f);
        // cameraRight = cameraFront.cross(worldUp).normalized;
        // cameraUp = cameraRight.cross(cameraFront).normalized;

        isRecalcPos = true;
    }

    void handlePointerMove(float mouseX, float mouseY, bool ctrlPressed)
    {
        if (ctrlPressed)
        {
            if (!mouseCaptured)
            {
                mouseCaptured = true;
                firstMouse = true;
            }

            if (firstMouse)
            {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
                firstMouse = false;
                return;
            }

            float deltaX = mouseX - lastMouseX;
            float deltaY = mouseY - lastMouseY;
            lastMouseX = mouseX;
            lastMouseY = mouseY;

            processMouseMovement(deltaX, deltaY);
        }
        else
        {
            if (mouseCaptured)
            {
                mouseCaptured = false;
                firstMouse = true;
            }
        }
    }
}
