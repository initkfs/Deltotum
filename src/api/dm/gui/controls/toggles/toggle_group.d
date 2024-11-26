module api.dm.gui.controls.toggles.toggle_group;

import api.dm.gui.containers.container : Container;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.toggles.base_bitoggle : BaseBitoggle;

/**
 * Authors: initkfs
 */
class ToggleGroup : Container
{
    alias add = Container.add;

    override void add(Sprite sprite, long index = -1)
    {
        super.add(sprite, index);

        if (auto toggle = cast(BaseBitoggle) sprite)
        {
            //TODO delete repeated calls
            toggle.onOldNewValue ~= (oldState, newState) {
                if (!newState)
                {
                    return;
                }
                toggleStates(toggle);
            };
        }
    }

    void toggleStates(BaseBitoggle control)
    {
        foreach (sprite; children)
        {
            if (sprite is control)
            {
                continue;
            }

            if (auto toggle = cast(BaseBitoggle) sprite)
            {
                if (control.isOn && toggle.isOn)
                {
                    toggle.isOn = false;
                }
            }

        }
    }

}
