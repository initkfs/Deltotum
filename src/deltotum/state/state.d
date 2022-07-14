module deltotum.state.state;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.display_object : DisplayObject;

import std.stdio;

import deltotum.display.layer.layer : Layer;

//TODO remove HAL api
import bindbc.sdl;
import deltotum.display.light.light_spot : LightSpot;

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
        Layer[] layers = [];
    }

    void create()
    {
    }

    void update(double delta)
    {
        window.renderer.clear;

        auto renderer = window.renderer.getStruct;

        foreach (obj; displayObjects)
        {
            obj.update(delta);
            obj.draw;
        }

        if (layers.length > 0)
        {
            SDL_Rect gameRect = {0, 0, window.getWidth, window.getHeight};
            foreach (Layer layer; layers)
            {
                SDL_SetRenderTarget(renderer, layer.getStruct);
                layer.drawContent;
                SDL_SetRenderTarget(renderer, null);
                SDL_RenderCopy(renderer, layer.getStruct, &gameRect, &gameRect);
            }
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

    void addLayer(Layer layer)
    {
        //TODO check if exists
        layers ~= layer;
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
