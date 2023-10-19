module deltotum.kit.inputs.keyboards.events.key_event;

import deltotum.core.events.event_base : EventBase;
import deltotum.kit.events.kit_event_type: KitEventType;
import deltotum.core.utils.type_util : enumNameByIndex;

import deltotum.com.inputs.keyboards.key_name : KeyName;
import deltotum.com.inputs.keyboards.key_modifier_info : KeyModifierInfo;

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

    this(int event, int ownerId, KeyName keyName, KeyModifierInfo keyModInfo, int keyCode)
    {
        this.type = KitEventType.key;
        this.event = event;
        this.ownerId = ownerId;
        this.keyName = keyName;
        this.keyMod = keyModInfo;
        this.keyCode = keyCode;
    }
}
