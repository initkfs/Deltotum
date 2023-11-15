module dm.core.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import dm.core.events.event_target : EventTarget;
    import dm.core.events.event_source : EventSource;

    int type;
    int event;

    EventSource source;
    EventTarget target;
    
    bool isChained = true;
    bool isConsumed;

    int ownerId;
}
