module dm.gui.controls.buttons.round_button;

import dm.gui.controls.buttons.button_base : ButtonBase;
import dm.kit.sprites.sprite : Sprite;
import dm.kit.graphics.styles.graphic_style : GraphicStyle;
import dm.gui.controls.texts.text : Text;
import dm.gui.controls.control: Control;

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
        import dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResizeAndAlignOne = true;
        this.layout.isAlign = true;
    }

    alias createDefaultShape = Control.createDefaultShape;

    protected override Sprite createDefaultShape(double width, double height, GraphicStyle style)
    {
        double radius = width / 2;

        Sprite shape;
        if (capGraphics.isVectorGraphics)
        {
            import dm.kit.sprites.textures.vectors.shapes.vcircle : VCircle;

            shape = new VCircle(radius, style);
        }
        else
        {
            import dm.kit.sprites.shapes.circle : Circle;

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
        return (width, height) { return createDefaultShape(width, height); };
    }

    override Sprite delegate(double, double) createHoverFactory()
    {
        return (width, height) {
            assert(graphics.theme);

            GraphicStyle style = createDefaultStyle;
            if (!style.isNested)
            {
                style.lineColor = graphics.theme.colorHover;
                style.fillColor = graphics.theme.colorHover;
                style.isFill = true;
            }

            Sprite newHover = createDefaultShape(width, height, style);
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

            GraphicStyle style = createDefaultStyle;
            if (!style.isNested)
            {
                style.lineColor = graphics
                    .theme.colorAccent;
                style.fillColor = graphics.theme.colorAccent;
                style.isFill = true;
            }

            Sprite sprite = createDefaultShape(width, height, style);
            sprite.id = idControlClick;
            sprite.isLayoutManaged = false;
            sprite.isResizedByParent = true;
            sprite.isVisible = false;

            return sprite;
        };
    }

    //TODO more correct hitbox
    override bool containsPoint(double x, double y)
    {
        if (background)
        {
            return background.containsPoint(x, y);
        }

        return super.containsPoint(x, y);
    }

    override bool intersectBounds(Sprite other)
    {
        if (background)
        {
            return background.intersectBounds(other);
        }
        return super.intersectBounds(other);
    }
}
