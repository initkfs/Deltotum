module dm.back.sdl2.events.sdl_event_processor;

// dfmt off
version(SdlBackend):
// dfmt on

import dm.kit.events.processing.kit_event_processor : KitEventProcessor;

import dm.kit.events.kit_event_type: KitEventType;
import dm.core.events.core_event_type: CoreEventType;
import dm.core.apps.events.app_event : AppEvent;
import dm.kit.inputs.pointers.events.pointer_event : PointerEvent;
import dm.kit.inputs.keyboards.events.key_event : KeyEvent;
import dm.kit.inputs.keyboards.events.text_input_event: TextInputEvent;
import dm.kit.windows.events.window_event : WindowEvent;
import dm.kit.inputs.joysticks.events.joystick_event : JoystickEvent;
import dm.back.sdl2.sdl_keyboard : SdlKeyboard;

import bindbc.sdl;
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
        auto exitEvent = AppEvent(AppEvent.Event.Exit, event.window.windowID);
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
        case SDL_KEYDOWN:
            type = KeyEvent.Event.keyDown;
            break;
        case SDL_KEYUP:
            type = KeyEvent.Event.keyUp;
            break;
        default:
            break;
        }

        import dm.com.inputs.keyboards.key_name : KeyName;

        const SDL_Keycode keyCode = event.key.keysym.sym;
        const keyName = keyboard.keyCodeToKeyName(keyCode);

        const mod = event.key.keysym.mod;

        import dm.com.inputs.keyboards.key_modifier_info : KeyModifierInfo;

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
        auto keyEvent = KeyEvent(type, ownerId, keyName, modInfo, keyCode);
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
        case SDL_MOUSEMOTION:
            type = PointerEvent.Event.move;
            x = event.motion.x;
            y = event.motion.y;
            movementX = event.motion.xrel;
            movementY = event.motion.yrel;
            break;
        case SDL_MOUSEBUTTONDOWN:
            SDL_CaptureMouse(SDL_TRUE);
            type = PointerEvent.Event.down;
            // - 1
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEBUTTONUP:
            SDL_CaptureMouse(SDL_FALSE);
            type = PointerEvent.Event.up;
            button = event.button.button;
            x = event.button.x;
            y = event.button.y;
            break;
        case SDL_MOUSEWHEEL:
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
            type, event.window.windowID, event.jbutton.button, event
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
        switch (event.window.event)
        {
        case SDL_WindowEventID.SDL_WINDOWEVENT_SHOWN:
            type = WindowEvent.Event.show;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_HIDDEN:
            type = WindowEvent.Event.hide;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_EXPOSED:
            type = WindowEvent.Event.expose;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_ENTER:
            type = WindowEvent.Event.enter;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE:
            type = WindowEvent.Event.close;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_GAINED:
            type = WindowEvent.Event.focusIn;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_LEAVE:
            type = WindowEvent.Event.leave;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_FOCUS_LOST:
            type = WindowEvent.Event.focusOut;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MINIMIZED:
            type = WindowEvent.Event.minimize;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MAXIMIZED:
            type = WindowEvent.Event.maximize;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_MOVED:
            type = WindowEvent.Event.move;
            x = event.window.data1;
            y = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_RESIZED:
            type = WindowEvent.Event.resize;
            width = event.window.data1;
            height = event.window.data2;
            break;
        case SDL_WindowEventID.SDL_WINDOWEVENT_RESTORED:
            type = WindowEvent.Event.restore;
            break;
        default:
            break;
        }

        auto windowEvent = WindowEvent(type, event.window.windowID, width, height, x, y);
        onWindow(windowEvent);
    }
}
