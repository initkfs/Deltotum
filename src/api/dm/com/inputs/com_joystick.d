module api.dm.com.inputs.com_joystick;

import api.dm.com.com_result : ComResult;
import api.dm.com.com_disposable : ComDisposable;
import api.dm.com.com_error_manageable : ComErrorManageable;

/**
 * Authors: initkfs
 */
interface ComJoystick : ComDisposable
{
nothrow:

    short getAxisOr0(size_t index);
    bool getButton(size_t button);

}
