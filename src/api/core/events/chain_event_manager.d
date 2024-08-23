module api.core.events.chain_event_manager;

import api.core.events.event_manager : EventManager;
import api.core.apps.events.app_event : AppEvent;
import api.core.events.processing.event_processor : EventProcessor;

import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class ChainEventManager(Component) : EventManager
{
    protected
    {
        DList!Component eventChain = DList!Component();
    }
}
