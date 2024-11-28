module api.dm.gui.controls.switches.toggles.base_orient_toggle_switch;

import api.dm.gui.controls.switches.toggles.base_toggle_switch : BaseToggleSwitch;
import api.math.geom2.vec2 : Vec2d;
import api.math.orientation : Orientation;

/**
 * Authors: initkfs
 */
class BaseOrientToggleSwitch : BaseToggleSwitch
{
    Orientation orientation = Orientation.horizontal;

    this(dstring label, double width, double height, string iconName = null, Orientation orientation, double graphicsGap = 5)
    {
        super(label, width, height, iconName, graphicsGap, isCreateLayout:
            false);
        this.orientation = orientation;
        if (orientation == Orientation.vertical)
        {
            import api.dm.kit.sprites.layouts.vlayout : VLayout;

            layout = new VLayout(5);
        }
        else
        {
            import api.dm.kit.sprites.layouts.hlayout : HLayout;

            layout = new HLayout(5);
        }

        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    bool isVertical() => orientation == Orientation.vertical;
}
