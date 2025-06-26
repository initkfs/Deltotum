module api.dm.com.objects.com_object;

import api.dm.com.objects.com_objectable: ComObjectable;

/**
 * Authors: initkfs
 */
class ComObject : ComObjectable
{
    string id = "com_object";

    final bool setNotEmptyId(string newId) pure @safe
    {
        if (newId.length == 0)
        {
            return false;
        }
        id = newId;
        return true;
    }
}
