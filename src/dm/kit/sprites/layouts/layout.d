module dm.kit.sprites.layouts.layout;

import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class Layout
{
    bool isAlignX;
    bool isAlignY;

    bool isFillFromStartToEnd = true;
    bool isResizeChildren;
    bool isResizeParent;

    double sizeChangeDelta = 0.15;

    abstract
    {
        void applyLayout(Sprite root);

        double childrenWidth(Sprite root);
        double childrenHeight(Sprite root);
    }

    double freeMaxWidth(Sprite root)
    {
        const childrenW = childrenWidth(root);
        const maxW = root.maxWidth - root.padding.width;
        if (childrenW >= maxW)
        {
            return 0;
        }

        return maxW - childrenW;
    }

    double freeMaxHeight(Sprite root)
    {
        const childrenH = childrenHeight(root);
        const maxH = root.maxHeight - root.padding.height;
        if (childrenH >= maxH)
        {
            return 0;
        }

        return maxH - childrenH;
    }

    auto childrenForLayout(Sprite root)
    {
        import std.algorithm.iteration : filter;

        return root.children.filter!(ch => ch.isLayoutManaged);
    }

    void isAutoResize(bool isResize) pure @safe
    {
        isResizeParent = isResize;
        isResizeChildren = isResize;
    }
}
