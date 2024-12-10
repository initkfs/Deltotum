module api.dm.kit.sprites2d.layouts.anchor_layout;

import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.sprites2d.layouts.managed_layout : ManagedLayout;
import api.math.alignment : Alignment;

/**
 * Authors: initkfs
 */
class AnchorLayout : ManagedLayout
{

    this() pure
    {

    }

    override bool alignChildren(Sprite2d root)
    {
        import Math = api.dm.math;
        import api.math.geom2.vec2 : Vec2d;
        import std.range.primitives : walkLength;

        auto children = childrenForLayout(root);
        const childCount = children.walkLength;
        if (childCount == 0)
        {
            return false;
        }

        const parentBounds = root.boundsRect;

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

    override double childrenWidth(Sprite2d root)
    {
        return root.width;
    }

    override double childrenHeight(Sprite2d root)
    {
        return root.height;
    }
}
