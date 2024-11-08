module api.dm.kit.graphics.themes.factories.theme_from_config_factory;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.resources.resource: Resource;
import api.dm.kit.graphics.themes.theme : Theme;
import api.dm.kit.assets.fonts.font : Font;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.insets : Insets;
import api.dm.kit.graphics.themes.icons.icon_pack : IconPack;

import api.core.loggers.loggers : Logging;

/**
 * Authors: initkfs
 */
class ThemeFromConfigFactory : ApplicationUnit
{
    private
    {
        IconPack iconPack;
        Resource resource;
    }
    this(Logging loggers, Config config, Context context, Resource resource, IconPack iconPack) pure @safe
    {
        super(loggers, config, context);
        //TODO check null
        this.iconPack = iconPack;
        this.resource = resource;
    }

    Theme createTheme()
    {
        auto theme = new Theme(iconPack);

        //TODO resource
        if (!resource.resourcesDir.isNull)
        {
            //TODO rewrite
            theme.colorPrimary = fromStringColor(config.getString("themeColorPrimary").get);
            theme.colorSecondary = fromStringColor(config.getString("themeColorSecondary").get);
            theme.colorAccent = fromStringColor(config.getString("themeColorAccent").get);

            theme.colorFocus = fromStringColor(config.getString("themeColorFocus").get);
            theme.colorText = fromStringColor(config.getString("themeColorText").get);
            theme.colorTextBackground = fromStringColor(config.getString("colorTextBackground").get);
            theme.colorHover = fromStringColor(config.getString("themeColorHover").get);

            theme.colorControlBackground = fromStringColor(
                config.getString("themeColorControlBackground").get);
            theme.colorContainerBackground = fromStringColor(
                config.getString("themeColorContainerBackground").get);

            theme.opacityContainers = config.getDouble("themeOpacityContainers").get;
            theme.opacityControls = config.getDouble("themeOpacityControls").get;
            theme.opacityHover = config.getDouble("themeOpacityHover").get;
            theme.controlPadding = Insets(config.getDouble("themeControlPadding").get);
            theme.controlCornersBevel = config.getDouble("themeControlCornersBevel").get;
        }

        return theme;
    }

    private RGBA fromStringColor(string color)
    {
        return RGBA.web(color);
    }

}
