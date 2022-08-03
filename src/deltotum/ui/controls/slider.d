module deltotum.ui.controls.slider;

import deltotum.ui.controls.control : Control;
import deltotum.ui.theme.theme : Theme;
import deltotum.display.texture.texture : Texture;

import deltotum.graphics.shape.shape : Shape;
import deltotum.graphics.shape.shape_style : ShapeStyle;
import deltotum.ui.layouts.managed_layout: ManagedLayout;
import deltotum.math.alignment: Alignment;

/**
 * Authors: initkfs
 */
class Slider : Control
{
    @property double minValue;
    @property double maxValue;
    @property double value;

    protected
    {
        Texture track;
        Texture thumb;
        ShapeStyle* trackStyle;
        ShapeStyle* thumbStyle;
    }

    this(Theme theme, double minValue = 0, double maxValue = 1.0, double width = 120, double height = 40)
    {
        super(theme);
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;
    }

    override void create()
    {
        super.create;

        trackStyle = new ShapeStyle(0.0, theme.colorAccent, true, theme.colorAccent);
        thumbStyle = new ShapeStyle(0.0, theme.colorAccent, true, theme.colorAccent);

        import deltotum.graphics.shape.circle : Circle;

        thumb = new Circle(10, thumbStyle);
        thumb.alignment = Alignment.y;
        thumb.x = -(thumb.width / 2);
        addCreated(thumb);
        thumb.isDraggable = true;
        thumb.onDrag = (x, y) {
            auto bounds = this.bounds;
            const minX = bounds.x - thumb.width / 2;
            const maxX = bounds.right - thumb.width / 2;
            if (x <= minX || x >= maxX)
            {
                return false;
            }
            thumb.x = x;

            const range = bounds.width;
            const dx = thumb.x - bounds.x;
            value = (dx * maxValue) / range;
            import std.stdio;
            writeln(value);
            return false;
        };

        import deltotum.graphics.shape.rectangle: Rectangle;

        track = new Rectangle(width, height / 6, trackStyle);
        track.alignment = Alignment.y;
        addCreated(track);

        this.layout.layout(this);
    }

    void createListeners()
    {

    }

}
