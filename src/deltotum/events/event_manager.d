module deltotum.events.event_manager;

import deltotum.events.processing.event_processor : EventProcessor;
import deltotum.scene.scene_manager : SceneManager;

import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.window.event.window_event : WindowEvent;
import deltotum.events.event_type: EventType;

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
        eventProcessor.onMouse = (mouseEvent) { dispatchMouseEvent(mouseEvent); };
        eventProcessor.onKey = (keyEvent) {
            if (onKey !is null)
            {
                onKey(keyEvent);
            }
            dispatchKeyEvent(keyEvent);
        };
    }

    void dispatchKeyEvent(KeyEvent e)
    {
        DisplayObject[] eventChain = [];

        foreach (DisplayObject target; sceneManager.currentScene.getActiveObjects)
        {
            target.buildEventRoute(eventChain, e);
            static if (__traits(compiles, e.target))
            {
                if (e.target is target)
                {
                    break;
                }
            }
        }
    }

    void dispatchMouseEvent(MouseEvent e)
    {
        DisplayObject[] eventChain = [];
        //TODO remove chains
        DisplayObject[] eventChainEntered = [];
        DisplayObject[] eventChainExited = [];
        MouseEvent[] exitedEvents = [];
        MouseEvent[] enteredEvents = [];

        foreach (DisplayObject target; sceneManager.currentScene.getActiveObjects)
        {
            if (!target.bounds.contains(e.x, e.y))
            {
                if (target.isMouseOver)
                {
                    target.isMouseOver = false;
                    exitedEvents ~= MouseEvent(EventType.mouse, MouseEvent.Event.mouseExited, e.windowId, e.x, e.y, e
                            .button, e.movementX, e.movementY);
                    target.buildEventRoute(eventChainExited, exitedEvents[0]);
                }
                continue;
            }

            if (!target.isMouseOver)
            {
                target.isMouseOver = true;
                enteredEvents ~= MouseEvent(EventType.mouse, MouseEvent.Event.mouseEntered, e.windowId, e.x, e.y, e
                        .button, e.movementX, e.movementY);
                target.buildEventRoute(eventChainEntered, enteredEvents[0]);
            }

            target.buildEventRoute(eventChain, e);
            static if (__traits(compiles, e.target))
            {
                if (e.target is target)
                {
                    break;
                }
            }
        }

        if (eventChainEntered.length > 0 && enteredEvents.length > 0)
        {
            processEvent(eventChainEntered, enteredEvents[0]);
        }

        //or after?
        if (eventChainExited.length > 0 && exitedEvents.length > 0)
        {
            processEvent(eventChainExited, exitedEvents[0]);
        }

        processEvent(eventChain, e);

    }

    void processEvent(E)(DisplayObject[] eventChain, E e)
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
