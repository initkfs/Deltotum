module dm.kit.gui.themes.factories.theme_from_config_factory;

import dm.core.units.services.application_unit : ApplicationUnit;
import dm.core.contexts.context : Context;
import dm.core.configs.config : Config;
import dm.core.resources.resource: Resource;
import dm.kit.graphics.themes.theme : Theme;
import dm.kit.assets.fonts.font : Font;
import dm.kit.graphics.colors.rgba : RGBA;
import dm.math.geom.insets : Insets;
import dm.kit.graphics.themes.icons.icon_pack : IconPack;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class ThemeFromConfigFactory : ApplicationUnit
{
    private
    {
        Font font;
        IconPack iconPack;
        Resource resource;
    }
    this(Logger logger, Config config, Context context, Resource resource, Font font, IconPack iconPack) pure @safe
    {
        super(logger, config, context);
        //TODO check null
        this.font = font;
        this.iconPack = iconPack;
        this.resource = resource;
    }

    Theme createTheme()
    {
        auto theme = new Theme(font, iconPack);

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
