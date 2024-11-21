module api.dm.gui.controls.buttons.round_button;

import api.dm.gui.controls.buttons.button_base : ButtonBase;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.controls.texts.text : Text;
import api.dm.gui.controls.control: Control;

/**
 * Authors: initkfs
 */
class RoundButton : ButtonBase
{
    this(dstring text = "Button", string iconName)
    {
        super(text, iconName);
    }

    this(
        dstring text = "Button",
        double diameter = defaultWidth,
        double graphicsGap = defaultGraphicsGap,
        string iconName = null
    )
    {
        super(text, diameter, diameter, graphicsGap, iconName);

        //TODO graphics
        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResizeAndAlignOne = true;
        this.layout.isAlign = true;
    }

    alias createShape = Control.createShape;

    protected override Sprite createShape(double width, double height, GraphicStyle style)
    {
        double radius = width / 2;

        Sprite shape;
        if (capGraphics.isVectorGraphics)
        {
            import api.dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

            shape = new VCircle(radius, style);
        }
        else
        {
            import api.dm.kit.sprites.shapes.circle : Circle;

            shape = new Circle(radius, style);
        }
        return shape;
    }

    override Text delegate() createTextFactory()
    {
        return () {
            auto text = new Text();
            //TODO best position or use padding?
            enum textPadding = 15;
            text.maxWidth = width > textPadding ? width - textPadding : width;
            text.maxHeight = height > textPadding ? height - textPadding : height;
            build(text);
            //String can be forced to be empty
            //if (_buttonText.length > 0)
            text.text = _labelText;
            return text;
        };
    }

    override Sprite delegate(double, double) createBackgroundFactory()
    {
        return (width, height) { return createShape(width, height); };
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

    //TODO more correct hitbox
    override bool containsPoint(double x, double y)
    {
        if (hasBackground)
        {
            return background.get.containsPoint(x, y);
        }

        return super.containsPoint(x, y);
    }

    override bool intersectBounds(Sprite other)
    {
        if (hasBackground)
        {
            return background.get.intersectBounds(other);
        }
        return super.intersectBounds(other);
    }
}
