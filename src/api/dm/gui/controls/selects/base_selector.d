module api.dm.gui.controls.selects.base_selector;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.selectable : Selectable;

/**
 * Authors: initkfs
 */
class BaseSelector(T) : Control
{
    bool isSelectable = true;

    protected
    {
        T _current;
    }

    void delegate(T, T)[] onChangeOldNew;

    bool current(T item, bool isTriggerListeners = true, bool isReplaceForce = false)
    {
        static if (__traits(compiles, item is item))
        {
            if (item is _current && !isReplaceForce)
            {
                return false;
            }
        }
        else
        {
            if (item == _current && !isReplaceForce)
            {
                return false;
            }
        }

        return currentForce(item, isTriggerListeners);
    }

    bool currentForce(T item, bool isTriggerListeners = true)
    {
        static if (is(T : Selectable))
        {
            if (!item.isSelected)
            {
                item.isSelected = true;
            }

            if (_current)
            {
                _current.isSelected = false;
            }
        }

        if (isTriggerListeners && onChangeOldNew.length > 0)
        {
            //_current may be null
            foreach (dg; onChangeOldNew)
            {
                assert(dg);
                dg(_current, item);
            }
        }

        _current = item;

        return true;
    }

    import api.core.utils.arrays : drop;

    bool removeOnChangeOnNew(void delegate(T, T) dg) => onChangeOldNew.drop(dg);

    inout(T) current() inout => _current;
}
