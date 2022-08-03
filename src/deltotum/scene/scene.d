module deltotum.scene.scene;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.display_object : DisplayObject;
import deltotum.graphics.colors.color : Color;

import std.stdio;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Scene : UniComponent
{
    @property void delegate(Scene) onSceneChange;

    @property size_t timeEventProcessing;
    @property double timeRate = 0;
    @property size_t timeUpdate;
    @property bool isClearingInCycle = true;

    protected
    {
        DisplayObject[] displayObjects = [];
    }

    void create()
    {
    }

    void update(double delta)
    {
        if (isClearingInCycle)
        {
            const screenColor = Color.black;
            window.renderer.setRenderDrawColor(screenColor.r, screenColor.g, screenColor.b, screenColor
                    .alphaNorm);
            window.renderer.clear;
        }

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

    void addCreated(DisplayObject obj){
        build(obj);
        obj.create;
        add(obj);
    }

    void add(DisplayObject object)
    {
        //TODO check if exists
        displayObjects ~= object;
    }

    void changeScene(Scene other)
    {
        if (onSceneChange !is null)
        {
            onSceneChange(other);
        }
    }

    DisplayObject[] getActiveObjects()
    {
        return displayObjects;
    }

}
