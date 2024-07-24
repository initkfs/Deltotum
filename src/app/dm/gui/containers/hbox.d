module app.dm.gui.containers.hbox;

import app.dm.gui.containers.base.spaceable_container : SpaceableContainer;
import app.dm.kit.sprites.layouts.hlayout : HLayout;
import app.dm.kit.sprites.sprite : Sprite;

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
        import app.core.utils.types : castSafe;

        super.spacing = value;
        if (auto hLayout = layout.castSafe!HLayout)
        {
            hLayout.spacing = value;
        }
    }
}
