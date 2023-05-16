module deltotum.kit.scenes.scene_manager;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.scenes.scene : Scene;

import std.stdio;

/**
 * Authors: initkfs
 */
class SceneManager : GraphicsComponent
{
    protected
    {
        Scene[] scenes;
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

    void addCreate(Scene scene)
    {
        build(scene);
        scene.create;
        add(scene);
    }

    void add(Scene scene)
    {
        if (!scene.isBuilt)
        {
            throw new Exception("Scene not built");
        }
        //TODO exists
        scenes ~= scene;
    }

    void setDefaultScene()
    {

        if (scenes.length == 0)
        {
            return;
        }

        debug
        {
            import ConfigKeys = deltotum.kit.kit_config_keys;

            if (config.containsKey(ConfigKeys.sceneNameCurrent))
            {
                const sceneName = config.getNotEmptyString(ConfigKeys.sceneNameCurrent);
                foreach (scene; scenes)
                {
                    if (scene.name == sceneName)
                    {
                        _currentScene = scene;
                        break;
                    }
                }

                return;
            }
        }

        _currentScene = scenes[$ - 1];
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
