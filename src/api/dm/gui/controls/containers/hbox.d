module api.dm.gui.controls.containers.hbox;

import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.layout2d : Layout2d;

/**
 * Authors: initkfs
 */
class HBox : SpaceableContainer
{
    this(float spacing = SpaceableLayout.DefaultSpacing, bool isAutoResize = true, bool isAlignY = false, bool isLayout = true)
    {
        super(spacing, () {
            import api.dm.kit.sprites2d.layouts.hlayout : HLayout;

            layout = new HLayout(spacing);
            layout.isAlignY = isAlignY;
            layout.isAutoResize = isAutoResize;
            return layout;
        }, isLayout, null);
    }
}
