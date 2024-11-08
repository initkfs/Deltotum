module api.core.events.base.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import api.core.events.base.event_target : EventTarget;
    import api.core.events.base.event_source : EventSource;

    EventSource source;
    EventTarget target;

    bool isSynthetic;
    bool isConsumed;
    
    int ownerId;
}
