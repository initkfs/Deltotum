module api.dm.gui.controls.switches.toggles.toggle;

import api.dm.gui.controls.switches.toggles.base_orient_toggle: BaseOrientToggle;
import api.math.geom2.vec2 : Vec2d;
import api.math.pos2.orientation : Orientation;
import api.math.geom2.points2;

/**
 * Authors: initkfs
 */
class Toggle : BaseOrientToggle
{
    this(dstring label, float width, float height, string iconName = null, Orientation orientation, float graphicsGap = 5)
    {
        super(label, width, height, iconName, orientation, graphicsGap);
    }

    this(dstring label = "Toggle", string iconName = null, Orientation orientation = Orientation.horizontal, float graphicsGap = 5)
    {
        this(label, 0, 0, iconName, orientation, graphicsGap);
    }

    override Vec2d thumbSize()
    {
        if (isVertical)
        {
            return Vec2d(thumbHeight, thumbWidth);
        }

        return Vec2d(thumbWidth, thumbHeight);
    }

    override Vec2d thumbContainerSize()
    {
        if (isVertical)
        {
            return Vec2d(thumbHeight, thumbWidth * 2);
        }

        return Vec2d(thumbWidth * 2, thumbHeight);
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

    override Vec2d thumbAnimationMinValue()
    {
        const hb = thumbContainer.boundsRect;

        if (isVertical)
        {
            return Vec2d(hb.x + thumbContainer.padding.left, hb
                    .bottom - thumbContainer.padding.bottom - thumb.height);
        }

        return Vec2d(hb.x + thumbContainer.padding.left, hb
                .y + thumbContainer.padding.top);
    }

    override Vec2d thumbAnimationMaxValue()
    {
        const hb = thumbContainer.boundsRect;

        if (isVertical)
        {
            return Vec2d(hb.x + thumbContainer.padding.left, hb
                    .y - thumbContainer.padding.top);
        }

        return Vec2d(
            hb.right - thumb.width - thumbContainer.padding.right, hb
                .y + thumbContainer.padding.top);
    }
}
