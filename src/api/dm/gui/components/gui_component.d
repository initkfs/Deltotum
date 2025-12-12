module api.dm.gui.components.gui_component;

import api.core.components.component_service : Service;
import api.dm.kit.sprites2d.sprite2d : Sprite2d;
import api.dm.gui.themes.theme : Theme;
import api.dm.gui.interacts.interact : Interact;

/**
 * Authors: initkfs
 */
class GuiComponent : Sprite2d
{
    protected
    {
        @Service Theme _theme;
        @Service Interact _interact;
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
        if (!newTheme)
        {
            throw new Exception("Theme must not be null");
        }
        _theme = newTheme;
    }

    bool hasInteract() nothrow pure @safe
    {
        return _interact !is null;
    }

    Interact interact() nothrow pure @safe
    out (_interact; _interact !is null)
    {
        return _interact;
    }

    void interact(Interact interact) pure @safe
    {
        if (!interact)
        {
            throw new Exception("Interaction must not be null");
        }

        _interact = interact;
    }

}
