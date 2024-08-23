module api.dm.gui.containers.border_box;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.layouts.vlayout : VLayout;
import api.dm.gui.containers.stack_box : StackBox;
import api.dm.math.insets : Insets;
import api.dm.gui.containers.hbox : HBox;

/**
 * Authors: initkfs
 */
class BorderBox : Container
{
    protected
    {
        StackBox _top;
        StackBox _left;
        StackBox _center;
        StackBox _right;
        StackBox _bottom;

        HBox _centerBox;
    }

    this()
    {
        this.layout = new VLayout;
        layout.isAutoResize = true;
    }

    protected StackBox createBox()
    {
        auto box = new StackBox;
        box.isHGrow = true;
        box.isVGrow = true;
        box.layout.isAutoResize = true;
        return box;
    }

    override void create()
    {
        super.create;

        //TODO lazy?
        _top = createBox;
        addCreate(_top);

        _centerBox = new HBox;
        _centerBox.layout.isAutoResize = true;
        _centerBox.isHGrow = true;
        _centerBox.isVGrow = true;
        addCreate(_centerBox);
        _centerBox.spacing = 0;
        _centerBox.padding = Insets(0, 0, 0, 0);

        _left = createBox;
        _centerBox.addCreate(_left);

        _center = createBox;
        _centerBox.addCreate(_center);

        _right = createBox;
        _centerBox.addCreate(_right);

        _bottom = createBox;
        addCreate(_bottom);
    }

    StackBox topPane()
    {
        return _top;
    }

    StackBox leftPane()
    {
        return _left;
    }

    StackBox centerPane()
    {
        return _center;
    }

    StackBox rightPane()
    {
        return _right;
    }

    StackBox bottomPane()
    {
        return _bottom;
    }

}
