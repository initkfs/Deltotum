module api.dm.gui.containers.stack_box;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

/**
 * Authors: initkfs
 */
class StackBox : Container
{
    this()
    {
        layout = new CenterLayout;
        layout.isAutoResize = true;
    }
}

unittest
{
    import api.dm.kit.sprites.sprite : Sprite;
    import api.math.insets : Insets;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new StackBox;
    //TODO insets
    //container1.padding = Insets(5);
    container1.width = 1000;
    container1.height = 2000;
    container1.add(sp1);
    container1.update(0);

    //assert(sp1.x == 450);
    //assert(sp1.y == 900);
}
