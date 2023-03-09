module deltotum.toolkit.ui.controls.vscrollbar;

import deltotum.toolkit.ui.controls.control : Control;
import deltotum.toolkit.display.textures.texture : Texture;

import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style: GraphicStyle;
import deltotum.toolkit.display.layouts.managed_layout: ManagedLayout;
import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
import deltotum.toolkit.display.alignment: Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
class VScrollbar : Control
{
    double minValue;
    double maxValue;
    double value;

    void delegate(double) onValue;

    protected
    {
        Texture thumb;
        GraphicStyle thumbStyle;
    }

    this(double minValue = 0, double maxValue = 1.0, double width = 20, double height = 120)
    {
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;
    }

    override void create()
    {
        backgroundStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorSecondary);
        backgroundFactory = (width, height) {
            import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;

            auto background = new Rectangle(width, height, backgroundStyle);
            background.opacity = graphics.theme.controlOpacity;
            background.isLayoutManaged = false;
            return background;
        };

        createBackground(width, height);

        thumbStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);

        thumb = new Rectangle(20, 20, thumbStyle);
        thumb.alignment = Alignment.x;

        addCreated(thumb);
        thumb.isDraggable = true;
        thumb.onDrag = (x, y) {
            auto bounds = this.bounds;
            const minY = bounds.y;
            const maxY = bounds.bottom - thumb.height;
            if (y <= minY || y >= maxY)
            {
                return false;
            }
            thumb.y = y;

            const range = bounds.height - thumb.height;
            auto dy = thumb.y - bounds.y;
            if(dy < 0){
                dy = -dy;
            }
            const numRange = maxValue - minValue;
            value = minValue + (numRange / range) * dy;

            if(onValue !is null){
                onValue(value);
            }

            return false;
        };

        this.layout.layout(this);
    }
}
