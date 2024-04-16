module dm.gui.containers.container;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Container : Control
{
    override void construct(){
        super.construct;
        isBackground = false;
    }

    alias addCreate = Sprite.addCreate;

    override void addCreate(Sprite sprite, long index = -1)
    {
        if (layout && sprite.isLayoutManaged)
        {
            sprite.x = 0;
            sprite.y = 0;
        }

        super.addCreate(sprite, index);
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

    bool isResizeChildren()
    {
        assert(layout);
        return layout.isResizeChildren;
    }

    void isResizeChildren(bool value)
    {
        assert(layout);
        layout.isResizeChildren = value;
        setInvalid;
    }

    bool isResizeParent()
    {
        assert(layout);
        return layout.isResizeParent;
    }

    void isResizeParent(bool value)
    {
        assert(layout);
        layout.isResizeParent = value;
        setInvalid;
    }
}

unittest
{

    import dm.kit.sprites.sprite : Sprite;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new Container;
    container1.add(sp1);
    container1.update(0);

    // assert(container1.width == sp1.width);
    // assert(container1.height == sp1.height);

    // import dm.math.insets : Insets;

    // container1.padding = Insets(5);
    // container1.setInvalid;
    // container1.update(0);

    // assert(container1.width == (sp1.width + container1.padding.width));
    // assert(container1.height == (sp1.height + container1.padding.height));

    // sp1.width = sp1.width * 2;
    // sp1.update(0);

    //assert(container1.width == (sp1.width + container1.padding.width));
}
