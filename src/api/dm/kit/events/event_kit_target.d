module api.dm.kit.events.event_kit_target;

import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.kit.events.event_target : EventTarget;

import api.dm.kit.apps.events.app_event : AppEvent;
import api.dm.kit.events.focus.focus_event : FocusEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.kit.windows.events.window_event : WindowEvent;

import api.core.utils.arrays : drop;

import std.meta : AliasSeq;

alias AllAppEvents = AliasSeq!(AppEvent, FocusEvent, KeyEvent, PointerEvent, TextInputEvent, JoystickEvent, WindowEvent);

enum EventKitPhase
{
    preDispatch,
    preDispatchChildren,
    postDispatchChildren,
    postDispatch
}

mixin template EventPhaseProcesor()
{
    //TODO remove imports
    import api.dm.kit.apps.events.app_event : AppEvent;
    import api.dm.kit.events.focus.focus_event : FocusEvent;
    import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
    import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
    import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
    import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
    import api.dm.kit.windows.events.window_event : WindowEvent;
    import api.dm.kit.events.event_kit_target : AllAppEvents, EventKitPhase;
    import std.conv : text;

    static foreach (e; AllAppEvents)
    {
        mixin(text("void onEventPhase(ref ", e.stringof, " e, ", EventKitPhase.stringof, " phase){}"));
    }
}

/**
 * Authors: initkfs
 */
class EventKitTarget : GraphicComponent, EventTarget
{
    void delegate(ref AppEvent)[] eventAppHandlers;

    void delegate(ref AppEvent)[] onAppExit;

    void delegate(ref PointerEvent)[] eventPointerHandlers;

    void delegate(ref PointerEvent)[] onPointerCancel;
    void delegate(ref PointerEvent)[] onPointerPress;
    void delegate(ref PointerEvent)[] onPointerClick;
    void delegate(ref PointerEvent)[] onPointerRelease;
    void delegate(ref PointerEvent)[] onPointerMove;
    void delegate(ref PointerEvent)[] onPointerWheel;

    bool isMouseOver;
    void delegate(ref PointerEvent)[] onPointerEnter;
    void delegate(ref PointerEvent)[] onPointerExit;

    void delegate(ref KeyEvent)[] eventKeyHandlers;

    void delegate(ref KeyEvent)[] onKeyRelease;
    void delegate(ref KeyEvent)[] onKeyPress;

    void delegate(ref TextInputEvent)[] eventTextInputHandlers;

    void delegate(ref TextInputEvent)[] onTextInput;

    void delegate(ref FocusEvent)[] eventFocusHandlers;

    void delegate(ref FocusEvent)[] onFocusEnter;
    void delegate(ref FocusEvent)[] onFocusExit;

    void delegate(ref JoystickEvent)[] eventJoystickHandlers;

    void delegate(ref JoystickEvent)[] onJoystickAxis;
    void delegate(ref JoystickEvent)[] onJoystickButtonPress;
    void delegate(ref JoystickEvent)[] onJoystickButtonRelease;

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
            case cancel:
                runDelegates(e, onPointerCancel);
                break;
            case press:
                runDelegates(e, onPointerPress);
                break;
            case release:
                runDelegates(e, onPointerRelease);
                break;
            case move:
                runDelegates(e, onPointerMove);
                break;
            case wheel:
                runDelegates(e, onPointerWheel);
                break;
            case enter:
                runDelegates(e, onPointerEnter);
                break;
            case exit:
                runDelegates(e, onPointerExit);
                break;
            case click:
                runDelegates(e, onPointerClick);
                break;
        }
    }

    void runListeners(ref KeyEvent keyEvent)
    {
        final switch (keyEvent.event) with (KeyEvent.Event)
        {
            case none:
                break;
            case release:
                runDelegates(keyEvent, onKeyRelease);
                break;
            case press:
                runDelegates(keyEvent, onKeyPress);
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
            case enter:
                runDelegates(focusEvent, onFocusEnter);
                break;
            case exit:
                runDelegates(focusEvent, onFocusExit);
                break;
        }
    }

    void runListeners(ref WindowEvent)
    {
        //TODO window events?
    }

    void fireEvent(E)(ref E e)
    {
        runEventHandlers!E(e);
    }

    bool removeHandler(void delegate(ref AppEvent) dg)
    {
        return drop(eventAppHandlers, dg);
    }

    bool removeOnAppExit(void delegate(ref AppEvent) dg)
    {
        return drop(onAppExit, dg);
    }

    bool removeHandler(void delegate(ref PointerEvent) dg)
    {
        return drop(eventPointerHandlers, dg);
    }

    bool removeOnPointerDown(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerPress, dg);
    }

    bool removeOnPointerReleased(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerRelease, dg);
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
        return drop(onPointerEnter, dg);
    }

    bool removeOnPointerExited(void delegate(ref PointerEvent) dg)
    {
        return drop(onPointerExit, dg);
    }

    bool removeHandler(void delegate(ref KeyEvent) dg)
    {
        return drop(eventKeyHandlers, dg);
    }

    bool removeOnKeyUp(void delegate(ref KeyEvent) dg)
    {
        return drop(onKeyRelease, dg);
    }

    bool removeOnKeyDown(void delegate(ref KeyEvent) dg)
    {
        return drop(onKeyRelease, dg);
    }

    bool removeHandler(void delegate(ref TextInputEvent) dg)
    {
        return drop(eventTextInputHandlers, dg);
    }

    bool removeOnTextInput(void delegate(ref TextInputEvent) dg)
    {
        return drop(onTextInput, dg);
    }

    bool removeHandler(void delegate(ref FocusEvent) dg)
    {
        return drop(eventFocusHandlers, dg);
    }

    bool removeOnFocusIn(void delegate(ref FocusEvent) dg)
    {
        return drop(onFocusEnter, dg);
    }

    bool removeOnFocusOut(void delegate(ref FocusEvent) dg)
    {
        return drop(onFocusExit, dg);
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

    bool removeHandler(void delegate(ref WindowEvent) dg)
    {
        return drop(eventWindowHandlers, dg);
    }

    override void dispose()
    {
        super.dispose;

        eventAppHandlers = null;

        onAppExit = null;

        eventPointerHandlers = null;

        onPointerPress = null;
        onPointerRelease = null;
        onPointerMove = null;
        onPointerWheel = null;

        onPointerEnter = null;
        onPointerExit = null;

        eventKeyHandlers = null;

        onKeyRelease = null;
        onKeyPress = null;

        eventTextInputHandlers = null;

        onTextInput = null;

        eventFocusHandlers = null;

        onFocusEnter = null;
        onFocusExit = null;

        eventJoystickHandlers = null;

        onJoystickAxis = null;
        onJoystickButtonPress = null;
        onJoystickButtonRelease = null;

        eventWindowHandlers = null;
    }

}
