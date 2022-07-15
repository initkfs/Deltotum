module deltotum.state.state;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.display_object : DisplayObject;

import std.stdio;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class State : UniComponent
{
    @property void delegate(State) onStateChange;

    @property size_t timeEventProcessing;
    @property double timeRate = 0;
    @property size_t timeUpdate;

    protected
    {
        DisplayObject[] displayObjects = [];
    }

    void create()
    {
    }

    void update(double delta)
    {
        window.renderer.clear;

        foreach (obj; displayObjects)
        {
            obj.update(delta);
            obj.draw;
        }

        window.renderer.present;
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
