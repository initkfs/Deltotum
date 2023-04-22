module deltotum.kit.graphics.themes.factories.theme_from_config_factory;

import deltotum.core.applications.components.units.services.application_unit : ApplicationUnit;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;
import deltotum.kit.graphics.themes.theme : Theme;
import deltotum.kit.asset.fonts.font : Font;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.geometry.insets : Insets;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class ThemeFromConfigFactory : ApplicationUnit
{
    private
    {
        Font defaultFont;
    }
    this(Logger logger, Config config, Context context, Font defaultFont) pure @safe
    {
        super(logger, config, context);
        this.defaultFont = defaultFont;
    }

    Theme create()
    {
        auto theme = new Theme(defaultFont);

        //TODO rewrite
        theme.colorPrimary = fromStringColor(config.getString("themeColorPrimary").get);
        theme.colorSecondary = fromStringColor(config.getString("themeColorSecondary").get);
        theme.colorAccent = fromStringColor(config.getString("themeColorAccent").get);

        theme.colorFocus = fromStringColor(config.getString("themeColorFocus").get);
        theme.colorText = fromStringColor(config.getString("themeColorText").get);
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

        return theme;
    }

    private RGBA fromStringColor(string color)
    {
        return RGBA.web(color);
    }

}
