module deltotum.sys.sdl.events.sdl_event_processor;

// dfmt off
version(SdlBackend):
// dfmt on

import deltotum.kit.events.processing.event_processor : EventProcessor;

import deltotum.core.events.event_type : EventType;
import deltotum.core.applications.events.application_event : ApplicationEvent;
import deltotum.kit.input.mouse.event.mouse_event : MouseEvent;
import deltotum.kit.input.keyboard.event.key_event : KeyEvent;
import deltotum.kit.input.keyboard.event.text_input_event: TextInputEvent;
import deltotum.kit.window.event.window_event : WindowEvent;
import deltotum.kit.input.joystick.event.joystick_event : JoystickEvent;
import deltotum.sys.sdl.sdl_keyboard : SdlKeyboard;

import bindbc.sdl;
import std.stdio;

/**
 * Authors: initkfs
 */
class SdlEventProcessor : EventProcessor!(SDL_Event*)
{
    private
    {
        SdlKeyboard keyboard;
    }

    this(SdlKeyboard keyboard)
    {
        assert(keyboard !is null);
        this.keyboard = keyboard;
    }

    override bool process(SDL_Event* event)
    {
        if (!event)
        {
            return false;
        }

        switch (event.type)
        {
        case SDL_KEYDOWN, SDL_KEYUP:
            handleKeyEvent(event);
            break;
        case SDL_TEXTINPUT:
            handleTextInputEvent(event);
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
            return false;
        }

        return true;
    }

    protected void handleQuit(SDL_Event* event)
    {
        if (onApplication is null)
        {
            return;
        }
        auto exitEvent = ApplicationEvent(
            EventType.application, ApplicationEvent.Event.EXIT, event.window.windowID);
        onApplication(exitEvent);
    }

    protected void handleTextInputEvent(SDL_Event* event)
    {
        if (onTextInput is null)
        {
            return;
        }

        auto type = TextInputEvent.Event.input;

        enum letterSize = dchar.sizeof;
        if (event.text.text.length < letterSize)
        {
            return;
        }

        import std.conv : to;
        import std.string: fromStringz;

        //TODO full string?
        dchar firstLetter = event.text.text[0 .. (letterSize + 1)].fromStringz.to!dchar;

        const ownerId = event.key.windowID;
        auto keyEvent = TextInputEvent(EventType.key, type, ownerId, firstLetter);
        onTextInput(keyEvent);
    }

    protected void handleKeyEvent(SDL_Event* event)
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

        import deltotum.com.commons.keyboards.key_name : KeyName;

        const SDL_Keycode keyCode = event.key.keysym.sym;
        const keyName = keyboard.keyCodeToKeyName(keyCode);

        const mod = event.key.keysym.mod;

        import deltotum.com.commons.keyboards.key_modifier_info : KeyModifierInfo;

        KeyModifierInfo modInfo = KeyModifierInfo(
            (mod & SDL_Keymod.KMOD_LSHIFT) == SDL_Keymod.KMOD_LSHIFT,
            (mod & SDL_Keymod.KMOD_RSHIFT) == SDL_Keymod.KMOD_RSHIFT,
            (mod & SDL_Keymod.KMOD_LCTRL) == SDL_Keymod.KMOD_LCTRL,
            (mod & SDL_Keymod.KMOD_RCTRL) == SDL_Keymod.KMOD_RCTRL,
            (mod & SDL_Keymod.KMOD_LALT) == SDL_Keymod.KMOD_LALT,
            (mod & SDL_Keymod.KMOD_RALT) == SDL_Keymod.KMOD_RALT,
            (mod & SDL_Keymod.KMOD_LGUI) == SDL_Keymod.KMOD_LGUI,
            (mod & SDL_Keymod.KMOD_RGUI) == SDL_Keymod.KMOD_RGUI,
            (mod & SDL_Keymod.KMOD_NUM) == SDL_Keymod.KMOD_NUM,
            (mod & SDL_Keymod.KMOD_CAPS) == SDL_Keymod.KMOD_CAPS,
            (mod & SDL_Keymod.KMOD_MODE) == SDL_Keymod.KMOD_MODE,
            (mod & SDL_Keymod.KMOD_SCROLL) == SDL_Keymod.KMOD_SCROLL,
        );

        const ownerId = event.key.windowID;
        auto keyEvent = KeyEvent(EventType.key, type, ownerId, keyName, modInfo, keyCode);
        onKey(keyEvent);
    }

    protected void handleMouseEvent(SDL_Event* event)
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

    protected void handleJoystickEvent(SDL_Event* event)
    {
        if (onJoystick is null)
        {
            return;
        }

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
        auto joystickEvent = JoystickEvent(
            EventType.joystick, type, event.window.windowID, event.jbutton.button, event
                .jaxis.axis, event.jaxis.value);
        onJoystick(joystickEvent);
    }

    protected void handleWindowEvent(SDL_Event* event)
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

        auto windowEvent = WindowEvent(EventType.window, type, event.window.windowID, width, height, x, y);
        onWindow(windowEvent);
    }
}
