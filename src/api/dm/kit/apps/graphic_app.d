module api.dm.kit.apps.graphic_app;

import api.dm.com.graphics.com_font : ComFont;
import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.resources.resourcing : Resourcing;
import api.core.apps.cli_app : CliApp;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.dm.kit.components.graphic_component : GraphicComponent;
import api.core.components.uni_component : UniComponent;
import api.dm.kit.graphics.graphic : Graphic;
import api.dm.kit.graphics.gpu.gpu_graphic : GPUGraphic;
import api.dm.kit.assets.asset : Asset;

import api.dm.kit.sprites2d.textures.texture2d : Texture2d;
import api.dm.kit.assets.fonts.bitmaps.alphabet_font_factory : AlphabetFontFactory;
import api.dm.kit.assets.fonts.bitmaps.bitmap_font : BitmapFont;
import api.core.utils.types : ProviderFactory;
import api.dm.kit.i18n.langs.alphabets.alphabet : Alphabet;
import api.dm.kit.factories.image_factory : ImageFactory;
import api.dm.kit.factories.shape_factory : ShapeFactory;

import api.dm.kit.windows.window : Window;
import api.dm.kit.apps.loops.loop : Loop;

import api.dm.kit.media.multimedia : MultiMedia;
import api.dm.kit.inputs.input : Input;
import api.dm.kit.events.kit_event_manager : KitEventManager;

import api.dm.com.graphics.com_renderer : ComRenderer;
import api.dm.com.graphics.com_surface : ComSurface;
import api.dm.com.platforms.com_platform : ComPlatform;
import api.dm.kit.platforms.platform : Platform;
import api.dm.kit.platforms.screens.screening : Screening;
import api.dm.kit.platforms.caps.cap_graphics : CapGraphics;
import api.dm.kit.platforms.timers.timing : Timing;
import api.dm.com.graphics.com_screen : ComScreen;
import api.dm.kit.i18n.i18n : I18n;
import api.dm.kit.i18n.langs.lang_messages : LangMessages;
import api.dm.gui.interacts.interact : Interact;
import api.dm.kit.factories.factory_kit : FactoryKit;
import api.dm.kit.windows.windowing : Windowing;
import api.dm.kit.graphics.colors.rgba : RGBA;

import api.core.validations.validators.validator : Validator;

/**
 * Authors: initkfs
 */
abstract class GraphicApp : CliApp
{
    bool isAudioEnabled;
    bool isJoystickEnabled;

    bool isHeadless;

    bool isQuitOnCloseAllWindows = true;

    protected
    {
        MultiMedia _media;
        Input _input;
        Screening _screening;
        Platform _platform;
        Windowing _windowing;
        I18n _i18n;

        KitEventManager eventManager;
    }

    private
    {
        GraphicComponent _graphicServices;
    }

    abstract
    {
        ComPlatform newComPlatform();
        ComScreen newComScreen();
    }

    override bool initialize(string[] args)
    {
        if (!super.initialize(args))
        {
            return false;
        }

        if (!_graphicServices)
        {
            //TODO meta?
            _graphicServices = newGraphicServices;
            uservices.build(_graphicServices);
        }

        _platform = createPlatform;

        if (!_graphicServices.hasPlatform)
        {
            _graphicServices.platform = _platform;
        }

        loadSettings;

        _i18n = createI18n(uservices.logging, uservices.config, uservices.context);

        return true;
    }

    abstract ulong ticksMs();

    void loadSettings()
    {
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (uservices.config.hasKey(KitConfigKeys.backendIsAudio))
        {
            //TODO remove
            isAudioEnabled = uservices.config.getBool(KitConfigKeys.backendIsAudio);
            _graphicServices.platform.cap.isAudio = isAudioEnabled;
        }

        if (uservices.config.hasKey(KitConfigKeys.backendIsJoystick))
        {
            isJoystickEnabled = uservices.config.getBool(KitConfigKeys.backendIsJoystick);
            _graphicServices.platform.cap.isJoystick = isJoystickEnabled;
        }

        if (uservices.config.hasKey(KitConfigKeys.graphicsIsImage))
        {
            _graphicServices.platform.cap.isImage = uservices.config.getBool(
                KitConfigKeys.graphicsIsImage);
        }

        if (uservices.config.hasKey(KitConfigKeys.graphicsIsVector))
        {
            _graphicServices.platform.cap.isVector = uservices.config.getBool(
                KitConfigKeys.graphicsIsVector);
        }

        if (uservices.config.hasKey(KitConfigKeys.graphicsIsIconPack))
        {
            _graphicServices.platform.cap.isIconPack = uservices.config.getBool(
                KitConfigKeys.graphicsIsIconPack);
        }

        if (uservices.config.hasKey(KitConfigKeys.backendIsPointer))
        {
            _graphicServices.platform.cap.isPointer = uservices.config.getBool(
                KitConfigKeys.backendIsPointer);
        }

        if (uservices.config.hasKey(KitConfigKeys.backendIsGPU))
        {
            _graphicServices.platform.cap.is3d = uservices.config.getBool(
                KitConfigKeys.backendIsGPU);
        }
    }

    override Validator[] createAppValidators()
    {
        Validator[] parent = super.createAppValidators;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        string[] kitConfigKeys;
        kitConfigKeys.reserve(10);

        foreach (key; __traits(allMembers, KitConfigKeys))
        {
            if (key == "object")
            {
                continue;
            }

            kitConfigKeys ~= key;
        }

        if (kitConfigKeys.length > 0)
        {
            assert(_graphicServices, "Graphic services is null");
            assert(_graphicServices.hasConfigs, "Graphics services without config");
            parent ~= createConfigValidator(_graphicServices.config, kitConfigKeys);
        }

        return parent;
    }

    Platform createPlatform()
    {
        auto sysPlaftorm = newComPlatform;
        auto caps = newCapGraphics;
        auto timing = newTiming(sysPlaftorm, () => ticksMs);
        auto screening = newScreening;
        return newPlatform(sysPlaftorm, caps, screening, timing);
    }

    CapGraphics newCapGraphics() => new CapGraphics;

    Screening newScreening()
    {
        return new Screening(newComScreen, uservices.logging);
    }

    Platform newPlatform(ComPlatform platform, CapGraphics caps, Screening screens, Timing timing)
    {
        return new Platform(platform, caps, screens, timing);
    }

    Timing newTiming(ComPlatform comPlatform, ulong delegate() tickProvider)
    {
        return new Timing(comPlatform, tickProvider);
    }

    I18n newI18n()
    {
        return new I18n(uservices.logging);
    }

    I18n createI18n(Logging logging, Config config, Context context)
    {
        const dataDir = context.app.dataDir;
        if (dataDir.length == 0)
        {
            logging.logger.info("Not found data dir, i18n not loaded");
            return newI18n;
        }

        import std.path : buildPath;
        import std.file : exists, isDir, dirEntries, SpanMode;
        import std.algorithm.iteration : filter;

        //TODO from config;
        auto langDir = buildPath(dataDir, "langs");
        if (!langDir.exists || !langDir.isDir)
        {
            logging.logger.info("Not found language dir: ", langDir);
            return newI18n;
        }

        import api.dm.kit.i18n.langs.configs.simple_config_loader : SimpleConfigLoader;
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        string lang = "en_EN";
        if (config.hasKey(KitConfigKeys.i18nLang))
        {
            lang = config.getNotEmptyString(KitConfigKeys.i18nLang);
        }

        LangMessages[] messages;

        auto langLoader = new SimpleConfigLoader;
        langLoader.allowedLangs ~= lang;

        foreach (langFile; dirEntries(langDir, SpanMode
                .depth).filter!(f => f.isFile))
        {
            auto newMessages = langLoader.loadFile(langFile);
            messages ~= new LangMessages(newMessages);
            version (EnableTrace)
            {
                logging.logger.tracef("Load for lang '%s' i18n messages: %s", lang, langFile);
            }
        }

        auto i18n = newI18n;
        i18n.lang = lang;
        i18n.langMessages = messages;

        return i18n;
    }

    GraphicComponent newWindowServices()
    {
        return new GraphicComponent;
    }

    GraphicComponent newGraphicServices()
    {
        return new GraphicComponent;
    }

    void build(GraphicComponent component)
    {
        gservices.build(component);
    }

    protected void buildPartially(GraphicComponent component)
    {
        import api.core.components.uni_component : UniComponent;
        import api.core.utils.types : castSafe;

        super.build(component.castSafe!UniComponent);

        component.isBuilt = false;
        component.media = _media;
        component.input = _input;
        component.platform = _platform;
        component.i18n = _i18n;
        component.windowing = windowing;
    }

    override void build(UniComponent component)
    {
        return super.build(component);
    }

    override void run()
    {
        super.run;
        windowing.onWindows((win) { win.run; assert(win.isRunning); return true; });
    }

    override void stop()
    {
        super.stop;
        windowing.onWindows((win) {
            if (!win.isDisposed && !win.isStopping)
            {
                win.stop;
                assert(win.isStopping);
            }
            return true;
        });
    }

    override void dispose()
    {
        if (_media && !_media.isDisposing)
        {
            _media.dispose;
        }

        if (_input)
        {
            _input.dispose;
        }

        // if (_screen)
        // {
        //     _screen.dispose;
        // }

        // if (_timer)
        // {
        //     _timer.dispose;
        //     uservices.logger.trace("Dispose timer");
        // }

        if (_platform)
        {
            _platform.dispose;
        }

        // if(eventManager){
        //     eventManager.dispose;
        // }
        super.dispose;
    }

    void exit()
    {
        if (uservices && uservices.hasLogging)
        {
            uservices.logger.tracef("Request quit");
        }

        if (isRunning)
        {
            stop;
        }

        dispose;
    }

    Graphic createGraphics(Logging logging, ComRenderer renderer)
    {
        return new Graphic(logging, renderer);
    }

    Asset createAsset(Logging logging, Config config, Context context, ComFont delegate() comFontProvider)
    {
        import api.dm.kit.assets.fonts.font_size : FontSize;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        //TODO move to config, duplication with SdlApp
        import std.file : getcwd, exists, isDir, isFile;
        import std.path : buildPath, dirName;

        auto mustBeResDir = uservices.reslocal.resourcesDir;

        import api.dm.kit.assets.asset : Asset;
        import api.dm.com.graphics.com_font : ComFont;

        //default dir?
        string assetsDir = mustBeResDir;

        Asset asset = new Asset(uservices.logging, assetsDir, comFontProvider);

        uint fontSizeSmall = 8;
        uint fontSizeMedium = 14;
        uint fontSizeLarge = 20;

        string fontDir;
        string fontFile;

        if (mustBeResDir.length > 0)
        {
            fontDir = buildPath(mustBeResDir, asset.defaultFontResourceDir);
            version (EnableTrace)
            {
                logging.logger.trace("Found font directory in resources: ", fontDir);
            }
        }
        else
        {
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
            version (EnableTrace)
            {
                logging.logger.tracef("Set system font directory %s and font file %s", fontDir, fontFile);
            }
        }

        if (config.hasKey(KitConfigKeys.fontTTFFile))
        {
            version (EnableTrace)
            {
                logging.logger.trace("Search font file in config with key: ", KitConfigKeys
                        .fontTTFFile);
            }
            if (config.hasKey(KitConfigKeys.fontIsOverwriteFontFile) && config.getBool(
                    KitConfigKeys.fontIsOverwriteFontFile))
            {
                fontFile = config.getNotEmptyString(KitConfigKeys.fontTTFFile);
                version (EnableTrace)
                {
                    logging.logger.trace("Set font file from config: ", fontFile);
                }
            }
            else
            {
                version (EnableTrace)
                {
                    logging.logger.trace(
                        "Configuration does not allow overwriting the font file from config, config key: ", KitConfigKeys
                            .fontIsOverwriteFontFile);
                }
            }
        }
        else
        {
            version (EnableTrace)
            {
                logging.logger.trace("Not found font file from config with key: ", KitConfigKeys
                        .fontTTFFile);
            }
        }

        if (fontFile.length > 0)
        {
            auto fontFilePath = buildPath(fontDir, fontFile);
            if (!fontFilePath.exists || !fontFilePath.isFile)
            {
                throw new Exception("Font path does not exist or not a file: " ~ fontFilePath);
            }

            auto defaultSize = fontSizeMedium;
            if (config.hasKey(KitConfigKeys.fontSizeMedium))
            {
                defaultSize = cast(uint) config.getPositiveLong(KitConfigKeys.fontSizeMedium);
            }

            ComFont defaultFont = asset.newFont(fontFilePath, defaultSize);
            asset.addFont(defaultFont);

            version (EnableTrace)
            {
                logging.logger.tracef("Create medium font with size %s from %s", defaultSize, fontFilePath);
            }

            if (config.hasKey(KitConfigKeys.fontIsCreateSmall) && config.getBool(
                    KitConfigKeys.fontIsCreateSmall))
            {
                uint size = fontSizeSmall;
                if (config.hasKey(KitConfigKeys.fontSizeSmall))
                {
                    size = cast(uint) config.getPositiveLong(KitConfigKeys.fontSizeSmall);
                }

                ComFont fontSmall = asset.newFont(fontFilePath, size);
                asset.addFontSmall(fontSmall);
                version (EnableTrace)
                {
                    logging.logger.tracef("Create small font with size %s from file %s", size, fontFilePath);
                }
            }

            if (config.hasKey(KitConfigKeys.fontIsCreateLarge) && config.getBool(
                    KitConfigKeys.fontIsCreateLarge))
            {
                uint size = fontSizeLarge;
                if (config.hasKey(KitConfigKeys.fontSizeLarge))
                {
                    size = cast(uint) config.getPositiveLong(KitConfigKeys.fontSizeLarge);
                }

                ComFont fontLarge = asset.newFont(fontFilePath, size);
                asset.addFontLarge(fontLarge);
                version (EnableTrace)
                {
                    logging.logger.tracef("Create large font with size %s from file %s", size, fontFilePath);
                }
            }
        }

        return asset;
    }

    AlphabetFontFactory newFontGenerator()
    {
        return new AlphabetFontFactory;
    }

    Alphabet[] createMediumFontAlphabets()
    {
        import api.dm.kit.i18n.langs.alphabets.alphabet_ru : AlphabetRu;
        import api.dm.kit.i18n.langs.alphabets.en : AlphabetEn;
        import api.dm.kit.i18n.langs.alphabets.arabic_num_alphabet : ArabicNumAlpabet;
        import api.dm.kit.i18n.langs.alphabets.special_alphabet : SpecialAlphabet;

        Alphabet[] alphabets = [
            new ArabicNumAlpabet,
            new SpecialAlphabet,
            new AlphabetEn,
            new AlphabetRu
        ];
        return alphabets;
    }

    Alphabet[] createSmallFontAlphabets()
    {
        import api.dm.kit.i18n.langs.alphabets.arabic_num_alphabet : ArabicNumAlpabet;
        import api.dm.kit.i18n.langs.alphabets.special_alphabet : SpecialAlphabet;
        import api.dm.kit.i18n.langs.alphabets.en : AlphabetEn;

        Alphabet[] alphabets = [
            new ArabicNumAlpabet,
            new SpecialAlphabet,
            new AlphabetEn
        ];
        return alphabets;
    }

    Alphabet[] createLargeFontAlphabets()
    {
        import api.dm.kit.i18n.langs.alphabets.arabic_num_alphabet : ArabicNumAlpabet;
        import api.dm.kit.i18n.langs.alphabets.light_special_alphabet : LightSpecialAlphabet;

        Alphabet[] alphabets = [
            new ArabicNumAlpabet,
            new LightSpecialAlphabet,
        ];
        return alphabets;
    }

    bool isFontTextureIsColorless(Config config, Context context)
    {
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (config.hasKey(KitConfigKeys.fontDefaultTextureIsColorless))
        {
            return config.getBool(KitConfigKeys.fontDefaultTextureIsColorless);
        }

        return false;
    }

    //TODO split function
    void createFontBitmaps(AlphabetFontFactory generator, Asset assets, RGBA colorText, RGBA colorTextBackground, scope void delegate(
            BitmapFont) onBitmap)
    {
        //TODO from config
        assets.defaultFontColor = colorText;
        version (EnableTrace)
        {
            uservices.logger.trace("Set default text color to ", colorText);
        }

        if (assets.hasFont)
        {
            auto font = assets.font;
            version (EnableTrace)
            {
                uservices.logger.trace("Found default font for default font bitmap: ", font
                        .getFontPath);
            }
            BitmapFont bitmapFont = generator.generate(createMediumFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmapFont);
            assets.setFontBitmap(bitmapFont);
            version (EnableTrace)
            {
                uservices.logger.tracef("Create font bitmap with foreground %s and background %s", colorText, colorTextBackground);
            }
        }

        if (assets.hasSmallFont)
        {
            auto font = assets.fontSmall;
            version (EnableTrace)
            {
                uservices.logger.trace("Found small font for bitmap: ", font.getFontPath);
            }
            BitmapFont bitmap = generator.generate(createSmallFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmap);
            assets.setFontBitmapSmall(bitmap);
            version (EnableTrace)
            {
                uservices.logger.tracef("Create small font bitmap with foreground %s and background %s", colorText, colorTextBackground);
            }
        }

        if (assets.hasLargeFont)
        {
            auto font = assets.fontLarge;
            version (EnableTrace)
            {
                uservices.logger.trace("Found large font for bitmap: ", font.getFontPath);
            }
            BitmapFont bitmap = generator.generate(createLargeFontAlphabets, font, colorText, colorTextBackground);
            onBitmap(bitmap);
            assets.setFontBitmapLarge(bitmap);
            version (EnableTrace)
            {
                uservices.logger.tracef("Create large font bitmap with foreground %s and background %s", colorText, colorTextBackground);
            }
        }
    }

    GraphicComponent gservices() nothrow pure @safe
    out (_graphicServices; _graphicServices !is null)
    {
        return _graphicServices;
    }

    void gservices(GraphicComponent services) pure @safe
    {
        if (!services)
        {
            throw new Exception("Graphic services must not be null");
        }
        _graphicServices = services;
    }

    bool hasWindowing() => _windowing !is null;

    Windowing windowing()
    {
        assert(_windowing);
        return _windowing;
    }
}
