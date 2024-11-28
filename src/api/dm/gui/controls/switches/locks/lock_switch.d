module api.dm.gui.controls.switches.locks.lock_switch;

import api.dm.gui.controls.switches.locks.base_lock_switch : BaseLockSwitch;

/**
 * Authors: initkfs
 */
class LockSwitch : BaseLockSwitch
{

    this(dstring text, string iconName)
    {
        this(text, 0, 0, iconName, 0);
    }

    this(dstring text)
    {
        this(text, 0, 0, null, 0);
    }

    this(
        dstring text,
        double width = 0,
        double height = 0,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, width, height, iconName, graphicsGap, isCreateLayout:
            true);
    }

}
