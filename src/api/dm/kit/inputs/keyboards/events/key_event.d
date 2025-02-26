module api.dm.kit.inputs.keyboards.events.key_event;

import api.core.events.base.event_base : EventBase;
import api.core.utils.types : enumNameByIndex;

import api.dm.com.inputs.com_keyboard : ComKeyName;
import api.dm.com.inputs.com_keyboard : KeyModifier;

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
    KeyModifier keyMod;
    int keyCode;

    this(Event event, int ownerId, ComKeyName keyName, KeyModifier keyModInfo, int keyCode)
    {
        this.event = event;
        this.ownerId = ownerId;
        this.keyName = keyName;
        this.keyMod = keyModInfo;
        this.keyCode = keyCode;
    }
}
