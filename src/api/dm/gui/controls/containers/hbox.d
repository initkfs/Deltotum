module api.dm.gui.controls.containers.hbox;

import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

/**
 * Authors: initkfs
 */
class HBox : SpaceableContainer
{
    this(float spacing = SpaceableLayout.DefaultSpacing)
    {
        super(spacing);

        import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

        layout = new HLayout(spacing);
        layout.isAutoResize = true;
    }
}
