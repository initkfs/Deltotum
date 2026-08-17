module api.dm.gui.controls.labels.badges.badge;

import api.dm.gui.controls.labels.label : Label;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.graphics.styles.gstyle : GStyle;
import api.math.pos2.position : Pos;

import std.conv : to;

/**
 * Authors: initkfs
 */
class Badge : Label
{
    bool isSmallSize = true;

    Pos position = Pos.topRight;

    float scaleDistance = 0.8;

    this(dstring text = "Badge", dchar iconName = dchar.init, float graphicsGap = 0)
    {
        super(text, iconName, graphicsGap);
        //TODO PosLayout in parent
        isLayoutManaged = false;
        isResizedByParent = false;
        isBorder = false;
        isBackground = true;
        isEnablePadding = true;
    }

    override void create()
    {
        super.create;
    }

    override void enablePadding()
    {
        enum minPad = 1;
        auto pad = theme.controlGraphicsGap / 5;
        if (pad < minPad)
        {
            pad = minPad;
        }
        _padding.set(pad);
    }

    override void applyLayout()
    {
        super.applyLayout;

        if (parent)
        {
            const thisBounds = boundsRect;
            pos = thisBounds.toParentBoundsHalf(parent.boundsRect.scale(scaleDistance), position);
        }
    }

    override protected GStyle createBackgroundStyle() => createSelectStyle;

    override protected Sprite2d createShape(float w, float h, float angle, GStyle style)
    {
        import Math = api.math;

        const size = Math.max(w, h);
        return theme.circleShape(size, createStyle);
    }
}
