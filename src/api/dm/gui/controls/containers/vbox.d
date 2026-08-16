module api.dm.gui.controls.containers.vbox;

import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;

/**
 * Authors: initkfs
 */
class VBox : SpaceableContainer
{
    this(float spacing = SpaceableLayout.DefaultSpacing, bool isNoLayout = false)
    {
        super(spacing, () {
            import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

            layout = new VLayout(spacing);
            layout.isAutoResize = true;
            return layout;
        }, isNoLayout, null);
    }
}
