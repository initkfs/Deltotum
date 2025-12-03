module api.sims.ele.components.connects.connection;

import api.sims.ele.components.base_component : BaseComponent;
import api.sims.ele.components.pin : Pin;

/**
 * Authors: initkfs
 */

class Connection : BaseComponent
{
    Pin pin;
    bool isNeg;
    bool isNode;

    this()
    {
        initSize(10);
    }

    override void create()
    {
        super.create;

        import api.dm.kit.graphics.colors.rgba : RGBA;

        auto style = createDefaultStyle;
        if (!isNeg)
        {
            style.color = RGBA.red;
        }
        else
        {
            style.color = RGBA.blue;
        }
        style.isFill = true;
        auto shape = theme.rectShape(width, height, angle, style);
        addCreate(shape);
    }
}
