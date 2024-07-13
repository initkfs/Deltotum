module core.events.bus.event_bus;

import std.variant : Variant;

/**
 * Authors: initkfs
 */
class EventBus
{
    bool enabled;

    protected
    {
        void delegate(Variant)[][string] delegateMap;
    }

    bool fire(P)(lazy string eventName, lazy P payload) if (!is(P : Variant))
    {
        return fire(eventName, Variant(payload));
    }

    bool fire(lazy string eventName, lazy Variant payload)
    {
        if (!enabled)
        {
            return false;
        }

        if (auto dgListPtr = eventName in delegateMap)
        {
            foreach (dg; *dgListPtr)
            {
                dg(payload);
            }
        }

        return true;
    }

    void subscribe(string eventName, void delegate(Variant) dg)
    {
        //TODO check exists, etc
        if (auto dgListPtr = eventName in delegateMap)
        {
            (*dgListPtr) ~= dg;
        }
        else
        {
            delegateMap[eventName] = [dg];
        }

    }

}
