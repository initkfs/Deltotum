module api.dm.gui.controls.viewers.magnifiers.texture_magnifier;

import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

import api.dm.gui.controls.viewers.magnifiers.base_magnifier : BaseMagnifier;
import api.dm.gui.controls.containers.container : Container;

import api.math.geom2.rect2 : Rect2d;

import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class TextureMagnifier : BaseMagnifier
{
    protected
    {
        Texture2d _original;
    }

    override void pointerMove(double pRelX, double pRelY, ref PointerEvent e)
    {
        assert(_original);

        auto originalXRel = (_original.width * pRelX) / thumbnail.width;
        auto originalYRel = (_original.height * pRelY) / thumbnail.height;

        Rect2d textureBounds = Rect2d(originalXRel, originalYRel, magnifier.width, magnifier
                .height);

        magnifier.setRendererTarget;
        scope (exit)
        {
            magnifier.restoreRendererTarget;
        }

        auto destBounds = Rect2d(0, 0, magnifier.width, magnifier.height);
        _original.drawTexture(textureBounds, destBounds);
    }

    override Texture2d newMagnifier(double w, double h)
    {
        auto t = new Texture2d(w, h);
        build(t);
        t.createTargetRGBA32;
        return t;
    }

    override Texture2d newThumbnail(double w, double h)
    {
        auto t = new Texture2d(w, h);
        build(t);
        t.createTargetRGBA32;
        return t;
    }

    void original(Texture2d sprite)
    {
        assert(magnifier, "Magnifier not created");

        _original = sprite;

        assert(thumbnail);
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

}
