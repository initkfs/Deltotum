module deltotum.gui.containers.typed_container;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class TypedContainer(T : Sprite) : Control
{
    protected
    {
        T[] items;
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
        if (auto typedItem = cast(T) sprite)
        {
            import std.algorithm.searching : canFind;

            if (items.canFind(typedItem))
            {
                return;
            }
            items ~= typedItem;
        }
        super.addCreate(sprite, index);
    }

    override void destroy()
    {
        super.destroy;
        items = null;
    }

}
