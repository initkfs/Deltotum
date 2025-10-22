module api.dm.kit.scenes.scene3d;

import api.dm.kit.scenes.scene2d : Scene2d;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites3d.cameras.perspective_camera : PerspectiveCamera;
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

class Scene3d : Scene2d
{
    PerspectiveCamera camera;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        super(isInitUDAProcessor);
        initProcessUDA!ThisType(isInitUDAProcessor);
    }

    override void create()
    {
        super.create;
        camera = createCamera;
        assert(camera);
    }

    PerspectiveCamera createCamera()
    {
        camera = new PerspectiveCamera(this);
        build(camera);
        camera.create;
        assert(camera.isCreated);
        return camera;
    }

    override void addCreate(Sprite2d object)
    {
        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                sprite3d.camera = camera;
            }
        }
        super.addCreate(object);
    }

    override void add(Sprite2d object)
    {
        super.add(object);

        if (auto sprite3d = cast(Sprite3d) object)
        {
            if (!sprite3d.hasCamera)
            {
                sprite3d.camera = camera;
            }
        }
    }

    void uploadToGPU()
    {
        if (!gpu.dev.startCopyPass)
        {
            throw new Exception("Unable to start copy pass");
        }

        foreach (sprite; sprites)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.uploadStart;
            }
        }

        if (!gpu.dev.endCopyPass)
        {
            throw new Exception("Unable to end copy pass");
        }

        foreach (sprite; sprites)
        {
            if (auto sprite3d = cast(Sprite3d) sprite)
            {
                sprite3d.uploadEnd;
            }
        }
    }

    override void drawAll()
    {
        bool isGPU = gpu.isActive;

        if (!isGPU)
        {
            super.drawAll;
            return;
        }

        if (!gpu.startRenderPass)
        {
            gpu.dev.resetState;
            //logger.error("Error starting gpu rendering");
            throw new Exception("Error starting gpu rendering");
        }

        drawSelfAndChildren;

        if (!gpu.dev.endRenderPass)
        {
            gpu.dev.resetState;
            //logger.error("Error ending gpu renderer");
            throw new Exception("Error ending gpu renderer");
        }
    }

    override protected void drawSelfAndChildren()
    {
        if (!isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        foreach (obj; sprites)
        {
            auto sprite3d = cast(Sprite3d) obj;
            if (!sprite3d)
            {
                continue;
            }

            sprite3d.pushUniforms;
            sprite3d.bindAll;
            sprite3d.draw;
            sprite3d.unvalidate;
        }

        if (isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        startDrawProcess = false;
    }

    override void update(double dt)
    {
        if (camera)
        {
            camera.update(dt);
        }
    }

    override void dispose()
    {
        super.dispose;
        if (camera)
        {
            camera.dispose;
        }
    }
}
