module api.dm.kit.scenes.scene;

import api.dm.kit.components.window_component : WindowComponent;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.factories.creation : Creation;
import api.dm.kit.interacts.interact : Interact;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.windows.window : Window;
import api.dm.gui.supports.sceneview : SceneView;
import api.dm.com.graphics.com_surface : ComSurface;

import std.stdio;

/**
 * Authors: initkfs
 */
class Scene : WindowComponent
{
    string name;

    bool isDestructible;

    void delegate(Scene) onSceneChange;
    void delegate() onDraw;

    size_t timeEventProcessingMs;
    size_t timeUpdateProcessingMs;
    size_t timeDrawProcessingMs;

    size_t worldTicks;

    SceneView debugger;

    bool startDrawProcess;

    protected
    {
        Sprite[] sprites;
    }

    private
    {
        Creation _creation;
        Interact _interact;
    }

    override void create()
    {
        super.create;
    }

    void draw()
    {

    }

    void drawAll()
    {
        if (onDraw)
        {
            onDraw();
        }

        draw;

        foreach (obj; sprites)
        {
            obj.draw;
            if (obj.isClipped)
            {
                obj.disableClipping;
            }

            obj.unvalidate;
        }

        startDrawProcess = false;
        //TODO multiple scenes
        graphics.rendererPresent;
    }

    void update(double delta)
    {
        if (!startDrawProcess)
        {
            graphics.clearScreen;
            startDrawProcess = true;
        }

        worldTicks++;

        size_t invalidNodesCount;

        foreach (root; sprites)
        {
            root.update(delta);

            root.validate((invSprite) { invalidNodesCount++; });
            //root.unvalidate;
        }

        if (debugger && debugger.isVisible)
        {
            import Math = api.dm.math;
            import std.conv : to;

            debugger.invalidNodesCount.text = invalidNodesCount.to!dstring;
            debugger.updateTimeMs.text = Math.round(timeUpdateProcessingMs).to!dstring;
            debugger.drawTimeMs.text = Math.round(timeDrawProcessingMs).to!dstring;

            import core.memory : GC;

            auto stats = GC.stats;
            auto usedSize = stats.usedSize / 1000.0;
            debugger.gcUsedBytes.text = usedSize.to!dstring;
        }
    }

    void createDebugger()
    {
        debugger = new SceneView(this);
        addCreate(debugger);
    }

    override void dispose()
    {
        super.dispose;
        foreach (obj; sprites)
        {
            obj.dispose;
        }
        sprites = null;
    }

    void addCreate(Sprite obj)
    {
        if (!obj.isBuilt)
        {
            build(obj);
        }

        obj.initialize;
        assert(obj.isInitialized);

        obj.create;
        assert(obj.isCreated);

        add(obj);
    }

    void add(Sprite object)
    {
        foreach (sp; sprites)
        {
            if (object is sp)
            {
                return;
            }
        }
        sprites ~= object;
    }

    void changeScene(Scene other)
    {
        if (onSceneChange !is null)
        {
            onSceneChange(other);
        }
    }

    void rescale(double factorWidth, double factorHeight)
    {
        foreach (Sprite sprite; sprites)
        {
            sprite.rescale(factorWidth, factorHeight);
        }
    }

    Sprite[] activeSprites()
    {
        return sprites;
    }

    final bool hasCreation() @safe pure nothrow
    {
        return _creation !is null;
    }

    final void creation(Creation creation) @safe pure
    {
        import std.exception : enforce;

        enforce(creation !is null, "Creation factory must not be null");
        _creation = creation;
    }

    final Creation creation() @safe pure nothrow
    out (_creation; _creation !is null)
    {
        return _creation;
    }

    final bool hasInteract() nothrow pure @safe
    {
        return _interact !is null;
    }

    final Interact interact() nothrow pure @safe
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

    ComSurface snapshot()
    {
        assert(window.width > 0 && window.height > 0);
        import api.dm.math.rect2d : Rect2d;

        auto bounds = Rect2d(
            0, 0, window.width, window.height
        );
        auto surf = graphics.comSurfaceProvider.getNew();
        auto err = surf.createRGB(window.width, window.height);
        if (err)
        {
            throw new Exception(err.toString);
        }
        graphics.readPixels(bounds, surf);
        return surf;
    }

    void snapshot(string path)
    {
        auto surf = snapshot;
        scope (exit)
        {
            surf.dispose;
        }

        import api.dm.kit.sprites.images.image : Image;

        auto im = new Image;
        build(im);
        im.initialize;
        im.create;
        scope(exit){
            im.dispose;
        }
        im.savePNG(surf, path);
    }
}
