module deltotum.events.event_type;

import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class EventType
{
    immutable string name;

    private
    {
        EventType _parent;
    }

    static
    {
        EventType any;
        EventType application;
        EventType action;
        EventType mouse;
        EventType key;
        EventType window;
        EventType joystick;
    }

    this(string name, EventType parent = null) pure @safe
    {
        this.name = name;
        this._parent = parent;
    }

    shared static this() @safe
    {
        any = new EventType("ANY");
        application = new EventType("APPLICATION", any);
        action = new EventType("ACTION", any);
        mouse = new EventType("MOUSE", any);
        key = new EventType("KEY", any);
        window = new EventType("WINDOW", any);
        joystick = new EventType("JOYSTICK", any);
    }

    Nullable!EventType parent() @nogc nothrow pure @safe
    {
        if (_parent is null)
        {
            return Nullable!EventType();
        }
        return Nullable!EventType(_parent);
    }

}
