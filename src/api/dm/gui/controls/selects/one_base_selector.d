module api.dm.gui.controls.selects.one_base_selector;

import api.dm.gui.controls.control : Control;
import api.dm.gui.controls.selects.selectable : Selectable;

/**
 * Authors: initkfs
 */
class OneBaseSelector(T) : Control
{
    bool isSelectable = true;

    protected
    {
        T _current;
    }

    void delegate(T, T)[] onChangeOldNew;

    inout(T) current() inout => _current;

    bool current(T item, bool isTrigger = true, bool isReplaceForce = false)
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

        return currentForce(item, isTrigger);
    }

    bool currentForce(T item, bool isTrigger = true)
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

        if (isTrigger && onChangeOldNew.length > 0)
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
}
