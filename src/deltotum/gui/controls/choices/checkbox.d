module deltotum.gui.controls.choices.checkbox;

import deltotum.kit.sprites.sprite : Sprite;
import deltotum.gui.controls.control : Control;
import deltotum.gui.controls.texts.text : Text;

/**
 * Authors: initkfs
 */
class CheckBox : Control
{
    //protected
    // {
    Text label;
    Sprite marker;
    // }

    bool isCheck;

    void delegate(bool, bool) onToggleOldNewValue;

    this()
    {
        import deltotum.kit.sprites.layouts.hlayout : HLayout;

        layout = new HLayout(5);
        layout.isAutoResize(true);
        layout.isAlignY = true;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        enableInsets;

        import deltotum.gui.containers.stack_box : StackBox;

        auto markerContainer = new StackBox;
        markerContainer.width = 20;
        markerContainer.height = 20;
        markerContainer.isBorder = true;
        addCreate(markerContainer);

        import deltotum.kit.graphics.shapes.regular_polygon : RegularPolygon;
        import deltotum.kit.graphics.styles.graphic_style : GraphicStyle;

        marker = new RegularPolygon(10, 10, GraphicStyle(1, graphics.theme.colorAccent, true, graphics
                .theme.colorAccent), 3);
        markerContainer.addCreate(marker);
        marker.isVisible = false;

        label = new Text;
        label.isFocusable = false;
        addCreate(label);

        onPointerDown = (ref e) { toggle; };
    }

    void toggle(bool value)
    {
        const bool oldValue = isCheck;
        isCheck = value;
        marker.isVisible = isCheck;
        if (onToggleOldNewValue)
        {
            onToggleOldNewValue(oldValue, value);
        }
    }

    void toggle()
    {
        toggle(!isCheck);
    }

}
