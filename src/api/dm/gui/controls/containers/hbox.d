module api.dm.gui.controls.containers.hbox;

import api.dm.gui.controls.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites2d.layouts.spaceable_layout : SpaceableLayout;
import api.dm.kit.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class HBox : SpaceableContainer
{
    this(double spacing = SpaceableLayout.DefaultSpacing)
    {
        super(spacing);

        auto hlayout = new HLayout(spacing);
        hlayout.isAlignY = false;
        hlayout.isAutoResize = true;
        this.layout = hlayout;
    }

    alias spacing = SpaceableContainer.spacing;

    override void spacing(double value)
    {
        import api.core.utils.types : castSafe;

        super.spacing = value;
        if (auto hLayout = layout.castSafe!HLayout)
        {
            hLayout.spacing = value;
        }
    }
}
