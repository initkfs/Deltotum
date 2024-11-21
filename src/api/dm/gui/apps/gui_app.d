module api.dm.gui.apps.gui_app;

import api.core.apps.app_init_ret : AppInitRet;
import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.resources.resourcing : Resourcing;
import api.dm.kit.apps.continuously_application : ContinuouslyApplication;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.apps.loops.loop : Loop;

abstract class GuiApp : ContinuouslyApplication
{
    bool isIconPackEnabled;

    protected
    {
        IconPack iconPack;
        Theme theme;
    }

    this(Loop loop)
    {
        super(loop);
    }

    override AppInitRet initialize(string[] args)
    {
        const initRes = super.initialize(args);
        if (!initRes || initRes.isExit)
        {
            return initRes;
        }

        if (isIconPackEnabled)
        {
            auto newIconPack = new IconPack;
            //TODO config
            auto mustBeIconPath = uservices.reslocal.fileResource("icons/packs/ionicons.txt");
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

        theme = createTheme(uservices.logging, uservices.config, uservices
                .context, uservices
                .resources);
        assert(theme);
        theme.isUseVectorGraphics = gservices.capGraphics.isVectorGraphics;
        uservices.logger.trace("Theme load");

        import LocatorKeys = api.dm.gui.locator_keys;
        uservices.locator.putObject(LocatorKeys.mainTheme, theme);

        return AppInitRet(isExit : false, isInit:
            true);
    }

    override void loadSettings()
    {
        super.loadSettings;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        immutable isIconPackFlag = uservices.config.getBool(KitConfigKeys.backendIsIconPackEnabled);
        isIconPackEnabled = isIconPackFlag.isNull ? true : isIconPackFlag.get;
        uservices.logger.trace("Icon pack enabled: ", isIconPackEnabled);
    }

    Theme createTheme(Logging logging, Config config, Context context, Resourcing resources)
    {
        import api.dm.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logging, config, context, resources, iconPack);

        auto theme = themeLoader.createTheme;
        return theme;
    }
}
