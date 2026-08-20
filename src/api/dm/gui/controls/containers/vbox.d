module api.dm.gui.controls.containers.vbox;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;

/**
 * Authors: initkfs
 */
class VBox : SpaceableContainer
{
    this(float spacing = SpaceableLayout.DefaultSpacing, bool isAutoResize = true, bool isAlignX = false, bool isLayout = true, Control[] children = null)
    {
        super(spacing, () {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout(spacing);
            layout.isAutoResize = isAutoResize;
            layout.isAlignX = isAlignX;
            return layout;
        }, isLayout, null, children);
    }
}
