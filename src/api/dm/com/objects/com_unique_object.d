module api.dm.com.objects.com_unique_object;

import api.dm.com.objects.com_unique_objectable : ComUniqueObjectable;

/**
 * Authors: initkfs
 */
class ComUniqueObject : ComUniqueObjectable
{
    protected
    {
        string _id = "com_object";
    }

    void id(string newId) nothrow @safe
    {
        _id = newId;
    }

    string id() nothrow @safe => _id;
}
