module deltotum.events.processing.event_processor;

import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.window.event.window_event : WindowEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    @property void delegate(ApplicationEvent) onApplication;
    @property void delegate(MouseEvent) onMouse;
    @property void delegate(KeyEvent) onKey;
    @property void delegate(WindowEvent) onWindow;

    abstract void process(E event);
}
