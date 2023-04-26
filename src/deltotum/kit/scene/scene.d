module deltotum.kit.scene.scene;

import deltotum.kit.applications.components.graphics_component : GraphicsComponent;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.factories.creation : Creation;
import deltotum.kit.windows.window: Window;

import std.stdio;

//TODO remove hal api
import bindbc.sdl;

/**
 * Authors: initkfs
 */
class Scene : GraphicsComponent
{
    void delegate(Scene) onSceneChange;

    size_t timeEventProcessingMs;
    size_t timeUpdateProcessingMs;

    bool isClearingInCycle = true;
    size_t worldTicks;

    protected
    {
        DisplayObject[] displayObjects;
    }

    private
    {
        Creation _creation;
    }

    void create()
    {
        //TODO move to scene manager?
        import deltotum.kit.factories.creation_images : CreationImages;

        auto imagesFactory = new CreationImages;
        build(imagesFactory);

        import deltotum.kit.factories.creation_shapes : CreationShapes;

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
            const screenColor = RGBA.black;
            if (const err = graphics.renderer.setRenderDrawColor(screenColor.r, screenColor.g, screenColor.b, screenColor
                    .alphaNorm))
            {
                //TODO logging in main loop?
            }
            else
            {
                if (const err = graphics.renderer.clear)
                {
                    //TODO loggong in main loop?
                }
            }
        }

        foreach (obj; displayObjects)
        {
            obj.update(delta);
            obj.draw;
        }

        graphics.renderer.present;
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

        obj.initialize;
        assert(obj.isInitialized);

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

    void creation(Creation creation) @safe pure
    {
        import std.exception : enforce;

        enforce(creation !is null, "Creation factory must not be null");
        _creation = creation;
    }

    Creation creation() @nogc @safe pure nothrow
    out (_creation; _creation !is null)
    {
        return _creation;
    }

    Window newWindow(dstring title, size_t prefWidth, size_t prefHeight, long x = 0, long y = 0)
    {
        version (SdlBackend)
        {
            import deltotum.kit.windows.factories.sdl_window_factory : SdlWindowFactory;

            auto winFactory = new SdlWindowFactory;
            build(winFactory);

            auto window = winFactory.create(title, prefWidth, prefHeight, x, y);
            this.window.windowManager.add(window);
            return window;
        }
        else
        {
            assert(0);
        }
    }

}
