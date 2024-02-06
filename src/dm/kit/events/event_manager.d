module dm.kit.events.event_manager;

import dm.kit.events.processing.kit_event_processor : KitEventProcessor;
import dm.kit.scenes.scene_manager : SceneManager;

import dm.core.apps.events.application_event : ApplicationEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.kit.windows.events.window_event : WindowEvent;
import dm.kit.events.kit_event_type : KitEventType;
import dm.core.events.core_event_type : CoreEventType;

import dm.kit.sprites.sprite : Sprite;
import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class EventManager(E)
{
    private
    {
        DList!Sprite eventChain = DList!Sprite();
    }

    protected
    {
        KitEventProcessor!E eventProcessor;
    }

    Nullable!(Sprite[]) delegate(long) targetsProvider;

    void delegate(ref KeyEvent) onKey;
    void delegate(ref JoystickEvent) onJoystick;
    void delegate(ref WindowEvent) onWindow;
    void delegate(ref PointerEvent) onPointer;
    void delegate(ref TextInputEvent) onTextInput;

    this(KitEventProcessor!E processor)
    {
        assert(processor);
        this.eventProcessor = processor;
    }

    void startEvents()
    {
        if (eventProcessor is null)
        {
            return;
        }

        eventProcessor.onWindow = (ref windowEvent) {
            if (onWindow !is null)
            {
                onWindow(windowEvent);
            }
            dispatchEvent(windowEvent);
        };
        eventProcessor.onPointer = (ref pointerEvent) {
            if (onPointer !is null)
            {
                onPointer(pointerEvent);
            }
            dispatchEvent(pointerEvent);

        };
        eventProcessor.onJoystick = (ref joystickEvent) {
            if (onJoystick !is null)
            {
                onJoystick(joystickEvent);
            }
            dispatchEvent(joystickEvent);
        };
        eventProcessor.onKey = (ref keyEvent) {
            if (onKey !is null)
            {
                onKey(keyEvent);
            }
            dispatchEvent(keyEvent);
        };

        eventProcessor.onTextInput = (ref keyEvent) {
            if (onTextInput !is null)
            {
                onTextInput(keyEvent);
            }
            dispatchEvent(keyEvent);
        };
    }

    void process(E event)
    {
        eventProcessor.process(event);
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
