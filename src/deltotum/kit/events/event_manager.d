module deltotum.kit.events.event_manager;

import deltotum.kit.events.processing.event_processor : EventProcessor;
import deltotum.kit.scene.scene_manager : SceneManager;

import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.kit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.kit.input.keyboard.event.key_event : KeyEvent;
import deltotum.kit.input.keyboard.event.text_input_event : TextInputEvent;
import deltotum.kit.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.kit.window.event.window_event : WindowEvent;
import deltotum.core.events.event_type : EventType;

import deltotum.kit.display.display_object : DisplayObject;
import std.container : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class EventManager
{
    private
    {
        DList!DisplayObject eventChain = DList!DisplayObject();
    }

    Nullable!(DisplayObject[]) delegate(long) targetsProvider;

    version (SdlBackend)
    {
        import deltotum.sys.sdl.events.sdl_event_processor : SdlEventProcessor;

        SdlEventProcessor eventProcessor;
    }

    void delegate(KeyEvent) onKey;
    void delegate(JoystickEvent) onJoystick;
    void delegate(WindowEvent) onWindow;
    void delegate(MouseEvent) onMouse;
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
        eventProcessor.onMouse = (mouseEvent) {
            if (onMouse !is null)
            {
                onMouse(mouseEvent);
            }
            dispatchEvent(mouseEvent);

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

        DisplayObject[] targets = mustBeTargets.get;

        foreach (DisplayObject target; targets)
        {
            dispatchEvent(e, target);
        }
    }

    void dispatchEvent(E)(E e, DisplayObject target)
    {
        if (!eventChain.empty)
        {
            eventChain.clear;
        }

        target.dispatchEvent(e, eventChain);

        if (!eventChain.empty)
        {
            foreach (DisplayObject eventTarget; eventChain)
            {
                const isConsumed = eventTarget.runEventFilters(e);
                if (isConsumed)
                {
                    return;
                }
            }

            foreach_reverse (DisplayObject eventTarget; eventChain)
            {
                const isConsumed = eventTarget.runEventHandlers(e);
                if (isConsumed)
                {
                    return;
                }
            }
        }
    }
}
