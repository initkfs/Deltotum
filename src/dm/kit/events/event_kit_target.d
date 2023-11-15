module dm.kit.events.event_kit_target;

import dm.kit.apps.comps.window_component : WindowComponent;
import dm.core.events.event_target : EventTarget;

import dm.core.apps.events.application_event : ApplicationEvent;
import dm.kit.sprites.events.focus.focus_event : FocusEvent;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;

/**
 * Authors: initkfs
 */
class EventKitTarget : WindowComponent, EventTarget
{
    void delegate(ref PointerEvent)[] eventPointerFilters;
    void delegate(ref PointerEvent)[] eventPointerHandlers;

    void delegate(ref PointerEvent)[] onPointerDown;
    void delegate(ref PointerEvent)[] onPointerUp;
    void delegate(ref PointerEvent)[] onPointerMove;
    void delegate(ref PointerEvent)[] onPointerWheel;

    bool isMouseOver;
    void delegate(ref PointerEvent)[] onPointerEntered;
    void delegate(ref PointerEvent)[] onPointerExited;

    void delegate(ref KeyEvent)[] eventKeyFilters;
    void delegate(ref KeyEvent)[] eventKeyHandlers;

    void delegate(ref KeyEvent)[] onKeyUp;
    void delegate(ref KeyEvent)[] onKeyDown;

    void delegate(ref TextInputEvent)[] eventTextInputFilters;
    void delegate(ref TextInputEvent)[] eventTextInputHandlers;

    void delegate(ref TextInputEvent)[] onTextInput;

    void delegate(ref FocusEvent)[] eventFocusFilters;
    void delegate(ref FocusEvent)[] eventFocusHandlers;

    void delegate(ref FocusEvent)[] onFocusIn;
    void delegate(ref FocusEvent)[] onFocusOut;

    void delegate(ref JoystickEvent)[] eventJoystickFilters;
    void delegate(ref JoystickEvent)[] eventJoystickHandlers;

    void delegate(ref JoystickEvent)[] onJoystickAxis;
    void delegate(ref JoystickEvent)[] onJoystickButtonPress;
    void delegate(ref JoystickEvent)[] onJoystickButtonRelease;

    void createHandlers()
    {
        //TODO check duplication
        eventPointerHandlers ~= (ref e) { runListeners(e); };
        eventKeyHandlers ~= (ref e) { runListeners(e); };
        eventJoystickHandlers ~= (ref e) { runListeners(e); };
        eventFocusHandlers ~= (ref e) { runListeners(e); };
        eventTextInputHandlers ~= (ref e) { runListeners(e); };
    }

    protected void runDelegates(E)(ref E e, void delegate(ref E)[] array)
    {
        if (array.length > 0)
        {
            foreach (dg; array)
            {
                dg(e);
                if (e.isConsumed)
                {
                    break;
                }
            }
        }
    }

    void runEventFilters(E)(ref E e)
    {
        static if (is(E : PointerEvent))
        {
            runDelegates(e, eventPointerFilters);
        }

        static if (is(E : KeyEvent))
        {
            runDelegates(e, eventKeyFilters);
        }

        static if (is(E : TextInputEvent))
        {
            runDelegates(e, eventTextInputFilters);
        }

        static if (is(E : JoystickEvent))
        {
            runDelegates(e, eventJoystickFilters);
        }

        static if (is(E : FocusEvent))
        {
            runDelegates(e, eventFocusFilters);
        }
    }

    void runEventHandlers(E)(ref E e)
    {
        static if (is(E : PointerEvent))
        {
            runDelegates(e, eventPointerHandlers);
        }

        static if (is(E : KeyEvent))
        {
            runDelegates(e, eventKeyHandlers);
        }

        static if (is(E : TextInputEvent))
        {
            runDelegates(e, eventTextInputHandlers);
        }

        static if (is(E : JoystickEvent))
        {
            runDelegates(e, eventJoystickHandlers);
        }

        static if (is(E : FocusEvent))
        {
            runDelegates(e, eventFocusHandlers);
        }
    }

    void runListeners(ref PointerEvent e)
    {
        if (e.event == PointerEvent.Event.down)
        {
            runDelegates(e, onPointerDown);
        }
        else if (e.event == PointerEvent.Event.move)
        {
            runDelegates(e, onPointerMove);
        }
        else if (e.event == PointerEvent.Event.up)
        {
            runDelegates(e, onPointerUp);
        }
        else if (e.event == PointerEvent.Event.wheel)
        {
            runDelegates(e, onPointerWheel);
        }
        else if (e.event == PointerEvent.Event.entered)
        {
            runDelegates(e, onPointerEntered);
        }
        else if (e.event == PointerEvent.Event.exited)
        {
            runDelegates(e, onPointerExited);
        }
    }

    void runListeners(ref KeyEvent keyEvent)
    {
        final switch (keyEvent.event) with (KeyEvent)
        {
            case Event.none:
                break;
            case Event.keyUp:
                if (onKeyUp.length > 0)
                {
                    runDelegates(keyEvent, onKeyUp);
                }
                break;
            case Event.keyDown:
                runDelegates(keyEvent, onKeyDown);
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
                runDelegates(keyEvent, onTextInput);
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
                runDelegates(joystickEvent, onJoystickButtonPress);
                break;
            case Event.release:
                runDelegates(joystickEvent, onJoystickButtonRelease);
                break;
            case Event.axis:
                runDelegates(joystickEvent, onJoystickAxis);
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
                runDelegates(focusEvent, onFocusIn);
                break;
            case Event.focusOut:
                runDelegates(focusEvent, onFocusOut);
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

    override void dispose()
    {
        super.dispose;

        eventPointerFilters = null;
        eventPointerHandlers = null;

        onPointerDown = null;
        onPointerUp = null;
        onPointerMove = null;
        onPointerWheel = null;

        onPointerEntered = null;
        onPointerExited = null;

        eventKeyFilters = null;
        eventKeyHandlers = null;

        onKeyUp = null;
        onKeyDown = null;

        eventTextInputFilters = null;
        eventTextInputHandlers = null;

        onTextInput = null;

        eventFocusFilters = null;
        eventFocusHandlers = null;

        onFocusIn = null;
        onFocusOut = null;

        eventJoystickFilters = null;
        eventJoystickHandlers = null;

        onJoystickAxis = null;
        onJoystickButtonPress = null;
        onJoystickButtonRelease = null;
    }

}
