module deltotum.core.extensions.extension_collector;

import deltotum.core.extensions.extension : Extension;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;

import std.logger: Logger;
import std.format : format;

class ExtensionsCollector(E : Extension) : Extension
{
    protected
    {
        E[] extensions;
    }

    this(Logger logger, Config config, Context context)
    {
        super(logger, config, context);
    }

    void addExtension(E ext)
    {
        import std.algorithm : canFind;
        import std.format : format;

        if (extensions.canFind(ext))
        {
            throw new Exception(format("Extension %s has been already added", ext));
        }

        extensions ~= ext;
    }

    override bool load()
    {
        size_t loadCounter;
        foreach (ext; extensions)
        {
            if (ext.load)
            {
                loadCounter++;
            }
        }
        //TODO log?
        return loadCounter == extensions.length;
    }

    override string[] call(string event, string[] args)
    {
        string[] result;
        foreach (ext; extensions)
        {
            string[] extResult = ext.call(event, args);
            if (extResult.length > 0)
            {
                result ~= extResult;
            }
        }
        return result;
    }
}
