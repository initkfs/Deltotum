module app.core.events.event_base;

/**
 * Authors: initkfs
 */
mixin template EventBase()
{
    import app.core.events.event_target : EventTarget;
    import app.core.events.event_source : EventSource;

    EventSource source;
    EventTarget target;

    bool isChained = true;
    bool isConsumed;

    int ownerId;
}
