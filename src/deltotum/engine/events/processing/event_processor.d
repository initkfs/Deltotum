module deltotum.engine.events.processing.event_processor;

import deltotum.core.application.events.application_event : ApplicationEvent;
import deltotum.engine.input.mouse.event.mouse_event : MouseEvent;
import deltotum.engine.input.keyboard.event.key_event : KeyEvent;
import deltotum.engine.window.event.window_event : WindowEvent;
import deltotum.engine.input.joystick.event.joystick_event : JoystickEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    void delegate(ApplicationEvent) onApplication;
    void delegate(MouseEvent) onMouse;
    void delegate(KeyEvent) onKey;
    void delegate(WindowEvent) onWindow;
    void delegate(JoystickEvent) onJoystick;

    abstract bool process(E event);
}
