module deltotum.hal.sdl.events.sdl_event_processor;

import deltotum.events.processing.event_processor : EventProcessor;

import deltotum.events.event_type : EventType;
import deltotum.application.event.application_event : ApplicationEvent;
import deltotum.input.mouse.event.mouse_event : MouseEvent;
import deltotum.input.keyboard.event.key_event : KeyEvent;
import deltotum.window.event.window_event : WindowEvent;
import deltotum.input.joystick.event.joystick_event : JoystickEvent;

import bindbc.sdl;
import std.stdio;

/**
 * Authors: initkfs
 */
class SdlEventProcessor : EventProcessor!(SDL_Event*)
{
    override void process(SDL_Event* event)
    {
        switch (event.type)
        {
        case SDL_KEYDOWN, SDL_KEYUP:
            handleKeyEvent(event);
            break;
        case SDL_MOUSEMOTION, SDL_MOUSEBUTTONDOWN, SDL_MOUSEBUTTONUP, SDL_MOUSEWHEEL:
            handleMouseEvent(event);
            break;
        case SDL_JOYAXISMOTION, SDL_JOYBUTTONDOWN, SDL_JOYBUTTONUP:
            handleJoystickEvent(event);
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
            EventType.application, ApplicationEvent.Event.EXIT, event.window.windowID);
        onApplication(exitEvent);
    }

    void handleKeyEvent(SDL_Event* event)
    {
        if (onKey is null)
        {
            return;
        }

        auto type = KeyEvent.Event.none;
        switch (event.type)
        {
        case SDL_KEYDOWN:
            type = KeyEvent.Event.keyDown;
            break;
        case SDL_KEYUP:
            type = KeyEvent.Event.keyUp;
            break;
        default:
            break;
        }
        const int keyCode = event.key.keysym.sym;
        const int mod = event.key.keysym.mod;
        const windowId = event.key.windowID;
        immutable keyEvent = KeyEvent(EventType.key, type, windowId, keyCode, mod);
        onKey(keyEvent);
    }

    void handleMouseEvent(SDL_Event* event)
    {
        if (onMouse is null)
        {
            return;
        }

        auto type = MouseEvent.Event.none;
        double x = 0;
        double y = 0;
        double movementX = 0;
        double movementY = 0;
        int button;

        switch (event.type)
        {
        case SDL_MOUSEMOTION:
            type = MouseEvent.Event.mouseMove;
            x = event.motion.x;
            y = event.motion.y;
            movementX = event.motion.xrel;
            movementY = event.motion.yrel;
            break;
        case SDL_MOUSEBUTTONDOWN:
            SDL_CaptureMouse(SDL_TRUE);
            type = MouseEvent.Event.mouseDown;
            // - 1
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEBUTTONUP:
            SDL_CaptureMouse(SDL_FALSE);
            type = MouseEvent.Event.mouseUp;
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEWHEEL:
            type = MouseEvent.Event.mouseWheel;
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

        auto mouseEvent = MouseEvent(EventType.mouse, type, event.window.windowID, x, y, button, movementX, movementY);
        onMouse(mouseEvent);
    }

    void handleJoystickEvent(SDL_Event* event)
    {
        JoystickEvent.Event type = JoystickEvent.Event.none;
        switch (event.type)
        {
        case SDL_JOYAXISMOTION:
            type = JoystickEvent.Event.axis;
            break;
        case SDL_JOYBUTTONDOWN:
            type = JoystickEvent.Event.press;
            break;
        case SDL_JOYBUTTONUP:
            type = JoystickEvent.Event.release;
            break;
        default:
            break;
        }
        import std.stdio;
        immutable joystickEvent = JoystickEvent(
            EventType.joystick, type, event.window.windowID, event.jbutton.button, event
                .jaxis.axis, event.jaxis.value);
        onJoystick(joystickEvent);
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

        immutable windowEvent = WindowEvent(EventType.window, type, event.window.windowID, width, height, x, y);
        onWindow(windowEvent);
    }
}
