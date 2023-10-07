module deltotum.kit.events.event_toolkit_target;

import deltotum.kit.apps.comps.window_component: WindowComponent;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_target : EventTarget;
import deltotum.kit.inputs.pointers.events.pointer_event : PointerEvent;
import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;

/**
 * Authors: initkfs
 *  Returning true from handler indicates that the event has been handled, and that it should not propagate further.
 */
class EventToolkitTarget : WindowComponent, EventTarget
{
    void delegate(ref PointerEvent) eventPointerFilter;
    void delegate(ref PointerEvent) eventPointerHandler;

    void delegate(ref PointerEvent) onPointerDown;
    void delegate(ref PointerEvent) onPointerUp;
    void delegate(ref PointerEvent) onPointerMove;
    void delegate(ref PointerEvent) onPointerWheel;

    bool isMouseOver;
    void delegate(ref PointerEvent) onPointerEntered;
    void delegate(ref PointerEvent) onPointerExited;

    void delegate(ref KeyEvent) eventKeyFilter;
    void delegate(ref KeyEvent) eventKeyHandler;

    void delegate(ref KeyEvent) onKeyUp;
    void delegate(ref KeyEvent) onKeyDown;

    void delegate(ref TextInputEvent) eventTextInputFilter;
    void delegate(ref TextInputEvent) eventTextInputHandler;

    void delegate(ref TextInputEvent) onTextInput;

    void delegate(ref FocusEvent) eventFocusFilter;
    void delegate(ref FocusEvent) eventFocusHandler;

    void delegate(ref FocusEvent) onFocusIn;
    void delegate(ref FocusEvent) onFocusOut;

    void delegate(ref JoystickEvent) eventJoystickFilter;
    void delegate(ref JoystickEvent) eventJoystickHandler;

    void delegate(ref JoystickEvent) onJoystickAxis;
    void delegate(ref JoystickEvent) onJoystickButtonPress;
    void delegate(ref JoystickEvent) onJoystickButtonRelease;

    void createHandlers()
    {
        eventPointerHandler = (ref e) { runListeners(e); };
        eventKeyHandler = (ref e) { runListeners(e); };
        eventJoystickHandler = (ref e) { runListeners(e); };
        eventFocusHandler = (ref e) { runListeners(e); };
        eventTextInputHandler = (ref e) { runListeners(e); };
    }

    void runEventFilters(E)(ref E e)
    {
        static if (is(E : PointerEvent))
        {
            if (eventPointerFilter !is null)
            {
                eventPointerFilter(e);
            }
        }

        static if (is(E : KeyEvent))
        {
            if (eventKeyFilter !is null)
            {
                eventKeyFilter(e);
            }
        }

        static if (is(E : TextInputEvent))
        {
            if (eventTextInputFilter !is null)
            {
                eventTextInputFilter(e);
            }
        }

        static if (is(E : JoystickEvent))
        {
            if (eventJoystickFilter !is null)
            {
                eventJoystickFilter(e);
            }
        }

        static if (is(E : FocusEvent))
        {
            if (eventFocusFilter !is null)
            {
                eventFocusFilter(e);
            }
        }
    }

    void runEventHandlers(E)(ref E e)
    {
        static if (is(E : PointerEvent))
        {
            if (eventPointerHandler !is null)
            {
                eventPointerHandler(e);
            }
        }

        static if (is(E : KeyEvent))
        {
            if (eventKeyHandler !is null)
            {
                eventKeyHandler(e);
            }
        }

        static if (is(E : TextInputEvent))
        {
            if (eventTextInputHandler !is null)
            {
                eventTextInputHandler(e);
            }
        }

        static if (is(E : JoystickEvent))
        {
            if (eventJoystickHandler !is null)
            {
                eventJoystickHandler(e);
            }
        }

        static if (is(E : FocusEvent))
        {
            if (eventFocusHandler !is null)
            {
                eventFocusHandler(e);
            }
        }
    }

    void runListeners(ref PointerEvent e)
    {
        if (e.event == PointerEvent.Event.down)
        {
            if (onPointerDown !is null)
            {
                onPointerDown(e);
            }
        }
        else if (e.event == PointerEvent.Event.move)
        {
            if (onPointerMove !is null)
            {
                onPointerMove(e);
            }
        }
        else if (e.event == PointerEvent.Event.up)
        {
            if (onPointerUp !is null)
            {
                onPointerUp(e);
            }
        }
        else if (e.event == PointerEvent.Event.wheel)
        {
            if (onPointerWheel !is null)
            {
                onPointerWheel(e);
            }
        }
        else if (e.event == PointerEvent.Event.entered)
        {
            if (onPointerEntered !is null)
            {
                onPointerEntered(e);
            }
        }
        else if (e.event == PointerEvent.Event.exited)
        {
            if (onPointerExited !is null)
            {
                onPointerExited(e);
            }
        }
    }

    void runListeners(ref KeyEvent keyEvent)
    {
        final switch (keyEvent.event) with (KeyEvent)
        {
        case Event.none:
            break;
        case Event.keyUp:
            if (onKeyUp !is null)
            {
                onKeyUp(keyEvent);
            }
            break;
        case Event.keyDown:
            if (onKeyDown !is null)
            {
                onKeyDown(keyEvent);
            }
            break;
        }
    }

    void runListeners(ref TextInputEvent keyEvent)
    {
        final switch (keyEvent.event) with (TextInputEvent)
        {
        case Event.none:
            break;
        case Event.input:
            if (onTextInput !is null)
            {
                onTextInput(keyEvent);
            }
            break;
        }
    }

    void runListeners(ref JoystickEvent joystickEvent)
    {
        final switch (joystickEvent.event) with (JoystickEvent)
        {
        case Event.none:
            break;
        case Event.press:
            if (onJoystickButtonPress !is null)
            {
                onJoystickButtonPress(joystickEvent);
            }
            break;
        case Event.release:
            if (onJoystickButtonRelease !is null)
            {
                onJoystickButtonRelease(joystickEvent);
            }
            break;
        case Event.axis:
            if (onJoystickAxis !is null)
            {
                onJoystickAxis(joystickEvent);
            }
            break;
        }
    }

    void runListeners(ref FocusEvent focusEvent)
    {
        final switch (focusEvent.event) with (FocusEvent)
        {
        case Event.none:
            break;
        case Event.focusIn:
            if (onFocusIn !is null)
            {
                onFocusIn(focusEvent);
            }
            break;
        case Event.focusOut:
            if (onFocusOut !is null)
            {
                onFocusOut(focusEvent);
            }
            break;
        }
    }

    void fireEvent(E)(ref E e)
    {
        runEventFilters!E(e);
        if (e.isConsumed)
        {
            return;
        }

        runEventHandlers!E(e);
    }
}
