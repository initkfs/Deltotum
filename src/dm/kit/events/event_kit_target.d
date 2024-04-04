module dm.kit.events.event_kit_target;

import dm.kit.components.window_component : WindowComponent;
import dm.core.events.event_target : EventTarget;

import dm.core.apps.events.app_event : AppEvent;
import dm.kit.sprites.events.focus.focus_event : FocusEvent;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.kit.windows.events.window_event : WindowEvent;

/**
 * Authors: initkfs
 */
class EventKitTarget : WindowComponent, EventTarget
{
    void delegate(ref AppEvent)[] eventAppFilters;
    void delegate(ref AppEvent)[] eventAppHandlers;

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

    void delegate(ref WindowEvent)[] eventWindowFilters;
    void delegate(ref WindowEvent)[] eventWindowHandlers;

    bool isCreateApplicationHandler = true;
    bool isCreatePointerHandler = true;
    bool isCreateKeyHandler = true;
    bool isCreateTextInputHandler = true;
    bool isCreateFocusHandler = true;
    bool isCreateJoystickHandler = true;
    bool isCreateWindowHandler = true;

    protected void createHandler(E)(ref void delegate(ref E)[] handlerArray)
    {
        //Transferring array to another memory location?
        handlerArray ~= (ref e) { runListeners(e); };
    }

    void createHandlers()
    {
        if (isCreateApplicationHandler)
        {
            createHandler(eventAppHandlers);
        }

        if (isCreatePointerHandler)
        {
            createHandler(eventPointerHandlers);
        }

        if (isCreateKeyHandler)
        {
            createHandler(eventKeyHandlers);
        }

        if (isCreateJoystickHandler)
        {
            createHandler(eventJoystickHandlers);
        }

        if (isCreateFocusHandler)
        {
            createHandler(eventFocusHandlers);
        }

        if (isCreateTextInputHandler)
        {
            createHandler(eventTextInputHandlers);
        }
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
        static if (is(E : AppEvent))
        {
            runDelegates(e, eventAppFilters);
        }
        else static if (is(E : PointerEvent))
        {
            runDelegates(e, eventPointerFilters);
        }
        else static if (is(E : KeyEvent))
        {
            runDelegates(e, eventKeyFilters);
        }
        else static if (is(E : TextInputEvent))
        {
            runDelegates(e, eventTextInputFilters);
        }
        else static if (is(E : JoystickEvent))
        {
            runDelegates(e, eventJoystickFilters);
        }
        else static if (is(E : FocusEvent))
        {
            runDelegates(e, eventFocusFilters);
        }
        else static if (is(E : WindowEvent))
        {
            runDelegates(e, eventWindowFilters);
        }
    }

    void runEventHandlers(E)(ref E e)
    {
        static if (is(E : AppEvent))
        {
            runDelegates(e, eventAppHandlers);
        }
        else static if (is(E : PointerEvent))
        {
            runDelegates(e, eventPointerHandlers);
        }
        else static if (is(E : KeyEvent))
        {
            runDelegates(e, eventKeyHandlers);
        }
        else static if (is(E : TextInputEvent))
        {
            runDelegates(e, eventTextInputHandlers);
        }
        else static if (is(E : JoystickEvent))
        {
            runDelegates(e, eventJoystickHandlers);
        }
        else static if (is(E : FocusEvent))
        {
            runDelegates(e, eventFocusHandlers);
        }
        else static if (is(E : WindowEvent))
        {
            runDelegates(e, eventWindowHandlers);
        }
    }

    void runListeners(ref AppEvent)
    {

    }

    void runListeners(ref PointerEvent e)
    {
        final switch (e.event) with (PointerEvent.Event)
        {
            case down:
                runDelegates(e, onPointerDown);
                break;
            case up:
                runDelegates(e, onPointerUp);
                break;
            case move:
                runDelegates(e, onPointerMove);
                break;
            case wheel:
                runDelegates(e, onPointerWheel);
                break;
            case entered:
                runDelegates(e, onPointerEntered);
                break;
            case exited:
                runDelegates(e, onPointerExited);
                break;
        }
    }

    void runListeners(ref KeyEvent keyEvent)
    {
        final switch (keyEvent.event) with (KeyEvent.Event)
        {
            case none:
                break;
            case keyUp:
                if (onKeyUp.length > 0)
                {
                    runDelegates(keyEvent, onKeyUp);
                }
                break;
            case keyDown:
                runDelegates(keyEvent, onKeyDown);
                break;
        }
    }

    void runListeners(ref TextInputEvent keyEvent)
    {
        final switch (keyEvent.event) with (
            TextInputEvent.Event)
        {
            case none:
                break;
            case input:
                runDelegates(keyEvent, onTextInput);
                break;
        }
    }

    void runListeners(ref JoystickEvent joystickEvent)
    {
        final switch (joystickEvent.event) with (
            JoystickEvent.Event)
        {
            case none:
                break;
            case press:
                runDelegates(joystickEvent, onJoystickButtonPress);
                break;
            case release:
                runDelegates(joystickEvent, onJoystickButtonRelease);
                break;
            case axis:
                runDelegates(joystickEvent, onJoystickAxis);
                break;
        }
    }

    void runListeners(ref FocusEvent focusEvent)
    {
        final switch (focusEvent.event) with (
            FocusEvent.Event)
        {
            case none:
                break;
            case focusIn:
                runDelegates(focusEvent, onFocusIn);
                break;
            case focusOut:
                runDelegates(focusEvent, onFocusOut);
                break;
        }
    }

    void runListeners(ref WindowEvent)
    {

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

        eventAppFilters = null;
        eventAppHandlers = null;

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

        eventWindowFilters = null;
        eventWindowHandlers = null;
    }

}
