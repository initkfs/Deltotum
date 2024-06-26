module dm.core.events.processing.event_processor;

import dm.core.apps.events.app_event : AppEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    void delegate(ref AppEvent) onApplication;

    abstract bool process(E event);
}
