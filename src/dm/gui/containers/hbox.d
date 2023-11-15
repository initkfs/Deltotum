module dm.gui.containers.hbox;

import dm.gui.containers.base.spaceable_container: SpaceableContainer;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class HBox : SpaceableContainer
{
    this(double spacing = 0) pure
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
        super.spacing = value;
        if (auto hLayout = cast(HLayout) layout)
        {
            hLayout.spacing = value;
        }
    }
}
