module api.core.utils.container_result;

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
        failread = "failread",
        failwrite = "failwrite",

        locked = "locked",
        empty = "empty",
        full = "full",

        noitems = "noitems",
        nofilled = "nofilled",
        noenoughspace = "not enough space",

        dataoverwriting = "data overwriting",
    }

    alias isSuccess this;

    const pure  nothrow @safe
    {
        bool isFail() => !isSuccess;
        bool isFailRead() => state == State.failread;
        bool isFailWrite() => state == State.failwrite;

        bool isLocked() => state == State.locked;
        bool isEmpty() => state == State.empty;
        bool isFull() => state == State.full;

        bool isNoItems() => state == State.noitems;
        bool isNoFilled() => state == State.nofilled;
        bool isNoSpace() => state == State.noenoughspace;

        bool isDataOverwriting() => state == State.dataoverwriting;

        string toString() => state;
    }

    static pure  nothrow @safe
    {
        ContainerResult success() => ContainerResult(State.success, true);

        ContainerResult fail() => ContainerResult(State.fail);
        ContainerResult failread() => ContainerResult(State.failread);
        ContainerResult failwrite() => ContainerResult(State.failwrite);

        ContainerResult locked() => ContainerResult(State.locked);
        ContainerResult empty() => ContainerResult(State.empty);
        ContainerResult full() => ContainerResult(State.full);

        ContainerResult noitems() => ContainerResult(State.noitems);
        ContainerResult nofilled() => ContainerResult(State.nofilled);
        ContainerResult noenoughspace() => ContainerResult(State.noenoughspace);

        ContainerResult dataoverwriting() => ContainerResult(State.dataoverwriting);
    }
}
