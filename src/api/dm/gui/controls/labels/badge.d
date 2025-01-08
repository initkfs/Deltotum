module api.dm.gui.controls.labels.badge;

import api.dm.gui.controls.labels.label: Label;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.popups.text_popup : TextPopup;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Label
{
    this(dstring text = "Badge", string iconName = null, double graphicsGap = 0)
    {
        super(text, iconName, graphicsGap);

        isLayoutManaged = false;
        isResizedByParent = false;
        isBorder = false;
    }

    override void applyLayout()
    {
        super.applyLayout;

        if (parent)
        {
            const thisBounds = boundsRect;
            auto newX = parent.boundsRect.right - thisBounds.halfWidth;
            auto newY = parent.boundsRect.y - thisBounds.halfHeight;
            x = newX;
            y = newY;
        }

    }

    override void initialize()
    {
        super.initialize;
    }

    override void create()
    {
        super.create;
    }

}
