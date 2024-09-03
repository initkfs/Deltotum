module api.dm.kit.sprites.layouts.anchor_layout;

import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.sprites.layouts.managed_layout : ManagedLayout;
import api.math.alignment : Alignment;

/**
 * Authors: initkfs
 */
class AnchorLayout : ManagedLayout
{

    this() pure
    {

    }

    override bool alignChildren(Sprite root)
    {
        import Math = api.dm.math;
        import api.math.vector2 : Vector2;
        import std.range.primitives : walkLength;

        auto children = childrenForLayout(root);
        const childCount = children.walkLength;
        if (childCount == 0)
        {
            return false;
        }

        const parentBounds = root.bounds;

        foreach (child; children)
        {
            if (child.margin.left != 0)
            {
                child.x = parentBounds.x + child.margin.left;
                child.y = parentBounds.y + child.margin.top;
            }
            else if (child.margin.right != 0)
            {
                child.x = parentBounds.right - child.margin.right - child.width;
                child.y = parentBounds.bottom - child.margin.bottom - child.height;
            }
        }
        return true;
    }

    override double childrenWidth(Sprite root)
    {
        return root.width;
    }

    override double childrenHeight(Sprite root)
    {
        return root.height;
    }
}
