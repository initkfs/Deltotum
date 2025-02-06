module api.dm.gui.controls.containers.border_box;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.layouts.vlayout : VLayout;
import api.dm.gui.controls.containers.center_box : CenterBox;
import api.math.insets : Insets;
import api.dm.gui.controls.containers.hbox : HBox;

/**
 * Authors: initkfs
 */
class BorderBox : Container
{
    protected
    {
        CenterBox _top;
        CenterBox _left;
        CenterBox _center;
        CenterBox _right;
        CenterBox _bottom;

        HBox _centerBox;
    }

    this()
    {
        this.layout = new VLayout;
        layout.isAutoResize = true;
    }

    protected CenterBox createBox()
    {
        auto box = new CenterBox;
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

    CenterBox topPane()
    {
        return _top;
    }

    CenterBox leftPane()
    {
        return _left;
    }

    CenterBox centerPane()
    {
        return _center;
    }

    CenterBox rightPane()
    {
        return _right;
    }

    CenterBox bottomPane()
    {
        return _bottom;
    }

}
