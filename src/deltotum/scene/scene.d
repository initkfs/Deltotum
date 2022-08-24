module deltotum.scene.scene;

import deltotum.application.components.uni.uni_component : UniComponent;
import deltotum.display.display_object : DisplayObject;
import deltotum.graphics.colors.color : Color;
import deltotum.factories.creation : Creation;

import std.stdio;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Scene : UniComponent
{
    @property void delegate(Scene) onSceneChange;

    @property size_t timeEventProcessingMs;
    @property size_t timeUpdateProcessingMs;

    @property bool isClearingInCycle = true;
    @property size_t worldTicks;

    protected
    {
        DisplayObject[] displayObjects = [];
    }

    private
    {
        Creation _creation;
    }

    void create()
    {
        //TODO move to scene manager?
        import deltotum.factories.creation_images : CreationImages;

        auto imagesFactory = new CreationImages;
        build(imagesFactory);

        import deltotum.factories.creation_shapes : CreationShapes;

        auto shapesFactory = new CreationShapes;
        build(shapesFactory);

        _creation = new Creation(imagesFactory, shapesFactory);
        build(_creation);
    }

    void update(double delta)
    {
        worldTicks++;

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

    void addCreated(DisplayObject obj)
    {
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

    @property void creation(Creation creation) @safe pure
    {
        import std.exception : enforce;

        enforce(creation !is null, "Creation factory must not be null");
        _creation = creation;
    }

    @property Creation creation() @nogc @safe pure nothrow
    out (_creation; _creation !is null)
    {
        return _creation;
    }

}
