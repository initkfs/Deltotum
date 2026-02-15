module api.dm.gui.controls.switches.toggles.toggle;

import api.dm.gui.controls.switches.toggles.base_orient_toggle: BaseOrientToggle;
import api.math.geom2.vec2 : Vec2f;
import api.math.pos2.orientation : Orientation;
import api.math.geom2.points2;

/**
 * Authors: initkfs
 */
class Toggle : BaseOrientToggle
{
    this(dstring label, float width, float height, dchar iconName = dchar.init, Orientation orientation, float graphicsGap = 5)
    {
        super(label, width, height, iconName, orientation, graphicsGap);
    }

    this(dstring label = "Toggle", dchar iconName = dchar.init, Orientation orientation = Orientation.horizontal, float graphicsGap = 5)
    {
        this(label, 0, 0, iconName, orientation, graphicsGap);
    }

    override Vec2f thumbSize()
    {
        if (isVertical)
        {
            return Vec2f(thumbHeight, thumbWidth);
        }

        return Vec2f(thumbWidth, thumbHeight);
    }

    override Vec2f thumbContainerSize()
    {
        if (isVertical)
        {
            return Vec2f(thumbHeight, thumbWidth * 2);
        }

        return Vec2f(thumbWidth * 2, thumbHeight);
    }

    override void initialize()
    {
        super.initialize;

        if (!isVertical)
        {
            onCreatedThumbContainer = (thumbContainer) {
                auto isRemove = remove(thumbContainer, isDestroy:
                    false);
                assert(isRemove);
                add(thumbContainer, 0);
            };
        }
    }

    override Vec2f thumbAnimationMinValue()
    {
        const hb = thumbContainer.boundsRect;

        if (isVertical)
        {
            return Vec2f(hb.x + thumbContainer.padding.left, hb
                    .bottom - thumbContainer.padding.bottom - thumb.height);
        }

        return Vec2f(hb.x + thumbContainer.padding.left, hb
                .y + thumbContainer.padding.top);
    }

    override Vec2f thumbAnimationMaxValue()
    {
        const hb = thumbContainer.boundsRect;

        if (isVertical)
        {
            return Vec2f(hb.x + thumbContainer.padding.left, hb
                    .y - thumbContainer.padding.top);
        }

        return Vec2f(
            hb.right - thumb.width - thumbContainer.padding.right, hb
                .y + thumbContainer.padding.top);
    }
}
