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
    }

    void requestResize()
    {
        isProcessLayout = true;
        autoResize;
        isProcessLayout = false;
    }

    override void applyLayout()
    {
        if (isProcessChildLayout)
        {
            return;
        }

        requestResize;

        isProcessChildLayout = true;
        resizeChildren;
        isProcessChildLayout = false;

        super.applyLayout;
    }

    protected auto childrenForLayout()
    {
        import std.algorithm.iteration : filter;

        return children.filter!(ch => ch.isLayoutManaged);
    }

    void autoResize()
    {
        double newWidth = childrenWidth;
        if (padding.width > 0)
        {
            newWidth += padding.width;
        }

        if (newWidth > width)
        {
            if (newWidth < maxWidth)
            {
                width = newWidth;
            }
            else
            {
                const double decWidth = (maxWidth - padding.width) / children.length;
                foreach (ch; children)
                {
                    ch.width(ch.width - decWidth);
                }
            }
        }

        double newHeight = childrenHeight;
        if (padding.height > 0)
        {
            newHeight += padding.height;
        }

        if (newHeight > height)
        {
            if (newHeight < maxHeight)
            {
                height = newHeight;
                resizeChildren;
            }
            else
            {
                //TODO reduce height
            }

        }
    }

    //TODO the first child occupies all available space
    void resizeChildren()
    {
        import std.range.primitives : empty, walkLength;
        import std.algorithm.searching : count;

        auto targetChildren = childrenForLayout;
        if (targetChildren.empty)
        {
            return;
        }

        const hgrowChildren = targetChildren.count!(ch => ch.isHGrow);
        const vgrowChildren = targetChildren.count!(ch => ch.isVGrow);

        if (hgrowChildren == 0 && vgrowChildren == 0)
        {
            return;
        }

        const freeWidth = width - childrenWidth - padding.width;
        const freeHeight = height - childrenHeight - padding.height;

        const dtWidth = freeWidth / hgrowChildren;
        const dtHeight = freeHeight / vgrowChildren;

        foreach (child; targetChildren)
        {
            if (child.isHGrow)
            {
                child.width = child.width + dtWidth;
            }

            if (child.isVGrow)
            {
                child.height = child.height + dtHeight;
            }
        }
    }

    double childrenWidth()
    {
        if (children.length == 0)
        {
            return 0;
        }

        auto targetChildren = childrenForLayout;
        double childrendWidth = 0;
        foreach (child; targetChildren)
        {
            childrendWidth += child.width + child.margin.width;
        }

        return childrendWidth;
    }

    double childrenHeight()
    {
        if (children.length == 0)
        {
            return 0;
        }

        auto targetChildren = childrenForLayout;
        double childrendHeight = 0;
        foreach (child; targetChildren)
        {
            childrendHeight += child.height + child.margin.height;
        }

        return childrendHeight;
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

        requestResize;
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
