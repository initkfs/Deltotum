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

    override void initialize()
    {
        super.initialize;

        invalidateListener = () { checkBackground; };
    }

    void requestResize()
    {
        isProcessLayout = true;
        autoResize;
        isProcessLayout = false;
    }

    override void applyLayout()
    {
        requestResize;
        super.applyLayout;
    }

    protected auto childrenWithGeometry()
    {
        import std.algorithm.iteration : filter;

        return children.filter!(ch => ch.isLayoutManaged);
    }

    private void checkBackground()
    {
        if (background)
        {
            background.width = width;
            background.height = height;
            return;
        }
        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
        }
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
            }
            else
            {
                //TODO reduce height
            }

        }
    }

    double childrenWidth()
    {
        import std.algorithm.iteration : sum, map;
        import std.algorithm.iteration : filter;

        const double childrenWidth = children.filter!(ch => ch.isLayoutManaged)
            .map!(ch => ch.width)
            .sum;
        return childrenWidth;
    }

    double childrenHeight()
    {
        if (children.length == 0)
        {
            return 0;
        }
        import std.algorithm.searching : maxElement;
        import std.algorithm.iteration : filter, map;
        import std.algorithm.comparison : max;
        import std.range.primitives : walkLength;

        auto childrenRange = children.filter!(ch => ch.isLayoutManaged);
        if (childrenRange.walkLength == 0)
        {
            return 0;
        }

        const double childrenMaxHeight = childrenRange.maxElement!"a.height".height;
        return childrenMaxHeight;
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
