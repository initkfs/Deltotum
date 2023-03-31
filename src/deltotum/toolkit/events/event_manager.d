module deltotum.toolkit.events.event_manager;

import deltotum.toolkit.events.processing.event_processor : EventProcessor;
import deltotum.toolkit.scene.scene_manager : SceneManager;

import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.toolkit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.toolkit.input.keyboard.event.key_event : KeyEvent;
import deltotum.toolkit.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.toolkit.window.event.window_event : WindowEvent;
import deltotum.core.events.event_type : EventType;

import deltotum.toolkit.display.display_object : DisplayObject;
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

    Nullable!(DisplayObject[]) delegate() targetsProvider;

    version (SdlBackend)
    {
        import deltotum.platform.sdl.events.sdl_event_processor : SdlEventProcessor;

        SdlEventProcessor eventProcessor;
    }

    void delegate(KeyEvent) onKey;
    void delegate(JoystickEvent) onJoystick;
    void delegate(WindowEvent) onWindow;

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
        eventProcessor.onMouse = (mouseEvent) { dispatchEvent(mouseEvent); };
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
    }

    void dispatchEvent(E)(E e)
    {
        if (targetsProvider is null)
        {
            return;
        }

        auto mustBeTargets = targetsProvider();
        if (mustBeTargets.isNull)
        {
            return;
        }

        DisplayObject[] targets = mustBeTargets.get;

        foreach (DisplayObject target; targets)
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
}
