module deltotum.gui.controls.choices.checkbox;

import deltotum.kit.sprites.sprite: Sprite;
import deltotum.gui.controls.control: Control;
import deltotum.gui.controls.texts.text: Text;

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

    this()
    {
        import deltotum.kit.sprites.layouts.horizontal_layout : HorizontalLayout;

        layout = new HorizontalLayout(5);
        layout.isAutoResize(true);
        layout.isAlignY = true;

        isBorder = true;
    }

    override void create()
    {
        super.create;

        import deltotum.gui.containers.stack_box: StackBox;

        auto markerContainer = new StackBox;
        markerContainer.width = 20;
        markerContainer.height = 20;
        markerContainer.isBorder = true;
        addCreate(markerContainer);

        import deltotum.kit.graphics.shapes.regular_polygon: RegularPolygon;
        import deltotum.kit.graphics.styles.graphic_style: GraphicStyle;

        marker = new RegularPolygon(10, 10, GraphicStyle(1, graphics.theme.colorAccent, true, graphics.theme.colorAccent), 3);
        markerContainer.addCreate(marker);
        marker.isVisible = false;

        label = new Text;
        addCreate(label);

        onMouseDown = (e){
            toggle;
            return false;
        };
    }

    void toggle(){
        isCheck = !isCheck;
        marker.isVisible = isCheck;
    }

}
