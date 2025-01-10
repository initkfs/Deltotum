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

    void delegate(T, T)[] onSelectOldNew;

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

        return selectForce(item, isTriggerListeners);
    }

    bool selectForce(T item, bool isTriggerListeners = true)
    {
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

        if (isTriggerListeners && onSelectOldNew.length > 0)
        {
            //selected may be null
            foreach (dg; onSelectOldNew)
            {
                assert(dg);
                dg(selected, item);
            }
        }

        selected = item;

        return true;
    }

    import api.core.utils.arrays : drop;

    bool removeOnSelectOnNew(void delegate(T, T) dg) => onSelectOldNew.drop(dg);
}
