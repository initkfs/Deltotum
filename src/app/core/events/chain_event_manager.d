module app.core.events.chain_event_manager;

import app.core.events.event_manager : EventManager;
import app.core.apps.events.app_event : AppEvent;
import app.core.events.processing.event_processor : EventProcessor;

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
