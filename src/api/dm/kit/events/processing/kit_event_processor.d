module api.dm.kit.events.processing.kit_event_processor;

import api.core.events.processing.event_processor: EventProcessor;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.windows.events.window_event : WindowEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event: TextInputEvent;

/**
 * Authors: initkfs
 * TODO. Parametrization here forces the event manager to be parametrized, which is inconvenient.
 */
abstract class KitEventProcessor(E) : EventProcessor!E
{
    void delegate(ref PointerEvent) onPointer;
    void delegate(ref KeyEvent) onKey;
    void delegate(ref WindowEvent) onWindow;
    void delegate(ref JoystickEvent) onJoystick;
    void delegate(ref TextInputEvent) onTextInput;
}
