module api.dm.gui.controls.switches.toggles.toggle;

import api.dm.gui.controls.switches.toggles.base_orient_toggle: BaseOrientToggle;
import api.math.geom2.vec2 : Vec2d;
import api.math.orientation : Orientation;
import api.math.geom2.points2;

/**
 * Authors: initkfs
 */
class Toggle : BaseOrientToggle
{
    this(dstring label, double width, double height, string iconName = null, Orientation orientation, double graphicsGap = 5)
    {
        super(label, width, height, iconName, orientation, graphicsGap);
    }

    this(dstring label = "Toggle", string iconName = null, Orientation orientation = Orientation.horizontal, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, orientation, graphicsGap);
    }

    override Vec2d handleSize()
    {
        if (isVertical)
        {
            return Vec2d(handleHeight, handleWidth);
        }

        return Vec2d(handleWidth, handleHeight);
    }

    override Vec2d handleContainerSize()
    {
        if (isVertical)
        {
            return Vec2d(handleHeight, handleWidth * 2);
        }

        return Vec2d(handleWidth * 2, handleHeight);
    }

    override void initialize()
    {
        super.initialize;

        if (!isVertical)
        {
            onHandleContainerCreated = (handleContainer) {
                auto isRemove = remove(handleContainer, isDestroy:
                    false);
                assert(isRemove);
                add(handleContainer, 0);
            };
        }
    }

    override Vec2d handleAnimationMinValue()
    {
        const hb = handleContainer.boundsRect;

        if (isVertical)
        {
            return Vec2d(hb.x + handleContainer.padding.left, hb
                    .bottom - handleContainer.padding.bottom - handle.height);
        }

        return Vec2d(hb.x + handleContainer.padding.left, hb
                .y + handleContainer.padding.top);
    }

    override Vec2d handleAnimationMaxValue()
    {
        const hb = handleContainer.boundsRect;

        if (isVertical)
        {
            return Vec2d(hb.x + handleContainer.padding.left, hb
                    .y - handleContainer.padding.top);
        }

        return Vec2d(
            hb.right - handle.width - handleContainer.padding.right, hb
                .y + handleContainer.padding.top);
    }
}
