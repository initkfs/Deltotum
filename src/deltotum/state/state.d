module deltotum.state.state;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.display_object : DisplayObject;

import std.stdio;

/**
 * Authors: initkfs
 */
class State : UniComponent
{
    @property void delegate(State) onStateChange;

    protected
    {
        DisplayObject[] displayObjects = [];
    }

    void create()
    {

    }

    void update(double delta)
    {
        foreach (obj; displayObjects)
        {
            obj.update(delta);
        }
    }

    void destroy()
    {
        foreach (obj; displayObjects)
        {
            obj.destroy;
        }
        displayObjects = [];
    }

    void add(DisplayObject object)
    {
        //TODO check if exists
        displayObjects ~= object;
    }

    void changeState(State other)
    {
        if (onStateChange !is null)
        {
            onStateChange(other);
        }
    }

    DisplayObject[] getActiveObjects()
    {
        return displayObjects;
    }

}
