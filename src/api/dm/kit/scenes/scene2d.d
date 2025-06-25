module api.dm.kit.scenes.scene2d;

import api.dm.kit.events.event_kit_target : EventKitTarget;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.kit.factories.factory_kit : FactoryKit;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.dm.kit.windows.window : Window;
import api.dm.com.graphic.com_surface : ComSurface;

import std.stdio;

/**
 * Authors: initkfs
 */
class Scene2d : EventKitTarget
{
    string name;

    bool isDestructible;

    void delegate(Scene2d) onSceneChange;
    void delegate() onDraw;

    size_t timeEventProcessingMs;
    size_t timeUpdateProcessingMs;
    size_t timeDrawProcessingMs;

    size_t worldTicks;

    bool startDrawProcess;

    bool isProcessUDA = true;

    bool isPause;
    Sprite2d[] eternalSprites;

    bool isDrawAfterAllSprites;
    Sprite2d drawBeforeSprite;

    void delegate(double dt)[] eternalTasks;

    //protected
    //{
        Sprite2d[] sprites;
    //}

    Sprite2d[] controlledSprites;

    protected
    {
        FactoryKit _factory;
    }

    void delegate() udaProcessor;

    size_t invalidNodesCount;

    this(this ThisType)(bool isInitUDAProcessor = true)
    {
        initProcessUDA!(ThisType)(isInitUDAProcessor);
    }

    bool initProcessUDA(Type)(bool isInitUDAProcessor)
    {
        if (!isInitUDAProcessor)
        {
            return false;
        }

        assert(!udaProcessor, "Scene UDA processor already exists.");

        udaProcessor = () {
            if (!isProcessUDA)
            {
                return;
            }
            processUDA!Type;
        };
        return true;
    }

    void processUDA(alias TargetType)()
    {
        import std.traits : hasUDA, getUDAs, hasStaticMember, isArray, FieldNameTuple;
        import api.core.utils.types : hasOverloads;
        import UDA = api.dm.kit.factories.uda;

        import api.dm.kit.factories;

        auto thisInstance = cast(TargetType) this;
        assert(thisInstance);

        enum isInjectable(alias T) = is(T == UDA.Load) || is(typeof(T) == UDA.Load);
        enum isTypeOrArray(alias T, Target) = is(typeof(T) == Target) || is(typeof(T) == Target[]);

        void injectField(alias Target, Type, string fieldName, alias udaAttr)(
            scope Type delegate() provider)
        {
            static if (isArray!Target)
            {
                auto array = new Type[](udaAttr.count);
                foreach (i; 0 .. udaAttr.count)
                {
                    array[i] = provider();
                    if (udaAttr.isAdd)
                    {
                        addCreate(array[i]);
                    }
                }
                __traits(getMember, thisInstance, fieldName) = array;
            }
            else
            {
                __traits(getMember, thisInstance, fieldName) = provider();
            }
        }

        static foreach (const fieldName; FieldNameTuple!TargetType)
        {
            static if (!hasOverloads!(TargetType, fieldName) && !hasStaticMember!(TargetType, fieldName))
            {
                {
                    alias member = __traits(getMember, thisInstance, fieldName);

                    static foreach (attr; __traits(getAttributes, member))
                    {
                        {
                            static if (isInjectable!(attr))
                            {
                                static if (is(attr == UDA.Load))
                                {
                                    enum udaAttr = Load.init;
                                }
                                else static if (is(typeof(attr) == UDA.Load))
                                {
                                    alias udaAttr = getUDAs!(member, Load)[0];
                                }

                                import api.dm.kit.sprites2d.images : Image;

                                static if (isTypeOrArray!(member, Image))
                                {
                                    const w = udaAttr.width > 0 ? udaAttr.width : -1;
                                    const h = udaAttr.height > 0 ? udaAttr.height : -1;

                                    injectField!(typeof(member), Image, fieldName, udaAttr)(() {
                                        return f.images.image(udaAttr.path, w, h);
                                    });
                                }

                                import api.dm.kit.sprites2d.textures.texture2d : Texture2d;

                                static if (isTypeOrArray!(member, Texture2d))
                                {
                                    const w = udaAttr.width > 0 ? udaAttr.width : 1;
                                    const h = udaAttr.height > 0 ? udaAttr.height : 1;

                                    injectField!(typeof(member), Texture2d, fieldName, udaAttr)(() {
                                        return f.textures.texture(w, h);
                                    });
                                }

                                static if (udaAttr.isAdd && !isArray!(typeof(member)))
                                {
                                    addCreate(__traits(getMember, thisInstance, fieldName));
                                }
                            }

                            // static if (is(typeof(attr) == UDA.LAnimImage))
                            // {
                            //     alias udaAttr = getUDAs!(member, LAnimImage)[0];
                            //     auto isAdd = udaAttr.isAdd;
                            //     __traits(getMember, thisInstance, fieldName) = f.images.animated(udaAttr.path,
                            //         udaAttr.frameCols,
                            //         udaAttr.frameRows,
                            //         udaAttr.frameWidth,
                            //         udaAttr.frameHeight,
                            //         udaAttr.frameDelay);
                            //     if (isAdd)
                            //     {
                            //         add(__traits(getMember, thisInstance, fieldName));
                            //     }
                            // }

                            // static if (is(typeof(attr) == UDA.LAnimImages))
                            // {
                            //     alias udaAttr = getUDAs!(member, LAnimImages)[0];
                            //     size_t count = udaAttr.count;
                            //     if (count > 0)
                            //     {
                            //         auto isAdd = udaAttr.isAdd;
                            //         typeof(member) array = new typeof(member)(count);
                            //         foreach (i; 0 .. count)
                            //         {
                            //             auto newItem = f.images.animated(udaAttr.path, udaAttr.frameWidth, udaAttr
                            //                     .frameHeight, udaAttr.frameDelay);
                            //             array[i] = newItem;
                            //             if (isAdd)
                            //             {
                            //                 add(newItem);
                            //             }
                            //         }

                            //         __traits(getMember, thisInstance, fieldName) = array;
                            //     }
                            // }
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

        if (udaProcessor)
        {
            udaProcessor();
        }
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

    protected void drawSelf()
    {
        if (onDraw)
        {
            onDraw();
        }

        draw;
    }

    void drawAll()
    {
        if (!isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        foreach (obj; sprites)
        {
            if (drawBeforeSprite && drawBeforeSprite is obj)
            {
                drawSelf;
            }

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

        if (isDrawAfterAllSprites && !drawBeforeSprite)
        {
            drawSelf;
        }

        startDrawProcess = false;
        //TODO multiple scenes
        graphic.rendererPresent;
    }

    void update(double delta)
    {
        if (!startDrawProcess)
        {
            graphic.clear;
            startDrawProcess = true;
        }

        worldTicks++;

        if (eternalTasks.length > 0)
        {
            foreach (task; eternalTasks)
            {
                task(delta);
            }
        }

        invalidNodesCount = 0;

        Sprite2d[] roots = isPause ? eternalSprites : sprites;

        foreach (root; roots)
        {
            root.update(delta);

            root.validate((invSprite) { invalidNodesCount++; });
            //root.unvalidate;
        }

        if (!isPause)
        {
            if (controlledSprites.length > 0)
            {
                foreach (cs; controlledSprites)
                {
                    cs.update(delta);
                    cs.validate;
                }
            }
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

    override void dispose()
    {
        super.dispose;
        foreach (obj; sprites)
        {
            obj.dispose;
        }
        sprites = null;
    }

    void addCreate(Sprite2d obj)
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

    void add(Sprite2d object)
    {
        assert(object);
        foreach (sp; sprites)
        {
            if (object is sp)
            {
                return;
            }
        }

        if (!object.sceneProvider)
        {
            object.sceneProvider = () => this;
        }

        sprites ~= object;
    }

    void changeScene(Scene2d other)
    {
        if (onSceneChange !is null)
        {
            onSceneChange(other);
        }
    }

    void rescale(double factorWidth, double factorHeight)
    {
        foreach (Sprite2d sprite; sprites)
        {
            sprite.rescale(factorWidth, factorHeight);
        }
    }

    Sprite2d[] activeSprites()
    {
        if (!isPause || eternalSprites.length == 0)
        {
            return sprites;
        }
        return eternalSprites;
    }

    import api.core.utils.arrays : drop;

    bool removeControlled(Sprite2d sprite)
    {
        return drop(controlledSprites, sprite);
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
        auto surf = graphic.comSurfaceProvider.getNew();
        auto err = surf.createRGBA32(cast(int) window.width, cast(int) window.height);
        if (err)
        {
            throw new Exception(err.toString);
        }
        
        if (const errRead = graphic.readPixels(bounds, surf))
        {
            logger.error(errRead.toString);
        }
        return surf;
    }

    void snapshot(string path)
    {
        auto surf = snapshot;
        scope (exit)
        {
            surf.dispose;
        }

        import api.dm.kit.sprites2d.images.image : Image;

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
