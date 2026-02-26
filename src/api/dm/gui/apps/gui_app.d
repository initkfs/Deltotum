module api.dm.gui.apps.gui_app;

import api.core.loggers.logging : Logging;
import api.core.configs.keyvalues.config : Config;
import api.core.contexts.context : Context;
import api.dm.kit.apps.loop_app : LoopApp;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;
import api.dm.gui.themes.icons.icon_pack : IconPack;
import api.core.validations.validators.validator : Validator;

abstract class GuiApp : LoopApp
{
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
        import api.dm.gui.themes.factories.theme_from_config_factory : ThemeFromConfigFactory;

        auto themeLoader = new ThemeFromConfigFactory(logging, config, context);

        auto theme = themeLoader.createTheme;
        assert(theme);

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
}
