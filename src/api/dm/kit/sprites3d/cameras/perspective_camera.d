module api.dm.kit.sprites3d.cameras.perspective_camera;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene2d : Scene2d;

import Math = api.math;
import api.math.geom2.vec3 : Vec3f;
import api.math.matrices.matrix : Matrix4x4f;
import api.math.matrices.affine3;

/**
 * Authors: initkfs
 */
class PerspectiveCamera : Sprite2d
{

    protected
    {
        Scene2d targetScene;
    }

    double lastCursorX = 0;
    double lastCursorY = 0;
    double cursorYaw = -90.0f;
    double cursorPitch = 0.0f;

    Vec3f cameraPos = Vec3f(0.0f, 0.0f, 3.0f);
    Vec3f cameraFront = Vec3f(0.0f, 0.0f, -1.0f);
    Vec3f cameraUp = Vec3f(0.0f, 1.0f, 0.0f);

    double fov = 45;

    align(16)
    {
        Matrix4x4f view;
        //TODO extract perspective
        Matrix4x4f projection;
    }

    this(Scene2d targetScene)
    {
        assert(targetScene);
        this.targetScene = targetScene;
    }

    override void create()
    {
        super.create;

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        targetScene.onKeyPress ~= (ref e) {
            if (e.keyName == ComKeyName.key_lctrl)
            {
                auto pos = input.pointerPos;
                lastCursorX = pos.x;
                lastCursorY = pos.y;
            }
        };

        targetScene.onPointerWheel ~= (ref e) {
            auto dy = e.y;

            if (fov >= 1.0f && fov <= 45.0f)
                fov -= dy;
            if (fov <= 1.0f)
                fov = 1.0f;
            if (fov >= 45.0f)
                fov = 45.0f;
        };

        targetScene.onPointerMove ~= (ref e) {

            if (!input.keyboard.keyModifier.isCtrl)
            {
                return;
            }

            double xpos = e.x;
            double ypos = e.y;

            auto xoffset = xpos - lastCursorX;
            auto yoffset = lastCursorY - ypos; //Y up

            lastCursorX = xpos;
            lastCursorY = ypos;

            double sensitivity = 0.055f;
            xoffset *= sensitivity;
            yoffset *= sensitivity;

            cursorYaw += xoffset;
            cursorPitch += yoffset;

            if (cursorPitch > 89.0f) //cos > 90 = neg
                cursorPitch = 89.0f;
            if (cursorPitch < -89.0f)
                cursorPitch = -89.0f;

            Vec3f front;
            front.x = -Math.cos(Math.degToRad(cursorPitch)) * Math.cos(Math.degToRad(cursorYaw));
            front.y = Math.sin(Math.degToRad(cursorPitch));
            front.z = Math.cos(Math.degToRad(cursorPitch)) * Math.sin(Math.degToRad(cursorYaw));
            cameraFront = front.normalize;
        };

        view = translateMatrix(0.0f, 0.0f, 3.0f);

        import api.math.geom2.vec3;

        view = lookAt(
            Vec3f(0, 0, -3),
            Vec3f(0, 0, 0),
            Vec3f(0, 1, 0)
        );

        float w = window.width;
        float h = window.height;
        assert(w > 0);
        assert(h > 0);

        projection = perspectiveMatrixRH(fov, w / h, 0.1f, 100.0f);
    }

    override void update(double dt)
    {
        super.update(dt);

        view = lookAt(cameraPos, cameraPos.add(cameraFront), cameraUp);

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        //* dt
        float cameraSpeed = 0.05f;

        if (input.isPressedKey(ComKeyName.key_w))
        {
            cameraPos = cameraPos.add(cameraFront.scale(cameraSpeed));
        }

        if (input.isPressedKey(ComKeyName.key_s))
        {
            cameraPos = cameraPos.sub(cameraFront.scale(cameraSpeed));
        }

        if (input.isPressedKey(ComKeyName.key_d))
        {
            cameraPos = cameraPos.sub(cameraFront.cross(cameraUp).normalize.scale(cameraSpeed));
        }

        if (input.isPressedKey(ComKeyName.key_a))
        {
            cameraPos = cameraPos.add(cameraFront.cross(cameraUp).normalize.scale(cameraSpeed));
        }
    }

}
