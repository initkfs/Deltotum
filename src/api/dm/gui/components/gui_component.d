module api.dm.gui.components.gui_component;

import api.core.components.uda : Service;
import api.dm.kit.sprites.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.themes.theme : Theme;

/**
 * Authors: initkfs
 */
class GuiComponent : Sprite2d
{
    protected
    {
        @Service Theme _theme;
    }

    alias build = Sprite2d.build;
    alias buildInit = Sprite2d.buildInit;
    alias buildInitCreate = Sprite2d.buildInitCreate;
    alias buildInitCreateRun = Sprite2d.buildInitCreateRun;

    void build(GuiComponent gComponent)
    {
        buildFromParent(gComponent, this);
    }

    void buildInit(GuiComponent component)
    {
        build(component);
        initialize(component);
    }

    void buildInitCreate(GuiComponent component)
    {
        buildInit(component);
        create(component);
    }

    void buildInitCreateRun(GuiComponent component)
    {
        buildInitCreate(component);
        run(component);
    }

    bool hasTheme() const nothrow pure @safe
    {
        return _theme !is null;
    }

    inout(Theme) theme() inout nothrow pure @safe
    out (_theme; _theme !is null)
    {
        return _theme;
    }

    void theme(Theme newTheme) pure @safe
    {
        import std.exception : enforce;

        enforce(newTheme, "Theme must not be null");
        _theme = newTheme;
    }

}
