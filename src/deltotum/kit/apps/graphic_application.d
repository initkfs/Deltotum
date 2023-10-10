module deltotum.kit.apps.graphic_application;

import deltotum.core.configs.config : Config;
import deltotum.core.contexts.context : Context;
import deltotum.core.apps.application_exit : ApplicationExit;
import deltotum.core.apps.cli_application : CliApplication;
import deltotum.kit.apps.comps.graphics_component : GraphicsComponent;
import deltotum.kit.apps.comps.window_component : WindowComponent;
import deltotum.core.apps.uni.uni_component : UniComponent;
import deltotum.kit.windows.window_manager : WindowManager;
import deltotum.core.extensions.extension : Extension;
import deltotum.kit.apps.caps.cap_graphics : CapGraphics;
import deltotum.kit.graphics.graphics : Graphics;
import deltotum.kit.assets.asset : Asset;
import deltotum.kit.graphics.themes.icons.icon_pack : IconPack;
import deltotum.kit.sprites.textures.texture : Texture;
import deltotum.kit.graphics.themes.theme : Theme;
import deltotum.gui.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;
import deltotum.kit.scenes.scene_manager : SceneManager;
import deltotum.gui.fonts.bitmap.bitmap_font : BitmapFont;

import deltotum.kit.windows.window : Window;
import deltotum.kit.apps.loops.loop : Loop;

import deltotum.media.audio.audio : Audio;
import deltotum.kit.inputs.input : Input;
import deltotum.kit.screens.screen : Screen;

import std.logger : Logger;
import std.typecons : Nullable;

//TODO replace with ComRenderer
import deltotum.sys.sdl.sdl_renderer : SdlRenderer;

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

    protected
    {
        Audio _audio;
        Input _input;
        Screen _screen;
    }

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

    SceneManager newSceneManager(Logger logger, Config config, Context context)
    {
        return new SceneManager;
    }

    WindowComponent newWindowServices()
    {
        return new WindowComponent;
    }

    GraphicsComponent newGraphicServices()
    {
        return new GraphicsComponent;
    }

    void build(GraphicsComponent component)
    {
        gservices.build(component);
    }

    protected void buildPartially(GraphicsComponent component)
    {
        import deltotum.core.apps.uni.uni_component : UniComponent;

        super.build(cast(UniComponent) component);

        component.isBuilt = false;

        component.audio = _audio;
        component.input = _input;
        component.screen = _screen;
        component.capGraphics = gservices.capGraphics;
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    override void run()
    {
        super.run;
        windowManager.onWindows((win){
            win.run;
            assert(win.isRunning);
            return true;
        });
    }

    override void stop()
    {
        super.stop;
        windowManager.onWindows((win){
            win.stop;
            assert(win.isStopped);
            return true;
        });
    }

    void requestQuit()
    {
        if (uservices && uservices.logger)
        {
            uservices.logger.tracef("Request quit");
        }
    }

    void destroyWindow(long id)
    {
        uservices.logger.tracef("Request close window with id '%s'", id);
        windowManager.dispose(id);

        if (windowManager.count == 0 && isQuitOnCloseAllWindows)
        {
            uservices.logger.tracef("All windows are closed, exit request");
            requestQuit;
        }
    }

    Graphics createGraphics(Logger logger, SdlRenderer renderer, Theme theme)
    {
        return new Graphics(logger, renderer, theme);
    }

    Theme createTheme(Logger logger, Config config, Context context, Asset asset)
    {
        //TODO null?
        IconPack pack = iconPack.isNull ? null : iconPack.get;

        import deltotum.kit.graphics.themes.theme : Theme;
        import deltotum.kit.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(uservices.logger, uservices.config, uservices.context, asset
                .font, pack);

        auto theme = themeLoader.createTheme;
        return theme;
    }

    Asset createAsset(Logger logger, Config config, Context context)
    {
        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir;
        import std.path : buildPath, dirName;

        auto mustBeResDir = uservices.resource.resourcesDir;
        if (mustBeResDir.isNull)
        {
            throw new Exception("Resources directory not found");
        }

        immutable string assetsDir = mustBeResDir.get;

        import deltotum.kit.assets.asset : Asset;

        auto asset = new Asset(uservices.logger, assetsDir);

        import deltotum.kit.assets.fonts.font : Font;

        //TODO from config
        Font font = asset.newFont(
            "fonts/JetBrains_Mono/static/JetBrainsMono-ExtraBold.ttf", 15);
        asset.font = font;

        return asset;
    }

    BitmapFontGenerator newFontGenerator()
    {
        return new BitmapFontGenerator;
    }

    BitmapFont createFontBitmap(BitmapFontGenerator generator, Asset asset, Theme theme)
    {
        import deltotum.kit.graphics.colors.rgba : RGBA;
        import deltotum.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import deltotum.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import deltotum.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import deltotum.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        //TODO from config
        BitmapFont bitmapFont = generator.generate(
            [
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ], asset.font, RGBA.white, theme.colorTextBackground);

        return bitmapFont;
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
