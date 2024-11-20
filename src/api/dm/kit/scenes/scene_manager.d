module api.dm.kit.scenes.scene_manager;

import api.dm.kit.components.graphics_component : GraphicsComponent;
import api.dm.kit.scenes.scene : Scene;

import api.dm.kit.factories.factory_kit : FactoryKit;
import api.core.components.units.simple_unit : SimpleUnit;

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

    this(FactoryKit factoryKit){
        assert(factoryKit);
        factory = factoryKit;
    }

    Scene currentScene() @safe pure nothrow
    out (_currentScene; _currentScene !is null)
    {
        return _currentScene;
    }

    void currentScene(Scene scene) @safe pure
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene must not be null");

        foreach (currScene; _scenes)
        {
            if (currScene is scene)
            {
                _currentScene = scene;
                return;
            }
        }
        throw new Exception("Scene not found in scene list: " ~ scene.name);
    }

    override void create()
    {
        super.create;
    }

    import api.dm.kit.components.graphics_component : GraphicsComponent;

    alias build = GraphicsComponent.build;

    void build(Scene scene)
    {
        super.build(scene);
        scene.interact = interact;
        scene.factory = factory;
    }

    alias create = SimpleUnit.create;

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

    bool addCreate(Scene scene)
    {
        create(scene);
        return add(scene);
    }

    bool add(Scene[] scenes...)
    {
        bool isAdd = true;
        foreach (Scene scene; scenes)
        {
            isAdd &= add(scene);
        }
        return isAdd;
    }

    bool add(Scene scene)
    {
        import std.exception : enforce;

        enforce(scene !is null, "Scene must not be null");

        foreach (sc; _scenes)
        {
            if (sc is scene)
            {
                return false;
            }
        }
        _scenes ~= scene;
        return true;
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
        import ConfigKeys = api.dm.kit.kit_config_keys;

            if (config.containsKey(ConfigKeys.sceneNameCurrent))
            {
                const sceneName = config.getNotEmptyString(ConfigKeys.sceneNameCurrent);
                if (!sceneName.isNull && changeByName(sceneName.get))
                {
                    return;
                }
            }

        setCurrent(scene);
    }

    protected void setCurrent(Scene scene)
    {
        assert(scene);

        if (_currentScene && _currentScene.isDestructible)
        {
            _currentScene.dispose;
        }

        if (!scene.isBuilt || scene.isDestructible)
        {
            create(scene);
        }

        _currentScene = scene;
    }

    override void pause()
    {
        super.pause;
        if (!_currentScene)
        {
            return;
        }
        _currentScene.pause;
    }

    override void run()
    {
        super.run;
        if (!_currentScene)
        {
            return;
        }
        _currentScene.run;
    }

    override void stop()
    {
        super.stop;
        if (!_currentScene)
        {
            return;
        }
        if (_currentScene.isRunning)
        {
            _currentScene.stop;
        }
    }

    bool draw(double alpha)
    {
        if (!_currentScene)
        {
            return false;
        }

        _currentScene.drawAll;
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

    override void dispose()
    {
        super.dispose;
        logger.trace("Start dispose all scenes");
        foreach (Scene scene; _scenes)
        {
            const sceneName = scene.name;
            if (scene.isComponentCreated)
            {
                logger.trace("Found created scene in window: ", sceneName);
                if (scene.isRunning)
                {
                    scene.stop;
                    assert(scene.isStopped);
                    logger.trace("Stop created scene: ", sceneName);
                }

                scene.dispose;
                logger.trace("Dispose created scene in window with name: ", sceneName);
            }
            else
            {
                logger.trace("Scene not created, disposing skipped: ", sceneName);
            }
        }
    }
}
