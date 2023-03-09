module deltotum.toolkit.scene.scene_manager;

import deltotum.toolkit.scene.scene: Scene;

import std.stdio;

/**
 * Authors: initkfs
 */
class SceneManager
{
    //TODO stack
    Scene _currentScene;

    void update(double delta)
    {
        if (_currentScene is null)
        {
            return;
        }
        _currentScene.update(delta);
    }

    void destroy()
    {
        if (_currentScene !is null)
        {
            _currentScene.destroy;
        }
    }

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
}
