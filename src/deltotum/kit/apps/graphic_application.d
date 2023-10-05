module deltotum.kit.apps.graphic_application;

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.comps.graphics_component : GraphicsComponent;
import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.core.extensions.extension : Extension;
import deltotum.kit.apps.caps.cap_graphics : CapGraphics;
import deltotum.kit.assets.asset : Asset;
import deltotum.gui.themes.icons.icon_pack : IconPack;
import deltotum.gui.themes.theme : Theme;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.loops.loop : Loop;

import std.logger : Logger;
import std.typecons : Nullable;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    bool isVideoEnabled = true;
    bool isAudioEnabled;
    bool isTimerEnabled;
    bool isJoystickEnabled;
    bool isIconPackEnabled = true;

    bool isQuitOnCloseAllWindows = true;

    private
    {
        GraphicsComponent _graphicServices;

        //TODO themes, assets?
        Nullable!IconPack iconPack;
    }

    WindowManager windowManager;

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

        if (!_graphicServices.hasCapGraphics)
        {
            _graphicServices.capGraphics = newCapability;
        }

        if (isIconPackEnabled)
        {
            auto newIconPack = new IconPack;
            newIconPack.load;
            iconPack = newIconPack;
            gservices.capGraphics.isIconPack = true;
        }

        return ApplicationExit(false);
    }

    CapGraphics newCapability()
    {
        return new CapGraphics;
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

    void requestQuit()
    {
        if (uservices && uservices.logger)
        {
            uservices.logger.tracef("Request quit");
        }
    }

    void closeWindow(long id)
    {
        uservices.logger.tracef("Request close window with id '%s'", id);
        windowManager.closeWindow(id);

        if (windowManager.windowsCount == 0 && isQuitOnCloseAllWindows)
        {
            uservices.logger.tracef("All windows are closed, exit request");
            requestQuit;
        }
    }

    Theme createTheme(Logger logger, Config config, Context context, Asset asset)
    {
        //TODO null?
        IconPack pack = iconPack.isNull ? null : iconPack.get;

        import deltotum.gui.themes.theme : Theme;
        import deltotum.kit.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(uservices.logger, uservices.config, uservices.context, asset
                .defaultFont, pack);

        auto theme = themeLoader.createTheme;
        return theme;
    }

    Asset createAsset(Logger logger, Config config, Context context)
    {
        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        immutable assetsDirPath = "data/assets";
        immutable assetsDir = buildPath(getcwd, assetsDirPath);

        import deltotum.kit.assets.asset : Asset;

        auto asset = new Asset(uservices.logger, assetsDir);

        import deltotum.kit.assets.fonts.font : Font;

        //TODO from config
        Font defaultFont = asset.font(
            "fonts/JetBrains_Mono/static/JetBrainsMono-ExtraBold.ttf", 15);
        asset.defaultFont = defaultFont;

        return asset;
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
