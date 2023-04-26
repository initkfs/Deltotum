module deltotum.kit.events.processing.event_processor;

import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.kit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.kit.input.keyboard.event.key_event : KeyEvent;
import deltotum.kit.windows.event.window_event : WindowEvent;
import deltotum.kit.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.kit.input.keyboard.event.text_input_event: TextInputEvent;

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
    void delegate(TextInputEvent) onTextInput;

    abstract bool process(E event);
}
