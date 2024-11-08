module api.dm.kit.inputs.keyboards.events.key_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.dm.com.inputs.com_keyboard : KeyModifierInfo;

/**
 * Authors: initkfs
 */
struct KeyEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        keyDown,
        keyUp
    }

    Event event;

    ComKeyName keyName;
    KeyModifierInfo keyMod;
    int keyCode;

    this(Event event, int ownerId, ComKeyName keyName, KeyModifierInfo keyModInfo, int keyCode)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.keyName = keyName;
        this.keyMod = keyModInfo;
        this.keyCode = keyCode;
    }
}
