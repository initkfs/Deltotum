module deltotum.ai.fsm.fsm;

import std.container.dlist : DList;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
class Fsm(T)
{
    protected
    {
        DList!T states;
    }

    this() nothrow pure @safe
    {
        states = DList!T();
    }

    Nullable!T state() @nogc nothrow pure @safe
    {
        Nullable!T last;
        if (isEmpty)
        {
            return last;
        }

        last = states.back;
        return last;
    }

    bool push(T state) pure @safe
    {
        import std.traits : isPointer, isAssociativeArray;

        //other?
        static if (__traits(compiles, state !is null))
        {
            import std.exception : enforce;
            import std.format : format;

            enforce(state !is null, format("State of type %s must not be null", typeof(state)
                    .stringof));
        }

        const isInsert = states.insertBack(state);
        return isInsert == 1;
    }

    bool isEmpty() const @nogc nothrow pure @safe
    {
        return states.empty;
    }

    bool clear() nothrow pure @safe
    {
        if (isEmpty)
        {
            return false;
        }
        states.clear;
        return true;
    }

    bool pop() nothrow pure @safe
    {
        if (isEmpty)
        {
            return false;
        }
        states.removeBack;
        return true;
    }
}
