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
import api.core.validations.validators.validator : Validator;

abstract class GuiApp : LoopApp
{
    bool isIconPackEnabled;

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

        mainLoop = newMainLoop;
        assert(mainLoop);

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

        float frameRate = 0;
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

        auto themeLoader = new ThemeFromConfigFactory(logging, config, context, resources);

        auto theme = themeLoader.createTheme;

        theme.iconPack = newIconPack;

        return theme;
    }

    version (EnableValidation)
    {
        override Validator[] createValidators()
        {
            Validator[] parent = super.createValidators;

            import I18nKeys = api.dm.gui.gui_i18n_keys;

            string[] keys;
            keys.reserve(10);

            foreach (key; __traits(allMembers, I18nKeys))
            {
                if (key == "object")
                {
                    continue;
                }

                keys ~= key;
            }

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
}
