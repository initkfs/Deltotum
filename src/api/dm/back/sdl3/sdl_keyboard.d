module api.dm.back.sdl3.sdl_keyboard;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.com.inputs.com_keyboard : ComKeyName, ComKeyboard, ComKeyModifier;
import api.dm.back.sdl3.base.sdl_object : SdlObject;
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.com_native_ptr : ComNativePtr;
import api.dm.com.graphics.com_window : ComWindow;

import api.dm.back.sdl3.externs.csdl3;

/**
 * Authors: initkfs
 */
class SdlKeyboard : SdlObject, ComKeyboard
{
    ComResult getKeyModifier(out ComKeyModifier comKeyMod) nothrow
    {
        comKeyMod = keyModToComKeyMod(keyMod);
        return ComResult.success;
    }

    ComKeyModifier keyModifier() nothrow => keyModToComKeyMod(keyMod);

    ComKeyModifier keyModToComKeyMod(SDL_Keymod mod) nothrow
    {
        return ComKeyModifier(
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
    }

    SDL_Keymod keyMod() nothrow => SDL_GetModState();

    void setModState(SDL_Keymod state) nothrow
    {
        SDL_SetModState(state);
    }

    bool hasKeyboard() nothrow => SDL_HasKeyboard();
    bool hasScreenKeyboardSupport() nothrow => SDL_HasScreenKeyboardSupport();

    void reset() nothrow
    {
        SDL_ResetKeyboard();
    }

    bool isScreenBoardShown(SDL_Window* window) nothrow
    {
        return SDL_ScreenKeyboardShown(window);
    }

    SDL_Scancode keyCodeToScanCode(SDL_Keycode key, SDL_Keymod* mods) nothrow
    {
        SDL_Scancode code = SDL_GetScancodeFromKey(key, mods);
        return code;
    }

    ComKeyName scanCodeToKeyName(SDL_Scancode scanCode, SDL_Keymod mods) nothrow
    {
        SDL_Keycode code = SDL_GetKeyFromScancode(scanCode, mods, false);
        return keyCodeToKeyName(code);
    }

    ComKeyName keyCodeToKeyName(SDL_Keycode code) nothrow
    {
        final switch (code)
        {
            case SDLK_UNKNOWN:
                return ComKeyName.key_unknown;
            case SDLK_RETURN:
                return ComKeyName.key_return;
            case SDLK_ESCAPE:
                return ComKeyName.key_escape;
            case SDLK_BACKSPACE:
                return ComKeyName.key_backspace;
            case SDLK_TAB:
                return ComKeyName.key_tab;
            case SDLK_SPACE:
                return ComKeyName.key_space;
            case SDLK_EXCLAIM:
                return ComKeyName.key_exclaim;
            case SDLK_DBLAPOSTROPHE:
                return ComKeyName.key_dblapostrophe;
            case SDLK_HASH:
                return ComKeyName.key_hash;
            case SDLK_DOLLAR:
                return ComKeyName.key_dollar;
            case SDLK_PERCENT:
                return ComKeyName.key_percent;
            case SDLK_AMPERSAND:
                return ComKeyName.key_ampersand;
            case SDLK_APOSTROPHE:
                return ComKeyName.key_apostrophe;
            case SDLK_LEFTPAREN:
                return ComKeyName.key_leftparen;
            case SDLK_RIGHTPAREN:
                return ComKeyName.key_rightparen;
            case SDLK_ASTERISK:
                return ComKeyName.key_asterisk;
            case SDLK_PLUS:
                return ComKeyName.key_plus;
            case SDLK_COMMA:
                return ComKeyName.key_comma;
            case SDLK_MINUS:
                return ComKeyName.key_minus;
            case SDLK_PERIOD:
                return ComKeyName.key_period;
            case SDLK_SLASH:
                return ComKeyName.key_slash;
            case SDLK_0:
                return ComKeyName.key_0;
            case SDLK_1:
                return ComKeyName.key_1;
            case SDLK_2:
                return ComKeyName.key_2;
            case SDLK_3:
                return ComKeyName.key_3;
            case SDLK_4:
                return ComKeyName.key_4;
            case SDLK_5:
                return ComKeyName.key_5;
            case SDLK_6:
                return ComKeyName.key_6;
            case SDLK_7:
                return ComKeyName.key_7;
            case SDLK_8:
                return ComKeyName.key_8;
            case SDLK_9:
                return ComKeyName.key_9;
            case SDLK_COLON:
                return ComKeyName.key_colon;
            case SDLK_SEMICOLON:
                return ComKeyName.key_semicolon;
            case SDLK_LESS:
                return ComKeyName.key_less;
            case SDLK_EQUALS:
                return ComKeyName.key_equals;
            case SDLK_GREATER:
                return ComKeyName.key_greater;
            case SDLK_QUESTION:
                return ComKeyName.key_question;
            case SDLK_AT:
                return ComKeyName.key_at;
            case SDLK_LEFTBRACKET:
                return ComKeyName.key_leftbracket;
            case SDLK_BACKSLASH:
                return ComKeyName.key_backslash;
            case SDLK_RIGHTBRACKET:
                return ComKeyName.key_rightbracket;
            case SDLK_CARET:
                return ComKeyName.key_caret;
            case SDLK_UNDERSCORE:
                return ComKeyName.key_underscore;
            case SDLK_GRAVE:
                return ComKeyName.key_grave;
            case SDLK_A:
                return ComKeyName.key_a;
            case SDLK_B:
                return ComKeyName.key_b;
            case SDLK_C:
                return ComKeyName.key_c;
            case SDLK_D:
                return ComKeyName.key_d;
            case SDLK_E:
                return ComKeyName.key_e;
            case SDLK_F:
                return ComKeyName.key_f;
            case SDLK_G:
                return ComKeyName.key_g;
            case SDLK_H:
                return ComKeyName.key_h;
            case SDLK_I:
                return ComKeyName.key_i;
            case SDLK_J:
                return ComKeyName.key_j;
            case SDLK_K:
                return ComKeyName.key_k;
            case SDLK_L:
                return ComKeyName.key_l;
            case SDLK_M:
                return ComKeyName.key_m;
            case SDLK_N:
                return ComKeyName.key_n;
            case SDLK_O:
                return ComKeyName.key_o;
            case SDLK_P:
                return ComKeyName.key_p;
            case SDLK_Q:
                return ComKeyName.key_q;
            case SDLK_R:
                return ComKeyName.key_r;
            case SDLK_S:
                return ComKeyName.key_s;
            case SDLK_T:
                return ComKeyName.key_t;
            case SDLK_U:
                return ComKeyName.key_u;
            case SDLK_V:
                return ComKeyName.key_v;
            case SDLK_W:
                return ComKeyName.key_w;
            case SDLK_X:
                return ComKeyName.key_x;
            case SDLK_Y:
                return ComKeyName.key_y;
            case SDLK_Z:
                return ComKeyName.key_z;
            case SDLK_LEFTBRACE:
                return ComKeyName.key_leftbrace;
            case SDLK_PIPE:
                return ComKeyName.key_pipe;
            case SDLK_RIGHTBRACE:
                return ComKeyName.key_rightbrace;
            case SDLK_TILDE:
                return ComKeyName.key_tilde;
            case SDLK_DELETE:
                return ComKeyName.key_delete;
            case SDLK_PLUSMINUS:
                return ComKeyName.key_plusminus;
            case SDLK_CAPSLOCK:
                return ComKeyName.key_capslock;
            case SDLK_F1:
                return ComKeyName.key_f1;
            case SDLK_F2:
                return ComKeyName.key_f2;
            case SDLK_F3:
                return ComKeyName.key_f3;
            case SDLK_F4:
                return ComKeyName.key_f4;
            case SDLK_F5:
                return ComKeyName.key_f5;
            case SDLK_F6:
                return ComKeyName.key_f6;
            case SDLK_F7:
                return ComKeyName.key_f7;
            case SDLK_F8:
                return ComKeyName.key_f8;
            case SDLK_F9:
                return ComKeyName.key_f9;
            case SDLK_F10:
                return ComKeyName.key_f10;
            case SDLK_F11:
                return ComKeyName.key_f11;
            case SDLK_F12:
                return ComKeyName.key_f12;
            case SDLK_PRINTSCREEN:
                return ComKeyName.key_printscreen;
            case SDLK_SCROLLLOCK:
                return ComKeyName.key_scrolllock;
            case SDLK_PAUSE:
                return ComKeyName.key_pause;
            case SDLK_INSERT:
                return ComKeyName.key_insert;
            case SDLK_HOME:
                return ComKeyName.key_home;
            case SDLK_PAGEUP:
                return ComKeyName.key_pageup;
            case SDLK_END:
                return ComKeyName.key_end;
            case SDLK_PAGEDOWN:
                return ComKeyName.key_pagedown;
            case SDLK_RIGHT:
                return ComKeyName.key_right;
            case SDLK_LEFT:
                return ComKeyName.key_left;
            case SDLK_DOWN:
                return ComKeyName.key_down;
            case SDLK_UP:
                return ComKeyName.key_up;
            case SDLK_NUMLOCKCLEAR:
                return ComKeyName.key_numlockclear;
            case SDLK_KP_DIVIDE:
                return ComKeyName.key_kp_divide;
            case SDLK_KP_MULTIPLY:
                return ComKeyName.key_kp_multiply;
            case SDLK_KP_MINUS:
                return ComKeyName.key_kp_minus;
            case SDLK_KP_PLUS:
                return ComKeyName.key_kp_plus;
            case SDLK_KP_ENTER:
                return ComKeyName.key_kp_enter;
            case SDLK_KP_1:
                return ComKeyName.key_kp_1;
            case SDLK_KP_2:
                return ComKeyName.key_kp_2;
            case SDLK_KP_3:
                return ComKeyName.key_kp_3;
            case SDLK_KP_4:
                return ComKeyName.key_kp_4;
            case SDLK_KP_5:
                return ComKeyName.key_kp_5;
            case SDLK_KP_6:
                return ComKeyName.key_kp_6;
            case SDLK_KP_7:
                return ComKeyName.key_kp_7;
            case SDLK_KP_8:
                return ComKeyName.key_kp_8;
            case SDLK_KP_9:
                return ComKeyName.key_kp_9;
            case SDLK_KP_0:
                return ComKeyName.key_kp_0;
            case SDLK_KP_PERIOD:
                return ComKeyName.key_kp_period;
            case SDLK_APPLICATION:
                return ComKeyName.key_application;
            case SDLK_POWER:
                return ComKeyName.key_power;
            case SDLK_KP_EQUALS:
                return ComKeyName.key_kp_equals;
            case SDLK_F13:
                return ComKeyName.key_f13;
            case SDLK_F14:
                return ComKeyName.key_f14;
            case SDLK_F15:
                return ComKeyName.key_f15;
            case SDLK_F16:
                return ComKeyName.key_f16;
            case SDLK_F17:
                return ComKeyName.key_f17;
            case SDLK_F18:
                return ComKeyName.key_f18;
            case SDLK_F19:
                return ComKeyName.key_f19;
            case SDLK_F20:
                return ComKeyName.key_f20;
            case SDLK_F21:
                return ComKeyName.key_f21;
            case SDLK_F22:
                return ComKeyName.key_f22;
            case SDLK_F23:
                return ComKeyName.key_f23;
            case SDLK_F24:
                return ComKeyName.key_f24;
            case SDLK_EXECUTE:
                return ComKeyName.key_execute;
            case SDLK_HELP:
                return ComKeyName.key_help;
            case SDLK_MENU:
                return ComKeyName.key_menu;
            case SDLK_SELECT:
                return ComKeyName.key_select;
            case SDLK_STOP:
                return ComKeyName.key_stop;
            case SDLK_AGAIN:
                return ComKeyName.key_again;
            case SDLK_UNDO:
                return ComKeyName.key_undo;
            case SDLK_CUT:
                return ComKeyName.key_cut;
            case SDLK_COPY:
                return ComKeyName.key_copy;
            case SDLK_PASTE:
                return ComKeyName.key_paste;
            case SDLK_FIND:
                return ComKeyName.key_find;
            case SDLK_MUTE:
                return ComKeyName.key_mute;
            case SDLK_VOLUMEUP:
                return ComKeyName.key_volumeup;
            case SDLK_VOLUMEDOWN:
                return ComKeyName.key_volumedown;
            case SDLK_KP_COMMA:
                return ComKeyName.key_kp_comma;
            case SDLK_KP_EQUALSAS400:
                return ComKeyName.key_kp_equalsas400;
            case SDLK_ALTERASE:
                return ComKeyName.key_alterase;
            case SDLK_SYSREQ:
                return ComKeyName.key_sysreq;
            case SDLK_CANCEL:
                return ComKeyName.key_cancel;
            case SDLK_CLEAR:
                return ComKeyName.key_clear;
            case SDLK_PRIOR:
                return ComKeyName.key_prior;
            case SDLK_RETURN2:
                return ComKeyName.key_return2;
            case SDLK_SEPARATOR:
                return ComKeyName.key_separator;
            case SDLK_OUT:
                return ComKeyName.key_out;
            case SDLK_OPER:
                return ComKeyName.key_oper;
            case SDLK_CLEARAGAIN:
                return ComKeyName.key_clearagain;
            case SDLK_CRSEL:
                return ComKeyName.key_crsel;
            case SDLK_EXSEL:
                return ComKeyName.key_exsel;
            case SDLK_KP_00:
                return ComKeyName.key_kp_00;
            case SDLK_KP_000:
                return ComKeyName.key_kp_000;
            case SDLK_THOUSANDSSEPARATOR:
                return ComKeyName.key_thousandsseparator;
            case SDLK_DECIMALSEPARATOR:
                return ComKeyName.key_decimalseparator;
            case SDLK_CURRENCYUNIT:
                return ComKeyName.key_currencyunit;
            case SDLK_CURRENCYSUBUNIT:
                return ComKeyName.key_currencysubunit;
            case SDLK_KP_LEFTPAREN:
                return ComKeyName.key_kp_leftparen;
            case SDLK_KP_RIGHTPAREN:
                return ComKeyName.key_kp_rightparen;
            case SDLK_KP_LEFTBRACE:
                return ComKeyName.key_kp_leftbrace;
            case SDLK_KP_RIGHTBRACE:
                return ComKeyName.key_kp_rightbrace;
            case SDLK_KP_TAB:
                return ComKeyName.key_kp_tab;
            case SDLK_KP_BACKSPACE:
                return ComKeyName.key_kp_backspace;
            case SDLK_KP_A:
                return ComKeyName.key_kp_a;
            case SDLK_KP_B:
                return ComKeyName.key_kp_b;
            case SDLK_KP_C:
                return ComKeyName.key_kp_c;
            case SDLK_KP_D:
                return ComKeyName.key_kp_d;
            case SDLK_KP_E:
                return ComKeyName.key_kp_e;
            case SDLK_KP_F:
                return ComKeyName.key_kp_f;
            case SDLK_KP_XOR:
                return ComKeyName.key_kp_xor;
            case SDLK_KP_POWER:
                return ComKeyName.key_kp_power;
            case SDLK_KP_PERCENT:
                return ComKeyName.key_kp_percent;
            case SDLK_KP_LESS:
                return ComKeyName.key_kp_less;
            case SDLK_KP_GREATER:
                return ComKeyName.key_kp_greater;
            case SDLK_KP_AMPERSAND:
                return ComKeyName.key_kp_ampersand;
            case SDLK_KP_DBLAMPERSAND:
                return ComKeyName.key_kp_dblampersand;
            case SDLK_KP_VERTICALBAR:
                return ComKeyName.key_kp_verticalbar;
            case SDLK_KP_DBLVERTICALBAR:
                return ComKeyName.key_kp_dblverticalbar;
            case SDLK_KP_COLON:
                return ComKeyName.key_kp_colon;
            case SDLK_KP_HASH:
                return ComKeyName.key_kp_hash;
            case SDLK_KP_SPACE:
                return ComKeyName.key_kp_space;
            case SDLK_KP_AT:
                return ComKeyName.key_kp_at;
            case SDLK_KP_EXCLAM:
                return ComKeyName.key_kp_exclam;
            case SDLK_KP_MEMSTORE:
                return ComKeyName.key_kp_memstore;
            case SDLK_KP_MEMRECALL:
                return ComKeyName.key_kp_memrecall;
            case SDLK_KP_MEMCLEAR:
                return ComKeyName.key_kp_memclear;
            case SDLK_KP_MEMADD:
                return ComKeyName.key_kp_memadd;
            case SDLK_KP_MEMSUBTRACT:
                return ComKeyName.key_kp_memsubtract;
            case SDLK_KP_MEMMULTIPLY:
                return ComKeyName.key_kp_memmultiply;
            case SDLK_KP_MEMDIVIDE:
                return ComKeyName.key_kp_memdivide;
            case SDLK_KP_PLUSMINUS:
                return ComKeyName.key_kp_plusminus;
            case SDLK_KP_CLEAR:
                return ComKeyName.key_kp_clear;
            case SDLK_KP_CLEARENTRY:
                return ComKeyName.key_kp_clearentry;
            case SDLK_KP_BINARY:
                return ComKeyName.key_kp_binary;
            case SDLK_KP_OCTAL:
                return ComKeyName.key_kp_octal;
            case SDLK_KP_DECIMAL:
                return ComKeyName.key_kp_decimal;
            case SDLK_KP_HEXADECIMAL:
                return ComKeyName.key_kp_hexadecimal;
            case SDLK_LCTRL:
                return ComKeyName.key_lctrl;
            case SDLK_LSHIFT:
                return ComKeyName.key_lshift;
            case SDLK_LALT:
                return ComKeyName.key_lalt;
            case SDLK_LGUI:
                return ComKeyName.key_lgui;
            case SDLK_RCTRL:
                return ComKeyName.key_rctrl;
            case SDLK_RSHIFT:
                return ComKeyName.key_rshift;
            case SDLK_RALT:
                return ComKeyName.key_ralt;
            case SDLK_RGUI:
                return ComKeyName.key_rgui;
            case SDLK_MODE:
                return ComKeyName.key_mode;
            case SDLK_SLEEP:
                return ComKeyName.key_sleep;
            case SDLK_WAKE:
                return ComKeyName.key_wake;
            case SDLK_CHANNEL_INCREMENT:
                return ComKeyName.key_channel_increment;
            case SDLK_CHANNEL_DECREMENT:
                return ComKeyName.key_channel_decrement;
            case SDLK_MEDIA_PLAY:
                return ComKeyName.key_media_play;
            case SDLK_MEDIA_PAUSE:
                return ComKeyName.key_media_pause;
            case SDLK_MEDIA_RECORD:
                return ComKeyName.key_media_record;
            case SDLK_MEDIA_FAST_FORWARD:
                return ComKeyName.key_media_fast_forward;
            case SDLK_MEDIA_REWIND:
                return ComKeyName.key_media_rewind;
            case SDLK_MEDIA_NEXT_TRACK:
                return ComKeyName.key_media_next_track;
            case SDLK_MEDIA_PREVIOUS_TRACK:
                return ComKeyName.key_media_previous_track;
            case SDLK_MEDIA_STOP:
                return ComKeyName.key_media_stop;
            case SDLK_MEDIA_EJECT:
                return ComKeyName.key_media_eject;
            case SDLK_MEDIA_PLAY_PAUSE:
                return ComKeyName.key_media_play_pause;
            case SDLK_MEDIA_SELECT:
                return ComKeyName.key_media_select;
            case SDLK_AC_NEW:
                return ComKeyName.key_ac_new;
            case SDLK_AC_OPEN:
                return ComKeyName.key_ac_open;
            case SDLK_AC_CLOSE:
                return ComKeyName.key_ac_close;
            case SDLK_AC_EXIT:
                return ComKeyName.key_ac_exit;
            case SDLK_AC_SAVE:
                return ComKeyName.key_ac_save;
            case SDLK_AC_PRINT:
                return ComKeyName.key_ac_print;
            case SDLK_AC_PROPERTIES:
                return ComKeyName.key_ac_properties;
            case SDLK_AC_SEARCH:
                return ComKeyName.key_ac_search;
            case SDLK_AC_HOME:
                return ComKeyName.key_ac_home;
            case SDLK_AC_BACK:
                return ComKeyName.key_ac_back;
            case SDLK_AC_FORWARD:
                return ComKeyName.key_ac_forward;
            case SDLK_AC_STOP:
                return ComKeyName.key_ac_stop;
            case SDLK_AC_REFRESH:
                return ComKeyName.key_ac_refresh;
            case SDLK_AC_BOOKMARKS:
                return ComKeyName.key_ac_bookmarks;
            case SDLK_SOFTLEFT:
                return ComKeyName.key_softleft;
            case SDLK_SOFTRIGHT:
                return ComKeyName.key_softright;
            case SDLK_CALL:
                return ComKeyName.key_call;
            case SDLK_ENDCALL:
                return ComKeyName.key_endcall;
            case SDLK_LEFT_TAB:
                return ComKeyName.key_left_tab;
            case SDLK_LEVEL5_SHIFT:
                return ComKeyName.key_level5_shift;
            case SDLK_MULTI_KEY_COMPOSE:
                return ComKeyName.key_multi_key_compose;
            case SDLK_LMETA:
                return ComKeyName.key_lmeta;
            case SDLK_RMETA:
                return ComKeyName.key_rmeta;
            case SDLK_LHYPER:
                return ComKeyName.key_lhyper;
            case SDLK_RHYPER:
                return ComKeyName.key_rhyper;
        }
    }
}
