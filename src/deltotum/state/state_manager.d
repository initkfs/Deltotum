module deltotum.state.state_manager;

import deltotum.state.state : State;

import std.stdio;

/**
 * Authors: initkfs
 */
class StateManager
{
    //TODO stack
    @property State _currentState;

    void update(double delta)
    {
        if (_currentState is null)
        {
            return;
        }
        _currentState.update(delta);
    }

    void destroy()
    {
        if (_currentState !is null)
        {
            _currentState.destroy;
        }
    }

    @property State currentState() @nogc @safe pure nothrow
    out (_currentState; _currentState !is null)
    {
        return _currentState;
    }

    @property void currentState(State state) @safe pure
    {
        import std.exception : enforce;

        enforce(state !is null, "State must not be null");
        _currentState = state;
    }
}
