module api.dm.back.sdl3.sdl_event_processor;

import api.dm.kit.events.processing.kit_event_processor : KitEventProcessor;

import api.core.apps.events.app_event : AppEvent;
import api.dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import api.dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import api.dm.kit.inputs.keyboards.events.text_input_event : TextInputEvent;
import api.dm.kit.windows.events.window_event : WindowEvent;
import api.dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import api.dm.back.sdl3.sdl_keyboard : SdlKeyboard;

import api.dm.back.sdl3.externs.csdl3;
import std.stdio;

/**
 * Authors: initkfs
 */
class SdlEventProcessor : KitEventProcessor!(SDL_Event*)
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

        if (event.type >= SDL_EVENT_WINDOW_FIRST && event.type <= SDL_EVENT_WINDOW_LAST)
        {
            handleWindowEvent(event);
            return true;
        }

        switch (event.type)
        {
            case SDL_EVENT_KEY_DOWN, SDL_EVENT_KEY_UP:
                handleKeyEvent(event);
                break;
            case SDL_EVENT_TEXT_INPUT:
                handleTextInputEvent(event);
                break;
            case SDL_EVENT_MOUSE_MOTION, SDL_EVENT_MOUSE_BUTTON_DOWN, SDL_EVENT_MOUSE_BUTTON_UP, SDL_EVENT_MOUSE_WHEEL:
                handleMouseEvent(event);
                break;
            case SDL_EVENT_JOYSTICK_BUTTON_DOWN, SDL_EVENT_JOYSTICK_BUTTON_UP, SDL_EVENT_JOYSTICK_AXIS_MOTION:
                handleJoystickEvent(event);
                break;
            case SDL_EVENT_QUIT:
                handleQuit(event);
                break;
            default:
                return false;
        }

        return true;
    }

    protected void handleQuit(SDL_Event* event)
    {
        if (onApp is null)
        {
            return;
        }
        auto exitEvent = AppEvent(AppEvent.Event.exit, event.window.windowID);
        onApp(exitEvent);
    }

    protected void handleTextInputEvent(SDL_Event* event)
    {
        if (onTextInput is null)
        {
            return;
        }

        auto type = TextInputEvent.Event.input;

        import std.conv : to;
        import std.string : fromStringz;

        //TODO full string?
        dchar firstLetter = event.text.text.fromStringz.to!dchar;

        const ownerId = event.key.windowID;
        auto keyEvent = TextInputEvent(type, ownerId, firstLetter);
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
            case SDL_EVENT_KEY_DOWN:
                type = KeyEvent.Event.press;
                break;
            case SDL_EVENT_KEY_UP:
                type = KeyEvent.Event.release;
                break;
            default:
                break;
        }

        import api.dm.com.inputs.com_keyboard : ComKeyName;

        const SDL_Keycode keyCode = event.key.key;
        const keyName = keyboard.keyCodeToKeyName(keyCode);

        const SDL_Scancode scanCode = event.key.scancode;

        const mod = event.key.mod;

        import api.dm.com.inputs.com_keyboard : ComKeyModifier;

        ComKeyModifier modInfo = ComKeyModifier(
            (mod & SDL_KMOD_LSHIFT) == SDL_KMOD_LSHIFT,
            (mod & SDL_KMOD_RSHIFT) == SDL_KMOD_RSHIFT,
            (mod & SDL_KMOD_LCTRL) == SDL_KMOD_LCTRL,
            (mod & SDL_KMOD_RCTRL) == SDL_KMOD_RCTRL,
            (mod & SDL_KMOD_LALT) == SDL_KMOD_LALT,
            (mod & SDL_KMOD_RALT) == SDL_KMOD_RALT,
            (mod & SDL_KMOD_LGUI) == SDL_KMOD_LGUI,
            (mod & SDL_KMOD_RGUI) == SDL_KMOD_RGUI,
            (mod & SDL_KMOD_NUM) == SDL_KMOD_NUM,
            (mod & SDL_KMOD_CAPS) == SDL_KMOD_CAPS,
            (mod & SDL_KMOD_MODE) == SDL_KMOD_MODE,
            (mod & SDL_KMOD_SCROLL) == SDL_KMOD_SCROLL,
        );

        const ownerId = event.key.windowID;
        auto keyEvent = KeyEvent(type, ownerId, keyName, modInfo, keyCode, scanCode);
        onKey(keyEvent);
    }

    protected void handleMouseEvent(SDL_Event* event)
    {
        if (onPointer is null)
        {
            return;
        }

        auto type = PointerEvent.Event.none;
        double x = 0;
        double y = 0;
        double movementX = 0;
        double movementY = 0;
        int button;

        switch (event.type)
        {
            case SDL_EVENT_MOUSE_MOTION:
                type = PointerEvent.Event.move;
                x = event.motion.x;
                y = event.motion.y;
                movementX = event.motion.xrel;
                movementY = event.motion.yrel;
                break;
            case SDL_EVENT_MOUSE_BUTTON_DOWN:
                SDL_CaptureMouse(true);
                type = PointerEvent.Event.press;
                // - 1
                button = event.button.button;
                x = event.button.x;
                y = event.button.y;
                break;
            case SDL_EVENT_MOUSE_BUTTON_UP:
                SDL_CaptureMouse(false);
                type = PointerEvent.Event.release;
                button = event.button.button;
                x = event.button.x;
                y = event.button.y;
                break;
            case SDL_EVENT_MOUSE_WHEEL:
                type = PointerEvent.Event.wheel;
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

        auto mouseEvent = PointerEvent(type, event.window.windowID, x, y, button, movementX, movementY);
        onPointer(mouseEvent);
    }

    protected void handleJoystickEvent(SDL_Event* event)
    {
        if (onJoystick is null)
        {
            return;
        }

        SDL_JoystickID id;

        JoystickEvent.Event type = JoystickEvent.Event.none;
        switch (event.type)
        {
            case SDL_EVENT_JOYSTICK_AXIS_MOTION:
                type = JoystickEvent.Event.axis;
                id = (cast(SDL_JoyAxisEvent*) event).which;
                break;
            case SDL_EVENT_JOYSTICK_BUTTON_DOWN:
                type = JoystickEvent.Event.press;
                id = (cast(SDL_JoyButtonEvent*) event).which;
                break;
            case SDL_EVENT_JOYSTICK_BUTTON_UP:
                type = JoystickEvent.Event.release;
                id = (cast(SDL_JoyButtonEvent*) event).which;
                break;
            default:
                break;
        }

        auto joystickEvent = JoystickEvent(
            type, id, event.jbutton.button, event.jbutton.down, event
                .jaxis.axis, event.jaxis.value);
        onJoystick(joystickEvent);
    }

    protected void handleWindowEvent(SDL_Event* event)
    {
        if (onWindow is null)
        {
            return;
        }

        auto type = WindowEvent.Event.none;
        long x = 0;
        long y = 0;
        long width = 0;
        long height = 0;
        switch (event.window.type)
        {
            case SDL_EVENT_WINDOW_SHOWN:
                type = WindowEvent.Event.show;
                break;
            case SDL_EVENT_WINDOW_HIDDEN:
                type = WindowEvent.Event.hide;
                break;
            case SDL_EVENT_WINDOW_EXPOSED:
                type = WindowEvent.Event.expose;
                break;
            case SDL_EVENT_WINDOW_MOUSE_ENTER:
                type = WindowEvent.Event.enter;
                break;
            case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
                type = WindowEvent.Event.close;
                break;
            case SDL_EVENT_WINDOW_FOCUS_GAINED:
                type = WindowEvent.Event.focusIn;
                break;
            case SDL_EVENT_WINDOW_MOUSE_LEAVE:
                type = WindowEvent.Event.leave;
                break;
            case SDL_EVENT_WINDOW_FOCUS_LOST:
                type = WindowEvent.Event.focusOut;
                break;
            case SDL_EVENT_WINDOW_MINIMIZED:
                type = WindowEvent.Event.minimize;
                break;
            case SDL_EVENT_WINDOW_MAXIMIZED:
                type = WindowEvent.Event.maximize;
                break;
            case SDL_EVENT_WINDOW_MOVED:
                type = WindowEvent.Event.move;
                x = event.window.data1;
                y = event.window.data2;
                break;
            case SDL_EVENT_WINDOW_RESIZED:
                type = WindowEvent.Event.resize;
                width = event.window.data1;
                height = event.window.data2;
                break;
            case SDL_EVENT_WINDOW_RESTORED:
                type = WindowEvent.Event.restore;
                break;
            default:
                break;
        }

        auto windowEvent = WindowEvent(type, event.window.windowID, width, height, x, y);
        onWindow(windowEvent);
    }
}
