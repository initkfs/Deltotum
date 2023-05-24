module deltotum.gui.containers.container;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Container : Control
{
    this() pure @safe
    {
        isBackground = false;

        import deltotum.kit.sprites.layouts.center_layout: CenterLayout;
        layout = new CenterLayout;
        layout.isAutoResize(true);
    }

    override void addCreate(Sprite[] sprites)
    {
        foreach (sprite; sprites)
        {
            addCreate(sprite);
        }
    }

    override void addCreate(Sprite sprite, long index = -1)
    {
        if (sprite.isLayoutManaged)
        {
            sprite.x = 0;
            sprite.y = 0;
        }

        if (sprite.isManaged)
        {
            sprite.isResizedByParent = true;
        }

        super.addCreate(sprite, index);
    }

    void isFillFromStartToEnd(bool isFill)
    {
        if (!layout)
        {
            return;
        }

        layout.isFillFromStartToEnd = isFill;
    }
}

unittest
{

    import deltotum.kit.sprites.sprite : Sprite;

    auto sp1 = new Sprite;
    sp1.width = 100;
    sp1.height = 200;

    auto container1 = new Container;
    container1.add(sp1);
    container1.update(0);

    assert(container1.width == sp1.width);
    assert(container1.height == sp1.height);

    import deltotum.math.geometry.insets : Insets;

    container1.padding = Insets(5);
    container1.setInvalid;
    container1.update(0);

    assert(container1.width == (sp1.width + container1.padding.width));
    assert(container1.height == (sp1.height + container1.padding.height));

    sp1.width = sp1.width * 2;
    sp1.update(0);

    assert(container1.width == (sp1.width + container1.padding.width));
}
