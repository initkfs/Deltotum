module dm.gui.containers.vbox;

import dm.gui.containers.base.spaceable_container: SpaceableContainer;
import dm.kit.sprites.layouts.vlayout : VLayout;

/**
 * Authors: initkfs
 */
class VBox : SpaceableContainer
{
    this(double spacing = 0) pure
    {
        super(spacing);

        auto vlayout = new VLayout(spacing);
        vlayout.isAlignX = false;
        this.layout = vlayout;
        layout.isAutoResize = true;
    }

    alias spacing = SpaceableContainer.spacing;

    override void spacing(double value)
    {
        super.spacing = value;
        if (auto vlayout = cast(VLayout) layout)
        {
            vlayout.spacing = value;
        }
    }
}

unittest
{
    import dm.kit.sprites.sprite : Sprite;
    import dm.math.geom.insets : Insets;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new VBox;
    container1.add(sp1);
    container1.update(0);

    //assert(container1.width == sp1.width);
    //assert(container1.height == sp1.height);
}
