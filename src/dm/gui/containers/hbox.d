module dm.gui.containers.hbox;

import dm.gui.containers.base.spaceable_container : SpaceableContainer;
import dm.kit.sprites.layouts.hlayout : HLayout;
import dm.kit.sprites.sprite : Sprite;

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
        import core.utils.type_util : castSafe;

        super.spacing = value;
        if (auto hLayout = layout.castSafe!HLayout)
        {
            hLayout.spacing = value;
        }
    }
}
