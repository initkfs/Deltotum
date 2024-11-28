module api.dm.gui.controls.switches.toggles.vtoggle_switch;

import api.dm.gui.controls.switches.toggles.base_toggle_switch : BaseToggleSwitch;
import api.dm.gui.controls.control : Control;
import api.math.geom2.vec2 : Vec2d;

/**
 * Authors: initkfs
 */
class VToggleSwitch : BaseToggleSwitch
{
    this(dstring label, double width, double height, string iconName = null, double graphicsGap = 5)
    {
        super(label, width, height, iconName, graphicsGap, isCreateLayout : false);

        import api.dm.kit.sprites.layouts.vlayout: VLayout;
        layout = new VLayout(5);
        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    this(dstring label = "Toggle", string iconName = null, double graphicsGap = 5)
    {
        this(label, 0, 0, iconName, graphicsGap);
    }

    override Vec2d handleSize() => Vec2d(handleHeight, handleWidth);
    override Vec2d handleContainerSize() => Vec2d(handleHeight, handleWidth * 2);

    override Vec2d handleOnAnimationMinValue(){
        const hb = handleContainer.bounds;
        return Vec2d(hb.x + handleContainer.padding.left, hb
                .bottom - handleContainer.padding.bottom - handle.height);
    }

    override Vec2d handleOnAnimationMaxValue(){
        const hb = handleContainer.bounds;
        return Vec2d(hb.x + handleContainer.padding.left, hb
                .y - handleContainer.padding.top);
    }

    override Vec2d handleOffAnimationMinValue(){
        return handleOnAnimationMaxValue;
    }

    override Vec2d handleOffAnimationMaxValue(){
        return handleOnAnimationMinValue;
    }
}
