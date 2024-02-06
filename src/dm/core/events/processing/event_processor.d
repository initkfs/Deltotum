module dm.core.events.processing.event_processor;

import dm.core.apps.events.application_event : ApplicationEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    void delegate(ref ApplicationEvent) onApplication;

    abstract bool process(E event);
}
