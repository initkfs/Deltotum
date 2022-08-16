module deltotum.events.event_manager;

import deltotum.events.processing.event_processor : EventProcessor;
import deltotum.scene.scene_manager : SceneManager;

import deltotum.application.event.application_event : ApplicationEvent;
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

        @property SdlEventProcessor eventProcessor;
    }

    @property SceneManager sceneManager;

    //TODO for input
    @property void delegate(KeyEvent) onKey;
    @property void delegate(JoystickEvent) onJoystick;

    this(SceneManager sceneManager)
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
        foreach (DisplayObject target; sceneManager.currentScene.getActiveObjects)
        {
            DisplayObject[] eventChain = [];
            target.dispatchEvent(e, eventChain, true);
        }
    }
}
