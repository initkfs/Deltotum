module deltotum.events.event_type;
/**
 * Authors: initkfs
 */
class EventType
{
    @property EventType parent;
    @property string name;

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

    this(string name, EventType parent = null)
    {
        this.name = name;
        this.parent = parent;
    }

    shared static this()
    {
        any = new EventType("ANY");
        application = new EventType("APPLICATION", any);
        action = new EventType("ACTION", any);
        mouse = new EventType("MOUSE", any);
        key = new EventType("KEY", any);
        window = new EventType("WINDOW", any);
        joystick = new EventType("JOYSTICK", any);
    }

}
