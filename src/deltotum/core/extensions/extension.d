module deltotum.core.extensions.extension;

import deltotum.core.apps.units.simple_unit : SimpleUnit;
import deltotum.core.extensions.plugins.plugin : Plugin;

import std.variant : Variant;
import std.typecons : Nullable;

class Extension : SimpleUnit
{
    protected
    {
        Plugin[] plugins;
    }

    void call(string extName, string[] args, scope void delegate(Variant) onResult, scope void delegate(
            string) onError = null) inout
    {
        foreach (p; plugins)
        {
            if (p.name == extName)
            {
                p.call(args, onResult, onError);
            }
        }

        //TODO logging if plugin not found
    }

    override void initialize()
    {
        super.initialize;

        foreach (p; plugins)
        {
            p.initialize;
        }
    }

    override void create()
    {
        super.create;
        foreach (p; plugins)
        {
            p.create;
        }
    }

    override void run()
    {
        super.run;

        foreach (p; plugins)
        {
            p.run;
        }
    }

    override void stop()
    {
        super.stop;

        foreach (p; plugins)
        {
            p.stop;
        }
    }

    override void dispose()
    {
        super.dispose;

        foreach (p; plugins)
        {
            p.dispose;
        }
    }

    Nullable!Plugin findFirst(string name)
    {
        foreach (p; plugins)
        {
            if (p.name == name)
            {
                return Nullable!Plugin(p);
            }
        }
        return Nullable!Plugin.init;
    }

    void addPlugin(Plugin plugin)
    {
        import std.algorithm : canFind;
        import std.format : format;

        if (plugins.canFind(plugin))
        {
            throw new Exception(format("Plugin %s has been already added", plugin));
        }

        plugins ~= plugin;
    }
}
