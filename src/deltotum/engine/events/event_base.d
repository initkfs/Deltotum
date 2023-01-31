module deltotum.engine.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import deltotum.engine.events.event_type : EventType;
    import deltotum.engine.events.event_target : EventTarget;
    import deltotum.engine.events.event_source : EventSource;

    EventType type;
    long event;

    EventSource source;
    EventTarget target;
    bool isChained = true;

    long windowId;
}
