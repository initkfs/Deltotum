module deltotum.kit.scenes.scene_manager;

import deltotum.kit.apps.comps.window_component : WindowComponent;
import deltotum.kit.scenes.scene : Scene;

import std.stdio;

/**
 * Authors: initkfs
 */
class SceneManager : WindowComponent
{
    protected
    {
        Scene[] _scenes;
    }
    Scene _currentScene;

    Scene currentScene() @nogc @safe pure nothrow
    out (_currentScene; _currentScene !is null)
    {
        return _currentScene;
    }

    void currentScene(Scene state) @safe pure
    {
        import std.exception : enforce;

        enforce(state !is null, "Scene must not be null");
        _currentScene = state;
    }

    override void create()
    {
        super.create;
    }

    void create(Scene scene)
    {
        assert(scene);
        if (!scene.isBuilt)
        {
            build(scene);
        }
        scene.initialize;
        scene.create;
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
        //TODO exists
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

    bool update(double delta)
    {
        if (!_currentScene)
        {
            return false;
        }

        _currentScene.update(delta);
        return true;
    }

    void destroy()
    {
        //super.destroy;
        if (_currentScene)
        {
            _currentScene.destroy;
        }
    }
}
