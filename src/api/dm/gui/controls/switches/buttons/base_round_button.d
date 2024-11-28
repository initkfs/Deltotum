module api.dm.gui.controls.switches.buttons.base_round_button;

import api.dm.gui.controls.switches.buttons.base_button : BaseButton;
import api.dm.kit.sprites.sprite : Sprite;
import api.dm.kit.graphics.styles.graphic_style : GraphicStyle;
import api.dm.gui.events.action_event : ActionEvent;
import api.dm.gui.controls.control : Control;

/**
 * Authors: initkfs
 */
class BaseRoundButton : BaseButton
{
    protected
    {
        double _diameter = 0;
    }

    this(dstring text = defaultButtonText)
    {
        this(text, 0, null, 0);
    }

    this(dstring text, void delegate(ref ActionEvent) onAction)
    {
        this(text, 0, null, 0);
        this.onAction ~= onAction;
    }

    this(
        dstring text,
        double diameter = 0,
        string iconName = null,
        double graphicsGap = 0,
    )
    {
        super(text, diameter, diameter, iconName, graphicsGap, isCreateLayout:
            false);

        this._diameter = diameter;

        import api.dm.kit.sprites.layouts.center_layout : CenterLayout;

        this.layout = new CenterLayout;
        this.layout.isAutoResizeAndAlignOne = true;
        this.layout.isAlign = true;
    }

    override bool containsPoint(double x, double y)
    {
        if (hasBackground)
        {
            return background.get.containsPoint(x, y);
        }

        return super.containsPoint(x, y);
    }

    override bool intersectBounds(Sprite other)
    {
        if (hasBackground)
        {
            return background.get.intersectBounds(other);
        }
        return super.intersectBounds(other);
    }
}
