module api.dm.com.objects.com_unique_objectable;

/**
 * Authors: initkfs
 */
interface ComUniqueObjectable
{
    string id() pure nothrow @safe;
    void id(string newId) nothrow @safe;
}
