module api.dm.gui.controls.buttons.rhombus_button;

import api.dm.gui.controls.buttons.base_button : BaseButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class RhombusButton : BaseButton
{
    this(dstring text = "Button", string iconName)
    {
        super(text, iconName);
    }

    this(
        dstring text = "Button",
        double size = 0,
        double graphicsGap = 0,
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

    override Sprite delegate(double, double) createHoverEffectFactory()
    {
        return (width, height) {
            assert(theme);

            GraphicStyle style = createStyle;
            if (!style.isNested)
            {
                style.lineColor = theme.colorHover;
                style.fillColor = theme.colorHover;
                style.isFill = true;
            }

            Sprite newHover = createShape(width, height, style);
            newHover.id = idHoverShape;
            newHover.isLayoutManaged = false;
            newHover.isResizedByParent = true;
            newHover.isVisible = false;
            return newHover;
        };
    }

    override Sprite delegate() createActionEffectFactory()
    {
        return () {
            assert(theme);

            GraphicStyle style = createStyle;
            if (!style.isNested)
            {
                style.lineColor = theme.colorAccent;
                style.fillColor = theme.colorAccent;
                style.isFill = true;
            }

            Sprite sprite = createShape(width, height, style);
            return sprite;
        };
    }

}
