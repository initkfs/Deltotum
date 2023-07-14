module deltotum.kit.apps.graphic_application;

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.components.graphics_component : GraphicsComponent;
import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.kit.extensions.extension : Extension;
import deltotum.kit.apps.capabilities.capability : Capability;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.loops.loop : Loop;

import std.logger : Logger;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    double frameRate = 60;

    bool isQuitOnCloseAllWindows = true;

    private
    {
        GraphicsComponent _graphicServices;
    }

    protected
    {
        Loop mainLoop;
        WindowManager windowManager;

        bool isProcessEvents = true;
    }

    this(Loop loop)
    {
        import std.exception : enforce;

        this.mainLoop = enforce(loop, "Main loop must not be null");
    }

    override ApplicationExit initialize(string[] args)
    {
        if (const exit = super.initialize(args))
        {
            return exit;
        }

        if (!_graphicServices)
        {
            _graphicServices = newGraphicServices;
        }

        if (!_graphicServices.hasCap)
        {
            _graphicServices.cap = newCapability;
        }

        return ApplicationExit(false);
    }

    Capability newCapability()
    {
        return new Capability;
    }

    GraphicsComponent newGraphicServices()
    {
        return new GraphicsComponent;
    }

    void build(GraphicsComponent component)
    {
        gservices.build(component);
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    void runLoop()
    in (mainLoop)
    {
        mainLoop.isRunning = true;
        mainLoop.runWait;
    }

    void stopLoop()
    in (mainLoop)
    {
        mainLoop.isRunning = false;
    }

    void requestQuit()
    {
        stopLoop;
        isProcessEvents = false;
    }

    void closeWindow(long id)
    {
        uservices.logger.tracef("Request close window with id '%s'", id);
        windowManager.closeWindow(id);

        if (windowManager.windowsCount == 0 && isQuitOnCloseAllWindows)
        {
            requestQuit;
        }
    }

    protected Extension createExtension(Logger logger, Config config, Context context)
    {
        auto extension = new Extension;

        //FIXME remove bindbc from core
        import bindbc.lua;

        const LuaSupport luaResult = loadLua();
        if (luaResult != luaSupport)
        {
            if (luaResult == luaSupport.noLibrary)
            {
                uservices.logger.warning("Lua shared library failed to load");
            }
            else if (luaResult == luaSupport.badLibrary)
            {
                uservices.logger.error("One or more Lua symbols failed to load");
            }

            import std.conv : to;

            uservices.logger.warningf("Couldn't load Lua environment, received lua load result: '%s'",
                to!string(luaSupport));
        }
        else
        {
            _graphicServices.cap.isEmbeddedScripting = true;
        }

        if (_graphicServices.cap.isEmbeddedScripting)
        {
            import deltotum.kit.extensions.plugins.lua.lua_script_text_plugin : LuaScriptTextPlugin;
            import deltotum.kit.extensions.plugins.lua.lua_file_script_plugin : LuaFileScriptPlugin;

            auto mustBeDataDir = context.appContext.dataDir;
            if (mustBeDataDir.isNull)
            {
                uservices.logger.warning("Data directory not found, plugins will not be loaded");
            }
            else
            {
                //TODO from config;
                import std.path : buildPath;

                const pluginsDir = buildPath(mustBeDataDir.get, "plugins");
                import std.file : dirEntries, DirEntry, SpanMode, exists, isFile, isDir;
                import std.path : buildPath, baseName;
                import std.format : format;
                import std.conv : to;

                foreach (DirEntry pluginFile; dirEntries(pluginsDir, SpanMode.shallow))
                {
                    if (!pluginFile.isDir)
                    {
                        continue;
                    }

                    //TODO from config
                    enum pluginMainMethod = "main";
                    const filePath = buildPath(pluginsDir, "main.lua");
                    if (!filePath.exists || !filePath.isFile)
                    {
                        continue;
                    }

                    const name = baseName(pluginFile);
                    auto plugin = new LuaFileScriptPlugin(logger, config, context, name, filePath, pluginMainMethod);
                    extension.addPlugin(plugin);
                }
            }

            auto consolePlugin = new LuaScriptTextPlugin(logger, config, context, "console");
            extension.addPlugin(consolePlugin);
        }

        extension.initialize;
        extension.run;

        return extension;
    }

    GraphicsComponent gservices() @nogc nothrow pure @safe
    out (_graphicServices; _graphicServices !is null)
    {
        return _graphicServices;
    }

    void gservices(GraphicsComponent services) pure @safe
    {
        import std.exception : enforce;

        enforce(services !is null, "Graphics services must not be null");
        _graphicServices = services;
    }
}
