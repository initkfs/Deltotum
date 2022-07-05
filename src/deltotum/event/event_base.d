module deltotum.event.event_base;

import deltotum.event.event_type : EventType;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    EventType type;
    uint event;
    uint windowId;

    string getEventName(E)(const int index) if (is(E == enum))
    {
        import std.traits : EnumMembers;

        string name = "";
        static foreach (i, member; EnumMembers!E)
        {
            if (i == index)
            {
                name = member.stringof;
            }

        }
        return name;
    }
}
