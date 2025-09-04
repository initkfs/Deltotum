module api.subs.ele.components.elements.base_one_pin_element;

import api.dm.kit.sprites2d.sprite2d: Sprite2d;

import api.subs.ele.components.elements.base_element: BaseElement;
import api.subs.ele.components.connects.connection: Connection;

import api.math.pos2.orientation : Orientation;

/**
 * Authors: initkfs
 */
 abstract class BaseOnePinElement : BaseElement
{
    Connection p;

    this(string id, Orientation orientation = Orientation.vertical)
    {
        super(id, orientation);
    }

    override void create()
    {
        super.create;

        p = new Connection;
        addCreate(p);

        content = createContent;
        addCreate(content);
    }

    Sprite2d createContent()
    {
        import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;

        auto style = createDefaultStyle;
        return theme.rectShape(width, height, angle, style);
    }
}