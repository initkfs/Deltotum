module api.dm.kit.inputs.keyboards.events.key_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.dm.com.inputs.com_keyboard : ComKeyModifier;

/**
 * Authors: initkfs
 */
struct KeyEvent
{
    mixin EventBase;

    enum Event
    {
        none,
        press,
        release
    }

    Event event;

    ComKeyName keyName;
    ComKeyModifier keyMod;
    int keyCode;
    int scanCode;

    this(Event event, int ownerId, ComKeyName keyName, ComKeyModifier keyModInfo, int keyCode, int scanCode)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.keyName = keyName;
        this.keyMod = keyModInfo;
        this.keyCode = keyCode;
        this.scanCode = scanCode;
    }
}
