module deltotum.event.sdl.sdl_event_manager;

import bindbc.sdl;
import std.stdio;

class SdlEventManager
{

    void process(SDL_Event* event)
    {
        switch (event.type)
        {
        case SDL_WINDOWEVENT:
            handleWindowEvent(event);
            break;
        case SDL_KEYDOWN, SDL_KEYUP:
            handleKeyEvent(event);
            break;
        case SDL_MOUSEMOTION,
            SDL_MOUSEBUTTONDOWN,
            SDL_MOUSEBUTTONUP,
        SDL_MOUSEWHEEL:
            handleMouseEvent(event);
            break;
        default:
            break;
        }
    }

    void handleKeyEvent(SDL_Event* event)
    {
        import deltotum.event.events.key_event;

        KeyEventType type = KeyEventType.NONE;
        switch (event.type)
        {
        case SDL_KEYDOWN:
            type = KeyEventType.KEY_DOWN;
            break;
        case SDL_KEYUP:
            type = KeyEventType.KEY_UP;
            break;
        default:
            break;
        }
        auto keyCode = event.key.keysym.sym;
        auto mod = event.key.keysym.mod;
        auto windowId = event.key.windowID;
    }

    void handleMouseEvent(SDL_Event* event)
    {
        switch (event.type)
        {
        case SDL_MOUSEMOTION:
            auto x = event.motion.x;
            auto y = event.motion.y;
            auto movementX = event.motion.xrel;
            auto movementY = event.motion.yrel;
            break;

        case SDL_MOUSEBUTTONDOWN:

            // SDL_CaptureMouse(SDL_TRUE);

            // - 1
            SDL_MouseButtonEvent button = event.button;
            auto x = event.button.x;
            auto y = event.button.y;
            break;

        case SDL_MOUSEBUTTONUP:

            // SDL_CaptureMouse(SDL_FALSE);

            SDL_MouseButtonEvent button = event.button;
            auto x = event.button.x;
            auto y = event.button.y;

            break;

        case SDL_MOUSEWHEEL:
            int x;
            int y;
            if (event.wheel.direction == SDL_MouseWheelDirection.SDL_MOUSEWHEEL_FLIPPED)
            {
                x = -event.wheel.x;
                y = -event.wheel.y;
            }
            else
            {
                x = event.wheel.x;
                y = event.wheel.y;
            }
            break;
        default:
            break;
        }
    }

    void handleWindowEvent(SDL_Event* event)
    {
        import deltotum.event.events.window_event;

        WindowEventType type = WindowEventType.NONE;
        switch (event.window.event)
        {
        case SDL_WindowEventID.SDL_WINDOWEVENT_SHOWN:
            type = WindowEventType.WINDOW_ACTIVATE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_HIDDEN:
            type = WindowEventType.WINDOW_DEACTIVATE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_EXPOSED:
            type = WindowEventType.WINDOW_EXPOSE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_ENTER:
            type = WindowEventType.WINDOW_ENTER;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE:
            type = WindowEventType.WINDOW_CLOSE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_GAINED:
            type = WindowEventType.WINDOW_FOCUS_IN;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_LEAVE:
            type = WindowEventType.WINDOW_LEAVE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_LOST:
            type = WindowEventType.WINDOW_FOCUS_OUT;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MINIMIZED:
            type = WindowEventType.WINDOW_MINIMIZE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MAXIMIZED:
            type = WindowEventType.WINDOW_MAXIMIZE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MOVED:
            type = WindowEventType.WINDOW_MOVE;
            int x = event.window.data1;
            int y = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_SIZE_CHANGED:
            type =  WindowEventType.WINDOW_RESIZE;
            int width = event.window.data1;
            int height = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_RESTORED:
            type = WindowEventType.WINDOW_RESTORE;
            break;
        default:
            break;
        }
    }
}
