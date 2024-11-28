module api.dm.gui.controls.switches.toggles.htoggle_switch;

import api.dm.gui.controls.switches.toggles.base_toggle_switch : BaseToggleSwitch;
import api.math.geom2.vec2: Vec2d;

/**
 * Authors: initkfs
 */
class HToggleSwitch : BaseToggleSwitch
{
    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(label, width, height, iconName, graphicsGap);
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        super(label, iconName, graphicsGap);
    }

    override Vec2d handleSize() => Vec2d(handleWidth, handleHeight);
    override Vec2d handleContainerSize() => Vec2d(handleWidth * 2, handleHeight);

    override void initialize(){
        super.initialize;

        onHandleContainerCreated = (handleContainer){
            auto isRemove = remove(handleContainer, isDestroy : false);
            assert(isRemove);
            add(handleContainer, 0);
        };
    }

    override Vec2d handleOnAnimationMinValue(){
        const hb = handleContainer.bounds;
        return Vec2d(hb.x + handleContainer.padding.left, hb
                .y + handleContainer.padding.top);
    }

    override Vec2d handleOnAnimationMaxValue(){
        const hb = handleContainer.bounds;
        return Vec2d(
            hb.right - handle.width - handleContainer.padding.right, hb
                .y + handleContainer.padding.top);
    }

    override Vec2d handleOffAnimationMinValue() => handleOnAnimationMaxValue;
    override Vec2d handleOffAnimationMaxValue() => handleOnAnimationMinValue;
}
