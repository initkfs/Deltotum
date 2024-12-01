module api.dm.gui.containers.container;

import api.dm.gui.controls.control : Control;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
class Container : Control
{

    this(){
        isBackground = false;
    }

    bool isAlignX()
    {
        assert(layout);
        return layout.isAlignX;
    }

    void isAlignX(bool value)
    {
        assert(layout);
        layout.isAlignX = value;
        setInvalid;
    }

    bool isAlignY()
    {
        assert(layout);
        return layout.isAlignY;
    }

    void isAlignY(bool value)
    {
        assert(layout);
        layout.isAlignY = value;
        setInvalid;
    }

    bool isFillFromStartToEnd()
    {
        assert(layout);
        return layout.isFillFromStartToEnd;
    }

    void isFillFromStartToEnd(bool isFill)
    {
        assert(layout);
        layout.isFillFromStartToEnd = isFill;
        setInvalid;
    }

    bool isLayoutResizeChildren()
    {
        assert(layout);
        return layout.isResizeChildren;
    }

    void isLayoutResizeChildren(bool value)
    {
        assert(layout);
        layout.isResizeChildren = value;
        setInvalid;
    }

    bool isResizeRoot()
    {
        assert(layout);
        return layout.isResizeRoot;
    }

    void isResizeRoot(bool value)
    {
        assert(layout);
        layout.isIncreaseRootSize = value;
        setInvalid;
    }
}

unittest
{

    import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;

    auto sp1 = new Sprite2d;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new Container;
    container1.add(sp1);
    container1.update(0);

    // assert(container1.width == sp1.width);
    // assert(container1.height == sp1.height);

    // import api.math.insets : Insets;

    // container1.padding = Insets(5);
    // container1.setInvalid;
    // container1.update(0);

    // assert(container1.width == (sp1.width + container1.padding.width));
    // assert(container1.height == (sp1.height + container1.padding.height));

    // sp1.width = sp1.width * 2;
    // sp1.update(0);

    //assert(container1.width == (sp1.width + container1.padding.width));
}
