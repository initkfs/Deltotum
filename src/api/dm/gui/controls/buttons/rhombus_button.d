module api.dm.gui.controls.buttons.rhombus_button;

import api.dm.gui.controls.buttons.button_base : ButtonBase;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RhombusButton : ButtonBase
{
    this(dstring text = "Button", string iconName)
    {
        super(text, iconName);
    }

    this(
        dstring text = "Button",
        double size = defaultWidth,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(text, size, size, graphicsGap, iconName);
    }

    override Sprite delegate(double, double) createBackgroundFactory()
    {
        return (w, h) { return createShape(w, h); };
    }

    protected override Sprite createShape(double w, double h)
    {
        return createShape(w, h, createStyle);
    }

    protected override Sprite createShape(double width, double height, GraphicStyle style)
    {
        double cornerBevel = width / 2;

        Sprite shape;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vconvex_polygon : VConvexPolygon;

            shape = new VConvexPolygon(width, height, style, cornerBevel);
        }
        else
        {
            import api.dm.kit.sprites.shapes.convex_polygon : ConvexPolygon;

            shape = new ConvexPolygon(width, height, style, cornerBevel);
        }
        return shape;
    }

    override Sprite delegate(double, double) createHoverFactory()
    {
        return (width, height) {
            assert(graphics.theme);

            GraphicStyle style = createStyle;
            if (!style.isNested)
            {
                style.lineColor = graphics.theme.colorHover;
                style.fillColor = graphics.theme.colorHover;
                style.isFill = true;
            }

            Sprite newHover = createShape(width, height, style);
            newHover.id = idControlHover;
            newHover.isLayoutManaged = false;
            newHover.isResizedByParent = true;
            newHover.isVisible = false;
            return newHover;
        };
    }

    override Sprite delegate() createPointerEffectFactory()
    {
        return () {
            assert(graphics.theme);

            GraphicStyle style = createStyle;
            if (!style.isNested)
            {
                style.lineColor = graphics
                    .theme.colorAccent;
                style.fillColor = graphics.theme.colorAccent;
                style.isFill = true;
            }

            Sprite sprite = createShape(width, height, style);
            return sprite;
        };
    }

}
