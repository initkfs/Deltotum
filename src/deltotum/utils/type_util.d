module deltotum.utils.type_util;

/**
 * Authors: initkfs
 */
mixin template NamedEnum(string enumName, enumMembersNames...)
{
    enum enumMembers = {
        string allMembers = "";
        foreach (name; enumMembersNames)
        {
            allMembers ~= name ~ "=" ~ name.stringof ~ ",";
        }
        return allMembers;
    }();
    mixin("enum " ~ enumName ~ " : string {" ~ enumMembers ~ "}");
}
