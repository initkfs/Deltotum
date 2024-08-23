module api.dm.kit.utils.state_manager;

import std.container.util: make;
import std.container.dlist : DList;
import std.typecons : Nullable;

alias NumericStateManager = StateManager!int;
alias StringStateManager = StateManager!string;

/**
 * Authors: initkfs
 */
class StateManager(T)
{
    protected
    {
        DList!T states;
    }

    this() nothrow @safe
    {
        states = make!(DList!T)();
    }

    Nullable!T state() nothrow pure @safe
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

    bool isEmpty() const nothrow pure @safe
    {
        return states.empty;
    }

    size_t length() nothrow pure @safe {
        import std.range : walkLength;
        return states[].walkLength;
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

unittest {
    auto fsm = new StateManager!string;
    assert(fsm.isEmpty);
    assert(fsm.state.isNull);
    assert(fsm.length == 0);
    
    enum state1 = "state1";
    assert(fsm.push(state1));
    assert(!fsm.isEmpty);
    assert(fsm.length == 1);

    enum state2 = "state2";
    assert(fsm.push(state2));
    assert(fsm.length == 2);

    immutable lastState = fsm.state;
    assert(!lastState.isNull);
    assert(lastState.get == state2);

    assert(fsm.pop);
    assert(fsm.length == 1);
    assert(fsm.state.get == state1);

    assert(fsm.pop);
    assert(fsm.isEmpty);
    assert(fsm.length == 0);
}
