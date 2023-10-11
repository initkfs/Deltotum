module deltotum.kit.events.processing.event_processor;

import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.pointers.events.pointer_event : PointerEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.windows.events.window_event : WindowEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event: TextInputEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class EventProcessor(E)
{
    void delegate(ref ApplicationEvent) onApplication;
    void delegate(ref PointerEvent) onPointer;
    void delegate(ref KeyEvent) onKey;
    void delegate(ref WindowEvent) onWindow;
    void delegate(ref JoystickEvent) onJoystick;
    void delegate(ref TextInputEvent) onTextInput;

    abstract bool process(E event);
}
