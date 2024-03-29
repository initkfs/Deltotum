module dm.gui.controls.labels.hyperlink;

import dm.gui.controls.labeled : Labeled;
import dm.kit.sprites.sprite : Sprite;
import dm.gui.controls.tooltips.tooltip: Tooltip;

import std.conv: to;

/**
 * Authors: initkfs
 */
class Hyperlink : Labeled
{
    protected
    {
        Sprite underline;
    }

    string url = "https://google.com";

    this(dstring text = "Hyperlink", string iconName = null, double graphicsGap = 0, bool isCreateLayout = true)
    {
        super(iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        import dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBorder = false;
        isCreateHoverFactory = false;
        isCreatePointerEffectFactory = false;
        isCreatePointerEffectAnimationFactory = false;
    }

    override void initialize()
    {
        super.initialize;

        onPointerEntered ~= (ref e) { underline.isVisible = false; };

        onPointerExited ~= (ref e) { underline.isVisible = true; };

        onPointerDown ~= (ref e) {
            if (url.length == 0)
            {
                return;
            }
            platform.openURL(url);
        };
    }

    override void create()
    {
        super.create;

        auto tooltip = new Tooltip(url.to!dstring);
        addCreate(tooltip);

        import dm.kit.sprites.textures.vectors.shapes.vregular_polygon : VRegularPolygon;

        auto style = createDefaultStyle;
        style.isFill = true;
        underline = new VRegularPolygon(10, 2, style, 0);
        underline.isResizable = true;
        underline.isHGrow = true;
        addCreate(underline);
    }

}
