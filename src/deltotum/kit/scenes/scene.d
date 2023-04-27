module deltotum.kit.scenes.scene;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.display.display_object : DisplayObject;
import deltotum.kit.interacts.interact : Interact;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.kit.factories.creation : Creation;
import deltotum.kit.windows.window : Window;

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

    size_t worldTicks;

    protected
    {
        DisplayObject[] displayObjects;
    }

    private
    {
        Creation _creation;
        Interact _interact;
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

        import deltotum.kit.interacts.dialogs.dialog_manager : DialogManager;

        auto dialogManager = new DialogManager;
        dialogManager.dialogWindowProvider = () { return newWindow; };
        dialogManager.parentWindowProvider = () { return window; };

        interact = new Interact(dialogManager);
    }

    void update(double delta)
    {
        worldTicks++;

        graphics.renderer.draw(() {
            foreach (obj; displayObjects)
            {
                obj.update(delta);
                obj.draw;
            }
        });
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

    bool hasCreation() @nogc @safe pure nothrow
    {
        return _creation !is null;
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

    final bool hasInteract() @nogc nothrow pure @safe
    {
        return _interact !is null;
    }

    final Interact interact() @nogc nothrow pure @safe
    out (_interact; _interact !is null)
    {
        return _interact;
    }

    final void interact(Interact interact) pure @safe
    {
        import std.exception : enforce;

        enforce(interact !is null, "Interaction must not be null");
        _interact = interact;
    }

    Window newWindow(dstring title = "New window", int prefWidth = 450, int prefHeight = 200, int x = 0, int y = 0)
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
