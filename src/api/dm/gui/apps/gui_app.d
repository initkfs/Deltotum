module api.dm.gui.apps.gui_app;

import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.dm.kit.apps.loop_app : LoopApp;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.core.validations.validators.validator : Validator;

import api.dm.com.graphics.com_font : ComFont;
import api.dm.kit.assets.asset : Asset;

abstract class GuiApp : LoopApp
{
    string themeDir = "themes";

    protected
    {
        Theme theme;
        Interact interact;
    }

    override bool initialize(string[] args)
    {
        if (!super.initialize(args))
        {
            return false;
        }

        theme = createTheme(uservices.logging, uservices.config, uservices
                .context);
        assert(theme);

        interact = createInteract(uservices.logging, uservices.config, uservices
                .context);
        assert(interact);

        return true;
    }

    Theme createTheme(Logging logging, Config config, Context context)
    {
        import std.path : buildPath, isAbsolute;
        import std.file : isDir, exists, isFile;

        string mustBeThemeDir = themeDir;
        if (mustBeThemeDir.length > 0 && !mustBeThemeDir.isAbsolute)
        {
            const mustBeDataDir = context.app.dataDir;
            mustBeThemeDir = buildPath(mustBeDataDir, mustBeThemeDir);
            // logging.logger.trace(
            //     "Set theme directory path to " ~ mustBeThemeDir);
        }

        if (mustBeThemeDir.length == 0 || (!mustBeThemeDir.exists) || (!mustBeThemeDir.isDir))
        {
            logging.logger.trace("Not found theme dir: " ~ mustBeThemeDir);
            return newDefaultTheme;
        }

        import GuiConfigKeys = api.dm.gui.gui_config_keys;

        string currentTheme;
        if (config.hasKey(GuiConfigKeys.guiTheme))
        {
            currentTheme = config.getNotEmptyString(GuiConfigKeys.guiTheme);
        }

        if (currentTheme.length == 0)
        {
            logging.logger.trace("Current theme name is null");
            return newDefaultTheme;
        }

        auto themeFile = buildPath(mustBeThemeDir, currentTheme ~ ".config");
        if (!themeFile.exists || !themeFile.isFile)
        {
            logging.logger.trace("Not found theme file: " ~ themeFile);
            return newDefaultTheme;
        }

        try
        {
            import api.core.configs.keyvalues.properties.property_config : PropertyConfig;
            import api.dm.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

            Config themeConfig = new PropertyConfig(themeFile);
            themeConfig.load;

            auto themeLoader = new ThemeFromConfigFactory(logging, themeConfig, context);
            auto theme = themeLoader.createTheme;
            if (!theme)
            {
                throw new Exception("Theme from loader is null");
            }
            theme.iconPack = newIconPack;
            logging.logger.trace("Load theme: " ~ themeFile);
            return theme;
        }
        catch (Exception e)
        {
            logging.logger.error(e.toString);
        }

        return newDefaultTheme;
    }

    Theme newDefaultTheme()
    {
        auto theme = newTheme;
        theme.iconPack = newIconPack;
        return theme;
    }

    Theme newTheme() => new Theme;

    version (EnableValidation)
    {
        override Validator[] createValidators()
        {
            Validator[] parent = super.createValidators;

            import I18nKeys = api.dm.gui.gui_i18n_keys;

            string[] keys;
            keys.reserve(20);

            import api.core.utils.types : moduleIter;

            moduleIter!(I18nKeys)((key) { keys ~= key; });

            if (keys.length > 0)
            {
                assert(gservices, "Graphic services is null");
                assert(gservices.hasI18n, "Graphics without i18n");

                import api.dm.kit.i18n.langs.validators.lang_key_validator : LangKeyValidator;

                parent ~= new LangKeyValidator(gservices.i18n, keys);
            }

            return parent;
        }
    }

    IconPack newIconPack() => new IconPack;

    Interact createInteract(Logging logging, Config config, Context context)
    {
        return new Interact;
    }

    override Asset createAsset(Logging logging, Config config, Context context, ComFont delegate() comFontProvider, bool isLoadFont)
    {
        import api.dm.kit.assets.fonts.font_size : FontSize;

        Asset asset = super.createAsset(logging, config, context, comFontProvider, isLoadFont);

        if (!theme)
        {
            throw new Exception("No theme found");
        }

        auto defaultSize = theme.fontSizeMedium;

        if(!isLoadFont){
            auto defaultFont = asset.newFont(null, defaultSize);
            asset.addFont(defaultFont);
            return asset;
        }

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        import std.file : getcwd, exists, isDir, isFile;
        import std.path : buildPath, dirName;

        import api.dm.com.graphics.com_font : ComFont;

        string fontFilePath = asset.fontPath(theme.fontTTFFile);

        //TODO Fontconfig
        if (!fontFilePath.exists || !fontFilePath.isFile)
        {
            throw new Exception("Font path does not exist or not a file: " ~ fontFilePath);
        }

        ComFont defaultFont = asset.newFont(fontFilePath, defaultSize);
        asset.addFont(defaultFont);
        version (EnableTrace)
        {
            logging.logger.tracef("Create medium font with size %s from %s", defaultSize, fontFilePath);
        }

        if (theme.fontIsCreateSmall)
        {
            uint size = theme.fontSizeSmall;
            ComFont fontSmall = asset.newFont(fontFilePath, size);
            asset.addFontSmall(fontSmall);
            version (EnableTrace)
            {
                logging.logger.tracef("Create small font with size %s from file %s", size, fontFilePath);
            }
        }

        if (theme.fontIsCreateLarge)
        {
            uint size = theme.fontSizeLarge;
            ComFont fontLarge = asset.newFont(fontFilePath, size);
            asset.addFontLarge(fontLarge);
            version (EnableTrace)
            {
                logging.logger.tracef("Create large font with size %s from file %s", size, fontFilePath);
            }
        }

        return asset;
    }
}
