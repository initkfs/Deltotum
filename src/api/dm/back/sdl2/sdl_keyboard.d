module api.dm.back.sdl2.sdl_keyboard;

// dfmt off
version(SdlBackend):
// dfmt on

import api.dm.back.sdl2.base.sdl_object : SdlObject;
import api.dm.com.inputs.com_keyboard : ComKeyName;

import bindbc.sdl;

/**
 * Authors: initkfs
 */
class SdlKeyboard : SdlObject
{
    ComKeyName keyCodeToKeyName(SDL_Keycode code)
    {
        //Generated automatically
        //final switch
        switch (code) with (SDL_Keycode)
        {
        case SDLK_UNKNOWN:
            return ComKeyName.UNKNOWN;
        case SDLK_RETURN:
            return ComKeyName.RETURN;
        case SDLK_ESCAPE:
            return ComKeyName.ESCAPE;
        case SDLK_BACKSPACE:
            return ComKeyName.BACKSPACE;
        case SDLK_TAB:
            return ComKeyName.TAB;
        case SDLK_SPACE:
            return ComKeyName.SPACE;
        case SDLK_EXCLAIM:
            return ComKeyName.EXCLAIM;
        case SDLK_QUOTEDBL:
            return ComKeyName.QUOTEDBL;
        case SDLK_HASH:
            return ComKeyName.HASH;
        case SDLK_PERCENT:
            return ComKeyName.PERCENT;
        case SDLK_DOLLAR:
            return ComKeyName.DOLLAR;
        case SDLK_AMPERSAND:
            return ComKeyName.AMPERSAND;
        case SDLK_QUOTE:
            return ComKeyName.QUOTE;
        case SDLK_LEFTPAREN:
            return ComKeyName.LEFTPAREN;
        case SDLK_RIGHTPAREN:
            return ComKeyName.RIGHTPAREN;
        case SDLK_ASTERISK:
            return ComKeyName.ASTERISK;
        case SDLK_PLUS:
            return ComKeyName.PLUS;
        case SDLK_COMMA:
            return ComKeyName.COMMA;
        case SDLK_MINUS:
            return ComKeyName.MINUS;
        case SDLK_PERIOD:
            return ComKeyName.PERIOD;
        case SDLK_SLASH:
            return ComKeyName.SLASH;
        case SDLK_0:
            return ComKeyName.num0;
        case SDLK_1:
            return ComKeyName.num1;
        case SDLK_2:
            return ComKeyName.num2;
        case SDLK_3:
            return ComKeyName.num3;
        case SDLK_4:
            return ComKeyName.num4;
        case SDLK_5:
            return ComKeyName.num5;
        case SDLK_6:
            return ComKeyName.num6;
        case SDLK_7:
            return ComKeyName.num7;
        case SDLK_8:
            return ComKeyName.num8;
        case SDLK_9:
            return ComKeyName.num9;
        case SDLK_COLON:
            return ComKeyName.COLON;
        case SDLK_SEMICOLON:
            return ComKeyName.SEMICOLON;
        case SDLK_LESS:
            return ComKeyName.LESS;
        case SDLK_EQUALS:
            return ComKeyName.EQUALS;
        case SDLK_GREATER:
            return ComKeyName.GREATER;
        case SDLK_QUESTION:
            return ComKeyName.QUESTION;
        case SDLK_AT:
            return ComKeyName.AT;
        case SDLK_LEFTBRACKET:
            return ComKeyName.LEFTBRACKET;
        case SDLK_BACKSLASH:
            return ComKeyName.BACKSLASH;
        case SDLK_RIGHTBRACKET:
            return ComKeyName.RIGHTBRACKET;
        case SDLK_CARET:
            return ComKeyName.CARET;
        case SDLK_UNDERSCORE:
            return ComKeyName.UNDERSCORE;
        case SDLK_BACKQUOTE:
            return ComKeyName.BACKQUOTE;
        case SDLK_a:
            return ComKeyName.a;
        case SDLK_b:
            return ComKeyName.b;
        case SDLK_c:
            return ComKeyName.c;
        case SDLK_d:
            return ComKeyName.d;
        case SDLK_e:
            return ComKeyName.e;
        case SDLK_f:
            return ComKeyName.f;
        case SDLK_g:
            return ComKeyName.g;
        case SDLK_h:
            return ComKeyName.h;
        case SDLK_i:
            return ComKeyName.i;
        case SDLK_j:
            return ComKeyName.j;
        case SDLK_k:
            return ComKeyName.k;
        case SDLK_l:
            return ComKeyName.l;
        case SDLK_m:
            return ComKeyName.m;
        case SDLK_n:
            return ComKeyName.n;
        case SDLK_o:
            return ComKeyName.o;
        case SDLK_p:
            return ComKeyName.p;
        case SDLK_q:
            return ComKeyName.q;
        case SDLK_r:
            return ComKeyName.r;
        case SDLK_s:
            return ComKeyName.s;
        case SDLK_t:
            return ComKeyName.t;
        case SDLK_u:
            return ComKeyName.u;
        case SDLK_v:
            return ComKeyName.v;
        case SDLK_w:
            return ComKeyName.w;
        case SDLK_x:
            return ComKeyName.x;
        case SDLK_y:
            return ComKeyName.y;
        case SDLK_z:
            return ComKeyName.z;
        case SDLK_CAPSLOCK:
            return ComKeyName.CAPSLOCK;
        case SDLK_F1:
            return ComKeyName.F1;
        case SDLK_F2:
            return ComKeyName.F2;
        case SDLK_F3:
            return ComKeyName.F3;
        case SDLK_F4:
            return ComKeyName.F4;
        case SDLK_F5:
            return ComKeyName.F5;
        case SDLK_F6:
            return ComKeyName.F6;
        case SDLK_F7:
            return ComKeyName.F7;
        case SDLK_F8:
            return ComKeyName.F8;
        case SDLK_F9:
            return ComKeyName.F9;
        case SDLK_F10:
            return ComKeyName.F10;
        case SDLK_F11:
            return ComKeyName.F11;
        case SDLK_F12:
            return ComKeyName.F12;
        case SDLK_PRINTSCREEN:
            return ComKeyName.PRINTSCREEN;
        case SDLK_SCROLLLOCK:
            return ComKeyName.SCROLLLOCK;
        case SDLK_PAUSE:
            return ComKeyName.PAUSE;
        case SDLK_INSERT:
            return ComKeyName.INSERT;
        case SDLK_HOME:
            return ComKeyName.HOME;
        case SDLK_PAGEUP:
            return ComKeyName.PAGEUP;
        case SDLK_DELETE:
            return ComKeyName.DELETE;
        case SDLK_END:
            return ComKeyName.END;
        case SDLK_PAGEDOWN:
            return ComKeyName.PAGEDOWN;
        case SDLK_RIGHT:
            return ComKeyName.RIGHT;
        case SDLK_LEFT:
            return ComKeyName.LEFT;
        case SDLK_DOWN:
            return ComKeyName.DOWN;
        case SDLK_UP:
            return ComKeyName.UP;
        case SDLK_NUMLOCKCLEAR:
            return ComKeyName.NUMLOCKCLEAR;
        case SDLK_KP_DIVIDE:
            return ComKeyName.KP_DIVIDE;
        case SDLK_KP_MULTIPLY:
            return ComKeyName.KP_MULTIPLY;
        case SDLK_KP_MINUS:
            return ComKeyName.KP_MINUS;
        case SDLK_KP_PLUS:
            return ComKeyName.KP_PLUS;
        case SDLK_KP_ENTER:
            return ComKeyName.KP_ENTER;
        case SDLK_KP_1:
            return ComKeyName.KP_1;
        case SDLK_KP_2:
            return ComKeyName.KP_2;
        case SDLK_KP_3:
            return ComKeyName.KP_3;
        case SDLK_KP_4:
            return ComKeyName.KP_4;
        case SDLK_KP_5:
            return ComKeyName.KP_5;
        case SDLK_KP_6:
            return ComKeyName.KP_6;
        case SDLK_KP_7:
            return ComKeyName.KP_7;
        case SDLK_KP_8:
            return ComKeyName.KP_8;
        case SDLK_KP_9:
            return ComKeyName.KP_9;
        case SDLK_KP_0:
            return ComKeyName.KP_0;
        case SDLK_KP_PERIOD:
            return ComKeyName.KP_PERIOD;
        case SDLK_APPLICATION:
            return ComKeyName.APPLICATION;
        case SDLK_POWER:
            return ComKeyName.POWER;
        case SDLK_KP_EQUALS:
            return ComKeyName.KP_EQUALS;
        case SDLK_F13:
            return ComKeyName.F13;
        case SDLK_F14:
            return ComKeyName.F14;
        case SDLK_F15:
            return ComKeyName.F15;
        case SDLK_F16:
            return ComKeyName.F16;
        case SDLK_F17:
            return ComKeyName.F17;
        case SDLK_F18:
            return ComKeyName.F18;
        case SDLK_F19:
            return ComKeyName.F19;
        case SDLK_F20:
            return ComKeyName.F20;
        case SDLK_F21:
            return ComKeyName.F21;
        case SDLK_F22:
            return ComKeyName.F22;
        case SDLK_F23:
            return ComKeyName.F23;
        case SDLK_F24:
            return ComKeyName.F24;
        case SDLK_EXECUTE:
            return ComKeyName.EXECUTE;
        case SDLK_HELP:
            return ComKeyName.HELP;
        case SDLK_MENU:
            return ComKeyName.MENU;
        case SDLK_SELECT:
            return ComKeyName.SELECT;
        case SDLK_STOP:
            return ComKeyName.STOP;
        case SDLK_AGAIN:
            return ComKeyName.AGAIN;
        case SDLK_UNDO:
            return ComKeyName.UNDO;
        case SDLK_CUT:
            return ComKeyName.CUT;
        case SDLK_COPY:
            return ComKeyName.COPY;
        case SDLK_PASTE:
            return ComKeyName.PASTE;
        case SDLK_FIND:
            return ComKeyName.FIND;
        case SDLK_MUTE:
            return ComKeyName.MUTE;
        case SDLK_VOLUMEUP:
            return ComKeyName.VOLUMEUP;
        case SDLK_VOLUMEDOWN:
            return ComKeyName.VOLUMEDOWN;
        case SDLK_KP_COMMA:
            return ComKeyName.KP_COMMA;
        case SDLK_KP_EQUALSAS400:
            return ComKeyName.KP_EQUALSAS400;
        case SDLK_ALTERASE:
            return ComKeyName.ALTERASE;
        case SDLK_SYSREQ:
            return ComKeyName.SYSREQ;
        case SDLK_CANCEL:
            return ComKeyName.CANCEL;
        case SDLK_CLEAR:
            return ComKeyName.CLEAR;
        case SDLK_PRIOR:
            return ComKeyName.PRIOR;
        case SDLK_RETURN2:
            return ComKeyName.RETURN2;
        case SDLK_SEPARATOR:
            return ComKeyName.SEPARATOR;
        case SDLK_OUT:
            return ComKeyName.OUT;
        case SDLK_OPER:
            return ComKeyName.OPER;
        case SDLK_CLEARAGAIN:
            return ComKeyName.CLEARAGAIN;
        case SDLK_CRSEL:
            return ComKeyName.CRSEL;
        case SDLK_EXSEL:
            return ComKeyName.EXSEL;
        case SDLK_KP_00:
            return ComKeyName.KP_00;
        case SDLK_KP_000:
            return ComKeyName.KP_000;
        case SDLK_THOUSANDSSEPARATOR:
            return ComKeyName.THOUSANDSSEPARATOR;
        case SDLK_DECIMALSEPARATOR:
            return ComKeyName.DECIMALSEPARATOR;
        case SDLK_CURRENCYUNIT:
            return ComKeyName.CURRENCYUNIT;
        case SDLK_CURRENCYSUBUNIT:
            return ComKeyName.CURRENCYSUBUNIT;
        case SDLK_KP_LEFTPAREN:
            return ComKeyName.KP_LEFTPAREN;
        case SDLK_KP_RIGHTPAREN:
            return ComKeyName.KP_RIGHTPAREN;
        case SDLK_KP_LEFTBRACE:
            return ComKeyName.KP_LEFTBRACE;
        case SDLK_KP_RIGHTBRACE:
            return ComKeyName.KP_RIGHTBRACE;
        case SDLK_KP_TAB:
            return ComKeyName.KP_TAB;
        case SDLK_KP_BACKSPACE:
            return ComKeyName.KP_BACKSPACE;
        case SDLK_KP_A:
            return ComKeyName.KP_A;
        case SDLK_KP_B:
            return ComKeyName.KP_B;
        case SDLK_KP_C:
            return ComKeyName.KP_C;
        case SDLK_KP_D:
            return ComKeyName.KP_D;
        case SDLK_KP_E:
            return ComKeyName.KP_E;
        case SDLK_KP_F:
            return ComKeyName.KP_F;
        case SDLK_KP_XOR:
            return ComKeyName.KP_XOR;
        case SDLK_KP_POWER:
            return ComKeyName.KP_POWER;
        case SDLK_KP_PERCENT:
            return ComKeyName.KP_PERCENT;
        case SDLK_KP_LESS:
            return ComKeyName.KP_LESS;
        case SDLK_KP_GREATER:
            return ComKeyName.KP_GREATER;
        case SDLK_KP_AMPERSAND:
            return ComKeyName.KP_AMPERSAND;
        case SDLK_KP_DBLAMPERSAND:
            return ComKeyName.KP_DBLAMPERSAND;
        case SDLK_KP_VERTICALBAR:
            return ComKeyName.KP_VERTICALBAR;
        case SDLK_KP_DBLVERTICALBAR:
            return ComKeyName.KP_DBLVERTICALBAR;
        case SDLK_KP_COLON:
            return ComKeyName.KP_COLON;
        case SDLK_KP_HASH:
            return ComKeyName.KP_HASH;
        case SDLK_KP_SPACE:
            return ComKeyName.KP_SPACE;
        case SDLK_KP_AT:
            return ComKeyName.KP_AT;
        case SDLK_KP_EXCLAM:
            return ComKeyName.KP_EXCLAM;
        case SDLK_KP_MEMSTORE:
            return ComKeyName.KP_MEMSTORE;
        case SDLK_KP_MEMRECALL:
            return ComKeyName.KP_MEMRECALL;
        case SDLK_KP_MEMCLEAR:
            return ComKeyName.KP_MEMCLEAR;
        case SDLK_KP_MEMADD:
            return ComKeyName.KP_MEMADD;
        case SDLK_KP_MEMSUBTRACT:
            return ComKeyName.KP_MEMSUBTRACT;
        case SDLK_KP_MEMMULTIPLY:
            return ComKeyName.KP_MEMMULTIPLY;
        case SDLK_KP_MEMDIVIDE:
            return ComKeyName.KP_MEMDIVIDE;
        case SDLK_KP_PLUSMINUS:
            return ComKeyName.KP_PLUSMINUS;
        case SDLK_KP_CLEAR:
            return ComKeyName.KP_CLEAR;
        case SDLK_KP_CLEARENTRY:
            return ComKeyName.KP_CLEARENTRY;
        case SDLK_KP_BINARY:
            return ComKeyName.KP_BINARY;
        case SDLK_KP_OCTAL:
            return ComKeyName.KP_OCTAL;
        case SDLK_KP_DECIMAL:
            return ComKeyName.KP_DECIMAL;
        case SDLK_KP_HEXADECIMAL:
            return ComKeyName.KP_HEXADECIMAL;
        case SDLK_LCTRL:
            return ComKeyName.LCTRL;
        case SDLK_LSHIFT:
            return ComKeyName.LSHIFT;
        case SDLK_LALT:
            return ComKeyName.LALT;
        case SDLK_LGUI:
            return ComKeyName.LGUI;
        case SDLK_RCTRL:
            return ComKeyName.RCTRL;
        case SDLK_RSHIFT:
            return ComKeyName.RSHIFT;
        case SDLK_RALT:
            return ComKeyName.RALT;
        case SDLK_RGUI:
            return ComKeyName.RGUI;
        case SDLK_MODE:
            return ComKeyName.MODE;
        case SDLK_AUDIONEXT:
            return ComKeyName.AUDIONEXT;
        case SDLK_AUDIOPREV:
            return ComKeyName.AUDIOPREV;
        case SDLK_AUDIOSTOP:
            return ComKeyName.AUDIOSTOP;
        case SDLK_AUDIOPLAY:
            return ComKeyName.AUDIOPLAY;
        case SDLK_AUDIOMUTE:
            return ComKeyName.AUDIOMUTE;
        case SDLK_MEDIASELECT:
            return ComKeyName.MEDIASELECT;
        case SDLK_WWW:
            return ComKeyName.WWW;
        case SDLK_MAIL:
            return ComKeyName.MAIL;
        case SDLK_CALCULATOR:
            return ComKeyName.CALCULATOR;
        case SDLK_COMPUTER:
            return ComKeyName.COMPUTER;
        case SDLK_AC_SEARCH:
            return ComKeyName.AC_SEARCH;
        case SDLK_AC_HOME:
            return ComKeyName.AC_HOME;
        case SDLK_AC_BACK:
            return ComKeyName.AC_BACK;
        case SDLK_AC_FORWARD:
            return ComKeyName.AC_FORWARD;
        case SDLK_AC_STOP:
            return ComKeyName.AC_STOP;
        case SDLK_AC_REFRESH:
            return ComKeyName.AC_REFRESH;
        case SDLK_AC_BOOKMARKS:
            return ComKeyName.AC_BOOKMARKS;
        case SDLK_BRIGHTNESSDOWN:
            return ComKeyName.BRIGHTNESSDOWN;
        case SDLK_BRIGHTNESSUP:
            return ComKeyName.BRIGHTNESSUP;
        case SDLK_DISPLAYSWITCH:
            return ComKeyName.DISPLAYSWITCH;
        case SDLK_KBDILLUMTOGGLE:
            return ComKeyName.KBDILLUMTOGGLE;
        case SDLK_KBDILLUMDOWN:
            return ComKeyName.KBDILLUMDOWN;
        case SDLK_KBDILLUMUP:
            return ComKeyName.KBDILLUMUP;
        case SDLK_EJECT:
            return ComKeyName.EJECT;
        case SDLK_SLEEP:
            return ComKeyName.SLEEP;
        default:
            return ComKeyName.EXTENDED;
        }
    }
}