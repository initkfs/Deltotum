module api.dm.kit.sprites.layouts.layout;

import api.dm.kit.sprites.sprite : Sprite;

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

    bool isIncreaseChildrenWidth;
    bool isIncreaseChildrenHeight;

    bool isDecreaseChildrenWidth;
    bool isDecreaseChildrenHeight;

    bool isIncreaseRootWidth;
    bool isIncreaseRootHeight;

    bool isDecreaseRootWidth;
    bool isDecreaseRootHeight;

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

        //TODO return root.children.filter!(ch => ch.isVisible && ch.isLayoutManaged);
        return root.children.filter!(ch => ch.isLayoutManaged);
    }

    bool isIncreaseRootSize() const pure nothrow @safe
    {
        return isIncreaseRootWidth || isIncreaseRootHeight;
    }

    bool isDecreaseRootSize() const pure nothrow @safe
    {
        return isDecreaseRootWidth || isDecreaseRootHeight;
    }

    bool isResizeRoot() const pure nothrow @safe
    {
        return isIncreaseRootSize || isDecreaseRootSize;
    }

    void isIncreaseRootSize(bool value) pure nothrow @safe
    {
        isIncreaseRootWidth = value;
        isIncreaseRootHeight = value;
    }

    void isDecreaseRootSize(bool value) pure nothrow @safe
    {
        isDecreaseRootWidth = value;
        isDecreaseRootHeight = value;
    }

    bool isIncreaseChildrenSize() const pure nothrow @safe
    {
        return isIncreaseChildrenWidth || isIncreaseChildrenHeight;
    }

    bool isDecreaseChildrenSize() const pure nothrow @safe
    {
        return isDecreaseChildrenWidth || isDecreaseChildrenHeight;
    }

    bool isResizeChildren() const pure nothrow @safe
    {
        return isIncreaseChildrenSize || isDecreaseChildrenSize ;
    }

    void isResizeChildren(bool value) pure nothrow @safe
    {
        isIncreaseChildrenWidth = value;
        isIncreaseChildrenHeight = value;
    }

    void isAutoResize(bool isResize) pure @safe
    {
        isIncreaseRootSize = isResize;
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

    void isParentSizeReduce(bool isValue) pure @safe
    {
        isDecreaseRootWidth = isValue;
        isDecreaseRootHeight = isValue;
    }
}
