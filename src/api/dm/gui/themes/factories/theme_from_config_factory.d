module api.dm.gui.themes.factories.theme_from_config_factory;

import api.core.components.units.services.application_unit : ApplicationUnit;
import api.core.contexts.context : Context;
import api.core.configs.keyvalues.config : Config;
import api.core.resources.resourcing : Resourcing;
import api.dm.gui.themes.theme : Theme;
import api.dm.com.graphics.com_font: ComFont;
import api.dm.kit.graphics.colors.rgba : RGBA;
import api.math.pos2.insets : Insets;
import api.dm.gui.themes.icons.icon_pack : IconPack;

import api.core.loggers.logging : Logging;

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

    protected void loadThemeFromConfig(T : Theme)(T newTheme, Config config)
    {
        import api.core.configs.uda : ConfigKey;
        import api.dm.kit.graphics.colors.rgba : RGBA;

        import std.traits : hasUDA;
        import api.core.utils.types : hasOverloads;
        import std.typecons : Nullable;

        static foreach (const fieldName; __traits(allMembers, T))
        {
            static if (!hasOverloads!(T, fieldName) && hasUDA!(__traits(getMember, newTheme, fieldName), ConfigKey))
            {
                {
                    import std.ascii : toUpper;

                    enum themeConfigKey = "theme" ~ fieldName[0].toUpper ~ fieldName[1 .. $];
                    if (!config.hasKey(themeConfigKey))
                    {
                        throw new Exception(
                            "Not found value for theme config key: " ~ themeConfigKey);
                    }
                    alias fieldType = typeof(__traits(getMember, T, fieldName));

                    static if (is(fieldType == float))
                    {
                        auto value = config.getDouble(themeConfigKey);
                    }
                    else static if (is(fieldType == long) || is(fieldType == ulong))
                    {
                        auto value = config.getLong(themeConfigKey);
                    }
                    else static if (is(fieldType == int))
                    {
                        auto value = config.getInt(themeConfigKey);
                    }
                    else static if (is(fieldType : RGBA) || is(fieldType : string))
                    {
                        auto value = config.getNotEmptyString(themeConfigKey);
                    }
                    else
                    {
                        import std.conv : text;

                        static assert(false, text("Not found type ", fieldType.stringof, " in theme with config key", themeConfigKey));
                    }


                    static if (is(fieldType : RGBA))
                    {
                        __traits(getMember, newTheme, fieldName) = RGBA.web(value);
                    }
                    else static if (is(fieldType == ulong))
                    {
                        import std.conv : to;

                        __traits(getMember, newTheme, fieldName) = value.to!ulong;
                    }
                    else
                    {
                        __traits(getMember, newTheme, fieldName) = value;
                    }
                }

            }
        }
    }

    Theme createTheme()
    {
        auto theme = new Theme(iconPack);

        if (!resources.local.resourcesDir.isNull)
        {
            loadThemeFromConfig(theme, config);
        }

        return theme;
    }

    private RGBA fromStringColor(string color)
    {
        return RGBA.web(color);
    }

}
