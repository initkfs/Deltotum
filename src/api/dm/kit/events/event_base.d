module api.dm.kit.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import api.dm.kit.events.event_target : EventTarget;

    EventTarget source;
    EventTarget target;

    bool isSynthetic;
    bool isConsumed;
    
    int ownerId;
}
