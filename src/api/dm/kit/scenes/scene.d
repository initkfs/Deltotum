module api.dm.kit.scenes.scene;

import api.dm.kit.events.event_kit_target : EventKitTarget;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.factories.creation : Creation;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.windows.window : Window;
import api.dm.gui.supports.sceneview : SceneView;
import api.dm.com.graphics.com_surface : ComSurface;

import std.stdio;

/**
 * Authors: initkfs
 */
class Scene : EventKitTarget
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

    Sprite[] controlledSprites;

    protected
    {
        Creation _creation;
    }

    override void create()
    {
        super.create;
        createHandlers;
    }

    void dispatchEvent(Event)(Event e)
    {
        if (!isReceiveEvents)
        {
            return;
        }
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

        if (controlledSprites.length > 0)
        {
            //TODO unvalidate?
            foreach (cs; controlledSprites)
            {
                cs.draw;
                cs.unvalidate;
            }
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

        if (controlledSprites.length > 0)
        {
            foreach (cs; controlledSprites)
            {
                cs.update(delta);
                cs.validate;
            }
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

    override void pause()
    {
        super.pause;
        if (sprites.length > 0)
        {
            foreach (obj; sprites)
            {
                obj.onScenePause;
            }
        }
    }

    override void run()
    {
        if (isPaused)
        {
            if (sprites.length > 0)
            {
                foreach (obj; sprites)
                {
                    obj.onSceneResume;
                }
            }
        }

        super.run;
    }

    void createDebugger()
    {
        import api.dm.gui.containers.slider : Slider, SliderPos;

        auto debugWrapper = new Slider(SliderPos.right);
        addCreate(debugWrapper);
        debugger = new SceneView(this);
        debugWrapper.addContent(debugger);
        window.showingTasks ~= (dt) { debugWrapper.setInitialPos; };
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
        if (!obj.sceneProvider)
        {
            obj.sceneProvider = () => this;
        }

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
        assert(object);
        foreach (sp; sprites)
        {
            if (object is sp)
            {
                return;
            }
        }

        if (!object.interact.hasDialog)
        {
            import api.dm.gui.interacts.dialogs.gui_dialog_manager : GuiDialogManager;

            auto dialogManager = new GuiDialogManager;
            object.addCreate(dialogManager, 0);
            object.interact.dialog = dialogManager;
        }

        if (!object.sceneProvider)
        {
            object.sceneProvider = () => this;
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

    ComSurface snapshot()
    {
        assert(window.width > 0 && window.height > 0);
        import api.math.rect2d : Rect2d;

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
        scope (exit)
        {
            im.dispose;
        }
        im.savePNG(surf, path);
    }
}
