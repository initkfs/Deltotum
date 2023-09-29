module deltotum.kit.gui.themes.factories.theme_from_config_factory;

import deltotum.core.apps.units.services.application_unit : ApplicationUnit;
import deltotum.core.contexts.context : Context;
import deltotum.core.configs.config : Config;
import deltotum.gui.themes.theme : Theme;
import deltotum.kit.assets.fonts.font : Font;
import deltotum.kit.graphics.colors.rgba : RGBA;
import deltotum.math.geom.insets : Insets;
import deltotum.gui.themes.icons.icon_pack: IconPack;

import std.logger.core : Logger;

/**
 * Authors: initkfs
 */
class ThemeFromConfigFactory : ApplicationUnit
{
    private
    {
        Font defaultFont;
        IconPack iconPack;
    }
    this(Logger logger, Config config, Context context, Font defaultFont, IconPack iconPack) pure @safe
    {
        super(logger, config, context);
        this.defaultFont = defaultFont;
        this.iconPack = iconPack;
    }

    Theme createTheme()
    {
        auto theme = new Theme(defaultFont, iconPack);

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

        return theme;
    }

    private RGBA fromStringColor(string color)
    {
        return RGBA.web(color);
    }

}
