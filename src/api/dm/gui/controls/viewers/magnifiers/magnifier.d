module api.dm.gui.controls.viewers.magnifiers.magnifier;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.center_box : CenterBox;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
import Math = api.dm.math;
import api.dm.com.graphic.com_surface : ComSurface;

enum Source
{
    currwindow,
    texture
}

/**
 * Authors: initkfs
 */
class Magnifier : Control
{
    CenterBox magnifierContainer;

    Texture2d magnifier;

    Texture2d thumbnail;

    protected
    {
        Texture2d _original;
        ComSurface buffer;
    }

    Source source = Source.currwindow;

    double scale = 1;
    double defaultWidth = 100;
    double defaultHeight = 100;

    this()
    {
        import api.dm.kit.sprites2d.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        layout.isAutoResize = true;
        isBorder = true;
    }

    override void loadTheme()
    {
        super.loadTheme;

        if (width == 0)
        {
            width = theme.controlDefaultWidth * 2;
        }

        if (height == 0)
        {
            height = theme.controlDefaultHeight * 2;
        }
    }

    override void initialize()
    {
        super.initialize;

        onPointerEnter ~= (ref e) {

            if (!magnifierContainer)
            {
                return;
            }

            if (!isLastIndex(magnifierContainer))
            {
                changeIndexToLast(magnifierContainer);
            }

            magnifierContainer.isVisible = true;
            //input.systemCursor.hide;
        };

        onPointerMove ~= (ref e) {

            if (!thumbnail)
            {
                return;
            }

            auto pointerPos = input.pointerPos;

            auto pointerMargin = 10;

            auto magnPosX = pointerPos.x + pointerMargin;
            auto magnPosY = pointerPos.y - magnifierContainer.height - pointerMargin;

            magnifierContainer.x = magnPosX;
            magnifierContainer.y = magnPosY;

            auto mouseXRel = pointerPos.x - x;
            auto mouseYRel = pointerPos.y - y;

            final switch (source) with (Source)
            {
                case currwindow:

                    auto currwindow = window;

                    auto originalXRel = (currwindow.width * mouseXRel) / thumbnail.width;
                    auto originalYRel = (currwindow.height * mouseYRel) / thumbnail.height;

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

                    break;
                case texture:

                    assert(_original);

                    auto originalXRel = (_original.width * mouseXRel) / thumbnail.width;
                    auto originalYRel = (_original.height * mouseYRel) / thumbnail.height;

                    Rect2d textureBounds = Rect2d(originalXRel, originalYRel, magnifier.width, magnifier
                            .height);

                    import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

                    magnifier.setRendererTarget;
                    scope (exit)
                    {
                        magnifier.restoreRendererTarget;
                    }

                    auto destBounds = Rect2d(0, 0, magnifier.width, magnifier.height);
                    _original.drawTexture(textureBounds, destBounds);
                    break;
            }
        };

        onPointerExit ~= (ref e) {
            magnifierContainer.isVisible = false;
            //input.systemCursor.show;
        };
    }

    override void create()
    {
        super.create;

        const w = defaultWidth * scale;
        const h = defaultHeight * scale;

        magnifierContainer = new CenterBox;
        magnifierContainer.isLayoutManaged = false;
        magnifierContainer.isVisible = false;
        magnifierContainer.isBorder = true;

        magnifierContainer.resize(w, h);

        addCreate(magnifierContainer);

        magnifier = new Texture2d(w, h);
        magnifierContainer.build(magnifier);

        thumbnail = new Texture2d(width, height);
        addCreate(thumbnail);
        thumbnail.createTargetRGBA32;

        final switch (source) with (Source)
        {
            case currwindow:
                magnifier.createMutRGBA32;

                buffer = graphic.comSurfaceProvider.getNew();

                thumbnail = new Texture2d(width, height);
                build(thumbnail);
                thumbnail.createTargetRGBA32;
                addCreate(thumbnail);

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
                        if (const err = buffer.getSize(w, h))
                        {
                            logger.error(err.toString);
                            return;
                        }

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

                break;
            case texture:
                magnifier.createTargetRGBA32;
                break;
        }

        magnifierContainer.addCreate(magnifier);
    }

    void original(Texture2d sprite)
    {
        assert(magnifier, "Magnifier not created");

        _original = sprite;

        source = Source.texture;

        thumbnail.copyFrom(sprite);

        assert(magnifier.width > 0 && magnifier.height > 0);

        auto widthZoom = _original.width / magnifier.width;
        auto heightZoom = _original.height / magnifier.height;
        if (magnifier.width < widthZoom)
        {
            magnifier.width = widthZoom;
        }
        if (magnifier.height < heightZoom)
        {
            magnifier.height = heightZoom;
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
