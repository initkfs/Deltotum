module deltotum.events.event_manager;

import deltotum.events.processing.event_processor : EventProcessor;
import deltotum.scene.scene_manager : SceneManager;

import deltotum.application.events.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.window.event.window_event : WindowEvent;
import deltotum.events.event_type : EventType;

import deltotum.display.display_object : DisplayObject;

/**
 * Authors: initkfs
 */
class EventManager
{
    version (sdl_backend)
    {
        import deltotum.hal.sdl.events.sdl_event_processor : SdlEventProcessor;

        SdlEventProcessor eventProcessor;
    }

    SceneManager sceneManager;

    void delegate(KeyEvent) onKey;
    void delegate(JoystickEvent) onJoystick;

    this(SceneManager sceneManager) pure @safe
    {
        this.sceneManager = sceneManager;
    }

    void startEvents()
    {
        if (eventProcessor is null)
        {
            return;
        }
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
        import std.container : DList;

        DList!DisplayObject chain = DList!DisplayObject();

        foreach (DisplayObject target; sceneManager.currentScene.getActiveObjects)
        {
            if (!chain.empty)
            {
                chain.clear;
            }

            target.dispatchEvent(e, chain);

            if (!chain.empty)
            {
                foreach (DisplayObject eventTarget; chain)
                {
                    const isConsumed = eventTarget.runEventFilters(e);
                    if (isConsumed)
                    {
                        return;
                    }
                }

                foreach_reverse (DisplayObject eventTarget; chain)
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
