module deltotum.kit.sprites.layouts.layout;

import deltotum.kit.sprites.sprite : Sprite;

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

    abstract
    {
        void applyLayout(Sprite root);
        double childrenWidth(Sprite root);
        double childrenHeight(Sprite root);
    }

    auto childrenForLayout(Sprite root)
    {
        import std.algorithm.iteration : filter;

        return root.children.filter!(ch => ch.isLayoutManaged);
    }

    void isAutoResize(bool isResize) pure @safe {
        isResizeParent = isResize;
        isResizeChildren = isResize;
    }
}
