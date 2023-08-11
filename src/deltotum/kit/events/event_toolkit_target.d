module deltotum.kit.events.event_toolkit_target;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.core.events.event_target : EventTarget;
import deltotum.core.events.event_target : EventTarget;
import deltotum.kit.inputs.mouse.events.mouse_event : MouseEvent;
import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import deltotum.kit.sprites.events.focus.focus_event : FocusEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;

/**
 * Authors: initkfs
 *  Returning true from handler indicates that the event has been handled, and that it should not propagate further.
 */
class EventToolkitTarget : GraphicsComponent, EventTarget
{
    void delegate(ref MouseEvent) eventMouseFilter;
    void delegate(ref MouseEvent) eventMouseHandler;

    void delegate(ref MouseEvent) onMouseDown;
    void delegate(ref MouseEvent) onMouseUp;
    void delegate(ref MouseEvent) onMouseMove;
    void delegate(ref MouseEvent) onMouseWheel;

    bool isMouseOver;
    void delegate(ref MouseEvent) onMouseEntered;
    void delegate(ref MouseEvent) onMouseExited;

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
        eventMouseHandler = (ref e) { runListeners(e); };
        eventKeyHandler = (ref e) { runListeners(e); };
        eventJoystickHandler = (ref e) { runListeners(e); };
        eventFocusHandler = (ref e) { runListeners(e); };
        eventTextInputHandler = (ref e) { runListeners(e); };
    }

    void runEventFilters(E)(ref E e)
    {
        static if (is(E : MouseEvent))
        {
            if (eventMouseFilter !is null)
            {
                eventMouseFilter(e);
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
        static if (is(E : MouseEvent))
        {
            if (eventMouseHandler !is null)
            {
                eventMouseHandler(e);
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

    void runListeners(ref MouseEvent e)
    {
        if (e.event == MouseEvent.Event.mouseDown)
        {
            if (onMouseDown !is null)
            {
                onMouseDown(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseMove)
        {
            if (onMouseMove !is null)
            {
                onMouseMove(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseUp)
        {
            if (onMouseUp !is null)
            {
                onMouseUp(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseWheel)
        {
            if (onMouseWheel !is null)
            {
                onMouseWheel(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseEntered)
        {
            if (onMouseEntered !is null)
            {
                onMouseEntered(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseExited)
        {
            if (onMouseExited !is null)
            {
                onMouseExited(e);
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
