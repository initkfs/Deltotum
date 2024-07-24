module app.dm.kit.inputs.keyboards.events.key_event;

import app.core.events.event_base : EventBase;
import app.core.utils.types : enumNameByIndex;

import app.dm.com.inputs.com_keyboard : ComKeyName;
import app.dm.com.inputs.com_keyboard : KeyModifierInfo;

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
