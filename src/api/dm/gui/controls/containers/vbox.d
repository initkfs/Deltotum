module api.dm.gui.controls.containers.vbox;

import api.dm.gui.controls.containers.base.spaceable_container: SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;

/**
 * Authors: initkfs
 */
class VBox : SpaceableContainer
{
    this(double spacing = SpaceableLayout.DefaultSpacing)
    {
        super(spacing);

        import api.dm.kit.sprites2d.layouts.vlayout : VLayout;

        layout = new VLayout(spacing);
        layout.isAutoResize = true;
    }
}
