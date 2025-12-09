module api.dm.gui.controls.switches.toggles.base_orient_toggle;

import api.dm.gui.controls.switches.toggles.base_toggle : BaseToggle;
import api.math.geom2.vec2 : Vec2d;
import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 */
class BaseOrientToggle : BaseToggle
{
    Orientation orientation = Orientation.horizontal;

    this(dstring label, float width, float height, string iconName = null, Orientation orientation, float graphicsGap = 5)
    {
        super(label, width, height, iconName, graphicsGap, isCreateLayout:
            false);
        this.orientation = orientation;
        if (orientation == Orientation.vertical)
        {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout;
        }
        else
        {
            import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

            layout = new HLayout;
        }

        layout.isAutoResize = true;
        layout.isAlignX = true;
    }

    bool isVertical() => orientation == Orientation.vertical;
}
