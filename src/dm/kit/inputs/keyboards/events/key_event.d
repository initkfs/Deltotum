module dm.kit.inputs.keyboards.events.key_event;

import dm.core.events.event_base : EventBase;
import dm.kit.events.kit_event_type: KitEventType;
import dm.core.utils.type_util : enumNameByIndex;

import dm.com.inputs.keyboards.key_name : KeyName;
import dm.com.inputs.keyboards.key_modifier_info : KeyModifierInfo;

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
