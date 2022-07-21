module deltotum.events.event_manager;

import deltotum.events.processing.event_processor : EventProcessor;
import deltotum.state.state_manager : StateManager;

import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.window.event.window_event : WindowEvent;

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

    @property StateManager stateManager;

    //TODO for input
    @property void delegate(KeyEvent) onKey;

    this(StateManager stateManager)
    {
        this.stateManager = stateManager;
    }

    void startEvents()
    {
        if (eventProcessor is null)
        {
            return;
        }
        eventProcessor.onMouse = (mouseEvent) { dispatchEvent(mouseEvent); };
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
        DisplayObject[] eventChain = [];

        foreach (DisplayObject target; stateManager.currentState.getActiveObjects)
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
