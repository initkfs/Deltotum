module deltotum.ui.controls.scrollbars.hscrollbar;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.textures.texture : Texture;

import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
import deltotum.toolkit.display.layouts.managed_layout : ManagedLayout;
import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;
import deltotum.toolkit.display.alignment : Alignment;

/**
 * Authors: initkfs
 * TODO remove duplication with slider after testing 
 */
class HScrollbar : Control
{
    double minValue;
    double maxValue;
    double value;

    void delegate(double) onValue;

    Texture delegate() thumbFactory;
    Texture delegate() trackFactory;

    protected
    {
        Texture thumb;
        Texture track;
    }

    this(double minValue = 0, double maxValue = 1.0, double width = 120, double height = 20)
    {
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;
    }

    override void initialize()
    {
        super.initialize;
        
        trackFactory = () {
            import deltotum.toolkit.graphics.styles.graphic_style : GraphicStyle;
            import deltotum.toolkit.graphics.shapes.rectangle : Rectangle;

            auto trackStyle = GraphicStyle(0.0, graphics.theme.colorAccent);
            auto track = new Rectangle(width / 2, height / 2, trackStyle);
            return track;
        };

        thumbFactory = () {
            auto thumbStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);
            auto thumb = new Rectangle(10, height, thumbStyle);
            //thumb.alignment = Alignment.x;
            return thumb;
        };
    }

    override void create()
    {
        super.create;

        track = trackFactory();
        addCreated(track);

        thumb = thumbFactory();
        addCreated(thumb);
        thumb.isDraggable = true;
        thumb.onDrag = (x, y) {
            auto bounds = this.bounds;
            const minX = bounds.x;
            const maxX = bounds.right - thumb.width;
            if (x <= minX || x >= maxX)
            {
                return false;
            }
            thumb.x = x;

            const range = bounds.width - thumb.width;
            auto dx = thumb.x - bounds.x;
            if (dx < 0)
            {
                dx = -dx;
            }
            const numRange = maxValue - minValue;
            value = minValue + (numRange / range) * dx;

            if (onValue !is null)
            {
                onValue(value);
            }

            return false;
        };
    }
}