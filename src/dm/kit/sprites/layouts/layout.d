module dm.kit.sprites.layouts.layout;

import dm.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
abstract class Layout
{
    bool isAlignX;
    bool isAlignY;

    bool isAlignXifOneChild;
    bool isAlignYifOneChild;

    bool isFillFromStartToEnd = true;
    bool isResizeChildren;
    bool isResizeParent;

    bool isAutoWidthReduction;
    bool isAutoHeightReduction;

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

        return root.children.filter!(ch => ch.isVisible && ch.isLayoutManaged);
    }

    void isAutoResize(bool isResize) pure @safe
    {
        isResizeParent = isResize;
        isResizeChildren = isResize;
    }

    void isAlignOneChild(bool isAlign) pure @safe
    {
        isAlignXifOneChild = isAlign;
        isAlignYifOneChild = isAlign;
    }

    void isAutoResizeAndAlignOne(bool value) pure @safe
    {
        isAutoResize = value;
        isAlignOneChild = value;
    }

    void isAlign(bool value) pure @safe
    {
        isAlignX = value;
        isAlignY = value;
    }

    void isAutoSizeReduction(bool isValue)
    {
        isAutoWidthReduction = isValue;
        isAutoHeightReduction = isValue;
    }
}
