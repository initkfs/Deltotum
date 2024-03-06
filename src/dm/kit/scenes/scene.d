module dm.kit.scenes.scene;

import dm.kit.apps.components.window_component : WindowComponent;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.factories.creation : Creation;
import dm.kit.interacts.interact : Interact;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.kit.windows.window : Window;
import dm.gui.supports.sceneview : SceneView;

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
            import Math = dm.math;
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

    final bool hasCreation() @nogc @safe pure nothrow
    {
        return _creation !is null;
    }

    final void creation(Creation creation) @safe pure
    {
        import std.exception : enforce;

        enforce(creation !is null, "Creation factory must not be null");
        _creation = creation;
    }

    final Creation creation() @nogc @safe pure nothrow
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
