module api.dm.gui.controls.labels.hyperlink;

import api.dm.gui.controls.labeled : Labeled;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.gui.controls.tooltips.popup: Popup;

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
        super(0, 0, iconName, graphicsGap, isCreateLayout);
        _labelText = text;

        import api.dm.kit.sprites.layouts.vlayout : VLayout;

        layout = new VLayout;
        layout.isAutoResize = true;
        isBorder = false;
        isCreateHoverEffectFactory = false;
        isCreateHoverAnimationFactory = false;
        isCreateActionEffectFactory = false;
        isCreateActionAnimationFactory = false;
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

        auto tooltip = new Popup(url.to!dstring);
        addCreate(tooltip);

        import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

        auto style = createStyle;
        style.isFill = true;
        underline = new VConvexPolygon(10, 2, style, 0);
        underline.isResizable = true;
        underline.isHGrow = true;
        addCreate(underline);
    }

}
