module api.dm.kit.sprites3d.cameras.orthographic_camera;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.scenes.scene3d : Scene3d;
import api.dm.kit.sprites3d.cameras.frustums.frustum3_ortho : Frustum3fOrtho;
import api.dm.kit.sprites3d.cameras.frustums.base_frustum3 : BaseFrustum3f;
import api.dm.kit.sprites3d.cameras.camera : Camera;

import Math = api.math;
import api.math.geom3.vec3 : Vec3f;
import api.math.matrices.affine3;

/**
 * Authors: initkfs
 */
class OrthographicCamera : Camera
{
    float _orthoSize = 5.0f;
    float aspectRatio = 1.0f;

    float left = -5.0f;
    float right = 5.0f;
    float bottom = -5.0f;
    float top = 5.0f;

    bool isRecalcProjection = true;

    float prevWindowW, prevWindowH;

    protected
    {
        Frustum3fOrtho _frustum;
    }

    override BaseFrustum3f frustum() => _frustum;

    this(Scene3d targetScene)
    {
        super(targetScene);
        updateOrthoBounds;

        _frustum = new Frustum3fOrtho;
    }

    override void create()
    {
        super.create;

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        targetScene.onPointerWheel ~= (ref e) {
            auto dy = e.y;

            _orthoSize -= dy * 0.5f;

            if (_orthoSize < 0.5f)
                _orthoSize = 0.5f;
            if (_orthoSize > 50.0f)
                _orthoSize = 50.0f;

            updateOrthoBounds;
            isRecalcProjection = true;
        };

        updateAspectRatio;
        updateOrthoBounds;
        projection = orthographicMatrixGL(left, right, bottom, top, nearPlane, farPlane);
        recalcView;

        prevWindowW = window.width;
        prevWindowH = window.height;
    }

    void updateOrthoBounds()
    {
        top = _orthoSize;
        bottom = -_orthoSize;
        right = _orthoSize * aspectRatio;
        left = -_orthoSize * aspectRatio;
    }

    void updateAspectRatio()
    {
        float w = window.width;
        float h = window.height;
        assert(w > 0);
        assert(h > 0);
        aspectRatio = w / h;
    }

    override void recalcFrustum()
    {
        _frustum.recalc(cameraPos, cameraFront, cameraUp, cameraRight,
            left, right, bottom, top, nearPlane, farPlane);
    }

    override void update(float dt)
    {
        super.update(dt);

        if (window.width != prevWindowW || window.height != prevWindowH)
        {
            updateAspectRatio;
            updateOrthoBounds;
            prevWindowW = window.width;
            prevWindowH = window.height;
            isRecalcProjection = true;
        }

        if (isRecalcProjection)
        {
            projection = orthographicMatrixGL(left, right, bottom, top, nearPlane, farPlane);
            isRecalcProjection = false;
        }
    }

    void orthoSize(float size)
    {
        _orthoSize = size;
        updateOrthoBounds;
        isRecalcProjection = true;
    }

    float orthoSize() const => _orthoSize;

    void setNearPlane(float near)
    {
        nearPlane = near;
        isRecalcProjection = true;
    }

    void setFarPlane(float far)
    {
        farPlane = far;
        isRecalcProjection = true;
    }

    void zoom(float delta)
    {
        _orthoSize -= delta;
        if (_orthoSize < 0.5f)
            _orthoSize = 0.5f;
        if (_orthoSize > 50.0f)
            _orthoSize = 50.0f;
        updateOrthoBounds;
        isRecalcProjection = true;
    }
}
