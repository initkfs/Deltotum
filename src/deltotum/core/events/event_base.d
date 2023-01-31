module deltotum.core.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import deltotum.core.events.event_type : EventType;
    import deltotum.core.events.event_target : EventTarget;
    import deltotum.core.events.event_source : EventSource;

    EventType type;
    long event;

    EventSource source;
    EventTarget target;
    bool isChained = true;

    long ownerId;
}
