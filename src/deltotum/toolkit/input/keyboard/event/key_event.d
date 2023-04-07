module deltotum.toolkit.input.keyboard.event.key_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.core.events.event_type : EventType;
import deltotum.core.utils.type_util : eventNameByIndex;

import deltotum.platform.commons.keyboards.key_name : KeyName;
import deltotum.platform.commons.keyboards.key_modifier_info : KeyModifierInfo;

/**
 * Authors: initkfs
 */
struct KeyEvent
{
    mixin EventBase;

    static enum Event
    {
        none,
        keyDown,
        keyUp
    }

    KeyName keyName;
    KeyModifierInfo keyMod;
    int keyCode;

    this(EventType type, uint event, uint ownerId, KeyName keyName, KeyModifierInfo keyModInfo, int keyCode)
    {
        this.type = type;
        this.event = event;
        this.ownerId = ownerId;
        this.keyName = keyName;
        this.keyMod = keyModInfo;
        this.keyCode = keyCode;
    }

    string toString()
    {
        import std.format : format;

        return format("{%s,%s,key:%s,mod:%s,code:%s,winid:%s}", type, eventNameByIndex!Event(event), keyName, keyMod, keyCode, ownerId);
    }
}
