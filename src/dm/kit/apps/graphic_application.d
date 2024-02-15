module dm.kit.apps.graphic_application;

import dm.com.graphics.com_font : ComFont;
import dm.core.configs.config : Config;
import dm.core.contexts.context : Context;
import dm.core.apps.application_exit : ApplicationExit;
import dm.core.apps.cli_application : CliApplication;
import dm.core.resources.resource : Resource;
import dm.kit.apps.comps.graphics_component : GraphicsComponent;
import dm.kit.apps.comps.window_component : WindowComponent;
import dm.core.units.components.uni_component : UniComponent;
import dm.kit.windows.window_manager : WindowManager;
import dm.kit.apps.caps.cap_graphics : CapGraphics;
import dm.kit.graphics.graphics : Graphics;
import dm.kit.assets.asset : Asset;
import dm.kit.graphics.themes.icons.icon_pack : IconPack;
import dm.kit.sprites.textures.texture : Texture;
import dm.kit.graphics.themes.theme : Theme;
import dm.kit.assets.fonts.bitmap.bitmap_font_generator : BitmapFontGenerator;
import dm.kit.scenes.scene_manager : SceneManager;
import dm.kit.assets.fonts.bitmap.bitmap_font : BitmapFont;
import dm.core.utils.provider : Provider;

import dm.kit.windows.window : Window;
import dm.kit.apps.loops.loop : Loop;

import dm.kit.media.audio.audio : Audio;
import dm.kit.inputs.input : Input;
import dm.kit.screens.screen : Screen;
import dm.kit.timers.timer : Timer;
import dm.kit.events.kit_event_manager : KitEventManager;

import std.logger : Logger;
import std.typecons : Nullable;

import dm.com.graphics.com_renderer : ComRenderer;
import dm.com.graphics.com_surface : ComSurface;

/**
 * Authors: initkfs
 */
abstract class GraphicApplication : CliApplication
{
    bool isVideoEnabled;
    bool isAudioEnabled;
    bool isTimerEnabled;
    bool isJoystickEnabled;
    bool isIconPackEnabled;
    bool isHeadless;

    bool isQuitOnCloseAllWindows = true;

    protected
    {
        Audio _audio;
        Input _input;
        Screen _screen;
        Timer _timer;

        KitEventManager eventManager;
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

        profile("Start graphics");

        if (!_graphicServices)
        {
            _graphicServices = newGraphicServices;
        }

        if (!_graphicServices.hasCapGraphics)
        {
            _graphicServices.capGraphics = newCapability;
        }

        loadSettings;

        if (isIconPackEnabled)
        {
            auto newIconPack = new IconPack;
            //TODO config
            auto mustBeIconPath = uservices.resource.fileResource("icons/packs/ionicons.txt");
            if(mustBeIconPath.isNull){
                throw new Exception("Not found icons");
            }
            auto iconPath = mustBeIconPath.get;
            newIconPack.load(iconPath);
            iconPack = newIconPack;
            gservices.capGraphics.isIconPack = true;
            uservices.logger.trace("Load icon pack: ", iconPath);
        }

        profile("Load graphics settings");

        return ApplicationExit(false);
    }

    void loadSettings()
    {
        import KitConfigKeys = dm.kit.kit_config_keys;

        immutable isVideoFlag = uservices.config.getBool(KitConfigKeys.backendIsVideoEnabled);
        isVideoEnabled = isVideoFlag.isNull ? true : isVideoFlag.get;
        uservices.logger.trace("Video enabled: ", isVideoEnabled);

        immutable isAudioFlag = uservices.config.getBool(KitConfigKeys.backendIsAudioEnabled);
        isAudioEnabled = isAudioFlag.isNull ? false : isAudioFlag.get;
        uservices.logger.trace("Audio enabled: ", isAudioEnabled);

        immutable isTimerFlag = uservices.config.getBool(KitConfigKeys.backendIsTimerEnabled);
        isTimerEnabled = isTimerFlag.isNull ? false : isTimerFlag.get;
        uservices.logger.trace("Timer enabled: ", isTimerEnabled);

        immutable isJoystickFlag = uservices.config.getBool(KitConfigKeys.backendIsJoystickEnabled);
        isJoystickEnabled = isJoystickFlag.isNull ? false : isJoystickFlag.get;
        uservices.logger.trace("Joystick enabled: ", isJoystickEnabled);

        immutable isIconPackFlag = uservices.config.getBool(KitConfigKeys.backendIsIconPackEnabled);
        isIconPackEnabled = isIconPackFlag.isNull ? true : isIconPackFlag.get;
        uservices.logger.trace("Icon pack enabled: ", isIconPackEnabled);
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
        import dm.core.units.components.uni_component : UniComponent;
        import dm.core.utils.type_util : castSafe;

        super.build(component.castSafe!UniComponent);

        component.isBuilt = false;
        component.audio = _audio;
        component.input = _input;
        component.screen = _screen;
        component.timer = _timer;
        component.capGraphics = gservices.capGraphics;
        component.eventManager = eventManager;
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    override void run()
    {
        super.run;
        windowManager.onWindows((win) {
            win.run;
            assert(win.isRunning);
            return true;
        });
    }

    override void stop()
    {
        super.stop;
        windowManager.onWindows((win) {
            if (!win.isStopped)
            {
                win.stop;
                assert(win.isStopped);
            }
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

    Graphics createGraphics(Logger logger, ComRenderer renderer, Theme theme)
    {
        return new Graphics(logger, renderer, theme);
    }

    Theme createTheme(Logger logger, Config config, Context context, Resource resource, Asset asset)
    {
        //TODO null?
        IconPack pack = iconPack.isNull ? null : iconPack.get;

        import dm.kit.graphics.themes.theme : Theme;
        import dm.kit.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logger, config, context, resource, asset
                .font, pack);

        auto theme = themeLoader.createTheme;
        return theme;
    }

    Asset createAsset(Logger logger, Config config, Context context, ComFont delegate(
            string fontPath, int fontSize) comFontProvider)
    {
        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir, isFile;
        import std.path : buildPath, dirName;

        auto mustBeResDir = uservices.resource.resourcesDir;

        import dm.kit.assets.asset : Asset;
        import dm.kit.assets.fonts.font : Font;

        Asset asset;
        if (!mustBeResDir.isNull)
        {
            auto assetsDir = mustBeResDir.get;
            logger.trace("Found resources directory: ", assetsDir);
            //TODO from config
            asset = new Asset(uservices.logger, assetsDir, comFontProvider);
            Font font = asset.newFont(
                "JetBrains_Mono/static/JetBrainsMono-ExtraBold.ttf", 15);
            asset.font = font;
        }
        else
        {
            uservices.logger.warning("Resources directory not found");

            import KitConfigKeys = dm.kit.kit_config_keys;

            string fontFile;
            if (config.containsKey(KitConfigKeys.fontDefaultTTFFile))
            {
                fontFile = config.getNotEmptyString(KitConfigKeys.fontDefaultTTFFile).get;
            }

            //TODO allsystem;
            string fontPath;
            if (config.containsKey(KitConfigKeys.fontSystemDefaultDir))
            {
                auto mustBeFontDir = config.getNotEmptyString(KitConfigKeys.fontSystemDefaultDir);
                if (mustBeFontDir.isNull)
                {
                    throw new Exception(
                        "System font dir is empty for config key: " ~ KitConfigKeys
                            .fontSystemDefaultDir);
                }
                fontPath = mustBeFontDir.get;

                if (!fontPath.exists || !fontPath.isDir)
                {
                    throw new Exception(
                        "The system font directory does not exist or is not a directory: " ~ fontPath);
                }
            }
            else
            {
                //TODO Fontconfig 
                version (linux)
                {
                    ///usr/share/fonts/TTF/
                    fontPath = "/usr/share/fonts/truetype/noto/";
                    if (!fontFile)
                    {
                        fontFile = "NotoSansMono-Bold.ttf";
                    }
                }
                else version (Windows)
                {
                    //TODO test separators /, \
                    fontPath = "C:\\Windows\\Fonts";
                    if (!fontFile)
                    {
                        fontFile = "arial.ttf";
                    }
                }
                else version (OSX)
                {
                    fontPath = "/Library/Fonts";
                    if (!fontFile)
                    {
                        fontFile = "Arial.ttf";
                    }
                }
                else
                {
                    static assert(false, "Not supported default fonts for platform");
                }
            }

            import std.path : buildPath;

            auto fontFilePath = buildPath(fontPath, fontFile);
            if (!fontFilePath.exists || !fontFilePath.isFile)
            {
                throw new Exception("Not found default system font: " ~ fontFilePath);
            }        

            //TODO default font
            asset = new Asset(uservices.logger, fontPath, comFontProvider);
            asset.defaultFontResourceDir = null;
            Font font = asset.newFont(fontFile, 15);
            asset.font = font;
        }

        return asset;
    }

    BitmapFontGenerator newFontGenerator(Provider!ComSurface comSurfaceProvider)
    {
        return new BitmapFontGenerator(comSurfaceProvider);
    }

    BitmapFont createFontBitmap(BitmapFontGenerator generator, Asset asset, Theme theme)
    {
        import dm.kit.graphics.colors.rgba : RGBA;
        import dm.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import dm.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import dm.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import dm.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

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
