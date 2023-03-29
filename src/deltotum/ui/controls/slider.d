module deltotum.ui.controls.slider;

import deltotum.ui.controls.control : Control;
import deltotum.toolkit.display.textures.texture : Texture;

import deltotum.toolkit.graphics.shapes.shape : Shape;
import deltotum.toolkit.graphics.styles.graphic_style: GraphicStyle;
import deltotum.toolkit.display.layouts.managed_layout: ManagedLayout;
import deltotum.toolkit.display.alignment: Alignment;

/**
 * Authors: initkfs
 */
class Slider : Control
{
    double minValue;
    double maxValue;
    double value;

    void delegate(double) onValue;

    protected
    {
        Texture track;
        Texture thumb;
        GraphicStyle trackStyle;
        GraphicStyle thumbStyle;
    }

    this(double minValue = 0, double maxValue = 1.0, double width = 120, double height = 40)
    {
        this.width = width;
        this.height = height;
        this.minValue = minValue;
        this.maxValue = maxValue;

        this.layout = new ManagedLayout;
    }

    override void create()
    {
        super.create;

        trackStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);
        thumbStyle = GraphicStyle(0.0, graphics.theme.colorAccent, true, graphics.theme.colorAccent);

        import deltotum.toolkit.graphics.shapes.circle : Circle;

        thumb = new Circle(10, thumbStyle);
        thumb.alignment = Alignment.y;

        //thumb.x = -(thumb.width / 2);
        thumb.x = width / 2;

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

            const widthRange = bounds.width;
            auto dx = thumb.x - bounds.x;
            if(dx < 0){
                dx = -dx;
            }
            const numRange = maxValue - minValue;
            value = minValue + (numRange / widthRange) * dx;

            if(onValue !is null){
                onValue(value);
            }

            return false;
        };

        import deltotum.toolkit.graphics.shapes.rectangle: Rectangle;

        track = new Rectangle(width, height / 6, trackStyle);
        track.alignment = Alignment.y;
        addCreated(track);

        this.layout.layout(this);
    }

    void createListeners()
    {

    }

}
