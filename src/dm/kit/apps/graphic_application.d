module dm.kit.apps.graphic_application;

import dm.com.graphics.com_font : ComFont;
import dm.core.configs.config : Config;
import dm.core.contexts.context : Context;
import dm.core.apps.app_exit : AppExit;
import dm.core.apps.cli_application : CliApplication;
import dm.core.resources.resource : Resource;
import dm.kit.components.graphics_component : GraphicsComponent;
import dm.kit.components.window_component : WindowComponent;
import dm.core.components.uni_component : UniComponent;
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
import dm.kit.i18n.langs.alphabets.alphabet : Alphabet;

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
import dm.com.platforms.com_system: ComSystem;
import dm.kit.platforms.platform: Platform;

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
        Platform _platform;

        KitEventManager eventManager;
    }

    private
    {
        GraphicsComponent _graphicServices;

        //TODO themes, assets?
        Nullable!IconPack iconPack;
    }

    WindowManager windowManager;

    abstract ComSystem newComSystem();

    override AppExit initialize(string[] args)
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
            if (mustBeIconPath.isNull)
            {
                throw new Exception("Not found icons");
            }
            auto iconPath = mustBeIconPath.get;
            newIconPack.load(iconPath);
            iconPack = newIconPack;
            gservices.capGraphics.isIconPack = true;
            uservices.logger.trace("Load icon pack: ", iconPath);
        }

        profile("Load graphics settings");

        _platform = newPlatform;

        return AppExit(false);
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

    Platform newPlatform(){
        return new Platform(newComSystem, uservices.logger, uservices.config, uservices.context);
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
        import dm.core.components.uni_component : UniComponent;
        import dm.core.utils.type_util : castSafe;

        super.build(component.castSafe!UniComponent);

        component.isBuilt = false;
        component.audio = _audio;
        component.input = _input;
        component.screen = _screen;
        component.timer = _timer;
        component.platform = _platform;
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
            if (!win.isDisposed && !win.isStopped)
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

    void destroyWindowById(long winId)
    {
        auto mustBeWindow = windowManager.byFirstId(winId);
        if (mustBeWindow.isNull)
        {
            uservices.logger.error("No window found to close with id ", winId);
            return ;
        }
        destroyWindow(mustBeWindow.get);
    }

    void destroyWindow(Window window)
    {
        auto winId = window.id;
        uservices.logger.tracef("Request close window with id '%s'", winId);

        if(window.isRunning){
            window.stop;
        }

        window.close;

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

    Theme createTheme(Logger logger, Config config, Context context, Resource resource)
    {
        //TODO null?
        IconPack pack = iconPack.isNull ? null : iconPack.get;

        import dm.kit.graphics.themes.theme : Theme;
        import dm.kit.graphics.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logger, config, context, resource, pack);

        auto theme = themeLoader.createTheme;
        return theme;
    }

    Asset createAsset(Logger logger, Config config, Context context, ComFont delegate(
            string fontPath, size_t fontSize) comFontProvider)
    {
        import dm.kit.assets.fonts.font_size : FontSize;

        import KitConfigKeys = dm.kit.kit_config_keys;

        //TODO move to config, duplication with SdlApplication
        import std.file : getcwd, exists, isDir, isFile;
        import std.path : buildPath, dirName;

        auto mustBeResDir = uservices.resource.resourcesDir;

        import dm.kit.assets.asset : Asset;
        import dm.kit.assets.fonts.font : Font;

        //default dir?
        string assetsDir = !mustBeResDir.isNull ? mustBeResDir.get : null;

        Asset asset = new Asset(uservices.logger, assetsDir, comFontProvider);

        //TODO from config, allsystem;
        size_t fontSizeSmall = 8;
        size_t fontSizeMedium = 14;
        size_t fontSizeLarge = 20;

        string fontDir;
        string fontFile;

        if (!mustBeResDir.isNull)
        {
            fontDir = buildPath(mustBeResDir.get, asset.defaultFontResourceDir);
            logger.trace("Found font directory in resources: ", fontDir);
        }
        else
        {
            uservices.logger.trace("Resources directory not found");

            if (config.containsKey(KitConfigKeys.fontDir))
            {
                auto mustBeFontDir = config.getNotEmptyString(KitConfigKeys.fontDir);
                if (mustBeFontDir.isNull)
                {
                    throw new Exception(
                        "Font directory is empty for config key: " ~ KitConfigKeys
                            .fontDir);
                }

                fontDir = mustBeFontDir.get;
                logger.trace("Set font directory from config: ", fontDir);
            }
            else
            {
                logger.trace("Search font directory in system");
                //TODO Fontconfig 
                version (linux)
                {
                    ///usr/share/fonts/TTF/
                    fontDir = "/usr/share/fonts/truetype/noto/";
                    if (!fontFile)
                    {
                        fontFile = "NotoSansMono-Bold.ttf";
                    }
                }
                else version (Windows)
                {
                    //TODO test separators /, \
                    fontDir = "C:\\Windows\\Fonts";
                    if (!fontFile)
                    {
                        fontFile = "arial.ttf";
                    }
                }
                else version (OSX)
                {
                    fontDir = "/Library/Fonts";
                    if (!fontFile)
                    {
                        fontFile = "Arial.ttf";
                    }
                }
                else
                {
                    static assert(false, "Not supported default fonts for platform");
                }
                logger.tracef("Set system font directory %s and font file %s", fontDir, fontFile);
            }
        }

        if (!fontDir.exists || !fontDir.isDir)
        {
            //TODO on all platforms?
            throw new Exception(
                "Font directory does not exist or is not a directory: " ~ fontDir);
        }

        if (config.containsKey(KitConfigKeys.fontTTFFile))
        {
            logger.trace("Search font file in config with key: ", KitConfigKeys.fontTTFFile);
            if (config.containsKey(KitConfigKeys.fontIsOverwriteFontFile) && config.getBool(
                    KitConfigKeys.fontIsOverwriteFontFile).get)
            {
                fontFile = config.getNotEmptyString(KitConfigKeys.fontTTFFile).get;
                logger.trace("Set font file from config: ", fontFile);
            }
            else
            {
                logger.trace(
                    "Configuration does not allow overwriting the font file from config, config key: ", KitConfigKeys
                        .fontIsOverwriteFontFile);
            }
        }
        else
        {
            logger.trace("Not found font file from config with key: ", KitConfigKeys.fontTTFFile);
        }

        if (fontFile.length == 0)
        {
            throw new Exception("Font file is empty");
        }

        auto fontFilePath = buildPath(fontDir, fontFile);
        if (!fontFilePath.exists || !fontFilePath.isFile)
        {
            throw new Exception("Font path does not exist or not a file: " ~ fontFilePath);
        }

        //TODO default font
        asset = new Asset(uservices.logger, fontDir, comFontProvider);

        auto defaultSize = fontSizeMedium;
        if (config.containsKey(KitConfigKeys.fontSizeMedium))
        {
            logger.trace("Check font medium size in config with key: ", KitConfigKeys
                    .fontSizeMedium);
            auto mustBeNewSize = config.getLong(KitConfigKeys.fontSizeMedium);
            if (!mustBeNewSize.isNull)
            {
                defaultSize = mustBeNewSize.get;
                logger.trace("Set font default medium size from config: ", defaultSize);
            }
        }
        else
        {
            logger.tracef("Default font medium size is used: ", defaultSize);
        }

        Font defaultFont = asset.newFont(fontFilePath, defaultSize);
        asset.addFont(defaultFont);
        logger.trace("Create medium font with size %s from %s", defaultSize, fontFilePath);

        if (config.containsKey(KitConfigKeys.fontIsCreateSmall))
        {
            logger.trace("Checking creation small font in config with key: ", KitConfigKeys
                    .fontIsCreateSmall);
            const isSmallFontCreate = config.getBool(KitConfigKeys.fontIsCreateSmall);
            if (!isSmallFontCreate.isNull && isSmallFontCreate.get)
            {
                size_t size = fontSizeSmall;
                if (config.containsKey(KitConfigKeys.fontSizeSmall))
                {
                    logger.trace("Search small font size in config with key: ", KitConfigKeys
                            .fontSizeSmall);
                    const mustBeSmallSize = config.getPositiveLong(KitConfigKeys.fontSizeSmall);
                    if (!mustBeSmallSize.isNull)
                    {
                        size = mustBeSmallSize.get;
                        logger.trace("Set small font size from config: ", size);
                    }
                }
                else
                {
                    logger.trace("Default font small size is used: ", size);
                }

                Font fontSmall = asset.newFont(fontFilePath, size);
                asset.addFontSmall(fontSmall);
                logger.tracef("Create small font with size %s from file %s", size, fontFilePath);
            }
            else
            {
                logger.trace("The config does not allow creating a small font with key: ", KitConfigKeys
                        .fontIsCreateSmall);
            }
        }
        else
        {
            logger.trace("Config does not contain small font key: ", KitConfigKeys
                    .fontIsCreateSmall);
        }

        if (config.containsKey(KitConfigKeys.fontIsCreateLarge))
        {
            logger.trace("Checking creation large font in config with key: ", KitConfigKeys
                    .fontIsCreateLarge);

            const isLargeFontCreate = config.getBool(KitConfigKeys.fontIsCreateLarge);
            if (!isLargeFontCreate.isNull && isLargeFontCreate.get)
            {
                size_t size = fontSizeLarge;
                if (config.containsKey(KitConfigKeys.fontSizeLarge))
                {
                    logger.trace("Search large font size in config with key: ", KitConfigKeys
                            .fontSizeLarge);
                    const mustBeNewSize = config.getPositiveLong(KitConfigKeys.fontSizeLarge);
                    if (!mustBeNewSize.isNull)
                    {
                        size = mustBeNewSize.get;
                        logger.trace("Set large font size from config: ", size);
                    }
                }
                else
                {
                    logger.trace("Default font large size is used: ", size);
                }

                Font fontLarge = asset.newFont(fontFilePath, size);
                asset.addFontLarge(fontLarge);
                logger.tracef("Create large font with size %s from file %s", size, fontFilePath);
            }
            else
            {
                logger.trace("The config does not allow creating a large font with key: ", KitConfigKeys
                        .fontIsCreateLarge);
            }
        }
        else
        {
            logger.trace("The config does not contain the large font creation key: ", KitConfigKeys
                    .fontIsCreateLarge);
        }

        return asset;
    }

    BitmapFontGenerator newFontGenerator(Provider!ComSurface comSurfaceProvider)
    {
        return new BitmapFontGenerator(comSurfaceProvider);
    }

    Alphabet[] createMediumFontAlphabets()
    {
        import dm.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import dm.kit.i18n.langs.alphabets.alphabet_en : AlphabetEn;
        import dm.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import dm.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        Alphabet[] alphabets = [
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ];
        return alphabets;
    }

    Alphabet[] createSmallFontAlphabets()
    {
        import dm.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;
        import dm.kit.i18n.langs.alphabets.special_characters_alphabet : SpecialCharactersAlphabet;

        Alphabet[] alphabets = [
            new ArabicNumeralsAlpabet,
            new SpecialCharactersAlphabet,
        ];
        return alphabets;
    }

    Alphabet[] createLargFontAlphabets()
    {
        import dm.kit.i18n.langs.alphabets.arabic_numerals_alphabet : ArabicNumeralsAlpabet;

        Alphabet[] alphabets = [
            new ArabicNumeralsAlpabet,
        ];
        return alphabets;
    }

    //TODO split function
    void createFontBitmaps(BitmapFontGenerator generator, Asset assets, Theme theme, scope void delegate(
            BitmapFont) onBitmap)
    {
        //TODO from config
        auto colorText = theme.colorText;
        assets.defaultFontColor = colorText;
        uservices.logger.trace("Set default text color to ", colorText);

        auto colorTextBackground = theme.colorTextBackground;

        if (assets.hasFont)
        {
            auto font = assets.font;
            uservices.logger.trace("Found default font for default font bitmap: ", font.fontPath);
            BitmapFont bitmapFont = generator.generate(createMediumFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmapFont);
            assets.setFontBitmap(bitmapFont);
            uservices.logger.tracef("Create font bitmap with foreground %s and background %s", colorText, colorTextBackground);
        }

        if (assets.hasSmallFont)
        {
            auto font = assets.fontSmall;
            uservices.logger.trace("Found small font for bitmap: ", font.fontPath);
            BitmapFont bitmap = generator.generate(createSmallFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmap);
            assets.setFontBitmapSmall(bitmap);
            uservices.logger.tracef("Create small font bitmap with foreground %s and background %s", colorText, colorTextBackground);
        }

        if (assets.hasLargeFont)
        {
            auto font = assets.fontLarge;
            uservices.logger.trace("Found large font for bitmap: ", font.fontPath);
            BitmapFont bitmap = generator.generate(createLargFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmap);
            assets.setFontBitmapLarge(bitmap);
            uservices.logger.tracef("Create large font bitmap with foreground %s and background %s", colorText, colorTextBackground);
        }
    }

    GraphicsComponent gservices() nothrow pure @safe
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
