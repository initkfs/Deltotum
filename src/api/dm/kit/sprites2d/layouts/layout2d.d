module api.dm.kit.sprites2d.layouts.layout2d;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;

/**
 * Authors: initkfs
 */
abstract class Layout2d
{
    bool isAlignX;
    bool isAlignY;

    bool isAlignXifOneChild;
    bool isAlignYifOneChild;

    bool isFillStartToEnd = true;

    bool isIncreaseChildrenWidth;
    bool isIncreaseChildrenHeight;

    bool isDecreaseChildrenWidth;
    bool isDecreaseChildrenHeight;

    bool isIncreaseRootWidth;
    bool isIncreaseRootHeight;

    bool isDecreaseRootWidth;
    bool isDecreaseRootHeight;

    float sizeChangeDelta = 0.15;

    float delegate(Sprite2d) childrenWidthProvider;
    float delegate(Sprite2d) childrenHeightProvider;

    abstract
    {
        void applyLayout(Sprite2d root);

        float calcChildrenWidth(Sprite2d root);
        float calcChildrenHeight(Sprite2d root);
    }

    float childrenWidth(Sprite2d root)
    {
        if (childrenWidthProvider)
        {
            return childrenWidthProvider(root);
        }
        return calcChildrenWidth(root);
    }

    float childrenHeight(Sprite2d root)
    {
        if (childrenHeightProvider)
        {
            return childrenHeightProvider(root);
        }
        return calcChildrenHeight(root);
    }

    float freeMaxWidth(Sprite2d root)
    {
        const childrenW = childrenWidth(root);
        const maxW = root.maxWidth - root.padding.width;
        if (childrenW >= maxW)
        {
            return 0;
        }

        return maxW - childrenW;
    }

    float freeMaxHeight(Sprite2d root)
    {
        const childrenH = childrenHeight(root);
        const maxH = root.maxHeight - root.padding.height;
        if (childrenH >= maxH)
        {
            return 0;
        }

        return maxH - childrenH;
    }

    auto childrenForAlign(Sprite2d root)
    {
        import std.algorithm.iteration : filter;

        //TODO return root.children.filter!(ch => ch.isVisible && ch.isLayoutManaged);
        return root.children.filter!(ch => ch.isLayoutManaged && ch.isLayoutMovable);
    }

    auto childrenForLayout(Sprite2d root)
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
        return isIncreaseChildrenSize || isDecreaseChildrenSize;
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
