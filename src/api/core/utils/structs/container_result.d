module api.core.utils.structs.container_result;

import core.attribute : mustuse;

/**
 * Authors: initkfs
 */
@mustuse struct ContainerResult
{
    State state;
    bool isSuccess;

    enum State
    {
        nostate = "nostate",

        success = "success",
        fail = "fail",

        locked = "locked",
        empty = "empty",
        full = "full",

        noitems = "noitems",
        nofilled = "nofilled",
    }

    alias isSuccess this;

    const pure @nogc nothrow @safe
    {
        bool isFail() => !isSuccess;
        
        bool isLocked() => state == State.locked;
        bool isEmpty() => state == State.empty;
        bool isFull() => state == State.full;

        bool isNoItems() => state == State.noitems;
        bool isNoFilled() => state == State.nofilled;

        string toString() => state;
    }

    static pure @nogc nothrow @safe
    {
        ContainerResult success() => ContainerResult(State.success, true);
        ContainerResult fail() => ContainerResult(State.fail);

        ContainerResult locked() => ContainerResult(State.locked);
        ContainerResult empty() => ContainerResult(State.empty);
        ContainerResult full() => ContainerResult(State.full);

        ContainerResult noitems() => ContainerResult(State.noitems);
        ContainerResult nofilled() => ContainerResult(State.nofilled);
    }
}
