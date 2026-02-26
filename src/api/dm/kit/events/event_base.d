module api.dm.kit.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import api.dm.kit.events.event_target : EventTarget;
    import api.dm.kit.events.event_source : EventSource;

    EventSource source;
    EventTarget target;

    bool isSynthetic;
    bool isConsumed;
    
    int ownerId;
}
