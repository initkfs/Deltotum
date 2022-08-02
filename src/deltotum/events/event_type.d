module deltotum.events.event_type;
/**
 * Authors: initkfs
 */
immutable class EventType
{
    EventType parent;
    string name;

    this(immutable string name, immutable EventType parent = null)
    {
        this.name = name;
        this.parent = parent;
    }

    static immutable
    {
        EventType any = new EventType("ANY");
        EventType application = new EventType("APPLICATION", any);
        EventType action = new EventType("ACTION", any);
        EventType mouse = new EventType("MOUSE", any);
        EventType key = new EventType("KEY", any);
        EventType window = new EventType("WINDOW", any);
    }

}
