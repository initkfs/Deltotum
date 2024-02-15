module dm.core.events.event_manager;

import dm.core.apps.events.application_event : ApplicationEvent;
import dm.core.events.core_event_type : CoreEventType;
import dm.core.events.processing.event_processor : EventProcessor;

import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class EventManager(Component)
{
    protected
    {
        DList!Component eventChain = DList!Component();
    }
}
