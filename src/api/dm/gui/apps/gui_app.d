module api.dm.gui.apps.gui_app;

import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.core.resources.resourcing : Resourcing;
import api.dm.kit.apps.loop_app : LoopApp;
import api.dm.kit.apps.loops.loop : Loop;
import api.dm.kit.apps.loops.integrated_loop : IntegratedLoop;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;
import api.dm.gui.themes.icons.icon_pack : IconPack;

abstract class GuiApp : LoopApp
{
    bool isIconPackEnabled;

    protected
    {
        IconPack iconPack;
        Theme theme;
        Interact interact;
    }

    override bool initialize(string[] args)
    {
        if (!super.initialize(args))
        {
            return false;
        }

        mainLoop = newMainLoop;
        assert(mainLoop);

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

        interact = createInteract(uservices.logging, uservices.config, uservices
                .context);

        return true;
    }

    Loop newMainLoop()
    {
        import KitConfigKeys = api.dm.kit.kit_config_keys;

        double frameRate = 0;
        if (uservices.config.hasKey(KitConfigKeys.engineFrameRate))
        {
            frameRate = uservices.config.getDouble(KitConfigKeys.engineFrameRate);
        }

        if (frameRate > 0)
        {
            return new IntegratedLoop(frameRate);
        }

        return new IntegratedLoop;
    }

    override void loadSettings()
    {
        super.loadSettings;

        import KitConfigKeys = api.dm.kit.kit_config_keys;

        if (uservices.config.hasKey(KitConfigKeys.graphicsIsIconPack))
        {
            isIconPackEnabled = uservices.config.getBool(KitConfigKeys.graphicsIsIconPack);
        }
    }

    Theme createTheme(Logging logging, Config config, Context context, Resourcing resources)
    {
        import api.dm.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logging, config, context, resources, iconPack);

        auto theme = themeLoader.createTheme;
        return theme;
    }

    Interact createInteract(Logging logging, Config config, Context context)
    {
        return new Interact;
    }
}
