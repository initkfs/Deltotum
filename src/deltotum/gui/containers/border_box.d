module deltotum.gui.containers.border_box;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.containers.container : Container;
import deltotum.kit.sprites.layouts.vertical_layout : VerticalLayout;
import deltotum.gui.containers.stack_box : StackBox;
import deltotum.math.geometry.insets : Insets;
import deltotum.gui.containers.hbox : HBox;

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
        this.layout = new VerticalLayout;
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

    StackBox top()
    {
        return _top;
    }

    StackBox left()
    {
        return _left;
    }

    StackBox center()
    {
        return _center;
    }

    StackBox right()
    {
        return _right;
    }

    StackBox bottom()
    {
        return _bottom;
    }

}
