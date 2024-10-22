module api.dm.kit.scenes.scene;

import api.dm.kit.events.event_kit_target : EventKitTarget;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.factories.factory_kit : FactoryKit;
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

    bool isProcessUDA = true;

    bool isPause;
    Sprite[] unlockSprites;

    protected
    {
        Sprite[] sprites;
    }

    Sprite[] controlledSprites;

    protected
    {
        FactoryKit _factory;
    }

    void delegate() udaProcessor;

    this(this ThisType)()
    {
        udaProcessor = () {
            if (!isProcessUDA)
            {
                return;
            }
            processUDA!ThisType;
        };
    }

    void processUDA(alias TargetType)()
    {
        import std.traits : hasUDA, getUDAs;
        import api.core.utils.types : hasOverloads;

        import api.dm.kit.factories;

        auto thisInstance = cast(TargetType) this;
        assert(thisInstance);

        static foreach (const fieldName; __traits(allMembers, TargetType))
        {
            static if (!hasOverloads!(TargetType, fieldName))
            {
                {
                    alias member = __traits(getMember, thisInstance, fieldName);
                    static foreach (attr; __traits(getAttributes, member))
                    {
                        {
                            static if (is(attr == placeholder))
                            {
                                __traits(getMember, thisInstance, fieldName) = f.placeholder;
                            }

                            static if (is(typeof(attr) == placeholder))
                            {
                                alias placeholderUDA = getUDAs!(member, placeholder)[0];
                                auto isAdd = placeholderUDA.isAdd;
                                __traits(getMember, thisInstance, fieldName) = f.placeholder(placeholderUDA.width, placeholderUDA
                                        .height);
                                if (isAdd)
                                {
                                    add(__traits(getMember, thisInstance, fieldName));
                                }
                            }

                            static if (is(typeof(attr) == image))
                            {
                                alias udaAttr = getUDAs!(member, image)[0];
                                auto isAdd = udaAttr.isAdd;
                                __traits(getMember, thisInstance, fieldName) = f.images.image(udaAttr.path, udaAttr.width, udaAttr
                                        .height);
                                if (isAdd)
                                {
                                    add(__traits(getMember, thisInstance, fieldName));
                                }
                            }
                        }
                    }
                }
            }

        }
    }

    override void create()
    {
        super.create;
        createHandlers;

        udaProcessor();
        // alias thisType = typeof(this);
        // static foreach (const fieldName; __traits(allMembers, parentType))
        // {
        //     static if (!hasOverloads!(parentType, fieldName) && hasUDA!(__traits(getMember, parentComponent, fieldName), Service))
        //     {
        //         {
        //             import std.algorithm.searching : startsWith;
        //             import std.uni : toUpper;

        //             enum fieldSetterName = (fieldName.startsWith("_") ? fieldName[1 .. $]
        //                         : fieldName);
        //             enum hasMethodName = "has" ~ fieldSetterName[0 .. 1].toUpper ~ fieldSetterName[1 .. $];
        //             immutable bool hasService = __traits(getMember, uniComponent, hasMethodName)();
        //             if (!hasService || uniComponent.isAllowRebuildServices)
        //             {
        //                 __traits(getMember, uniComponent, fieldSetterName) = __traits(getMember, parentComponent, fieldSetterName);
        //             }
        //         }

        //     }
        // }
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

        if (isPause)
        {
            foreach (obj; unlockSprites)
            {
                obj.update(delta);
                obj.validate;
            }
            return;
        }

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
            assert(obj.isBuilt);
        }

        if (!obj.isCreated)
        {
            if (!obj.isInitialized)
            {
                obj.initialize;
                assert(obj.isInitialized);
            }

            obj.create;
            assert(obj.isCreated);
        }

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

            onKeyDown ~= (ref e) {
                import api.dm.com.inputs.com_keyboard : ComKeyName;

                //TODO toggle pause?
                if (e.keyName != ComKeyName.F12 || isPause)
                {
                    return;
                }

                if (!isPause)
                {
                    isPause = true;
                    dialogManager.showInfo("Pause!", "Info", () {
                        isPause = false;
                        unlockSprites = null;
                    });
                    unlockSprites ~= dialogManager;
                }
            };
        }

        if (!object.interact.hasPopup)
        {
            import api.dm.gui.controls.popups.gui_popup_manager : GuiPopupManager;

            auto popupManager = new GuiPopupManager;
            //TODO first, after dialogs
            object.addCreate(popupManager, 1);
            object.interact.popup = popupManager;
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
        if (!isPause || unlockSprites.length == 0)
        {
            return sprites;
        }
        return unlockSprites;
    }

    final bool hasFactory() @safe pure nothrow
    {
        return _factory !is null;
    }

    alias f = factory;

    final void factory(FactoryKit newFactory) @safe pure
    {
        import std.exception : enforce;

        enforce(newFactory !is null, "Engine factory must not be null");
        _factory = newFactory;
    }

    final FactoryKit factory() @safe pure nothrow
    out (_factory; _factory !is null)
    {
        return _factory;
    }

    ComSurface snapshot()
    {
        assert(window.width > 0 && window.height > 0);
        import api.math.geom2.rect2 : Rect2d;

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
