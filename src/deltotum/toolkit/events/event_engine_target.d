module deltotum.toolkit.events.event_engine_target;

import deltotum.toolkit.applications.components.graphics_component: GraphicsComponent;
import deltotum.core.events.event_target: EventTarget;
import deltotum.core.events.event_target: EventTarget;
import deltotum.toolkit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.toolkit.input.keyboard.event.key_event : KeyEvent;
import deltotum.toolkit.input.joystick.event.joystick_event : JoystickEvent;

/**
 * Authors: initkfs
 *  Returning true from handler indicates that the event has been handled, and that it should not propagate further.
 */
class EventEngineTarget : GraphicsComponent, EventTarget
{
    bool delegate(MouseEvent) eventMouseFilter;
    bool delegate(MouseEvent) eventMouseHandler;

    bool delegate(MouseEvent) onMouseDown;
    bool delegate(MouseEvent) onMouseUp;
    bool delegate(MouseEvent) onMouseMove;
    bool delegate(MouseEvent) onMouseWheel;

    bool isMouseOver;
    bool delegate(MouseEvent) onMouseEntered;
    bool delegate(MouseEvent) onMouseExited;

    bool delegate(KeyEvent) eventKeyFilter;
    bool delegate(KeyEvent) eventKeyHandler;

    bool delegate(KeyEvent) onKeyUp;
    bool delegate(KeyEvent) onKeyDown;

    bool delegate(JoystickEvent) eventJoystickFilter;
    bool delegate(JoystickEvent) eventJoystickHandler;

    bool delegate(JoystickEvent) onJoystickAxis;
    bool delegate(JoystickEvent) onJoystickButtonPress;
    bool delegate(JoystickEvent) onJoystickButtonRelease;

    void createHandlers()
    {
        eventMouseHandler = (e) { return runListeners(e); };
        eventKeyHandler = (e) { return runListeners(e); };
        eventJoystickHandler = (e) { return runListeners(e); };
    }

    bool runEventFilters(E)(E e)
    {
        static if (is(E : MouseEvent))
        {
            if (eventMouseFilter !is null)
            {
                return eventMouseFilter(e);
            }
        }

        static if (is(E : KeyEvent))
        {
            if (eventKeyFilter !is null)
            {
                return eventKeyFilter(e);
            }
        }

        static if (is(E : JoystickEvent))
        {
            if (eventJoystickFilter !is null)
            {
                return eventJoystickFilter(e);
            }
        }

        return false;
    }

    bool runEventHandlers(E)(E e)
    {
        static if (is(E : MouseEvent))
        {
            if (eventMouseHandler !is null)
            {
                return eventMouseHandler(e);
            }
        }

        static if (is(E : KeyEvent))
        {
            if (eventKeyHandler !is null)
            {
                return eventKeyHandler(e);
            }
        }

        static if (is(E : JoystickEvent))
        {
            if (eventJoystickHandler !is null)
            {
                return eventJoystickHandler(e);
            }
        }

        return false;
    }

    bool runListeners(MouseEvent e)
    {
        if (e.event == MouseEvent.Event.mouseDown)
        {
            if (onMouseDown !is null)
            {
                return onMouseDown(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseMove)
        {
            if (onMouseMove !is null)
            {
                return onMouseMove(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseUp)
        {
            if (onMouseUp !is null)
            {
                return onMouseUp(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseWheel)
        {
            if (onMouseWheel !is null)
            {
                return onMouseWheel(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseEntered)
        {
            if (onMouseEntered !is null)
            {
                return onMouseEntered(e);
            }
        }
        else if (e.event == MouseEvent.Event.mouseExited)
        {
            if (onMouseExited !is null)
            {
                return onMouseExited(e);
            }
        }

        return false;
    }

    bool runListeners(KeyEvent keyEvent)
    {
        final switch (keyEvent.event) with (KeyEvent)
        {
        case Event.none:
            break;
        case Event.keyUp:
            if (onKeyUp !is null)
            {
                return onKeyUp(keyEvent);
            }
            break;
        case Event.keyDown:
            if (onKeyDown !is null)
            {
                return onKeyDown(keyEvent);
            }
            break;
        }

        return false;
    }

    bool runListeners(JoystickEvent joystickEvent)
    {
        final switch (joystickEvent.event) with (JoystickEvent)
        {
        case Event.none:
            break;
        case Event.press:
            if (onJoystickButtonPress !is null)
            {
                return onJoystickButtonPress(joystickEvent);
            }
            break;
        case Event.release:
            if (onJoystickButtonRelease !is null)
            {
                return onJoystickButtonRelease(joystickEvent);
            }
            break;
        case Event.axis:
            if (onJoystickAxis !is null)
            {
                return onJoystickAxis(joystickEvent);
            }
            break;
        }

        return false;
    }

    void fireEvent(E)(E e)
    {
        if (const isConsumed = runEventFilters!E(e))
        {
            return;
        }

        if (const isConsumed = runEventHandlers!E(e))
        {
            return;
        }
    }
}
