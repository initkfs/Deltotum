module app.dm.kit.events.kit_event_manager;

import app.core.events.processing.event_processor: EventProcessor;
import app.core.events.chain_event_manager: ChainEventManager;
import app.dm.kit.events.processing.kit_event_processor: KitEventProcessor;
import app.dm.kit.scenes.scene_manager : SceneManager;

import app.core.apps.events.app_event : AppEvent;
import app.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import app.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import app.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import app.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import app.dm.kit.windows.events.window_event : WindowEvent;

import app.dm.kit.sprites.sprite : Sprite;
import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class KitEventManager : ChainEventManager!(Sprite)
{
    Nullable!(Sprite[]) delegate(long) targetsProvider;

    void delegate(ref KeyEvent) onKey;
    void delegate(ref JoystickEvent) onJoystick;
    void delegate(ref WindowEvent) onWindow;
    void delegate(ref PointerEvent) onPointer;
    void delegate(ref TextInputEvent) onTextInput;

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
