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

    override void initialize()
    {
        super.initialize;

        isBackground = false;

        backgroundFactory = (width, height) {

            import deltotum.kit.graphics.shapes.rectangle : Rectangle;
            import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

            GraphicStyle backgroundStyle = GraphicStyle(0, graphics.theme.colorContainerBackground, true, graphics
                    .theme.colorContainerBackground);

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.opacityContainers;
            return background;
        };
    }

    private void checkBackground()
    {
        if (width > 0 && height > 0)
        {
            createBackground(width - backgroundInsets.width, height - backgroundInsets.height);
        }
    }

    protected void layoutWithoutChildren(){
        isResizeChildren = false;
        requestLayout;
        isResizeChildren = true;
    }

    override void addCreated(Sprite obj, long index = -1)
    {
        obj.x = 0;
        obj.y = 0;
        super.addCreated(obj, index);
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
