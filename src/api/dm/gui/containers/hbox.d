module api.dm.gui.containers.hbox;

import api.dm.gui.containers.base.spaceable_container : SpaceableContainer;
import api.dm.kit.sprites.sprites2d.layouts.hlayout : HLayout;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class HBox : SpaceableContainer
{
    this(double spacing = 0)
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
