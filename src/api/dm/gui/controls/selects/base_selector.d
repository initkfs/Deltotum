module api.dm.gui.controls.selects.base_selector;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.selectable : Selectable;

/**
 * Authors: initkfs
 */
class BaseSelector(T) : Control
{
    bool isSelectable = true;

    T selected;

    void delegate(T, T) onSelectOldNew;

    bool select(T item, bool isTriggerListeners = true)
    {
        static if (__traits(compiles, item is item))
        {
            if (item is selected)
            {
                return false;
            }
        }
        else
        {
            if (item == selected)
            {
                return false;
            }
        }

        static if (is(T : Selectable))
        {
            if (!item.isSelected)
            {
                item.isSelected = true;
            }

            if (selected)
            {
                selected.isSelected = false;
            }
        }

        if (isTriggerListeners && onSelectOldNew)
        {
            //selected may be null
            onSelectOldNew(selected, item);
        }

        selected = item;

        return true;
    }
}
