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

    void setState(State state)
    {
        _currentState = state;
    }

    void update(double delta)
    {
        _currentState.update(delta);
    }

    void destroy()
    {
        if (_currentState !is null)
        {
            _currentState.destroy;
        }
    }
}
