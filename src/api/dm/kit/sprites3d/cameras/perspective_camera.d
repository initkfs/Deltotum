module api.dm.kit.sprites3d.cameras.perspective_camera;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : Scene3d;

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
        Scene3d targetScene;
    }

    double lastCursorX = 0;
    double lastCursorY = 0;
    double cursorYaw = -90.0f;
    double cursorPitch = 0.0f;

    Vec3f cameraPos = Vec3f(0.0f, 0.0f, 3.0f);

    Vec3f cameraFront;
    Vec3f cameraUp;
    Vec3f cameraRight;

    Vec3f cameraTarget;

    bool isOrbital;

    float nearPlane = 0.1;
    float farPlane = 100;

    double fov = 45;

    float angleX = 0;
    float angleY = 0;

    bool isRecalcPos;

    float mouseSensitivity = 0.1f;
    bool mouseCaptured = false;
    double lastMouseX = 0, lastMouseY = 0;
    bool firstMouse = true;

    align(16)
    {
        Matrix4x4f view;
        //TODO extract perspective
        Matrix4x4f projection;
    }

    this(Scene3d targetScene)
    {
        assert(targetScene);
        this.targetScene = targetScene;
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

        targetScene.onPointerMove ~= (ref e) {

            if (!input.keyboard.keyModifier.isCtrl)
            {
                handlePointerMove(e.x, e.y, false);
                return;
            }

            handlePointerMove(e.x, e.y, true);
        };

        float w = window.width;
        float h = window.height;
        assert(w > 0);
        assert(h > 0);

        projection = perspectiveMatrixRH(fov, w / h, nearPlane, farPlane);

        recalcView;
    }

    double targetDistance;

    void recalcView()
    {
        import api.math.quaternion : Quaternion;

        Vec3f localFront = Vec3f(0.0f, 0.0f, -1.0f);
        Vec3f localUp = Vec3f(0.0f, 1.0f, 0.0f);
        Vec3f localRight = Vec3f(1.0f, 0.0f, 0.0f);

        if (angleX != 0 || angleY != 0 || angle != 0)
        {
            Quaternion q1 = Quaternion.fromEuler(angleX, angleY, angle);
            Matrix4x4f rotation = q1.toMatrix4x4LH;

            cameraFront = rotation.transformDir(localFront).normalize;
            cameraUp = rotation.transformDir(localUp).normalize;
            cameraRight = rotation.transformDir(localRight).normalize;

            Vec3f orbitOffset = cameraFront.scale(-targetDistance);
            cameraPos = cameraTarget + orbitOffset;
        }
        else
        {
            cameraFront = localFront; // (0, 0, -1)
            cameraUp = localUp; // (0, 1, 0)
            cameraRight = localRight; // (1, 0, 0)
        }

        if (isOrbital)
        {

            view = lookAt(cameraPos, cameraTarget, cameraUp);
        }
        else
        {
            // view = lookAt(cameraPos, cameraPos.add(cameraFront), cameraUp);
        }
    }

    override void update(double dt)
    {
        super.update(dt);

        if (isRecalcPos)
        {
            recalcView;
            isRecalcPos = false;
        }

        import api.math.matrices.affine3;

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        //* dt
        float cameraSpeed = 0.05f;

        if (input.isPressedKey(ComKeyName.key_a))
        {
            moveLeft(cameraSpeed);
        }

        if (input.isPressedKey(ComKeyName.key_d))
        {
            moveRight(cameraSpeed);
        }

        if (input.isPressedKey(ComKeyName.key_w))
        {
            moveUp(cameraSpeed);
        }

        if (input.isPressedKey(ComKeyName.key_s))
        {
            moveDown(cameraSpeed);
        }

        if (input.isPressedKey(ComKeyName.key_q))
        {
            moveForward(cameraSpeed);
        }

        if (input.isPressedKey(ComKeyName.key_z))
        {
            moveBack(cameraSpeed);
        }

        auto rotateSpeedDeg = 5;

        if (input.isPressedKey(ComKeyName.key_r))
        {
            angle = Math.wrapAngle360(angle + rotateSpeedDeg);
            isRecalcPos = true;
        }

        if (input.isPressedKey(ComKeyName.key_t))
        {
            angle = Math.wrapAngle360(angle - rotateSpeedDeg);
            isRecalcPos = true;
        }

        if (input.isPressedKey(ComKeyName.key_f))
        {
            angleX = Math.wrapAngle360(angleX + rotateSpeedDeg);
            isRecalcPos = true;
        }

        if (input.isPressedKey(ComKeyName.key_g))
        {
            angleX = Math.wrapAngle360(angleX - rotateSpeedDeg);
            isRecalcPos = true;
        }

        if (input.isPressedKey(ComKeyName.key_v))
        {
            angleY = Math.wrapAngle360(angleY - rotateSpeedDeg);
            isRecalcPos = true;
        }

        if (input.isPressedKey(ComKeyName.key_b))
        {
            angleY = Math.wrapAngle360(angleY - rotateSpeedDeg);
            isRecalcPos = true;
        }
    }

    void handlePointerMove(double mouseX, double mouseY, bool ctrlPressed)
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

            double deltaX = mouseX - lastMouseX;
            double deltaY = mouseY - lastMouseY;
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

        isRecalcPos = true;
    }

    void moveRight(float speed)
    {
        cameraPos = cameraPos.add(cameraRight.scale(speed));
        isRecalcPos = true;
    }

    void moveLeft(float speed)
    {
        cameraPos = cameraPos.sub(cameraRight.scale(speed));
        isRecalcPos = true;
    }

    void moveForward(float speed)
    {
        cameraPos = cameraPos.add(cameraFront.scale(speed));
        isRecalcPos = true;
    }

    void moveBack(float speed)
    {
        cameraPos = cameraPos.sub(cameraFront.scale(speed));
        isRecalcPos = true;
    }

    void moveUp(float speed)
    {
        cameraPos = cameraPos.add(cameraUp.scale(speed));
        isRecalcPos = true;
    }

    void moveDown(float speed)
    {
        cameraPos = cameraPos.sub(cameraUp.scale(speed));
        isRecalcPos = true;
    }

    void moveHorizontal(float speed)
    {
        Vec3f horizontalRight = cameraFront.cross(Vec3f(0, 1, 0)).normalize;
        cameraPos = cameraPos.add(horizontalRight.scale(speed));
        isRecalcPos = true;
    }

    void moveAroundTarget(Vec3f target, float horizontalAngleDeg, float verticalAngleDeg = 0, float radius = 5.0f)
    {
        //TODO vertical angle incorrect
        import api.math.matrices.affine3;

        Vec3f cameraOffset = Vec3f(0, 0, radius);

        Matrix4x4f rotation = combinedRotation(verticalAngleDeg, horizontalAngleDeg, angle);
        cameraOffset = rotation.transformDir(cameraOffset);

        cameraPos = target + cameraOffset;

        cameraFront = (target - cameraPos).normalize;
        cameraRight = cameraFront.cross(Vec3f(0, 1, 0)).normalize;
        cameraUp = cameraRight.cross(cameraFront).normalize;

        view = lookAt(cameraPos, target, cameraUp);
    }

}
