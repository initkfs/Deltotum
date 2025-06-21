module api.dm.gui.apps.gui_app;

import api.core.apps.app_result : AppResult;
import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.resources.resourcing : Resourcing;
import api.dm.kit.apps.loop_app : LoopApp;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.dm.kit.apps.loops.loop : Loop;

abstract class GuiApp : LoopApp
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

    override AppResult initialize(string[] args)
    {
        const initRes = super.initialize(args);
        if (!initRes.isInit || initRes.isExit)
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
            gservices.platform.cap.isIconPack = true;
            uservices.logger.trace("Load icon pack: ", iconPath);
        }

        theme = createTheme(uservices.logging, uservices.config, uservices
                .context, uservices
                .resources);
        assert(theme);
        uservices.logger.trace("Theme load");

        return AppResult(isExit : false, isInit:
            true);
    }

    override void loadSettings()
    {
        super.loadSettings;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        immutable isIconPackFlag = uservices.config.getBool(KitConfigKeys.graphicsIsIconPack);
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
