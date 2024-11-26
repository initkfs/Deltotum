module api.dm.gui.controls.checks.check_group;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.checks.check : Check;

/**
 * Authors: initkfs
 */
class CheckGroup : Container
{
    alias add = Container.add;

    override void add(Sprite sprite, long index = -1)
    {
        super.add(sprite, index);

        if (auto check = cast(Check) sprite)
        {
            //TODO delete repeated calls
            check.onOldNewValue ~= (oldState, newState) {
                if (!newState)
                {
                    return;
                }
                toggle(check);
            };
        }
    }

    void toggle(Check control)
    {
        foreach (sprite; children)
        {
            if (sprite is control)
            {
                continue;
            }

            if (auto check = cast(Check) sprite)
            {
                if (control.isOn && check.isOn)
                {
                    check.isOn = false;
                }
            }

        }
    }

}
