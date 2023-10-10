module deltotum.kit.scenes.scene_manager;

import deltotum.kit.apps.comps.window_component : WindowComponent;
import deltotum.kit.scenes.scene : Scene;

import deltotum.kit.factories.creation : Creation;
import deltotum.kit.interacts.interact : Interact;
import deltotum.kit.factories.creation_images : CreationImages;
import deltotum.kit.factories.creation_shapes : CreationShapes;

import std.stdio;

/**
 * Authors: initkfs
 */
class SceneManager : Scene
{
    protected
    {
        Scene[] _scenes;
    }

    private
    {
        Scene _currentScene;
    }

    Scene currentScene() @nogc @safe pure nothrow
    out (_currentScene; _currentScene !is null)
    {
        return _currentScene;
    }

    void currentScene(Scene scene) @safe pure
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene must not be null");
        _currentScene = scene;
    }

    CreationImages newCreationImages()
    {
        return new CreationImages;
    }

    CreationShapes newCreationShapes()
    {
        return new CreationShapes;
    }

    override void create()
    {
        super.create;

        auto imagesFactory = newCreationImages;
        build(imagesFactory);

        auto shapesFactory = newCreationShapes;
        build(shapesFactory);

        //TODO extrace factory methods
        creation = new Creation(imagesFactory, shapesFactory);
        build(creation);

        import deltotum.kit.interacts.dialogs.dialog_manager : DialogManager;

        auto dialogManager = new DialogManager;
        dialogManager.dialogWindowProvider = () { return window.newChildWindow; };
        dialogManager.parentWindowProvider = () { return window; };

        interact = new Interact(dialogManager);
    }

    import deltotum.kit.apps.comps.window_component: WindowComponent;

    alias build = WindowComponent.build;

    void build(Scene scene)
    {
        super.build(scene);
        scene.interact = interact;
        scene.creation = creation;
    }

    void create(Scene scene)
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene must not be null");

        if (!scene.isBuilt)
        {
            build(scene);
            assert(scene.isBuilt);
        }

        scene.initialize;
        assert(scene.isInitialized);

        scene.create;
        assert(scene.isCreated);
    }

    void addCreate(Scene scene)
    {
        create(scene);
        add(scene);
    }

    void add(Scene[] scenes...)
    {
        foreach (Scene scene; scenes)
        {
            add(scene);
        }
    }

    void add(Scene scene)
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene must not be null");

        foreach (sc; _scenes)
        {
            if (sc is scene)
            {
                return;
            }
        }
        _scenes ~= scene;
    }

    bool changeByName(string name)
    {
        foreach (sc; _scenes)
        {
            if (sc.name == name)
            {
                setCurrent(sc);
                return true;
            }
        }
        return false;
    }

    void change(Scene scene)
    {
        //TODO check in scenes
        debug
        {
            import ConfigKeys = deltotum.kit.kit_config_keys;

            if (config.containsKey(ConfigKeys.sceneNameCurrent))
            {
                const sceneName = config.getNotEmptyString(ConfigKeys.sceneNameCurrent);
                if (!sceneName.isNull && changeByName(sceneName.get))
                {
                    return;
                }
            }
        }

        setCurrent(scene);
    }

    protected void setCurrent(Scene scene)
    {
        assert(scene);

        if (_currentScene && _currentScene.isDestructible)
        {
            _currentScene.destroy;
        }

        if (!scene.isBuilt || scene.isDestructible)
        {
            create(scene);
        }

        _currentScene = scene;
    }

    override void run()
    {
        super.run;
        foreach (scene; _scenes)
        {
            if (!scene.isCreated)
            {
                continue;
            }
            scene.run;
        }
    }

    override void stop()
    {
        super.stop;
        foreach (scene; _scenes)
        {
            if (!scene.isRunning)
            {
                continue;
            }
            scene.stop;
        }
    }

    bool draw(double alpha)
    {
        if (!_currentScene)
        {
            return false;
        }

        _currentScene.draw;
        return true;
    }

    override void update(double delta)
    {
        if (!_currentScene)
        {
            return;
        }

        _currentScene.update(delta);
    }

    override void destroy()
    {
        super.destroy;
        if (_currentScene)
        {
            _currentScene.destroy;
        }
    }
}
