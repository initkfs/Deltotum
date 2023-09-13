module deltotum.kit.events.event_manager;

import deltotum.kit.events.processing.event_processor : EventProcessor;
import deltotum.kit.scenes.scene_manager : SceneManager;

import deltotum.core.apps.events.application_event : ApplicationEvent;
import deltotum.kit.inputs.pointers.events.pointer_event : PointerEvent;
import deltotum.kit.inputs.keyboards.events.key_event : KeyEvent;
import deltotum.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import deltotum.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import deltotum.kit.windows.events.window_event : WindowEvent;
import deltotum.core.events.event_type : EventType;

import deltotum.kit.sprites.sprite : Sprite;
import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class EventManager
{
    private
    {
        DList!Sprite eventChain = DList!Sprite();
    }

    Nullable!(Sprite[]) delegate(long) targetsProvider;

    version (SdlBackend)
    {
        import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;

        SdlEventProcessor eventProcessor;
    }

    void delegate(KeyEvent) onKey;
    void delegate(JoystickEvent) onJoystick;
    void delegate(WindowEvent) onWindow;
    void delegate(PointerEvent) onPointer;
    void delegate(TextInputEvent) onTextInput;

    void startEvents()
    {
        if (eventProcessor is null)
        {
            return;
        }

        eventProcessor.onWindow = (windowEvent) {
            if (onWindow !is null)
            {
                onWindow(windowEvent);
            }
            dispatchEvent(windowEvent);
        };
        eventProcessor.onPointer = (pointerEvent) {
            if (onPointer !is null)
            {
                onPointer(pointerEvent);
            }
            dispatchEvent(pointerEvent);

        };
        eventProcessor.onJoystick = (joystickEvent) {
            if (onJoystick !is null)
            {
                onJoystick(joystickEvent);
            }
            dispatchEvent(joystickEvent);
        };
        eventProcessor.onKey = (keyEvent) {
            if (onKey !is null)
            {
                onKey(keyEvent);
            }
            dispatchEvent(keyEvent);
        };

        eventProcessor.onTextInput = (keyEvent)
        {
            if (onTextInput !is null)
            {
                onTextInput(keyEvent);
            }
            dispatchEvent(keyEvent);
        };
    }

    void dispatchEvent(E)(E e)
    {
        if (targetsProvider is null)
        {
            return;
        }

        const windowId = e.ownerId;

        auto mustBeTargets = targetsProvider(windowId);
        if (mustBeTargets.isNull)
        {
            return;
        }

        Sprite[] targets = mustBeTargets.get;

        foreach (Sprite target; targets)
        {
            dispatchEvent(e, target);
        }
    }

    void dispatchEvent(E)(E e, Sprite target)
    {
        if (!eventChain.empty)
        {
            eventChain.clear;
        }

        target.dispatchEvent(e, eventChain);

        if (!eventChain.empty)
        {
            foreach (Sprite eventTarget; eventChain)
            {
                eventTarget.runEventFilters(e);
                if (e.isConsumed)
                {
                    return;
                }
            }

            foreach_reverse (Sprite eventTarget; eventChain)
            {
                eventTarget.runEventHandlers(e);
                if (e.isConsumed)
                {
                    return;
                }
            }
        }
    }
}
