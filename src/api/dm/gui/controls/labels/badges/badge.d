module api.dm.gui.controls.labels.badges.badge;

import api.dm.gui.controls.labels.label : Label;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.math.pos2.position : Pos;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Label
{
    bool isSmallSize = true;

    Pos position = Pos.topRight;

    this(dstring text = "Badge", dchar iconName = dchar.init, float graphicsGap = 0)
    {
        super(text, iconName, graphicsGap);
        //TODO PosLayout in parent
        isLayoutManaged = false;
        isResizedByParent = false;
        isBorder = false;
        isBackground = true;
        isEnablePadding = false;
    }

    override void create()
    {
        super.create;
    }

    override void applyLayout()
    {
        super.applyLayout;

        if (parent)
        {
            const thisBounds = boundsRect;
            pos = thisBounds.toParentBoundsHalf(parent.boundsRect, position);
        }
    }

    override protected GraphicStyle createBackgroundStyle() => createFillStyle;
}
