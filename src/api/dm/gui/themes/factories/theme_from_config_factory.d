module api.dm.gui.themes.factories.theme_from_config_factory;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.resources.resourcing: Resourcing;
import api.dm.gui.themes.theme : Theme;
import api.dm.kit.assets.fonts.font : Font;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.insets : Insets;
import api.dm.gui.themes.icons.icon_pack : IconPack;

import api.core.loggers.logging : Logging;
import api.dm.gui.display_layout;

/**
 * Authors: initkfs
 */
class ThemeFromConfigFactory : ApplicationUnit
{
    private
    {
        IconPack iconPack;
        Resourcing resources;
    }
    this(Logging logging, Config config, Context context, Resourcing resources, IconPack iconPack) pure @safe
    {
        super(logging, config, context);
        //TODO check null
        this.iconPack = iconPack;
        this.resources = resources;
    }

    Theme createTheme()
    {
        auto theme = new Theme(iconPack);

        //TODO resources
        if (!resources.local.resourcesDir.isNull)
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

            theme.tooltipDelayMs = config.getLong("themeTooltipDelayMs").get;
            theme.actionAnimationDelayMs = config.getLong("themeActionAnimationDelayMs").get;
            theme.hoverAnimationDelayMs = config.getLong("themeHoverAnimationDelayMs").get;
            
            theme.controlDefaultWidth = config.getDouble("themeControlDefaultWidth").get;
            theme.controlDefaultHeight = config.getDouble("themeControlDefaultHeight").get;
            theme.controlGraphicsGap = config.getDouble("themeControlGraphicsGap").get;

            theme.buttonWidth = config.getDouble("themeButtonWidth").get;
            theme.buttonHeight = config.getDouble("themeButtonHeight").get;
            theme.roundShapeDiameter = config.getDouble("themeRoundShapeDiameter").get;
            theme.regularPolyDiameter = config.getDouble("themeRegularPolyDiameter").get;
            theme.regularPolySides = config.getLong("themeRegularPolySides").get;
        }

        return theme;
    }

    private RGBA fromStringColor(string color)
    {
        return RGBA.web(color);
    }

}
