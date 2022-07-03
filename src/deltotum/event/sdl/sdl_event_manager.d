module deltotum.event.sdl.sdl_event_manager;

import deltotum.event.event_type : EventType;
import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.window.event.window_event : WindowEvent;

import bindbc.sdl;
import std.stdio;

class SdlEventManager
{
    @property void delegate(ApplicationEvent) onApplication;
    @property void delegate(MouseEvent) onMouse;
    @property void delegate(KeyEvent) onKey;
    @property void delegate(WindowEvent) onWindow;

    void process(SDL_Event* event)
    {
        switch (event.type)
        {
        case SDL_KEYDOWN, SDL_KEYUP:
            handleKeyEvent(event);
            break;
        case SDL_MOUSEMOTION, SDL_MOUSEBUTTONDOWN, SDL_MOUSEBUTTONUP, SDL_MOUSEWHEEL:
            handleMouseEvent(event);
            break;
        case SDL_QUIT:
            handleQuit(event);
            break;
        case SDL_WINDOWEVENT:
            handleWindowEvent(event);
            break;
        default:
            break;
        }
    }

    void handleQuit(SDL_Event* event)
    {
        if (onApplication is null)
        {
            return;
        }
        immutable exitEvent = ApplicationEvent(
            EventType.APPLICATION, ApplicationEvent.Event.EXIT, event.window.windowID);
        onApplication(exitEvent);
    }

    void handleKeyEvent(SDL_Event* event)
    {
        if (onKey is null)
        {
            return;
        }

        auto type = KeyEvent.Event.NONE;
        switch (event.type)
        {
        case SDL_KEYDOWN:
            type = KeyEvent.Event.KEY_DOWN;
            break;
        case SDL_KEYUP:
            type = KeyEvent.Event.KEY_UP;
            break;
        default:
            break;
        }
        const int keyCode = event.key.keysym.sym;
        const int mod = event.key.keysym.mod;
        const windowId = event.key.windowID;
        immutable keyEvent = KeyEvent(EventType.KEY, type, windowId, keyCode, mod);
        onKey(keyEvent);
    }

    void handleMouseEvent(SDL_Event* event)
    {
        if (onMouse is null)
        {
            return;
        }

        auto type = MouseEvent.Event.NONE;
        double x = 0;
        double y = 0;
        double movementX = 0;
        double movementY = 0;
        int button;

        switch (event.type)
        {
        case SDL_MOUSEMOTION:
            type = MouseEvent.Event.MOUSE_MOVE;
            x = event.motion.x;
            y = event.motion.y;
            movementX = event.motion.xrel;
            movementY = event.motion.yrel;
            break;
        case SDL_MOUSEBUTTONDOWN:
            SDL_CaptureMouse(SDL_TRUE);
            type = MouseEvent.Event.MOUSE_DOWN;
            // - 1
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEBUTTONUP:
            SDL_CaptureMouse(SDL_FALSE);
            type = MouseEvent.Event.MOUSE_UP;
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEWHEEL:
            type = MouseEvent.Event.MOUSE_WHEEL;
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

        immutable mouseEvent = MouseEvent(EventType.MOUSE, type, event.window.windowID, x, y, button, movementX, movementY);
        onMouse(mouseEvent);
    }

    void handleWindowEvent(SDL_Event* event)
    {
        if (onWindow is null)
        {
            return;
        }

        auto type = WindowEvent.Event.NONE;
        double x = 0;
        double y = 0;
        double width = 0;
        double height = 0;
        switch (event.window.event)
        {
        case SDL_WindowEventID.SDL_WINDOWEVENT_SHOWN:
            type = WindowEvent.Event.WINDOW_SHOW;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_HIDDEN:
            type = WindowEvent.Event.WINDOW_HIDE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_EXPOSED:
            type = WindowEvent.Event.WINDOW_EXPOSE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_ENTER:
            type = WindowEvent.Event.WINDOW_ENTER;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE:
            type = WindowEvent.Event.WINDOW_CLOSE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_GAINED:
            type = WindowEvent.Event.WINDOW_FOCUS_IN;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_LEAVE:
            type = WindowEvent.Event.WINDOW_LEAVE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_LOST:
            type = WindowEvent.Event.WINDOW_FOCUS_OUT;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MINIMIZED:
            type = WindowEvent.Event.WINDOW_MINIMIZE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MAXIMIZED:
            type = WindowEvent.Event.WINDOW_MAXIMIZE;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MOVED:
            type = WindowEvent.Event.WINDOW_MOVE;
            x = event.window.data1;
            y = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_SIZE_CHANGED:
            type = WindowEvent.Event.WINDOW_RESIZE;
            width = event.window.data1;
            height = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_RESTORED:
            type = WindowEvent.Event.WINDOW_RESTORE;
            break;
        default:
            break;
        }

        immutable windowEvent = WindowEvent(EventType.WINDOW, type, event.window.windowID, width, height, x, y);
        onWindow(windowEvent);
    }
}
