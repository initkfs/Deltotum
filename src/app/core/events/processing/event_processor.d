module app.core.events.processing.event_processor;

import app.core.apps.events.app_event : AppEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    void delegate(ref AppEvent) onApp;

    abstract bool process(E event);
}
