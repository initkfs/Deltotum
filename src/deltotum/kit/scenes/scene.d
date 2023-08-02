module deltotum.kit.scenes.scene;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.sprites.sprite : Sprite;
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
    string name;

    bool isDestructible;
    
    void delegate(Scene) onSceneChange;

    size_t timeEventProcessingMs;
    size_t timeUpdateProcessingMs;
    size_t timeDrawProcessingMs;

    size_t worldTicks;

    protected
    {
        Sprite[] sprites;
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
        dialogManager.dialogWindowProvider = () { return window.newChildWindow; };
        dialogManager.parentWindowProvider = () { return window; };

        interact = new Interact(dialogManager);
    }

    void draw()
    {
        graphics.draw(() {
            foreach (obj; sprites)
            {
                obj.draw;
            }
        });
    }

    void update(double delta)
    {
        worldTicks++;

        foreach (obj; sprites)
        {
            obj.validate;
            obj.applyAllLayouts;
            obj.update(delta);
        }
    }

    void destroy()
    {
        foreach (obj; sprites)
        {
            obj.destroy;
        }
        sprites = [];
    }

    void addCreate(Sprite obj)
    {
        build(obj);

        obj.initialize;
        assert(obj.isInitialized);

        obj.create;

        add(obj);
    }

    void add(Sprite object)
    {
        //TODO check if exists
        sprites ~= object;
    }

    void changeScene(Scene other)
    {
        if (onSceneChange !is null)
        {
            onSceneChange(other);
        }
    }

    void scale(double factorWidth, double factorHeight)
    {
        foreach (Sprite sprite; sprites)
        {
            sprite.setScale(factorWidth, factorHeight);
        }
    }

    Sprite[] getActiveObjects()
    {
        return sprites;
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
}
