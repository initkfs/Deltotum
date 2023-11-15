module dm.gui.containers.typed_container;

import dm.gui.controls.control : Control;
import dm.kit.sprites.sprite : Sprite;

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

    override void dispose()
    {
        super.dispose;
        items = null;
    }

}
