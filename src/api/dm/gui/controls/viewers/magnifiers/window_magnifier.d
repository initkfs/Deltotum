module api.dm.gui.controls.viewers.magnifiers.window_magnifier;

import api.dm.com.graphics.com_surface : ComSurface;

import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import api.dm.gui.controls.viewers.magnifiers.base_magnifier : BaseMagnifier;
import api.dm.gui.controls.containers.container : Container;

import api.math.geom2.rect2 : Rect2d;
import api.math.geom2.vec2 : Vec2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class WindowMagnifier : BaseMagnifier
{
    protected
    {
        ComSurface buffer;
        bool canUpdate;
        Vec2d lastUpdatePos;
        size_t lastUpdateTimeMs;
    }

    bool isUpdateWhenShow = true;
    size_t updateIntervalMs = 1000;

    override void create()
    {
        super.create;

        buffer = graphic.comSurfaceProvider.getNew();

        import api.dm.kit.sprites2d.tweens.pause_tween2d : PauseTween2d;

        auto pause = new PauseTween2d(1000);
        addCreate(pause);
        pause.onEnd ~= () {

            window.drawingSceneTasks ~= (dt) {

                assert(thumbnail);

                remove(pause);

                auto bounds = window.boundsSafe;
                if (const err = graphic.readPixels(bounds, buffer))
                {
                    logger.error(err.toString);
                    return;
                }

                int w, h;
                buffer.getSize(w, h);

                auto winTexture = new Texture2d(w, h);
                buildInitCreate(winTexture);
                winTexture.loadFromSurface(buffer);
                scope (exit)
                {
                    winTexture.dispose;
                }

                thumbnail.copyFrom(winTexture);

                buffer.dispose;
            };

        };
        pause.run;

    }

    override void pointerMove(double pRelX, double pRelY, ref PointerEvent e)
    {
        drawMagnifier(pRelX, pRelY);

        if (isUpdateWhenShow)
        {
            canUpdate = false;
            lastUpdatePos = Vec2d(pRelX, pRelY);
        }
    }

    void drawMagnifier(double pRelX, double pRelY)
    {
        assert(thumbnail);

        auto originalXRel = (window.width * pRelX) / thumbnail.width;
        auto originalYRel = (window.height * pRelY) / thumbnail.height;

        Rect2d textureBounds = Rect2d(originalXRel, originalYRel, magnifier.width, magnifier
                .height);

        auto safeBounds = window.boundsSafe;
        if (!safeBounds.contains(textureBounds))
        {
            return;
        }

        magnifier.lock;
        scope (exit)
        {
            magnifier.unlock;
        }

        if (const err = graphic.readPixels(textureBounds, buffer))
        {
            logger.error(err.toString);
            return;
        }

        //TODO batch
        const isErr = buffer.getPixels((size_t x, size_t y, ubyte r, ubyte g, ubyte b, ubyte a) {
            magnifier.changeColor(cast(uint) x, cast(uint) y, r, g, b, a);
            return true;
        });
        if (isErr)
        {
            logger.error(isErr.toString);
        }
    }

    override Texture2d newMagnifier(double w, double h)
    {
        auto magn = new Texture2d(w, h);
        build(magn);
        magn.createMutRGBA32;
        return magn;
    }

    override Texture2d newThumbnail(double w, double h)
    {
        auto t = new Texture2d(w, h);
        build(t);
        t.createTargetRGBA32;
        return t;
    }

    override void drawContent()
    {
        super.drawContent;

        if (isUpdateWhenShow && isMagnVisible && canUpdate)
        {
            drawMagnifier(lastUpdatePos.x, lastUpdatePos.y);
        }

    }

    override void update(double dt){
        super.update(dt);

        if (isUpdateWhenShow && isMagnVisible)
        {
            auto lastTime = platform.timer.ticksMs;
            if (lastTime - lastUpdateTimeMs >= updateIntervalMs)
            {
                canUpdate = true;
                lastUpdateTimeMs = lastTime;
            }
        }
    }

    override void dispose()
    {
        super.dispose;

        if (buffer)
        {
            buffer.dispose;
        }
    }
}
