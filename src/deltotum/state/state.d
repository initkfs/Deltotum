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
        auto renderer = window.renderer.getStruct;

        foreach (obj; displayObjects)
        {
            obj.update(delta);
            obj.draw;
        }

        SDL_Rect gameRect = {0, 0, window.getWidth, window.getHeight};

        foreach (Layer layer; layers)
        {
            SDL_SetRenderTarget(renderer, layer.getStruct);
            layer.drawContent;
            SDL_SetRenderTarget(renderer, null);
            SDL_RenderCopy(renderer, layer.getStruct, &gameRect, &gameRect);
        }

        // SDL_SetRenderTarget(renderer, lightLayer.getStruct);
        // window.renderer.setRenderDrawColor(60, 0, 100, 255);
        // SDL_RenderFillRect(renderer, null);

        // SDL_Rect srcl = {0, 0, cast(int) light.width, cast(int) light.height};
        // SDL_Rect srcl1 = {0, 0, cast(int) light.width, cast(int) light.height};

        // SDL_RenderCopy(renderer, light.getStruct, &srcl, &srcl1);

        // SDL_SetRenderTarget(renderer, null) /* set the render back to your scene*/ ;

        // SDL_RenderCopy(renderer, lightLayer.getStruct, &gameRect, &gameRect);

        // foreach (obj; displayObjects)
        // {
        //     obj.update(delta);
        //     obj.draw;
        // }

        // SDL_Rect gameRect = {0, 0, window.getWidth, window.getHeight};

        // SDL_SetRenderTarget(renderer, null);

        // SDL_SetRenderTarget(renderer, lightLayer.getStruct);
        // SDL_SetTextureBlendMode(lightLayer.getStruct, SDL_BLENDMODE_MOD);
        // SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        // // // change the black color to a more transparent one
        // // // SDL_SetRenderDrawColor(renderer, 0x36, 0x45, 0x9b, 0xff);
        // window.renderer.clear;

        // SDL_Rect spot1 = {10, 10, 200, 200};
        // SDL_RenderCopy(renderer, light.getStruct, null, &spot1);

        // SDL_SetRenderTarget(renderer, null);

        // SDL_SetRenderTarget(renderer, resultLayer.getStruct);

        // SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        // window.renderer.clear;

        // SDL_SetTextureBlendMode(resultLayer.getStruct, SDL_BLENDMODE_BLEND);
        // SDL_RenderCopy(renderer, worldLayer.getStruct, null, &gameRect);
        // SDL_RenderCopy(renderer, lightLayer.getStruct, null, &gameRect);

        // SDL_SetRenderTarget(renderer, null);
        // SDL_RenderCopy(renderer, resultLayer.getStruct, null, &gameRect);

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
