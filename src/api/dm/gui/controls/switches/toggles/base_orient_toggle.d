module api.dm.gui.controls.switches.toggles.base_orient_toggle;

import api.dm.gui.controls.switches.toggles.base_toggle : BaseToggle;
import api.math.geom2.vec2 : Vec2d;
import api.math.orientation : Orientation;

/**
 * Authors: initkfs
 */
class BaseOrientToggle : BaseToggle
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
