module deltotum.events.event_target;

import deltotum.application.components.uni.uni_component : UniComponent;

import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;

/**
 * Authors: initkfs
 *  Returning true from handler indicates that the event has been handled, and that it should not propagate further.
 */
abstract class EventTarget : UniComponent
{
    @property bool delegate(MouseEvent) eventMouseFilter;
    @property bool delegate(MouseEvent) eventMouseHandler;

    @property bool delegate(MouseEvent) onMouseDown;
    @property bool delegate(MouseEvent) onMouseUp;
    @property bool delegate(MouseEvent) onMouseMove;
    @property bool delegate(MouseEvent) onMouseWheel;

    @property bool isMouseOver;
    @property bool delegate(MouseEvent) onMouseEntered;
    @property bool delegate(MouseEvent) onMouseExited;

    @property bool delegate(KeyEvent) eventKeyFilter;
    @property bool delegate(KeyEvent) eventKeyHandler;

    @property bool delegate(KeyEvent) onKeyUp;
    @property bool delegate(KeyEvent) onKeyDown;

    void buildEventRoute(T, E)(ref T[] targets, E e);

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
        final switch (keyEvent.event)
        {
        case KeyEvent.Event.none:
            break;
        case KeyEvent.Event.keyUp:
            if (onKeyUp !is null)
            {
                return onKeyUp(keyEvent);
            }
            break;
        case KeyEvent.Event.keyDown:
            if (onKeyDown !is null)
            {
                return onKeyDown(keyEvent);
            }
            break;
        }

        return false;
    }
}
