module deltotum.kit.events.kit_event_type;

import deltotum.core.events.core_event_type : CoreEventType;

/**
 * Authors: initkfs
 */
enum KitEventType
{
    action = CoreEventType.max + 1,
    pointer,
    key,
    window,
    joystick,
    focus
}
