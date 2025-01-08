module api.dm.gui.controls.switches.switch_group;

import api.dm.gui.controls.containers.container : Container;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.controls.switches.base_biswitch : BaseBiswitch;

/**
 * Authors: initkfs
 */
class SwitchGroup : Container
{
    alias add = Container.add;

    override void add(Sprite2d sprite, long index = -1)
    {
        super.add(sprite, index);

        if (auto toggle = cast(BaseBiswitch) sprite)
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

    void toggleStates(BaseBiswitch control)
    {
        foreach (sprite; children)
        {
            if (sprite is control)
            {
                continue;
            }

            if (auto toggle = cast(BaseBiswitch) sprite)
            {
                if (control.isOn && toggle.isOn)
                {
                    toggle.isOn = false;
                }
            }

        }
    }

}
