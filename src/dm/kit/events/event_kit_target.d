module dm.kit.events.event_kit_target;

import dm.kit.components.window_component : WindowComponent;
import dm.core.events.event_target : EventTarget;

import dm.core.apps.events.app_event : AppEvent;
import dm.kit.events.focus.focus_event : FocusEvent;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.kit.windows.events.window_event : WindowEvent;

import dm.core.utils.type_util : drop;

/**
 * Authors: initkfs
 */
class EventKitTarget : WindowComponent, EventTarget
{
    void delegate(ref AppEvent)[] eventAppFilters;
    void delegate(ref AppEvent)[] eventAppHandlers;

    void delegate(ref AppEvent)[] onAppExit;

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

    void runListeners(ref AppEvent e)
    {
        final switch (e.event) with (AppEvent.Event)
        {
            case none:
                break;
            case exit:
                runDelegates(e, onAppExit);
                break;
        }
    }

    void runListeners(ref PointerEvent e)
    {
        final switch (e.event) with (PointerEvent.Event)
        {
            case none:
                break;
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
                runDelegates(keyEvent, onKeyUp);
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
        //TODO window events?
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

    bool removeFilter(void delegate(ref AppEvent) dg)
    {
        return drop(eventAppFilters, dg);
    }

    bool removeHandler(void delegate(ref AppEvent) dg)
    {
        return drop(eventAppHandlers, dg);
    }

    bool removeOnAppExit(void delegate(ref AppEvent) dg)
    {
        return drop(onAppExit, dg);
    }

    bool removeFilter(void delegate(ref PointerEvent) dg)
    {
        return drop(eventPointerFilters, dg);
    }

    bool removeHandler(void delegate(ref PointerEvent) dg)
    {
        return drop(eventPointerHandlers, dg);
    }

    bool removeOnPointerDown(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerDown, dg);
    }

    bool removeOnPointerUp(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerUp, dg);
    }

    bool removeOnPointerMove(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerMove, dg);
    }

    bool removeOnPointerWheel(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerWheel, dg);
    }

    bool removeOnPointerEntered(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerEntered, dg);
    }

    bool removeOnPointerExited(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerExited, dg);
    }

    bool removeFilter(void delegate(ref KeyEvent) dg)
    {
        return drop(eventKeyFilters, dg);
    }

    bool removeHandler(void delegate(ref KeyEvent) dg)
    {
        return drop(eventKeyHandlers, dg);
    }

    bool removeOnKeyUp(void delegate(ref KeyEvent) dg)
    {
        return drop(onKeyUp, dg);
    }

    bool removeOnKeyDown(void delegate(ref KeyEvent) dg)
    {
        return drop(onKeyUp, dg);
    }

    bool removeFilter(void delegate(ref TextInputEvent) dg)
    {
        return drop(eventTextInputFilters, dg);
    }

    bool removeHandler(void delegate(ref TextInputEvent) dg)
    {
        return drop(eventTextInputHandlers, dg);
    }

    bool removeOnTextInput(void delegate(ref TextInputEvent) dg)
    {
        return drop(onTextInput, dg);
    }

    bool removeFilter(void delegate(ref FocusEvent) dg)
    {
        return drop(eventFocusFilters, dg);
    }

    bool removeHandler(void delegate(ref FocusEvent) dg)
    {
        return drop(eventFocusHandlers, dg);
    }

    bool removeOnFocusIn(void delegate(ref FocusEvent) dg)
    {
        return drop(onFocusIn, dg);
    }

    bool removeOnFocusOut(void delegate(ref FocusEvent) dg)
    {
        return drop(onFocusOut, dg);
    }

    bool removeFilter(void delegate(ref JoystickEvent) dg)
    {
        return drop(eventJoystickFilters, dg);
    }

    bool removeHandler(void delegate(ref JoystickEvent) dg)
    {
        return drop(eventJoystickHandlers, dg);
    }

    bool removeOnJoystickAxis(void delegate(ref JoystickEvent) dg)
    {
        return drop(onJoystickAxis, dg);
    }

    bool removeOnJoystickButtonPress(void delegate(ref JoystickEvent) dg)
    {
        return drop(onJoystickButtonPress, dg);
    }

    bool removeOnJoystickButtonRelease(void delegate(ref JoystickEvent) dg)
    {
        return drop(onJoystickButtonRelease, dg);
    }

    bool removeFilter(void delegate(ref WindowEvent) dg)
    {
        return drop(eventWindowFilters, dg);
    }

    bool removeHandler(void delegate(ref WindowEvent) dg)
    {
        return drop(eventWindowHandlers, dg);
    }

    override void dispose()
    {
        super.dispose;

        eventAppFilters = null;
        eventAppHandlers = null;

        onAppExit = null;

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
