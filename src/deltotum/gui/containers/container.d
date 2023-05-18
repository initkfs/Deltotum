module deltotum.gui.containers.container;

import deltotum.gui.controls.control : Control;
import deltotum.kit.sprites.sprite : Sprite;

/**
 * Authors: initkfs
 */
class Container : Control
{
    void requestLayout()
    {

    }

    this() pure
    {
        isBackground = false;
    }

    override void initialize()
    {
        super.initialize;

        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.kit.graphics.colors.rgba : RGBA;

            GraphicStyle backgroundStyle = GraphicStyle(1, graphics.theme.colorAccent, isBackground, graphics
                    .theme.colorControlBackground);

            auto background = new RegularPolygon(width, height, backgroundStyle, graphics
                    .theme.controlCornersBevel);

            // auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityControls;
            return background;
        };
    }

    protected auto childrenWithGeometry()
    {
        import std.algorithm.iteration : filter;

        return children.filter!(ch => ch.isLayoutManaged);
    }

    private void checkBackground()
    {
        if (background)
        {
            background.width = width;
            background.height = height;
            return;
        }
        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
        }
    }

    protected void layoutWithoutChildren()
    {
        isResizeChildren = false;
        requestLayout;
        isResizeChildren = true;
    }

    override void addCreate(Sprite[] sprites)
    {
        foreach (sprite; sprites)
        {
            addCreate(sprite);
        }
    }

    override void addCreate(Sprite obj, long index = -1)
    {
        if (obj.isLayoutManaged)
        {
            obj.x = 0;
            obj.y = 0;
        }
        super.addCreate(obj, index);
        obj.isResizedByParent = true;

        layoutWithoutChildren;
    }

    override double width()
    {
        return super.width;
    }

    override void width(double value)
    {
        super.width = value;
        checkBackground;
    }

    override double height()
    {
        return super.height;
    }

    override void height(double value)
    {
        super.height = value;
        checkBackground;
    }
}
