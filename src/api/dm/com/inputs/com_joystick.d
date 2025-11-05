module api.dm.com.inputs.com_joystick;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_destroyable : ComDestroyable;
import api.dm.com.com_error_manageable : ComErrorManageable;

/**
 * Authors: initkfs
 */
interface ComJoystick : ComDestroyable
{
nothrow:

    short getAxisOr0(size_t index);
    bool getButton(size_t button);

}
