module deltotum.kit.scenes.scene_manager;

import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.kit.scenes.scene : Scene;

import std.stdio;

/**
 * Authors: initkfs
 */
class SceneManager : GraphicsComponent
{
    //TODO stack
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
        if(!scene.isBuilt){
            throw new Exception("Scene not built");
        }
        currentScene = scene;
    }
}
