module api.dm.gui.controls.viewers.magnifiers.base_magnifier;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.container : Container;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.gui.controls.texts.text : Text;
import api.math.geom2.rect2 : Rect2d;
import Math = api.dm.math;

/**
 * Authors: initkfs
 */
class BaseMagnifier : Control
{
    Container magnifierContainer;
    Container delegate(Container) onNewMagnifierContainer;
    void delegate(Container) onConfiguredMagnifierContainer;
    void delegate(Container) onCreatedMagnifierContainer;

    Texture2d magnifier;
    Texture2d delegate(Texture2d) onNewMagnifier;
    void delegate(Texture2d) onConfiguredMagnifier;
    void delegate(Texture2d) onCreatedMagnifier;

    Texture2d thumbnail;
    Texture2d delegate(Texture2d) onNewThumbnail;
    void delegate(Texture2d) onConfiguredThumbnail;
    void delegate(Texture2d) onCreatedThumbnail;

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

            auto pXRel = pointerPos.x - x;
            auto pYRel = pointerPos.y - y;

            pointerMove(pXRel, pYRel, e);
        };

        onPointerExit ~= (ref e) {
            magnifierContainer.isVisible = false;
            //input.systemCursor.show;
        };
    }

    bool isMagnVisible() => magnifierContainer && magnifierContainer.isVisible;

    void pointerMove(double pRelX, double pRelY, ref PointerEvent e)
    {

    }

    override void create()
    {
        super.create;

        const w = defaultWidth * scale;
        const h = defaultHeight * scale;

        auto magnContainer = newMagnifierContainer;
        magnifierContainer = !onNewMagnifierContainer ? magnContainer : onNewMagnifierContainer(
            magnContainer);

        magnifierContainer.isLayoutManaged = false;
        magnifierContainer.isVisible = false;
        magnifierContainer.isBorder = true;

        magnifierContainer.resize(w, h);

        if (onConfiguredMagnifierContainer)
        {
            onConfiguredMagnifierContainer(magnifierContainer);
        }

        addCreate(magnifierContainer);

        if (onCreatedMagnifierContainer)
        {
            onCreatedMagnifierContainer(magnifierContainer);
        }

        auto newMagn = newMagnifier(w, h);
        magnifier = !onNewMagnifier ? newMagn : onNewMagnifier(newMagn);
        if (onConfiguredMagnifier)
        {
            onConfiguredMagnifier(magnifier);
        }

        assert(magnifierContainer);
        magnifierContainer.addCreate(magnifier);

        if (onCreatedMagnifier)
        {
            onCreatedMagnifier(magnifier);
        }

        auto newThumb = newThumbnail(width, height);
        thumbnail = !onNewThumbnail ? newThumb : onNewThumbnail(newThumb);

        if (onConfiguredThumbnail)
        {
            onConfiguredThumbnail(thumbnail);
        }

        addCreate(thumbnail);
        if (onCreatedThumbnail)
        {
            onCreatedThumbnail(thumbnail);
        }
    }

    Container newMagnifierContainer()
    {
        import api.dm.gui.controls.containers.center_box : CenterBox;

        return new CenterBox;
    }

    Texture2d newMagnifier(double w, double h)
    {
        return new Texture2d(w, h);
    }

    Texture2d newThumbnail(double w, double h)
    {
        return new Texture2d(w, h);
    }

}
