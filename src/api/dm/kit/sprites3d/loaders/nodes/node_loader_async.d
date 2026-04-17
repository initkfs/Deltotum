module api.dm.kit.sprites3d.loaders.nodes.node_loader_async;

import api.dm.kit.sprites3d.loaders.nodes.node_loader : NodeLoader;
import api.dm.kit.sprites3d.sprite3d : Sprite3d;

import core.thread.osthread : Thread;
import core.atomic : atomicLoad, atomicStore;

import api.dm.lib.assimp;

/**
 * Authors: initkfs
 */

class NodeLoaderAsync : Thread
{
    NodeLoader loader;

    string path;
    string baseDir;
    bool isFlatScene = true;

    shared Sprite3d _result;

    this(AssimpLib loaderLib = null)
    {
        this.loader = new NodeLoader(loaderLib);
        super(&load);
    }

    void load()
    {
        try
        {
            loader.baseDir = baseDir;
            loader.isFlatScene = isFlatScene;
            auto root = cast(shared(Sprite3d)) loader.load(path);
            atomicStore(_result, root);
        }
        catch (Exception e)
        {
            import std.stdio : stderr, writeln;

            stderr.writeln(e.toString);
        }
    }

    shared(Sprite3d) result() => atomicLoad(_result);
}
